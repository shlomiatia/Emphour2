class_name BattleTutorial extends Node

@onready var message: TutorialMessage = $TutorialMessage

var game: CardBattle
var active := false
var stage := 0

signal action_done
signal replacement_done

func setup(value: CardBattle) -> void:
    game = value
    active = CampaignState.selected_city == CampaignState.act_1_city_id(1)
    if !active:
        return
    game.draws.force_draws(GameRules.Side.PLAYER, ["Militia", "Stakes", "Archer", "Light Cavalry", "Militia", "Light Cavalry", "Militia", "Militia", "Mantlet"])
    game.turns.set_enemy_plays(["Light Cavalry", "Militia", "Militia", "Militia"])

func enemy_cards(cards: Array[String]) -> Array[String]:
    if !active:
        return cards
    var result: Array[String] = ["Light Cavalry", "Militia", "Militia", "Militia"]
    return result

func start() -> void:
    if active:
        run()

func run() -> void:
    await get_tree().process_frame
    await say("General, there are 2 ways to win battles")
    await say("Move the balance of power all the way to the right", meter_right())
    await say("Or have it on the right when your cards run out", meter_right())
    await say("Nothing will move until one battle line is full", line_rect())
    await say("Our opponent played a card in secret", enemy_rect())
    await say("Let's deploy a militia by dragging to our battle line")
    restrict("Militia")
    stage = 1
    await action_done
    await game.turns.player_action_started
    await say("Our militia and their light cavalry have equal strength", strengths_rect())
    await say("But the light cavalry have a charge attack", attack_rect())
    await say("It will kill the militia once the battle starts")
    await say("Let's deploy stakes")
    restrict("Stakes")
    stage = 2
    await action_done
    await game.turns.player_action_started
    await get_tree().create_timer(0.25).timeout
    await say("Stakes will block the light cavalry charge attack", stakes_right())
    await say("Our opponent now have higher strength", game.battle_hud.preview.get_global_rect())
    await say("But I have a plan")
    message.show_action("Hover the opponent face down card", enemy_rect())
    game.player_hand.set_draggable(false)
    var tooltip := game.get_node("CardTooltip") as CardTooltip
    await tooltip.enemy_tooltip_shown
    message.hide_message()
    await say("They don't have a card that blocks missile attacks!")
    await say("Deploy an archer. This will fill the battle line and start the battle")
    restrict("Archer")
    stage = 3

func after_player_action() -> void:
    if !active:
        return
    if stage == 4:
        message.hide_message()
        await say("You can discard instead of replacing, by dragging to the discard pile", discard_rect())
        await say("You must play or discard a card each turn")
        await say("Our strength is now equal")
        await say("But I trust you to win the battle now\nGood luck!")
        game.turns.set_allowed_slots([], true)
        game.player_hand.set_draggable_cards(game.player_hand.get_cards())
        stage = 6
        replacement_done.emit()
        return
    if stage <= 3:
        message.hide_message()
        if stage == 3:
            game.player_hand.set_draggable_cards(game.player_hand.get_cards())
            return
        action_done.emit()

func after_battle() -> bool:
    if !active || stage != 5:
        return false
    game.turns.play_enemy_card()
    game.turns.begin_player_action()
    await say("We don't need the stakes anymore, let's replace it")
    game.turns.set_allowed_slots([player_slot(1)], false)
    game.player_hand.set_draggable_cards(game.player_hand.get_cards())
    stage = 4
    await replacement_done
    return true

func prepare_choices(cards: Array[Card]) -> Array[Card]:
    if !active || stage != 3:
        return cards
    var targets := cards.filter(func(card: Card) -> bool: return card.card_name == "Light Cavalry")
    await say("The balance of power moved in the enemy favor, so let's weaken them", game.battle_hud.preview.get_global_rect())
    message.show_action("Kill the light cavalry by clicking on it!", targets[0].get_global_rect())
    stage = 5
    return targets

func choice_selected() -> void:
    if active && stage == 5:
        message.hide_message()

func restrict(card_name: String) -> void:
    game.player_hand.set_draggable_cards(game.player_hand.get_cards().filter(func(card: Card) -> bool: return card.card_name == card_name))

func say(text: String, rect := Rect2()) -> void:
    game.player_hand.hover_enabled = false
    message.show_message(text, rect)
    await message.completed
    game.player_hand.hover_enabled = true

func player_slot(index: int) -> CardSlot:
    return game.board.get_row_slots(Board.PLAYER_ROW)[index]

func meter_right() -> Rect2:
    var rect := game.battle_hud.meter.get_global_rect()
    rect.position.x += rect.size.x / 2.0
    rect.size.x /= 2.0
    return rect

func line_rect() -> Rect2:
    return row_rect(Board.ENEMY_ROW).merge(row_rect(Board.PLAYER_ROW))

func row_rect(row: int) -> Rect2:
    var slots := game.board.get_row_slots(row)
    return slots[0].get_global_rect().merge(slots[-1].get_global_rect())

func enemy_rect() -> Rect2:
    if game.turns.pending_enemy:
        return game.turns.pending_enemy.get_global_rect()
    for card in game.board.get_cards(GameRules.Side.ENEMY):
        if card.face_down:
            return card.get_global_rect()
    return Rect2()

func strengths_rect() -> Rect2:
    var militia := player_slot(0).get_card().strength.get_global_rect()
    return militia.merge(game.board.get_row_slots(Board.ENEMY_ROW)[0].get_card().strength.get_global_rect())

func attack_rect() -> Rect2:
    return game.board.get_row_slots(Board.ENEMY_ROW)[0].get_card().attack.get_global_rect()

func stakes_right() -> Rect2:
    var card := player_slot(1).get_card()
    return card.defence.get_global_rect().grow(8.0)

func discard_rect() -> Rect2:
    return Rect2(game.player_discard.global_position - Card.SIZE / 2.0, Card.SIZE)
