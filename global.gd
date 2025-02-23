extends Node

var is_dragging = false
var dragging_object = null

func rand_weighted(keys, weights):
	var accu = []
	var a: float = 0
	for w in weights:
		a += w
		accu.append(a)
	
	var r = randf_range(0, a)
	for i in range(accu.size()):
		if r <= accu[i]:
			return keys[i]
		
