#!/usr/bin/env python3
"""Applique la rotation EXIF aux photos puis supprime les métadonnées.
   Godot ne lit pas l'EXIF → les photos apparaissent tournées sans ça.
   
   Usage: python tools/fix_photos.py
"""

import os
import sys

try:
    from PIL import Image, ExifTags
except ImportError:
    print("Installe Pillow : pip install Pillow")
    sys.exit(1)

PHOTOS_DIR = os.path.join(os.path.dirname(__file__), "..", "data", "photos")

def fix_orientation(filepath: str) -> bool:
    try:
        img = Image.open(filepath)
    except Exception as e:
        print(f"  ⚠ Impossible d'ouvrir {filepath}: {e}")
        return False

    exif = img.getexif()
    # Tag 274 = Orientation
    orientation = exif.get(274, 1)

    if orientation == 1:
        return False  # Déjà correct

    transforms = {
        2: Image.FLIP_LEFT_RIGHT,
        3: Image.ROTATE_180,
        4: Image.FLIP_TOP_BOTTOM,
        5: Image.TRANSPOSE,
        6: Image.ROTATE_270,
        7: Image.TRANSVERSE,
        8: Image.ROTATE_90,
    }

    transform = transforms.get(orientation)
    if transform is None:
        return False

    img = img.transpose(transform)

    # Supprime toutes les métadonnées EXIF
    clean = Image.new(img.mode, img.size)
    clean.putdata(list(img.getdata()))

    # Sauvegarde en écrasant
    ext = os.path.splitext(filepath)[1].lower()
    if ext in (".jpg", ".jpeg"):
        clean.save(filepath, "JPEG", quality=95)
    elif ext == ".png":
        clean.save(filepath, "PNG")
    else:
        clean.save(filepath)

    return True


def main():
    if not os.path.isdir(PHOTOS_DIR):
        print(f"Dossier introuvable : {PHOTOS_DIR}")
        sys.exit(1)

    count = 0
    for filename in sorted(os.listdir(PHOTOS_DIR)):
        filepath = os.path.join(PHOTOS_DIR, filename)
        if not os.path.isfile(filepath):
            continue
        ext = os.path.splitext(filename)[1].lower()
        if ext not in (".jpg", ".jpeg", ".png"):
            continue

        if fix_orientation(filepath):
            print(f"  ✓ Corrigé : {filename}")
            count += 1
        else:
            print(f"  · OK      : {filename}")

    print(f"\n{count} photo(s) corrigée(s).")


if __name__ == "__main__":
    main()