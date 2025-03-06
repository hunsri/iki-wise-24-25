extends Node3D

# 52 per deck, 4 decks are used for Baccarat
const DECK_SIZE = 52 * 4

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

@onready var deck: CardCollection3D = $Deck_Cards

@onready var player_hand: CardCollection3D = $Player_Hand
@onready var dealer_hand: CardCollection3D = $Dealer_Hand

@onready var player_score_label: Label = $Player_Score
@onready var dealer_score_label: Label = $Dealer_Score
@onready var winner_label: Label = $Winner

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

func get_card(hand):
	
	var card: Card3D = deck.pop_card()
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

func calc_score(hand) -> int:
	var score = 0
	for card in hand.cards:
		# In case it is an Ace
		if card.rank == 14:
			score = score + 1
		# In case it is 10, B, D, K
		elif card.rank >= 10:
			score = score + 0
		else:
			score = score + card.rank
	# Finally check if score > 9 and drop first digit
	if score > 9:
		score = score % 10
	return score
	
	
func check_if_winner(player_score, dealer_score):
	if (player_score == 9 && dealer_score == 9):
		return [true, true, 'tie']
	if (player_score == 8 && dealer_score == 8):
		return [true, true, 'tie']
	
	if (player_score == 9 && dealer_score == 8):
		return [true, false, 'player wins']
	if (player_score == 8 && dealer_score == 9):
		return [false, true, 'dealer wins'] 

	if (player_score == 8 || player_score == 9):
		if (dealer_score < 8):
			return [true, false, 'player wins']
	if (dealer_score == 8 || dealer_score == 9):
		if (player_score < 8):
			return [false, true, 'dealer wins']
	
	if (player_score < 8 && dealer_score < 8):
		return [false, false, "No winner yet"]

func check_player_third_card(player_score, dealer_score):
	var player_third = false
	# Player "stands" if between 6-7 -> then player gets no third card
	if (player_score == 6 || player_score == 7):
		player_third = false
	# Player gets 3. card if between 0-5
	if (player_score >= 0 && player_score <= 5):
		player_third = true
	return player_third

func should_bank_get_third_card(player_third_card: int, dealer_score: int) -> bool:

	# Check if dealer also gets a third card according to the rule
	if (dealer_score >= 0 && dealer_score <= 2):
		return true
	elif (dealer_score == 3 && player_third_card != 8):
		return true
	elif (dealer_score == 4 && player_third_card >= 2 && player_third_card <= 7 ):
		return true
	elif (dealer_score == 5 && player_third_card >= 4 && player_third_card <= 7 ):
		return true
	elif (dealer_score == 6 && player_third_card >= 6 && player_third_card <= 7 ):
		return true
	
	return false

func _on_button_play_pressed():
	
	if stop_index_reached():
		print("++++++++++++++++++++++")
		print("Stop index has been reached!")
		fill_deck()
		print("Deck has been refilled and shuffled!")
	
	if round_ongoing:
		return
	else:
		round_ongoing = true
	
	print("Play one Round of Baccarat")
	# Remove cards before each round
	player_hand.remove_all()
	dealer_hand.remove_all()
	# Remove labels
	winner_label.text = ""
	player_score_label.text = ""
	dealer_score_label.text = ""
	
	# Give Player and Dealer two cards
	get_2_card(player_hand)
	get_2_card(dealer_hand)
	
	print("Player has: ", player_hand.cards)
	print("Dealer has: ", dealer_hand.cards)
	
	# Calculate the current score for the player and dealer
	var player_score = calc_score(player_hand)
	player_score_label.text = "Player Score: " + str(player_score)
	var dealer_score = calc_score(dealer_hand)
	dealer_score_label.text = "Dealer Score: " + str(dealer_score)
	print("Player Score: ", player_score)
	print("Dealer Score: ", dealer_score)
	
	# Check if there is already a winner
	var winner = check_if_winner(player_score, dealer_score)  
	print("Has player won? -> ", winner[0])
	print("Has dealer won? -> ", winner[1])
	print("Result: ", winner[2])
	
	# If there is no winner yet do:
	if (winner[2] == "No winner yet"):
		# Check if the player takes a third card according to the rules
		var player_third_card = check_player_third_card(player_score, dealer_score)
		# If the player has to get a third card do:
		if (player_third_card):
			print("Player gets 3rd card")
			# Player takes 3. card and wait 2 seconds for animation
			await get_tree().create_timer(2).timeout 
			var player_3_card_rank = get_card(player_hand)
			# Check new score 
			player_score = calc_score(player_hand)
			player_score_label.text = "Player Score: " + str(player_score)
			
			if should_bank_get_third_card(player_3_card_rank, dealer_score):
				print("Dealer gets also a 3rd card")
				await get_tree().create_timer(2).timeout 
				var dealer_card_rank = get_card(dealer_hand)
				dealer_score = calc_score(dealer_hand)
				dealer_score_label.text = "Dealer Score: " + str(dealer_score)
				
		elif not player_third_card:
			if (dealer_score >= 0 && dealer_score <= 5):
				print("Dealer gets 3rd card")
				await get_tree().create_timer(2).timeout 
				var dealer_card_rank = get_card(dealer_hand)
				dealer_score = calc_score(dealer_hand)
				dealer_score_label.text = "Dealer Score: " + str(dealer_score)
			elif (dealer_score >= 6 && dealer_score <= 7):
				print("Dealer stands. No third card for dealer")
				
		# Check score again, highest score wins
		player_score = calc_score(player_hand)
		player_score_label.text = "Player Score: " + str(player_score)
		dealer_score = calc_score(dealer_hand)
		dealer_score_label.text = "Dealer Score: " + str(dealer_score)
		print("Player Score: ", player_score)
		print("Dealer Score: ", dealer_score)
		
		if player_score > dealer_score:
			print("Player wins")
			winner_label.text = "--> PLAYER WINS <--"
		else:
			print("Dealer wins")
			winner_label.text = "--> DEALER WINS <--"
	# if it is a tie
	elif (winner[2] == "tie"):
		winner_label.text = "--> IT IS A TIE <--"
	elif (winner[2] == "player wins"):
		winner_label.text = "--> PLAYER WINS <--"
	elif (winner[2] == "dealer wins"):
		winner_label.text = "--> DEALER WINS <--"
	else:
		print("Shit da klappt was nicht")
	
	print("End of round!")
	print("--------------------------")
	
	round_ongoing = false
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
