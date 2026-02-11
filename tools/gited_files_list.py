import os
from pathlib import Path
import pathspec

def load_gitignore(repo_path):
    gitignore_path = Path(repo_path) / ".gitignore"
    if not gitignore_path.exists():
        return pathspec.PathSpec.from_lines("gitwildmatch", [])
    
    with open(gitignore_path, "r", encoding="utf-8") as f:
        return pathspec.PathSpec.from_lines("gitwildmatch", f.readlines())

def list_repo_files(repo_path):
    repo_path = Path(repo_path)
    spec = load_gitignore(repo_path)

    tracked_files = []

    for root, dirs, files in os.walk(repo_path):
        # Ignore .git folder manually
        if ".git" in dirs:
            dirs.remove(".git")

        for file in files:
            full_path = Path(root) / file
            rel_path = full_path.relative_to(repo_path)

            # Check if ignored
            if not spec.match_file(str(rel_path)):
                tracked_files.append(str(rel_path))

    return tracked_files

def export_file_list(repo_path):
    repo_path = Path(repo_path)
    output_dir = repo_path / "documentation"
    output_dir.mkdir(exist_ok=True)

    output_file = output_dir / "gited_files_list.txt"

    files = list_repo_files(repo_path)

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("Liste des fichiers non ignorés par .gitignore\n")
        f.write("================================================\n\n")
        for file in files:
            f.write(file + "\n")

    print(f"Export terminé : {output_file}")

if __name__ == "__main__":
    export_file_list(".")
