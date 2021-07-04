extends Node2D
var next_scene1 = null

var background_music = "res://Audio/BGM/PU-Route 01.ogg";

var type = "Outside"
var place_name = "Route 01"
var wild_battle_back = BattleInstanceData.BattleBack.FOREST

# Wild Poke table
var wild_table = [
#	 ID  chance  lowest_level highest_level
	[7,   40,   2,           3],
	[9,   30,   2,           3],
	[12,  30,   2,           3]
]

# Trainers
var trainer1
var trainer2


# Called when the node enters the scene tree for the first time.
func _ready():
	trainer1 = $NPC_Layer/Trainer1
	trainer2 = $NPC_Layer/Trainer2

	Global.game.player.connect("trainer_battle", self, "trainer_battle")

	if Global.past_events.has("ROUTE1_TRAINER1_DEFEATED"):
		trainer1.seeking = false
		trainer1.defeated = true
	if Global.past_events.has("ROUTE1_TRAINER2_DEFEATED"):
		trainer2.seeking = false
		trainer2.defeated = true

func interaction(check_pos : Vector2, direction): # check_pos is a Vector2 of the position of object to interact
	if check_pos == $NPC_Layer/Trainer1.position:
		$NPC_Layer/Trainer1.face_player(direction)
		if !trainer1.defeated:
			trainer_battle(trainer1)
		else:
			Global.game.lock_player()
			Global.game.play_dialogue_with_point("NPC_ROUTE1_TRAINER_1_DEFEAT" , trainer1.get_global_transform_with_canvas().get_origin())
			yield(Global.game, "event_dialogue_end")
			Global.game.release_player()
		pass
	if check_pos == $NPC_Layer/Trainer2.position:
		$NPC_Layer/Trainer2.face_player(direction)
		if !trainer2.defeated:
			trainer_battle(trainer2)
		else:
			Global.game.lock_player()
			Global.game.play_dialogue_with_point("NPC_ROUTE1_TRAINER_2_DEFEAT" , trainer2.get_global_transform_with_canvas().get_origin())
			yield(Global.game, "event_dialogue_end")
			Global.game.release_player()
		pass
	if check_pos == $NPC_Layer/Chyinmunk.position:
		#$NPC_Layer/Trainer2.face_player(direction)
		Global.game.lock_player()
		Global.game.get_node("Effect_music").stream = load("res://Audio/SE/007Cry.wav")
		Global.game.get_node("Effect_music").play()
		Global.game.play_dialogue_with_point("NPC_ROUTE1_CHYINMUNK" , $NPC_Layer/Chyinmunk.get_global_transform_with_canvas().get_origin())
		yield(Global.game, "event_dialogue_end")
		Global.game.release_player()
	pass

func get_grass_cells():
	return get_node("Tile Layer 1/PU_autotiles").get_used_cells()

func trainer_battle(npc_trainer):
			Global.game.lock_player()
			npc_trainer.seeking = false
			# Play encounter music
			npc_trainer.alert()
			yield(npc_trainer, "alert_done")
			match npc_trainer:
				trainer1, trainer2:
					Global.game.get_node("Background_music").stream = load("res://Audio/ME/PU-FemaleEncounter.ogg")
			Global.game.get_node("Background_music").play()

			# Turn player to face trainer
			match npc_trainer.facing:
				"Up":
					Global.game.player.set_facing_direction("Down")
				"Down":
					Global.game.player.set_facing_direction("Up")
				"Left":
					Global.game.player.set_facing_direction("Right")
				"Right":
					Global.game.player.set_facing_direction("Left")

			# Walk towards player
			npc_trainer.move_to_player()
			yield(npc_trainer, "done_movement")

			# Pre-battle talk
			match npc_trainer:
				trainer1, trainer2:
					Global.game.play_dialogue_with_point("NPC_ROUTE1_TRAINER_1" , npc_trainer.get_global_transform_with_canvas().get_origin())
			yield(Global.game, "event_dialogue_end")

			match npc_trainer:
				trainer1:
					trainer1_battle()
				trainer2:
					trainer2_battle()
	
func trainer1_battle():
	var trainer = trainer1
	trainer.seeking = false
	print("Start Trainer1 battle")

	var bid = BattleInstanceData.new()
	bid.battle_type = bid.BattleType.SINGLE_TRAINER
	bid.battle_back = bid.BattleBack.FEILD_1
	bid.opponent = Opponent.new()
	bid.opponent.name = trainer.trainer_name
	bid.opponent.battle_texture = load("res://Graphics/Characters/trainer002.png")
	bid.opponent.opponent_type = Opponent.OPPONENT_TRAINER
	bid.opponent.after_battle_quote = tr("NPC_ROUTE1_TRAINER_1_DEFEAT")
	bid.victory_award = trainer.trainer_reward
	bid.opponent.ai = load("res://Utilities/Battle/Classes/AI.gd").new()
	bid.opponent.ai.AI_Behavior = bid.opponent.ai.WILD
	bid.opponent.pokemon_group = trainer.get_poke_group()
	
	Global.game.trainer_battle(bid)
	yield(Global.game.battle, "battle_complete")
	if Global.game.battle.player_won:
		trainer.defeated = true
		Global.past_events.append("ROUTE1_TRAINER1_DEFEATED")
	Global.game.get_node("Background_music").stream = load(background_music)
	Global.game.get_node("Background_music").play()
	Global.game.release_player()
func trainer2_battle():
	var trainer = trainer2
	trainer.seeking = false
	print("Start Trainer2 battle")

	var bid = BattleInstanceData.new()
	bid.battle_type = bid.BattleType.SINGLE_TRAINER
	bid.battle_back = bid.BattleBack.FEILD_1
	bid.opponent = Opponent.new()
	bid.opponent.name = trainer.trainer_name
	bid.opponent.battle_texture = load("res://Graphics/Characters/trainer063.png")
	bid.opponent.opponent_type = Opponent.OPPONENT_TRAINER
	bid.opponent.after_battle_quote = tr("NPC_ROUTE1_TRAINER_2_DEFEAT")
	bid.victory_award = trainer.trainer_reward
	bid.opponent.ai = load("res://Utilities/Battle/Classes/AI.gd").new()
	bid.opponent.ai.AI_Behavior = bid.opponent.ai.WILD
	bid.opponent.pokemon_group = trainer.get_poke_group()
	
	Global.game.trainer_battle(bid)
	yield(Global.game.battle, "battle_complete")
	if Global.game.battle.player_won:
		trainer.defeated = true
		Global.past_events.append("ROUTE1_TRAINER2_DEFEATED")
	Global.game.get_node("Background_music").stream = load(background_music)
	Global.game.get_node("Background_music").play()
	Global.game.release_player()
