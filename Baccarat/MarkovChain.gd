class_name MarkovChain
extends Node

var _deck_amount : int = 1

var origin: MarkovNode = null

func _init(deck_amount = 1):
	_deck_amount = deck_amount
	origin = MarkovNode.new(_deck_amount)
