extends ParallaxBackground
## Fond parallaxe qui défile avec la timeline.
## Les couches les plus éloignées défilent plus lentement.

@export var auto_scroll := true


func _process(delta: float) -> void:
	if not auto_scroll or Global.is_paused:
		return

	# Le ParallaxBackground gère automatiquement les ratios de vitesse
	# via motion_scale de chaque ParallaxLayer.
	scroll_offset.x -= Global.scroll_speed * delta
