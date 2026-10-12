class_name Equippable
extends Item

enum Kind { HEAD, BODY, LEGS, ACCESSORY }

@export var kind := Kind.HEAD
## Subtracted from every hit the wearer takes.
@export var defense := 0
## Extra walking speed as a fraction, e.g. 0.25 walks 25% faster.
@export var speed_bonus := 0.0
