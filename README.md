# ✈️ Lettre pour Béa — Guide de mise en place

## Architecture du projet

```
lettre_pour_bea/
├── data/
│   ├── timeline_data.json       ← ⭐ ÉDITE CE FICHIER avec tes événements
│   └── photos/                  ← Mets tes photos ici (PNG recommandé)
│       ├── event_01_a.png
│       ├── event_02_a.png
│       └── ...
├── objects/
│   ├── player/
│   │   ├── player.gd            ← Machine à états : vol, looping, plongeon
│   │   └── player.tscn
│   ├── timeline/
│   │   ├── timeline.gd          ← Génère la barre + panneaux depuis le JSON
│   │   └── timeline.tscn
│   └── popup/
│       ├── event_popup.gd       ← Popup photos + texte
│       └── event_popup.tscn
├── scenes/
│   ├── title_screen.gd / .tscn  ← Écran titre
│   ├── game.gd / .tscn          ← Scène de jeu principale
│   └── end_screen.gd / .tscn    ← Message de fin
├── maps/
│   ├── backgrounds/              ← Images de fond (ciel, montagnes)
│   ├── parallax_bg.gd           ← Défilement parallaxe
│   └── scroller.gdshader        ← Shader de scroll UV
├── music/                        ← Fichiers .ogg
├── fonts/                        ← Polices .ttf
├── global.gd                     ← Autoload : charge le JSON, gère la sauvegarde
└── project.godot
```

## Comment personnaliser le jeu

### 1. Édite `data/timeline_data.json`

C'est le seul fichier que tu dois modifier pour ajouter tes souvenirs :

```json
{
    "title": "Lettre à Béa",
    "subtitle": "Notre histoire en avions de papier",
    "end_message": "Je t'aime ♥",
    "events": [
        {
            "date": "14 Fév 2023",
            "title": "Le premier avion",
            "description": "Ton premier message...",
            "photos": ["res://data/photos/event_01_a.png"]
        }
    ]
}
```

### 2. Ajoute tes photos

Place tes images dans `data/photos/`. Formats acceptés : PNG, JPG, WebP.
Taille recommandée : environ 400×300px.

### 3. Configure le sprite de l'avion

Ouvre `objects/player/player.tscn` dans l'éditeur Godot et configure le nœud
`Sprite` (AnimatedSprite2D) avec ton spritesheet d'avion en papier.

Crée 3 animations dans le SpriteFrames :
- **fly** : animation de vol normal (boucle)
- **dive** : animation de plongeon
- **idle** : avion posé (1 frame)

### 4. Ajuste les paramètres dans l'éditeur

Le nœud `Player` expose des exports ajustables :
- `flight_altitude` : hauteur de croisière
- `loop_duration` : durée du looping
- `dive_speed` / `rise_speed`
- `timeline_y` : doit correspondre à `bar_y` de la Timeline

Le nœud `Timeline` expose :
- `bar_y` : position Y de la barre (défaut 570)
- `sign_spacing` : distance entre panneaux (défaut 500)
- `sign_post_height` : hauteur des poteaux
- Couleurs des panneaux et du texte

## Contrôles

| Action | Touche |
|--------|--------|
| Plonger | **Espace** ou **Flèche Bas** |
| Plonger (mobile) | **Touch** |
| Continuer (popup) | Touche / Touch |

## Flux du jeu

```
Titre → Appui → Jeu
                  ↓
        Avion vole automatiquement →
                  ↓
        Appui Espace = Looping + Plongeon
                  ↓
        Touche la barre = Popup (photos + texte)
                  ↓
        Appui = Ferme popup, avion remonte
                  ↓
        Tous les événements vus → Écran de fin ♥
```

## Notes techniques

- **Godot 4.5**, rendu Mobile
- L'autoload `Global` charge le JSON au démarrage
- La timeline est générée dynamiquement (pas de scène à modifier)
- Les photos manquantes affichent un placeholder gris
- La sauvegarde (`user://save.json`) mémorise les événements vus
