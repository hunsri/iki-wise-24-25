class_name StateObserver
extends Node

enum WinProbs
{
	VERY_LOW,
	LOW,
	SLIGHT_LOW,
	SLIGHT_HIGH,
	HIGH,
	VERY_HIGH
}

var remaining_cards: int = 0

var low_cards: int = 0
var middle_cards: int = 0
var high_cards: int = 0

func _init(cards_in_deck:int = 52):
	print("Initiating new StateObserver for a fresh deck of cards!")
	remaining_cards = cards_in_deck

func add_card(rank:int):
	if rank < 7:
		low_cards += 1
	elif rank < 10:
		middle_cards += 1
	else:
		high_cards += 1
	
	remaining_cards -= 1

func _calculate_HLI() -> float:
	return 100 * (low_cards - high_cards) / remaining_cards

func advice() -> WinProbs:
	var hli = _calculate_HLI()
	
	if hli < -15:
		return WinProbs.VERY_LOW
	elif hli < -7:
		return WinProbs.LOW
	elif hli < 0:
		return WinProbs.SLIGHT_LOW
	elif hli < 8:
		return WinProbs.SLIGHT_HIGH
	elif hli < 16:
		return WinProbs.HIGH
		
	return WinProbs.VERY_HIGH
