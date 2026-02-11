#!/usr/bin/env python3
"""
Godot Project Architecture Generator
=====================================
Generates a comprehensive, AI-readable architecture file (.md) of a Godot 4 project.
Uses godot-gdscript-toolkit (gdtoolkit) for precise GDScript parsing.

Usage:
    python godot_architecture_generator.py /path/to/godot/project
    python godot_architecture_generator.py /path/to/godot/project -o custom_output.md
    python godot_architecture_generator.py /path/to/godot/project --full-source
    python godot_architecture_generator.py /path/to/godot/project --exclude addons,test

Requirements:
    pip install "gdtoolkit==4.*"
"""

import os
import sys
import re
import argparse
import configparser
from pathlib import Path
from datetime import datetime
from collections import defaultdict
from typing import Optional

try:
    from gdtoolkit.parser import parser as gdparser
    from lark import Tree, Token
except ImportError:
    print("ERROR: gdtoolkit is required. Install it with:")
    print('  pip install "gdtoolkit==4.*"')
    sys.exit(1)


# ─────────────────────────────────────────────
# GDScript Parser (via gdtoolkit)
# ─────────────────────────────────────────────

class GDScriptAnalyzer:
    """Analyzes a .gd file using gdtoolkit's parser to extract structured info."""

    def __init__(self, filepath: str, code: str):
        self.filepath = filepath
        self.code = code
        self.tree = None
        self.error = None

        self.class_name: Optional[str] = None
        self.extends: Optional[str] = None
        self.is_tool: bool = False
        self.signals: list[dict] = []
        self.enums: list[dict] = []
        self.constants: list[dict] = []
        self.exports: list[dict] = []
        self.onready_vars: list[dict] = []
        self.variables: list[dict] = []
        self.functions: list[dict] = []
        self.inner_classes: list[dict] = []
        self.static_functions: list[dict] = []
        self.preloads: list[str] = []

        self._parse()

    def _parse(self):
        try:
            self.tree = gdparser.parse(self.code)
            self._extract_from_tree(self.tree)
        except Exception as e:
            self.error = str(e)
            # Fallback: regex-based extraction
            self._fallback_parse()

    def _get_tokens(self, node, depth=0) -> list[str]:
        """Recursively collect all token values from a subtree."""
        tokens = []
        if isinstance(node, Token):
            tokens.append(str(node))
        elif isinstance(node, Tree):
            for child in node.children:
                tokens.extend(self._get_tokens(child, depth + 1))
        return tokens

    def _get_first_token(self, node) -> Optional[str]:
        """Get the first Token value from a subtree."""
        if isinstance(node, Token):
            return str(node)
        if isinstance(node, Tree):
            for child in node.children:
                result = self._get_first_token(child)
                if result is not None:
                    return result
        return None

    def _extract_func_args(self, func_args_node) -> list[dict]:
        """Extract function arguments from a func_args node."""
        args = []
        if not isinstance(func_args_node, Tree):
            return args
        for child in func_args_node.children:
            if isinstance(child, Tree):
                tokens = self._get_tokens(child)
                if child.data == "func_arg_typed" and len(tokens) >= 2:
                    args.append({"name": tokens[0], "type": tokens[1]})
                elif child.data == "func_arg_untyped" and len(tokens) >= 1:
                    args.append({"name": tokens[0], "type": None})
                elif child.data in ("func_arg_typed_default", "func_arg_inf_typed_default"):
                    name = tokens[0] if tokens else "?"
                    type_ = tokens[1] if len(tokens) > 2 else None
                    args.append({"name": name, "type": type_})
                else:
                    if tokens:
                        args.append({"name": tokens[0], "type": None})
        return args

    def _extract_func_info(self, func_node) -> dict:
        """Extract function information from a func_def node."""
        info = {"name": "?", "args": [], "return_type": None, "is_static": False, "is_coroutine": False}

        # Check annotations preceding (handled at parent level)
        for child in func_node.children:
            if isinstance(child, Tree) and child.data == "func_header":
                header_children = child.children
                for i, hc in enumerate(header_children):
                    if isinstance(hc, Token) and hc.type == "NAME":
                        info["name"] = str(hc)
                    elif isinstance(hc, Tree) and hc.data == "func_args":
                        info["args"] = self._extract_func_args(hc)
                    elif isinstance(hc, Token) and str(hc) == "void":
                        info["return_type"] = "void"
                    elif isinstance(hc, Tree) and hc.data in ("func_typed_return", "type"):
                        info["return_type"] = " ".join(self._get_tokens(hc))
                # Last element might be the return type as a simple token
                if info["return_type"] is None:
                    for hc in reversed(header_children):
                        if isinstance(hc, Token) and hc.type == "NAME" and str(hc) != info["name"]:
                            # Could be a return type
                            info["return_type"] = str(hc)
                            break
                        elif isinstance(hc, Tree):
                            break

        # Count approximate lines
        func_tokens = self._get_tokens(func_node)
        info["approx_complexity"] = len(func_tokens)

        return info

    @staticmethod
    def _clean_expr(text: str) -> str:
        """Clean up expression text from token concatenation artifacts."""
        if not text:
            return text
        # Fix "State . IDLE" -> "State.IDLE", "Vector2 . ZERO" -> "Vector2.ZERO"
        text = re.sub(r'\s*\.\s*', '.', text)
        return text.strip()

    def _extract_var_info(self, var_node) -> dict:
        """Extract variable info from a class_var_stmt node."""
        info = {"name": "?", "type": None, "default": None}
        for child in var_node.children:
            if isinstance(child, Tree):
                tokens = self._get_tokens(child)
                if child.data == "class_var_typed_assgnd" and len(tokens) >= 3:
                    info["name"] = tokens[0]
                    info["type"] = tokens[1]
                    info["default"] = self._clean_expr(" ".join(tokens[2:]))
                elif child.data == "class_var_typed" and len(tokens) >= 2:
                    info["name"] = tokens[0]
                    info["type"] = tokens[1]
                elif child.data == "class_var_assigned" and len(tokens) >= 2:
                    info["name"] = tokens[0]
                    info["default"] = self._clean_expr(" ".join(tokens[1:]))
                elif child.data == "class_var_untyped":
                    info["name"] = tokens[0] if tokens else "?"
                elif tokens:
                    info["name"] = tokens[0]
                    if len(tokens) > 1:
                        info["type"] = tokens[1]
            elif isinstance(child, Token) and child.type == "NAME":
                info["name"] = str(child)
        return info

    def _extract_signal_info(self, sig_node) -> dict:
        """Extract signal info."""
        info = {"name": "?", "args": []}
        for child in sig_node.children:
            if isinstance(child, Token) and child.type == "NAME":
                info["name"] = str(child)
            elif isinstance(child, Tree) and child.data == "signal_args":
                for arg_child in child.children:
                    if isinstance(arg_child, Tree):
                        tokens = self._get_tokens(arg_child)
                        if arg_child.data == "signal_arg_typed" and len(tokens) >= 2:
                            info["args"].append({"name": tokens[0], "type": tokens[1]})
                        elif tokens:
                            info["args"].append({"name": tokens[0], "type": None})
        return info

    def _extract_enum_info(self, enum_node) -> dict:
        """Extract enum info."""
        info = {"name": None, "values": []}
        for child in enum_node.children:
            if isinstance(child, Tree):
                if child.data == "enum_named":
                    tokens = self._get_tokens(child)
                    if tokens:
                        info["name"] = tokens[0]
                        info["values"] = tokens[1:]
                elif child.data == "enum_body":
                    tokens = self._get_tokens(child)
                    info["values"] = tokens
            elif isinstance(child, Token) and child.type == "NAME":
                if info["name"] is None:
                    info["name"] = str(child)
        return info

    def _extract_const_info(self, const_node) -> dict:
        """Extract constant info."""
        tokens = self._get_tokens(const_node)
        info = {"name": "?", "type": None, "value": None}
        if tokens:
            info["name"] = tokens[0]
            if len(tokens) > 1:
                info["value"] = self._clean_expr(" ".join(tokens[1:]))
        return info

    def _extract_inner_class(self, class_node) -> dict:
        """Extract inner class info."""
        info = {"name": "?", "extends": None, "functions": [], "variables": []}
        pending_annotations = []
        for child in class_node.children:
            if isinstance(child, Token) and child.type == "NAME":
                info["name"] = str(child)
            elif isinstance(child, Tree):
                if child.data == "extends_stmt":
                    info["extends"] = self._get_first_token(child)
                elif child.data == "annotation":
                    pending_annotations.append(self._get_first_token(child))
                elif child.data == "func_def":
                    fi = self._extract_func_info(child)
                    info["functions"].append(fi)
                    pending_annotations = []
                elif child.data == "class_var_stmt":
                    vi = self._extract_var_info(child)
                    info["variables"].append(vi)
                    pending_annotations = []
        return info

    def _extract_from_tree(self, tree: Tree):
        """Walk the top-level parse tree and extract all components."""
        pending_annotations = []

        for child in tree.children:
            if isinstance(child, Token):
                continue

            if not isinstance(child, Tree):
                continue

            data = child.data

            if data == "tool_stmt":
                self.is_tool = True

            elif data == "classname_stmt":
                self.class_name = self._get_first_token(child)

            elif data == "extends_stmt":
                self.extends = self._get_first_token(child)

            elif data == "signal_stmt":
                self.signals.append(self._extract_signal_info(child))

            elif data == "annotation":
                ann_name = self._get_first_token(child)
                pending_annotations.append(ann_name)

            elif data == "class_var_stmt":
                var_info = self._extract_var_info(child)
                if "export" in pending_annotations:
                    var_info["annotations"] = list(pending_annotations)
                    self.exports.append(var_info)
                elif "onready" in pending_annotations:
                    var_info["annotations"] = list(pending_annotations)
                    self.onready_vars.append(var_info)
                else:
                    var_info["annotations"] = list(pending_annotations)
                    self.variables.append(var_info)
                pending_annotations = []

            elif data == "func_def":
                func_info = self._extract_func_info(child)
                if "static" in pending_annotations:
                    func_info["is_static"] = True
                    self.static_functions.append(func_info)
                else:
                    self.functions.append(func_info)
                pending_annotations = []

            elif data == "enum_stmt":
                self.enums.append(self._extract_enum_info(child))

            elif data in ("const_stmt", "const_typed_stmt"):
                self.constants.append(self._extract_const_info(child))

            elif data == "class_def":
                self.inner_classes.append(self._extract_inner_class(child))

            else:
                pending_annotations = []

        # Extract preloads from raw code (not well-suited for AST)
        self._extract_preloads()

    def _extract_preloads(self):
        """Extract preload/load references from source code."""
        for match in re.finditer(r'(?:preload|load)\s*\(\s*["\']([^"\']+)["\']\s*\)', self.code):
            self.preloads.append(match.group(1))

    def _fallback_parse(self):
        """Regex-based fallback when gdtoolkit parser fails."""
        lines = self.code.split("\n")

        for line in lines:
            stripped = line.strip()

            m = re.match(r'^class_name\s+(\w+)', stripped)
            if m:
                self.class_name = m.group(1)

            m = re.match(r'^extends\s+(\w+)', stripped)
            if m:
                self.extends = m.group(1)

            if stripped.startswith("@tool") or stripped == "tool":
                self.is_tool = True

            m = re.match(r'^signal\s+(\w+)(?:\(([^)]*)\))?', stripped)
            if m:
                sig = {"name": m.group(1), "args": []}
                if m.group(2):
                    for arg in m.group(2).split(","):
                        parts = arg.strip().split(":")
                        sig["args"].append({
                            "name": parts[0].strip(),
                            "type": parts[1].strip() if len(parts) > 1 else None
                        })
                self.signals.append(sig)

            m = re.match(r'^@export.*var\s+(\w+)\s*(?::\s*(\w+))?', stripped)
            if m:
                self.exports.append({"name": m.group(1), "type": m.group(2), "default": None, "annotations": ["export"]})
                continue

            m = re.match(r'^@onready\s+var\s+(\w+)\s*(?::\s*(\w+))?', stripped)
            if m:
                self.onready_vars.append({"name": m.group(1), "type": m.group(2), "default": None, "annotations": ["onready"]})
                continue

            m = re.match(r'^var\s+(\w+)\s*(?::\s*(\w+))?', stripped)
            if m:
                self.variables.append({"name": m.group(1), "type": m.group(2), "default": None, "annotations": []})

            m = re.match(r'^(?:static\s+)?func\s+(\w+)\s*\(([^)]*)\)\s*(?:->\s*(\w+))?', stripped)
            if m:
                args = []
                if m.group(2).strip():
                    for arg in m.group(2).split(","):
                        parts = arg.strip().split(":")
                        args.append({"name": parts[0].strip(), "type": parts[1].strip() if len(parts) > 1 else None})
                fi = {"name": m.group(1), "args": args, "return_type": m.group(3), "is_static": "static" in stripped}
                if fi["is_static"]:
                    self.static_functions.append(fi)
                else:
                    self.functions.append(fi)

            m = re.match(r'^const\s+(\w+)', stripped)
            if m:
                self.constants.append({"name": m.group(1), "type": None, "value": None})

            m = re.match(r'^enum\s+(\w+)', stripped)
            if m:
                self.enums.append({"name": m.group(1), "values": []})

        self._extract_preloads()


# ─────────────────────────────────────────────
# Scene (.tscn) Parser
# ─────────────────────────────────────────────

class TscnParser:
    """Parses a Godot .tscn file to extract scene structure."""

    def __init__(self, filepath: str):
        self.filepath = filepath
        self.nodes: list[dict] = []
        self.ext_resources: list[dict] = []
        self.sub_resources: list[dict] = []
        self.connections: list[dict] = []
        self.root_type: Optional[str] = None
        self.root_name: Optional[str] = None
        self.script_path: Optional[str] = None
        self.error = None

        self._parse()

    def _parse(self):
        try:
            with open(self.filepath, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
        except Exception as e:
            self.error = str(e)
            return

        # Parse ext_resource entries
        for m in re.finditer(
            r'\[ext_resource\s+(?:type="([^"]*)")?\s*(?:path="([^"]*)")?\s*(?:uid="[^"]*")?\s*(?:id="([^"]*)")?\]',
            content
        ):
            self.ext_resources.append({
                "type": m.group(1),
                "path": m.group(2),
                "id": m.group(3)
            })

        # Also handle different ordering of attributes
        for m in re.finditer(
            r'\[ext_resource\s+path="([^"]*)"\s+type="([^"]*)"\s+id=(\S+)\]',
            content
        ):
            self.ext_resources.append({
                "type": m.group(2),
                "path": m.group(1),
                "id": m.group(3)
            })

        # Parse sub_resource entries
        for m in re.finditer(r'\[sub_resource\s+type="([^"]*)"', content):
            self.sub_resources.append({"type": m.group(1)})

        # Parse node entries
        for m in re.finditer(
            r'\[node\s+([^\]]+)\]',
            content
        ):
            attrs_str = m.group(1)
            node = {}
            for attr_m in re.finditer(r'(\w+)="([^"]*)"', attrs_str):
                node[attr_m.group(1)] = attr_m.group(2)

            self.nodes.append(node)

        # Identify root
        if self.nodes:
            root = self.nodes[0]
            self.root_type = root.get("type", "?")
            self.root_name = root.get("name", "?")

        # Find script attached to root
        for res in self.ext_resources:
            if res.get("type") in ("Script", "GDScript"):
                self.script_path = res.get("path")
                break

        # Parse connections
        for m in re.finditer(
            r'\[connection\s+signal="([^"]*)"\s+from="([^"]*)"\s+to="([^"]*)"\s+method="([^"]*)"',
            content
        ):
            self.connections.append({
                "signal": m.group(1),
                "from": m.group(2),
                "to": m.group(3),
                "method": m.group(4)
            })

    def get_node_tree_text(self, indent=2) -> str:
        """Build a visual tree representation of the scene nodes."""
        if not self.nodes:
            return "(empty scene)"

        lines = []
        for node in self.nodes:
            name = node.get("name", "?")
            type_ = node.get("type", "")
            parent = node.get("parent", "")
            instance = node.get("instance", "")

            depth = 0
            if parent == "":
                depth = 0  # root
            elif parent == ".":
                depth = 1
            else:
                depth = parent.count("/") + 2

            prefix = " " * indent * depth + ("└─ " if depth > 0 else "")
            type_label = f" ({type_})" if type_ else ""
            inst_label = f" [Instance]" if instance else ""

            # Check if this node has a script
            script_label = ""
            lines.append(f"{prefix}{name}{type_label}{inst_label}{script_label}")

        return "\n".join(lines)


# ─────────────────────────────────────────────
# Resource (.tres) Parser
# ─────────────────────────────────────────────

class TresParser:
    """Parses a .tres file header to identify resource type."""

    def __init__(self, filepath: str):
        self.filepath = filepath
        self.resource_type: Optional[str] = None
        self.class_name: Optional[str] = None
        self.script_path: Optional[str] = None

        self._parse()

    def _parse(self):
        try:
            with open(self.filepath, "r", encoding="utf-8", errors="replace") as f:
                # Only read first 20 lines
                header_lines = []
                for i, line in enumerate(f):
                    if i > 30:
                        break
                    header_lines.append(line)
                header = "".join(header_lines)
        except Exception:
            return

        m = re.search(r'\[gd_resource\s+type="([^"]*)"', header)
        if m:
            self.resource_type = m.group(1)

        m = re.search(r'class_name\s*=\s*"([^"]*)"', header)
        if m:
            self.class_name = m.group(1)

        m = re.search(r'script/source\s*=\s*"([^"]*)"', header)
        if m:
            self.script_path = m.group(1)

        m = re.search(r'script\s*=\s*ExtResource\(\s*"([^"]*)"\s*\)', header)
        if m:
            self.script_path = m.group(1)


# ─────────────────────────────────────────────
# Project Configuration Parser
# ─────────────────────────────────────────────

class ProjectConfigParser:
    """Parses project.godot to extract project settings."""

    def __init__(self, project_path: str):
        self.project_path = project_path
        self.project_name = "Unknown"
        self.godot_version = "Unknown"
        self.main_scene = None
        self.autoloads: list[dict] = []
        self.input_actions: list[str] = []
        self.features: list[str] = []
        self.render_method = None

        self._parse()

    def _parse(self):
        config_path = os.path.join(self.project_path, "project.godot")
        if not os.path.isfile(config_path):
            return

        try:
            with open(config_path, "r", encoding="utf-8", errors="replace") as f:
                content = f.read()
        except Exception:
            return

        # Project name
        m = re.search(r'config/name="([^"]*)"', content)
        if m:
            self.project_name = m.group(1)

        # Main scene
        m = re.search(r'run/main_scene="([^"]*)"', content)
        if m:
            self.main_scene = m.group(1)

        # Godot features / version hints
        for fm in re.finditer(r'config/features=PackedStringArray\(([^)]+)\)', content):
            features_str = fm.group(1)
            self.features = [f.strip().strip('"') for f in features_str.split(",")]

        # Renderer
        m = re.search(r'rendering/renderer/rendering_method(?:\.mobile)?="([^"]*)"', content)
        if m:
            self.render_method = m.group(1)

        # Autoloads
        for m in re.finditer(r'(\w+)="\*?res://([^"]*)"', content):
            section_before = content[:m.start()]
            if "[autoload]" in section_before:
                last_section = re.findall(r'\[([^\]]+)\]', section_before)
                if last_section and last_section[-1] == "autoload":
                    self.autoloads.append({
                        "name": m.group(1),
                        "path": "res://" + m.group(2)
                    })

        # Input map actions
        for m in re.finditer(r'^(\w+)=\{', content, re.MULTILINE):
            section_before = content[:m.start()]
            if "[input]" in section_before:
                last_section = re.findall(r'\[([^\]]+)\]', section_before)
                if last_section and last_section[-1] == "input":
                    self.input_actions.append(m.group(1))


# ─────────────────────────────────────────────
# Architecture Generator
# ─────────────────────────────────────────────

class ArchitectureGenerator:
    """Main orchestrator: scans project and generates the architecture document."""

    def __init__(self, project_path: str, exclude_dirs: list[str] = None,
                 include_full_source: bool = False):
        self.project_path = os.path.abspath(project_path)
        self.exclude_dirs = set(exclude_dirs or [".godot", ".git", "__pycache__", ".import"])
        self.include_full_source = include_full_source

        self.gd_files: dict[str, GDScriptAnalyzer] = {}
        self.tscn_files: dict[str, TscnParser] = {}
        self.tres_files: dict[str, TresParser] = {}
        self.other_files: dict[str, list[str]] = defaultdict(list)  # ext -> list of paths
        self.project_config: Optional[ProjectConfigParser] = None

        self.class_name_map: dict[str, str] = {}  # class_name -> file_path

    def scan(self):
        """Scan the entire project."""
        print(f"Scanning project: {self.project_path}")

        # Parse project.godot
        self.project_config = ProjectConfigParser(self.project_path)

        file_count = 0
        for root, dirs, files in os.walk(self.project_path):
            # Filter excluded directories
            dirs[:] = [d for d in dirs if d not in self.exclude_dirs]

            for filename in sorted(files):
                filepath = os.path.join(root, filename)
                relpath = os.path.relpath(filepath, self.project_path)
                ext = os.path.splitext(filename)[1].lower()

                if ext == ".gd":
                    self._analyze_gd(filepath, relpath)
                elif ext == ".tscn":
                    self._analyze_tscn(filepath, relpath)
                elif ext == ".tres":
                    self._analyze_tres(filepath, relpath)
                elif ext not in (".uid", ".import", ".tmp"):
                    self.other_files[ext].append(relpath)

                file_count += 1

        print(f"  Found {len(self.gd_files)} scripts, {len(self.tscn_files)} scenes, "
              f"{len(self.tres_files)} resources, {file_count} total files")

    def _analyze_gd(self, filepath: str, relpath: str):
        try:
            with open(filepath, "r", encoding="utf-8", errors="replace") as f:
                code = f.read()
        except Exception:
            return

        analyzer = GDScriptAnalyzer(relpath, code)
        self.gd_files[relpath] = analyzer

        if analyzer.class_name:
            self.class_name_map[analyzer.class_name] = relpath

    def _analyze_tscn(self, filepath: str, relpath: str):
        self.tscn_files[relpath] = TscnParser(filepath)

    def _analyze_tres(self, filepath: str, relpath: str):
        self.tres_files[relpath] = TresParser(filepath)

    # ── Markdown Generation ──

    def generate(self) -> str:
        """Generate the full architecture markdown document."""
        sections = []

        sections.append(self._header())
        sections.append(self._section_project_overview())
        sections.append(self._section_directory_tree())
        sections.append(self._section_autoloads())
        sections.append(self._section_class_registry())
        sections.append(self._section_scene_map())
        sections.append(self._section_scripts_detail())
        sections.append(self._section_signal_map())
        sections.append(self._section_resource_list())
        sections.append(self._section_asset_summary())
        sections.append(self._section_dependency_graph())
        if self.include_full_source:
            sections.append(self._section_full_source())
        sections.append(self._footer())

        return "\n\n".join(s for s in sections if s)

    def _header(self) -> str:
        name = self.project_config.project_name if self.project_config else "Godot Project"
        now = datetime.now().strftime("%Y-%m-%d %H:%M")
        return f"""# 🎮 Project Architecture: {name}

> **Generated:** {now}
> **Path:** `{self.project_path}`
> **Generator:** godot_architecture_generator.py (using gdtoolkit {self._get_gdtoolkit_version()})

---"""

    def _get_gdtoolkit_version(self) -> str:
        try:
            from importlib.metadata import version
            return version("gdtoolkit")
        except Exception:
            return "4.x"

    def _section_project_overview(self) -> str:
        cfg = self.project_config
        if not cfg:
            return ""

        lines = ["## 1. Project Overview", ""]
        lines.append(f"| Property | Value |")
        lines.append(f"|----------|-------|")
        lines.append(f"| **Project Name** | {cfg.project_name} |")
        if cfg.features:
            lines.append(f"| **Engine Features** | {', '.join(cfg.features)} |")
        if cfg.main_scene:
            lines.append(f"| **Main Scene** | `{cfg.main_scene}` |")
        if cfg.render_method:
            lines.append(f"| **Renderer** | {cfg.render_method} |")
        lines.append(f"| **Scripts** | {len(self.gd_files)} |")
        lines.append(f"| **Scenes** | {len(self.tscn_files)} |")
        lines.append(f"| **Resources (.tres)** | {len(self.tres_files)} |")

        if cfg.input_actions:
            lines.append(f"| **Input Actions** | {', '.join(f'`{a}`' for a in cfg.input_actions)} |")

        return "\n".join(lines)

    def _section_directory_tree(self) -> str:
        lines = ["## 2. Directory Structure", "", "```"]

        all_files = (
            list(self.gd_files.keys()) +
            list(self.tscn_files.keys()) +
            list(self.tres_files.keys()) +
            [f for files in self.other_files.values() for f in files]
        )

        # Build directory tree
        dirs_seen = set()
        entries = []
        for fpath in sorted(all_files):
            parts = Path(fpath).parts
            for i in range(len(parts) - 1):
                d = os.path.join(*parts[:i + 1])
                if d not in dirs_seen:
                    dirs_seen.add(d)
                    indent = "  " * i
                    entries.append(f"{indent}{parts[i]}/")
            indent = "  " * (len(parts) - 1)
            entries.append(f"{indent}{parts[-1]}")

        # Deduplicate while preserving order
        seen = set()
        for entry in entries:
            if entry not in seen:
                seen.add(entry)
                lines.append(entry)

        lines.append("```")
        return "\n".join(lines)

    def _section_autoloads(self) -> str:
        cfg = self.project_config
        if not cfg or not cfg.autoloads:
            return ""

        lines = ["## 3. Autoloads (Singletons)", ""]
        lines.append("| Name | Path | Type |")
        lines.append("|------|------|------|")

        for al in cfg.autoloads:
            # Try to find the type
            rel = al["path"].replace("res://", "")
            gd = self.gd_files.get(rel)
            type_info = ""
            if gd:
                type_info = gd.extends or ""
                if gd.class_name:
                    type_info = f"{gd.class_name} (extends {gd.extends})" if gd.extends else gd.class_name
            lines.append(f"| **{al['name']}** | `{al['path']}` | {type_info} |")

        return "\n".join(lines)

    def _section_class_registry(self) -> str:
        if not self.class_name_map:
            return ""

        lines = ["## 4. Class Registry (class_name)", ""]
        lines.append("| Class Name | File | Extends |")
        lines.append("|------------|------|---------|")

        for cname, fpath in sorted(self.class_name_map.items()):
            gd = self.gd_files.get(fpath)
            ext = gd.extends if gd else "?"
            lines.append(f"| `{cname}` | `{fpath}` | `{ext}` |")

        return "\n".join(lines)

    def _section_scene_map(self) -> str:
        if not self.tscn_files:
            return ""

        lines = ["## 5. Scene Map", ""]

        for relpath, scene in sorted(self.tscn_files.items()):
            lines.append(f"### `{relpath}`")
            if scene.error:
                lines.append(f"  ⚠️ Parse error: {scene.error}")
                continue

            lines.append(f"- **Root:** {scene.root_name} ({scene.root_type})")
            if scene.script_path:
                lines.append(f"- **Script:** `{scene.script_path}`")

            # Node tree
            tree_text = scene.get_node_tree_text()
            if tree_text:
                lines.append(f"\n```")
                lines.append(tree_text)
                lines.append("```")

            # Connections
            if scene.connections:
                lines.append("\n**Signal Connections:**")
                for conn in scene.connections:
                    lines.append(f"- `{conn['from']}`.{conn['signal']} → `{conn['to']}`.{conn['method']}()")

            # External resources
            non_script_res = [r for r in scene.ext_resources if r.get("type") not in ("Script", "GDScript", None)]
            if non_script_res:
                lines.append("\n**External Resources:**")
                for res in non_script_res:
                    lines.append(f"- [{res.get('type', '?')}] `{res.get('path', '?')}`")

            lines.append("")

        return "\n".join(lines)

    def _section_scripts_detail(self) -> str:
        if not self.gd_files:
            return ""

        lines = ["## 6. Scripts Detail", ""]

        for relpath, gd in sorted(self.gd_files.items()):
            lines.append(f"### `{relpath}`")

            if gd.error:
                lines.append(f"⚠️ Parser error (used regex fallback): {gd.error[:100]}")

            # Header info
            header_parts = []
            if gd.is_tool:
                header_parts.append("🔧 @tool")
            if gd.class_name:
                header_parts.append(f"**class_name** `{gd.class_name}`")
            if gd.extends:
                header_parts.append(f"**extends** `{gd.extends}`")
            if header_parts:
                lines.append(" | ".join(header_parts))

            # Enums
            if gd.enums:
                lines.append("\n**Enums:**")
                for enum in gd.enums:
                    name = enum['name'] or '(anonymous)'
                    vals = ", ".join(enum.get('values', []))
                    lines.append(f"- `{name}` {{ {vals} }}")

            # Constants
            if gd.constants:
                lines.append("\n**Constants:**")
                for const in gd.constants:
                    val = f" = {const['value']}" if const.get('value') else ""
                    lines.append(f"- `{const['name']}`{val}")

            # Signals
            if gd.signals:
                lines.append("\n**Signals:**")
                for sig in gd.signals:
                    args_str = ", ".join(
                        f"{a['name']}: {a['type']}" if a.get('type') else a['name']
                        for a in sig.get('args', [])
                    )
                    lines.append(f"- `{sig['name']}({args_str})`")

            # Exports
            if gd.exports:
                lines.append("\n**Exports:**")
                for var in gd.exports:
                    type_str = f": {var['type']}" if var.get('type') else ""
                    default_str = f" = {var['default']}" if var.get('default') else ""
                    lines.append(f"- `{var['name']}{type_str}{default_str}`")

            # Onready vars
            if gd.onready_vars:
                lines.append("\n**@onready Variables:**")
                for var in gd.onready_vars:
                    type_str = f": {var['type']}" if var.get('type') else ""
                    lines.append(f"- `{var['name']}{type_str}`")

            # Regular variables
            if gd.variables:
                lines.append("\n**Variables:**")
                for var in gd.variables:
                    type_str = f": {var['type']}" if var.get('type') else ""
                    default_str = f" = {var['default']}" if var.get('default') else ""
                    lines.append(f"- `{var['name']}{type_str}{default_str}`")

            # Functions
            all_funcs = gd.functions + gd.static_functions
            if all_funcs:
                lines.append("\n**Functions:**")
                lines.append("| Function | Arguments | Returns | Notes |")
                lines.append("|----------|-----------|---------|-------|")
                for func in all_funcs:
                    args_str = ", ".join(
                        f"{a['name']}: {a['type']}" if a.get('type') else a['name']
                        for a in func.get('args', [])
                    )
                    ret = func.get('return_type') or "—"
                    notes = []
                    if func.get('is_static'):
                        notes.append("static")
                    name = func['name']
                    if name.startswith("_"):
                        notes.append("override/private")
                    lines.append(f"| `{name}` | `({args_str})` | `{ret}` | {', '.join(notes)} |")

            # Inner classes
            if gd.inner_classes:
                lines.append("\n**Inner Classes:**")
                for ic in gd.inner_classes:
                    ext = f" extends {ic['extends']}" if ic.get('extends') else ""
                    lines.append(f"- `class {ic['name']}{ext}`")
                    for fn in ic.get('functions', []):
                        lines.append(f"  - func `{fn['name']}()`")

            # Preloads / dependencies
            if gd.preloads:
                lines.append("\n**Dependencies (preload/load):**")
                for p in gd.preloads:
                    lines.append(f"- `{p}`")

            lines.append("")

        return "\n".join(lines)

    def _section_signal_map(self) -> str:
        """Global signal map across all scripts and scenes."""
        all_signals = []

        for relpath, gd in self.gd_files.items():
            for sig in gd.signals:
                all_signals.append({"signal": sig['name'], "defined_in": relpath, "args": sig.get('args', [])})

        if not all_signals:
            return ""

        lines = ["## 7. Global Signal Map", ""]
        lines.append("| Signal | Defined In | Arguments | Connected In |")
        lines.append("|--------|-----------|-----------|-------------|")

        # Build connection map from scenes
        signal_connections = defaultdict(list)
        for scene_path, scene in self.tscn_files.items():
            for conn in scene.connections:
                signal_connections[conn['signal']].append(scene_path)

        for sig_info in sorted(all_signals, key=lambda x: x['signal']):
            args_str = ", ".join(
                f"{a['name']}: {a['type']}" if a.get('type') else a['name']
                for a in sig_info['args']
            )
            connected_in = ", ".join(f"`{s}`" for s in signal_connections.get(sig_info['signal'], [])) or "—"
            lines.append(f"| `{sig_info['signal']}` | `{sig_info['defined_in']}` | `({args_str})` | {connected_in} |")

        return "\n".join(lines)

    def _section_resource_list(self) -> str:
        if not self.tres_files:
            return ""

        lines = ["## 8. Resources (.tres)", ""]
        lines.append("| File | Type | Script |")
        lines.append("|------|------|--------|")

        for relpath, tres in sorted(self.tres_files.items()):
            rtype = tres.resource_type or "?"
            script = f"`{tres.script_path}`" if tres.script_path else "—"
            lines.append(f"| `{relpath}` | {rtype} | {script} |")

        return "\n".join(lines)

    def _section_asset_summary(self) -> str:
        # Gather non-code files
        asset_exts = {
            "Images": [".png", ".jpg", ".jpeg", ".webp", ".svg", ".bmp"],
            "Audio": [".wav", ".ogg", ".mp3", ".opus"],
            "Fonts": [".ttf", ".otf", ".woff", ".woff2"],
            "3D Models": [".glb", ".gltf", ".obj", ".fbx", ".dae"],
            "Shaders": [".gdshader", ".gdshaderinc", ".shader"],
            "Data": [".json", ".cfg", ".ini", ".csv", ".xml"],
            "Other": []
        }

        categorized = defaultdict(list)
        uncategorized = []

        for ext, files in self.other_files.items():
            placed = False
            for category, exts in asset_exts.items():
                if ext in exts:
                    categorized[category].extend(files)
                    placed = True
                    break
            if not placed and ext not in (".godot", ".gdignore", ".gitignore", ".md", ".txt"):
                uncategorized.extend(files)

        if not categorized and not uncategorized:
            return ""

        lines = ["## 9. Asset Summary", ""]

        for category, files in sorted(categorized.items()):
            if files:
                lines.append(f"**{category}** ({len(files)} files):")
                # Show up to 20 then truncate
                for f in sorted(files)[:20]:
                    lines.append(f"- `{f}`")
                if len(files) > 20:
                    lines.append(f"- ... and {len(files) - 20} more")
                lines.append("")

        if uncategorized:
            lines.append(f"**Other** ({len(uncategorized)} files):")
            for f in sorted(uncategorized)[:15]:
                lines.append(f"- `{f}`")
            if len(uncategorized) > 15:
                lines.append(f"- ... and {len(uncategorized) - 15} more")

        return "\n".join(lines)

    def _section_dependency_graph(self) -> str:
        """Build a text-based dependency graph."""
        lines = ["## 10. Dependency Graph", ""]
        lines.append("```")
        lines.append("(script) --preloads/extends--> (dependency)")
        lines.append("")

        for relpath, gd in sorted(self.gd_files.items()):
            deps = []
            if gd.extends and gd.extends in self.class_name_map:
                deps.append(f"extends {gd.extends} ({self.class_name_map[gd.extends]})")
            for p in gd.preloads:
                deps.append(f"loads {p}")

            if deps:
                lines.append(f"  {relpath}")
                for dep in deps:
                    lines.append(f"    └─→ {dep}")

        lines.append("```")
        return "\n".join(lines)

    def _section_full_source(self) -> str:
        """Optionally include full source code of all scripts."""
        lines = ["## 📝 Full Source Code", ""]
        lines.append("> Included with `--full-source` flag. Useful for complete AI context.")
        lines.append("")

        for relpath, gd in sorted(self.gd_files.items()):
            lines.append(f"### `{relpath}`")
            lines.append("```gdscript")
            lines.append(gd.code)
            lines.append("```")
            lines.append("")

        return "\n".join(lines)

    def _footer(self) -> str:
        total_funcs = sum(len(gd.functions) + len(gd.static_functions) for gd in self.gd_files.values())
        total_signals = sum(len(gd.signals) for gd in self.gd_files.values())
        total_exports = sum(len(gd.exports) for gd in self.gd_files.values())

        parse_errors = sum(1 for gd in self.gd_files.values() if gd.error)

        lines = ["---", ""]
        lines.append("## Stats Summary")
        lines.append("")
        lines.append(f"| Metric | Count |")
        lines.append(f"|--------|-------|")
        lines.append(f"| Scripts | {len(self.gd_files)} |")
        lines.append(f"| Scenes | {len(self.tscn_files)} |")
        lines.append(f"| Resources | {len(self.tres_files)} |")
        lines.append(f"| Registered Classes | {len(self.class_name_map)} |")
        lines.append(f"| Total Functions | {total_funcs} |")
        lines.append(f"| Total Signals | {total_signals} |")
        lines.append(f"| Total Exports | {total_exports} |")
        lines.append(f"| Autoloads | {len(self.project_config.autoloads) if self.project_config else 0} |")
        if parse_errors:
            lines.append(f"| ⚠️ Parse Errors | {parse_errors} |")

        return "\n".join(lines)


# ─────────────────────────────────────────────
# CLI Entry Point
# ─────────────────────────────────────────────

def main():
    argparser = argparse.ArgumentParser(
        description="Generate a comprehensive architecture document for a Godot project.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python godot_architecture_generator.py /path/to/my_game
  python godot_architecture_generator.py . -o architecture.md
  python godot_architecture_generator.py . --full-source
  python godot_architecture_generator.py . --exclude addons,test
        """
    )

    argparser.add_argument("project_path", help="Path to the Godot project root (containing project.godot)")
    argparser.add_argument("-o", "--output", default=None,
                           help="Output file path (default: PROJECT_ARCHITECTURE.md in project root)")
    argparser.add_argument("--full-source", action="store_true",
                           help="Include full GDScript source code in the output")
    argparser.add_argument("--exclude", default=".godot,.git,__pycache__,.import",
                           help="Comma-separated list of directories to exclude (default: .godot,.git,__pycache__,.import)")

    args = argparser.parse_args()

    project_path = os.path.abspath(args.project_path)

    # Validate
    if not os.path.isdir(project_path):
        print(f"ERROR: '{project_path}' is not a directory.")
        sys.exit(1)

    if not os.path.isfile(os.path.join(project_path, "project.godot")):
        print(f"WARNING: No 'project.godot' found in '{project_path}'. Are you sure this is a Godot project root?")

    exclude_dirs = [d.strip() for d in args.exclude.split(",")]
    output_path = args.output or os.path.join(project_path, "PROJECT_ARCHITECTURE.md")

    # Run
    generator = ArchitectureGenerator(
        project_path=project_path,
        exclude_dirs=exclude_dirs,
        include_full_source=args.full_source
    )
    generator.scan()

    result = generator.generate()

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(result)

    print(f"\n✅ Architecture file generated: {output_path}")
    print(f"   Size: {len(result):,} characters / ~{len(result) // 4:,} tokens")


if __name__ == "__main__":
    main()