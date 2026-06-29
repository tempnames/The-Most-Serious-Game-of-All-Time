class_name EventManager
extends Control

@export var main_title: Label
@export var main_desc: Label
@export var options: VBoxContainer
@export var result: Label
@export var effect: Label
@export var audioplayer: AudioStreamPlayer
@export var cam: Camera2D

@export var titles: Array[String]
@export_multiline var descriptions: Array[String]
enum Event {
	TANTALUS,
	ICARUS,
	EURADYCE,
	ORPHEUS,
	ACHILLES,
	VOICES,
	HARDENED,
	FOOTPRINT
}

const BASIC_ATTACK = preload("uid://thtg33rjpmyv")
const BASIC_BLOCK = preload("uid://clvm7rkk570lq")
const CONSISTENT_ATTACK = preload("uid://cagekksltlqld")
const MEDIUM_ATTACK = preload("uid://c2wqlf5f046tu")
const SPINNER_BLOCK = preload("uid://4oj0ejng8m75")
const STRONG_ATTACK = preload("uid://dqwjt81xxbn58")
const STRONG_BLOCK = preload("uid://0egxmowvdaj5")
const VERSATILE_ATTACKBLOCK = preload("uid://c6124accy1y8d")

var event: Event
var at_end: bool = false

func _ready() -> void {
	var prevev := GamestateManager.previous_event
	var possible_events := [
		Event.TANTALUS,
		Event.ICARUS,
		Event.EURADYCE,
		Event.ORPHEUS,
		Event.ACHILLES
	] as Array[Event]
	event = possible_events.pick_random()
	while event == prevev {
		event = possible_events.pick_random()
	}
	
	main_title.text = titles[event]
	main_desc.text = descriptions[event]
	var eurycardice: bool = GamestateManager.flags.get_or_add(GamestateManager.Flag.EURYCARDICE, false)
	var songpheus: bool = GamestateManager.flags.get_or_add(GamestateManager.Flag.SONGPHEUS, false)
	var together_again: bool = GamestateManager.flags.get_or_add(GamestateManager.Flag.TOGETHER_AGAIN, false)
	if event == Event.EURADYCE {
		match songpheus:
			false:
				main_desc.text += "But who is she waiting for?"
			true:
				main_desc.text += "Staring at this woman, you suddenly get the sense that you’ve seen her before. Your mind drifts to the lyreman’s song, the picture it painted…"
	} elif event == Event.ORPHEUS {
		match eurycardice:
			true:
				main_desc.text += "\n\nThe wedded woman’s words echo in your ears: “Waiting.” “Waiting.” “Waiting.”"
	}
	
	var btns: Array[String]
	match event:
		Event.TANTALUS:
			btns = ["Walk away", "Take his apple", "Give him the apple"]
		Event.ICARUS:
			btns = ["Walk away", "Call to him", "Sit with him"]
		Event.EURADYCE:
			btns = ["Walk away", "Ask her who she waits for", ""]
			if songpheus and not eurycardice:
				btns[2] = "Tell her of the Lyreman's song"
		Event.ORPHEUS:
			btns = ["Walk away", "", ""]
			if not songpheus:
				btns[1] = "Listen to his song"
			if eurycardice and not together_again:
				btns[2] = "Give him The Wedded Woman's Hope"
		Event.ACHILLES:
			btns = ["Walk away", "Talk to the man", "Take the arrow out"]
		Event.VOICES, Event.HARDENED, Event.FOOTPRINT:
			btns = ["Accept", "Decry"]
	
	for button in options.get_children() {
		button.queue_free()
	}
	var i := 0
	for btn in btns {
		# have filler ""s to ensure i remains constantly tied to specific options
		if btn != "" {
			var button := Button.new()
			button.text = " " + btn + " "
			button.alignment = HORIZONTAL_ALIGNMENT_CENTER
			button.size_flags_horizontal = Control.SIZE_SHRINK_END
			options.add_child(button)
			button.pressed.connect(_on_btn_press.bind(i))
		}
		i += 1
	}
}

func _on_btn_press(idx: int) -> void {
	if at_end: return
	audioplayer.stream = null
	var card_ev := false
	var potential_cards: Array[Card]
	var remove_con := func(card: Card) -> bool { return false }
	match event:
		Event.TANTALUS:
			match idx:
				0:
					result.text = "You scoff. Some people down here are so caught up in singular goals that they don’t see the futility of what they’re doing."
					audioplayer.stream = preload("uid://diy6vvi4p328n")
					effect.visible = false
				1:
					if randf() <= 0.5:
						result.text = "You reach for the apple yourself, and the man cries in despair, watching helplessly as you do in a few seconds what he could not do in thousands of years.\n\nYou eat the apple. It tastes like victory."
						audioplayer.stream = preload("uid://d0cmqn55ybj7y")
						effect.text = "You feel revitalized"
						GamestateManager.health = clampi(GamestateManager.health + 30, 0, GamestateManager.max_health)
					else:
						result.text = "As you reach for the apple yourself, you stumble as the bearded man grabs you by the leg. He berates you for attempting to grab his food, and as he begins to lay his fists against your body, you think it strange.\n\nIf it was “his” food, wouldn’t he have reached it by now?"
						audioplayer.stream = preload("uid://c4gbs86pgkuh")
						effect.text = "What doesn't kill you makes you stronger"
						GamestateManager.health = clampi(GamestateManager.health - 1, 0, GamestateManager.max_health)
						GamestateManager.max_health += 5
				2:
					result.text = "When at first you reach towards his apple, the man protests, thinking the worst. But you assure him he has nothing to worry about. You pluck the apple off its tree, and hand it over. It is gone in an instant as the man devours it.\n\nSeeing a dream achieved, you feel revitalized."
					audioplayer.stream = preload("uid://i80dlv57l8mh")
					effect.text = "You've grown stronger"
					GamestateManager.atk_mult *= 1.1
		Event.ICARUS:
			match idx:
				0:
					result.text = "There is no time to lose yourself in the banal cruelty of this world. You have a quest to complete."
					audioplayer.stream = preload("uid://x6r0gkg4mwah")
					effect.visible = false
				1:
					result.text = "You call to the boy, extending your support despite the ever trying times you find yourself in. He does not respond.\n\nHe is too far gone."
					audioplayer.stream = preload("uid://c4wyl1gccvkh8")
					effect.text = "You've grown frailer"
					GamestateManager.blk_mult /= 1.1
				2:
					result.text = "You sit with the boy, silent for what feels like ages. But at one point, you could almost swear you hear him mumble something under his breath.\n\n“It was worth it.”"
					audioplayer.stream = preload("uid://sw12bpx4cfss")
					effect.text = "You've grown sturdier"
					GamestateManager.blk_mult *= 1.1
		Event.EURADYCE:
			match idx:
				0:
					result.text = "It is true that this place brings out despair in all of us. But there is no time to rest on that fact."
					audioplayer.stream = preload("uid://b50k5f0367cn1")
					effect.visible = false
				1:
					if randf() <= 0.5:
						result.text = "The woman smiles fondly as she hears your question. Her eyes fill with joyous memories, so infectious that despite her sorry state you almost wish you could live inside her mind to feel that joy yourself.\n\nThere does exist hope, down in the underworld. Something to fight for."
						audioplayer.stream = preload("uid://ciq3c1elt2hlv")
						effect.text = "You've grown stronger"
						GamestateManager.atk_mult *= 1.1
					else:
						result.text = "The woman’s lips quiver as she hears your question. Oh, no… she begins to cry. Not a simple cry of pain, or of remorse, but that of years and years of grief, of true and utter heartbreak.\n\nYou have seen much in your time down here. Even then, this sight is too much to bear."
						audioplayer.stream = preload("uid://cxa1k0yecc1hq")
						effect.text = "You've grown frailer"
						GamestateManager.blk_mult /= 1.1
				2:
					result.text = "You tell this woman of the lyreman’s song. Her stony facade melts into a hopeful posture it’s clear she hasn’t had in years. She grabs you by the shoulders, and begins talking at you so fast you can only catch a sliver of what she’s saying.\n\n“Husband.” “Came back for me.” “Turned around.” “Waiting.” “Waiting.” “Waiting.”\n\nIt’s all so much that by the time a NEW CARD is shoved into your hands, along with a “for him,” you’re too overwhelmed to protest."
					audioplayer.stream = preload("uid://brveypqf2xseu")
					effect.text = "You feel… reminiscent. Wistful."
					GamestateManager.inventory[0].cards.push_back(preload("uid://4w8psb2wrr06"))
					GamestateManager.flags.set(GamestateManager.Flag.EURYCARDICE, true)
		Event.ORPHEUS:
			match idx:
				0:
					result.text = "There is no use for listening to music down here. No time, either."
					audioplayer.stream = preload("uid://htgvpp0hlq5f")
					effect.visible = false
				1:
					result.text = "You sit nearby, entranced by the man as he continues to play his tune. A vivid image appears to you within the notes. Hazy, fading, but undoubtedly there. \n\nThe vision of a veiled woman, just out of reach.\n\nA deep sorrow grows within you from a heart you long thought incapable of such emotion."
					audioplayer.stream = preload("uid://yiodsjp4vb1a")
					effect.text = "You feel… depressed. Apathetic."
					GamestateManager.atk_mult /= 1.3
					GamestateManager.blk_mult /= 1.3
					GamestateManager.flags.set(GamestateManager.Flag.SONGPHEUS, true)
				2:
					result.text = "You tap the Lyreman on his shoulder. At first he is annoyed that you have disturbed him, until he sees the card you have for him. It is then that, for the first time, the man’s fingers stop plucking at his instrument’s strings.\n\nHe looks to you. To the card. Back to you. Not having words, he returns to his lyre, and plays a tune. But a different tune than the last. \n\nOne full of love. Painful, dangerous, beautiful love."
					audioplayer.stream = preload("uid://dbyucgqcpkoxi")
					effect.text = "His song… it fills you with determination."
					GamestateManager.atk_mult *= 1.3 * 2
					GamestateManager.blk_mult *= 1.3 * 2
					GamestateManager.inventory[0].cards.erase(
						preload("uid://4w8psb2wrr06")
					)
					GamestateManager.inventory[0].window += 1
					GamestateManager.flags.set(GamestateManager.Flag.TOGETHER_AGAIN, true)
					if OS.has_feature("web"):
						JavaScriptBridge.eval("localStorage.setItem(\"tempnames/spinnyphus\", new Date().toJSON());")
		Event.ACHILLES:
			match idx:
				0:
					result.text = "You know from enough time down in the underworld that the best course of action when faced with someone you do not understand is to simply disengage."
					audioplayer.stream = preload("uid://vts8x5i3a4x5")
					effect.visible = false
				1:
					result.text = "You attempt to reason with the warrior, asking what evil he could possibly hope to fell in his current manner. The man lashes out at you, an incoherent ramble of names and battles that have been lost to time. Yet the last thing he says continues to stick with you.\n\n“A weak, fragile man like yourself could never hope to understand me.” Perhaps he is right."
					audioplayer.stream = preload("uid://c0afalrwou882")
					effect.text = "You've grown weaker"
					GamestateManager.atk_mult /= 1.1
				2:
					if randf() <= 0.5:
						result.text = "The man screams and screams until you finally find an opening… and pluck the arrow from his heel. As if a switch is flipped, he calms. After catching his breath, he thanks you, and leaves you with some parting advice:\n\n“The best warriors are not those without weaknesses. They’re the ones who know their weaknesses, and how best to cover them.”"
						audioplayer.stream = preload("uid://dqq5tqb0c0nan")
						effect.text = "You've grown sturdier"
						GamestateManager.blk_mult *= 1.1
					else:
						result.text = "The man screams and screams, and you hope that by plucking the arrow out, you can put an end to his suffering. But as you approach, his eyes lock on to you, and he bats you away with his sword, before running off."
						audioplayer.stream = preload("uid://dobe3dhpimngh")
						effect.text = "You're injured"
						GamestateManager.health = clampi(GamestateManager.health - 10, 0, GamestateManager.max_health)
		Event.VOICES:
			card_ev = true
			match idx:
				0:
					potential_cards = [
						BASIC_ATTACK,
						CONSISTENT_ATTACK,
						VERSATILE_ATTACKBLOCK,
						MEDIUM_ATTACK,
						STRONG_ATTACK
					]
				1:
					remove_con = func(card: Card) -> bool:
						for c_effect in card.effects {
							if c_effect.effect_type == Effect.Type.ATTACK {
								return true
							}
						}
						return false
		Event.HARDENED:
			card_ev = true
			match idx:
				0:
					potential_cards = [
						BASIC_BLOCK,
						SPINNER_BLOCK,
						STRONG_BLOCK,
						VERSATILE_ATTACKBLOCK
					]
				1:
					remove_con = func(card: Card) -> bool:
						for c_effect in card.effects {
							if c_effect.effect_type == Effect.Type.DEFEND {
								return true
							}
						}
						return false
		Event.FOOTPRINT:
			card_ev = true
			match idx:
				0:
					potential_cards = [
						CONSISTENT_ATTACK,
						STRONG_ATTACK,
						STRONG_BLOCK
					]
				1:
					remove_con = func(card: Card) -> bool:
						for c_effect in card.effects {
							if c_effect.roll_min <= 1 {
								return true
							}
						}
						return false
	if card_ev {
		result.visible = false
		if potential_cards.is_empty() {
			effect.text = "It's you."
			for card in GamestateManager.inventory[0].cards {
				if remove_con.call(card) {
					GamestateManager.inventory[0].cards.erase(card)
					effect.text = "You've withered."
					break
				}
			}
		} else {
			GamestateManager.inventory[0].cards.push_back(potential_cards.pick_random())
			effect.text = "You've grown."
		}
	}
	if GamestateManager.health <= 0 {
		GamestateManager.switch_to.emit(Master.Scenes.GAMEOVER)
	}
	at_end = true
	cam.position.y += get_viewport_rect().size.y
}

func _on_voice_trigger_1() -> void {
	var eurycardice: bool = GamestateManager.flags.get_or_add(GamestateManager.Flag.EURYCARDICE, false)
	var songpheus: bool = GamestateManager.flags.get_or_add(GamestateManager.Flag.SONGPHEUS, false)
	match event:
		Event.TANTALUS:
			audioplayer.stream = preload("uid://dnujksio03wj0")
		Event.ICARUS:
			audioplayer.stream = preload("uid://dekhuxnwc8f8c")
		Event.EURADYCE:
			if songpheus:
				audioplayer.stream = preload("uid://dcpmyu0jhwxhu")
			else:
				audioplayer.stream = preload("uid://cbfj2gb3lned7")
		Event.ORPHEUS:
			if eurycardice:
				audioplayer.stream = preload("uid://bppdefy0jerp8")
			else:
				audioplayer.stream = preload("uid://bl3bnjd8lkwwp")
		Event.ACHILLES:
			audioplayer.stream = preload("uid://bjur8t612xklc")
		Event.VOICES:
			audioplayer.stream = preload("uid://el23y0t185ex")
		Event.HARDENED:
			audioplayer.stream = preload("uid://bv763jolplb4g")
		Event.FOOTPRINT:
			audioplayer.stream = preload("uid://df4p7bjg6qy4x")
	audioplayer.play()
}

func _on_voice_trigger_2() -> void {
	audioplayer.play()
}
