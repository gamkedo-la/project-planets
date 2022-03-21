extends Node2D

export var cast = false


func _ready():
	if cast:
		$LazerBeam.is_casting = true



func _on_Area2D_area_entered(area):
	if area.is_in_group("bullet"):
		$LazerBeam.is_casting = true
