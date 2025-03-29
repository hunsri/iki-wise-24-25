class_name MarkovChain
extends Node

var _deck_amount : int = 1

var origin: MarkovNode = null
var index: MarkovNode = null

func _init(deck_amount = 1):
	_deck_amount = deck_amount
	origin = MarkovNode.new(_deck_amount)
	index = origin
	
# When a card gets played, its value determines which transit is taken
func do_transit(transit_value):
	index.create_child(transit_value)
	index = index.child_node

func possibility_of_not_exceeding(drawing_value) -> float:
	return index.possibility_of_not_exceeding(drawing_value)
