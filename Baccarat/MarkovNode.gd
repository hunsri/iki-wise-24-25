class_name MarkovNode
extends Node

var value = [4, 4, 4, 4, 4, 4, 4, 4, 4, 16]
var cards_remaining = 52
var child_nodes: Array[MarkovNode] = []

func _init(deck_amount = 1):
	
	cards_remaining *= deck_amount 
	value = value.map(func (i): return deck_amount * i)
	print(value)
	
	#create_transition(self)

# Input value has to be between 1 and 10 inclusive
func possibility_of_not_exceeding(drawing_value) -> float:
	
	var combined_p: float = 0
	
	for i in range(drawing_value):
		combined_p += possibility_of(i)
	
	return combined_p
	

# Input value has to be between 1 and 10 inclusive, to reflect hard card values
func possibility_of(drawing_value) -> float:
	return value[drawing_value - 1] / cards_remaining

func create_transition(node: MarkovNode, decks_amount: int = 1):
	if node == null:
		return
	
	# creates all possible transitions for the current state of the node
	for i in range(10):
		if value[i] != 0:
			#node.child_nodes[i] = MarkovNode.new(decks_amount)
			node.child_nodes[i].value = value[i]-1
		else:
			node.child_nodes[i] = null

 
