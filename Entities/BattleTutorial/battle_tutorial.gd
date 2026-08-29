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
    await say(tr("tutorial.battle.ways"))
    await say(tr("tutorial.battle.meter"), meter_right())
    await say(tr("tutorial.battle.cards_run_out"), meter_right())
    await say(tr("tutorial.battle.kill_all"))
    await say(tr("tutorial.battle.line_full"), line_rect())
    await say(tr("tutorial.battle.secret"), enemy_rect())
    await say(tr("tutorial.battle.deploy_militia"))
    restrict("Militia")
    stage = 1
    await action_done
    await game.turns.player_action_started
    await say(tr("tutorial.battle.equal_strength"), strengths_rect())
    await say(tr("tutorial.battle.charge"), attack_rect())
    await say(tr("tutorial.battle.kill_militia"))
    await say(tr("tutorial.battle.deploy_stakes"))
    restrict("Stakes")
    stage = 2
    await action_done
    await game.turns.player_action_started
    await get_tree().create_timer(0.25).timeout
    await say(tr("tutorial.battle.block_charge"), stakes_right())
    await say(tr("tutorial.battle.enemy_stronger"), game.battle_hud.preview.get_global_rect())
    await say(tr("tutorial.battle.plan"))
    message.show_action(tr("tutorial.battle.hover_face_down"), enemy_rect())
    game.player_hand.set_draggable(false)
    var tooltip := game.get_node("CardTooltip") as CardTooltip
    await tooltip.enemy_card_hovered
    message.play_progress_sound()
    await tooltip.enemy_tooltip_shown
    message.hide_message()
    await say(tr("tutorial.battle.no_missile_block"))
    await say(tr("tutorial.battle.deploy_archer"))
    restrict("Archer")
    stage = 3

func after_player_action() -> void:
    if !active:
        return
    if stage == 4:
        message.hide_message()
        await say(tr("tutorial.battle.discard"), discard_rect())
        await say(tr("tutorial.battle.turn"))
        await say(tr("tutorial.battle.good_luck"))
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
    await say(tr("tutorial.battle.replace_stakes"))
    game.turns.set_allowed_slots([player_slot(1)], false)
    game.board.set_enabled_cards([player_slot(1).get_card()])
    game.player_hand.set_draggable_cards(game.player_hand.get_cards())
    stage = 4
    await replacement_done
    return true

func prepare_choices(cards: Array[Card]) -> Array[Card]:
    if !active || stage != 3:
        return cards
    var targets := cards.filter(func(card: Card) -> bool: return card.card_name == "Light Cavalry")
    await say(tr("tutorial.battle.enemy_favor"), game.battle_hud.preview.get_global_rect())
    message.show_action(tr("tutorial.battle.kill_cavalry"), targets[0].get_global_rect())
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
