extends Node3D

# 52 per deck, 1 deck is used for Blackjack
const DECK_SIZE = 52 * 1

var card_database = FaceCards.new()
var suits = [
	FaceCards.Suit.CLUB,
	FaceCards.Suit.SPADE,
	FaceCards.Suit.DIAMOND,
	FaceCards.Suit.HEART,
]
var ranks = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]

var suit_index = 0
var rank_index = 0

var round_ongoing:bool = false
var hide_dealer_score = true

@onready var deck: CardCollection3D = $Deck_Cards

@onready var player_hand: CardCollection3D = $Player_Hand
@onready var dealer_hand: CardCollection3D = $Dealer_Hand

@onready var player_score_label: Label = $Player_Score
@onready var dealer_score_label: Label = $Dealer_Score
@onready var winner_label: Label = $Winner

@onready var info_label: Label = $Info_label

# Asks the player if he wants to take a 3. card
@export var cardDialog : CardDialog

func _ready() -> void:
	fill_deck()

func next_card():
	# Hier muss noch random gezogen werden
	var suit = suits[suit_index]
	var rank = ranks[rank_index]
	rank_index += 1
	if rank_index == ranks.size():
		rank_index = 0
		suit_index += 1
	if suit_index == suits.size():
		suit_index = 0
	return {"suit": suit, "rank": rank}

func instantiate_face_card(rank, suit) -> FaceCard3D:
	var scene = load("res://Baccarat/face_card_3d.tscn")
	var face_card_3d: FaceCard3D = scene.instantiate()
	var card_data: Dictionary = card_database.get_card_data(rank, suit)
	face_card_3d.rank = card_data["rank"]
	face_card_3d.suit = card_data["suit"]
	face_card_3d.front_material_path = card_data["front_material_path"]
	face_card_3d.back_material_path = card_data["back_material_path"]
	
	return face_card_3d

func get_2_card(hand):
	get_card(hand)
	get_card(hand)

func get_card(hand, face_down:bool = false):
	
	var card: Card3D = deck.pop_card()
	card.face_down = face_down
	hand.append_card(card)
	card.global_position = $"../Deck".global_position
	
	return card.rank
	
func stop_index_reached() -> bool:
	print("Stop Index At: ", DECK_SIZE / 2)
	print("Remaining Cards: ",deck.cards.size())
	return (DECK_SIZE / 2 > deck.cards.size())
	
func fill_deck():
	
	deck.remove_all()
	
	for n in DECK_SIZE:
		var data = next_card()
		var card = instantiate_face_card(data["rank"], data["suit"])
		deck.append_card(card)
	
	deck.cards.shuffle()
	
	
# NOT FINISHED YET
func calc_score(hand):
	var score = 0
	var ace_found = false
	var more_ace_found = false
	
	var ace_count = 0
	
	for card in hand.cards:
		if card.rank <= 10:
			score += card.rank
		elif (card.rank >= 10 && card.rank <= 13):
			score += 10
		# NOT FINISHED YET
		elif card.rank == 14:
			ace_count += 1
	
	# calculating score through states of possible ace counts
	if ace_count == 1:
		if score < 11:
			score += 11
		elif score >= 12:
			score += 1
	elif ace_count == 2:
		if score + 12 > 21:
			score += 2
		else:
			score += 12
	elif ace_count == 3:
		score = 13
	
	return score

# Check if dealer gets a 3. card	
func dealer_3card(hand, score):
	if score <= 16:
		get_card(hand)
		info_label.text += "Dealer takes 3. card\n"
		info_label.text += "Dealer cards: " + str(dealer_hand.cards) + "\n"

	

func display_score(player_score, dealer_score):
	player_score_label.text = "Player Score: " + str(player_score)
	var d_score: String = "hidden" if hide_dealer_score else str(dealer_score)
	dealer_score_label.text = "Dealer Score: " + d_score
	

func check_blackjack(score):
	if score == 21:
		info_label.text += "Blackjack!\n"
		return true
	return false

func check_lost(score):
	if score > 21:
		return true
	return false

func _on_button_play_pressed():
	
	if round_ongoing:
		return

	round_ongoing = true
	hide_dealer_score = true
	
	# [0] Set up labels, scores, hands and deck
	var player_score = 0
	var dealer_score = 0
	var player_wins = false
	var dealer_wins = false
	info_label.text = "[Info]\n"
	# Remove cards before each round
	player_hand.remove_all()
	dealer_hand.remove_all()
	# Remove labels
	winner_label.text = ""
	player_score_label.text = ""
	dealer_score_label.text = ""
	
	if stop_index_reached():
		print("++++++++++++++++++++++")
		print("Stop index has been reached!")
		fill_deck()
		print("Deck has been refilled and shuffled!")
	
	# [1] START OF ROUND
	print("Play one Round of Blackjack")
	info_label.text += "Play one round of Blackjack\n"
	
	# [2] Give Player and Dealer two cards
	get_2_card(player_hand)
	# Dealer gets two cards but only second one is shown until the player decides if he
	# takes a third card or not
	get_card(dealer_hand, true)
	
	get_card(dealer_hand)
	

	print("Player has: ", player_hand.cards)
	print("Dealer has: ", dealer_hand.cards)

	# Calculate current score
	player_score = calc_score(player_hand)
	dealer_score = calc_score(dealer_hand)
	display_score(player_score, dealer_score)
	
	# [2.5] Check for blackjack
	player_wins = check_blackjack(player_score)
	dealer_wins = check_blackjack(dealer_score)
	
	if (player_wins && not dealer_wins):
		round_ongoing = false
		info_label.text += "[Result] Player wins\n"
	else:
		# [3] Ask player for 3. card and wait for button pressed
		cardDialog.popup()
		var take_3_card = await cardDialog.wait_for_user_decision()
		if take_3_card:
			get_card(player_hand)
		
		# Reveil dealers first card
		hide_dealer_score = false
		dealer_hand.cards[0].face_down = false
		#dealer_hand.append_card(dealer_second_card)
		dealer_score = calc_score(dealer_hand)

		# Recalculate the score
		player_score = calc_score(player_hand)
		display_score(player_score, dealer_score)
		print("Player has: ", player_hand.cards)
		info_label.text += "Player cards: " + str(player_hand.cards) + "\n"
		info_label.text += "Dealer cards: " + str(dealer_hand.cards) + "\n"
		# wait 2 seconds
		await get_tree().create_timer(2).timeout
		
		# [3.5] Check if player lost 
		if check_lost(player_score):
			info_label.text += "[Result] Dealer wins\n"
		# If not continue
		else:
			# TODO: Implement a function that reveals the 2. card of the dealer
			# and recalculates the score
			# [4] Check if dealer gets a 3. card and recalculate the score
			dealer_3card(dealer_hand, dealer_score)
			dealer_score = calc_score(dealer_hand)
			display_score(player_score, dealer_score)
		
			# [4.5] Check for blackjack
			player_wins = check_blackjack(player_score)
			dealer_wins = check_blackjack(dealer_score)
			if player_wins && not dealer_wins:
				info_label.text += "[Result] Player wins\n"
			elif player_wins && dealer_wins:
				info_label.text += "[Result] Tie\n"
			elif dealer_wins && not player_wins:
				info_label.text += "[Result] Dealer wins\n"
			# No blackjack, calculating the score
			else:
				if check_lost(dealer_score):
					info_label.text += "[Result] Player wins\n"
				elif player_score > dealer_score:
					info_label.text += "[Result] Player wins\n"
				elif dealer_score > player_score:
					info_label.text += "[Result] Dealer wins\n"
				elif dealer_score == player_score:
					info_label.text += "[Result] Tie\n"
		
	
	# End of round
	info_label.text += "End of Round\n"
	print("End of round!")
	print("--------------------------")
	
	round_ongoing = false
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
