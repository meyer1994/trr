class_name Blocks
extends RefCounted

const DIRT := preload("res://blocks/dirt.tres")
const GRASS := preload("res://blocks/grass.tres")
const STONE := preload("res://blocks/stone.tres")

## Every placeable block. The order sets each block's tile in the map atlas.
const ALL: Array[Block] = [DIRT, GRASS, STONE]
