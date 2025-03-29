class_name MarkovNode
extends Node

var value = [4, 4, 4, 4, 4, 4, 4, 4, 4, 16]
var cards_remaining = 52
var child_nodes: Array[MarkovNode] = []
var child_node: MarkovNode = null

func _init(deck_amount = 1):
	
	cards_remaining *= deck_amount 
	value = value.map(func (i): return deck_amount * i)
	print(value)

func create_child(transit_value):
	cards_remaining -= 1
	
	child_node = MarkovNode.new()
	child_node.value = value
	child_node.value[transit_value - 1] -= 1
	

# Input value has to be between 1 and 10 inclusive
func possibility_of_not_exceeding(drawing_value) -> float:
	
	var combined_p: float = 0
	
	if drawing_value > 10:
		drawing_value = 10
	
	for i in range(drawing_value):
		combined_p += possibility_of(i+1)
		print("for i:",i,"p of:",possibility_of(i+1))
	
	return combined_p
	
# Input value has to be between 1 and 10 inclusive, to reflect hard card values
func possibility_of(drawing_value) -> float:
	return value[drawing_value - 1] as float / cards_remaining as float
