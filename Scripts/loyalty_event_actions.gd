class_name LoyaltyEventActions extends RefCounted

var game: CardBattle

func setup(card_battle: CardBattle) -> void:
    game = card_battle

func create_deck_card(card_name: String) -> Card:
    var card := game.create_card(card_name, GameRules.Side.PLAYER)
    game.card_space.add_child(card)
    card.global_position = game.player_deck.global_position
    card.scale = Vector2.ONE * 0.18
    return card

func execute(card: Card, event: int) -> void:
    card.reparent(game.card_space)
    if event == LoyaltyRules.Event.REFUSE:
        await refuse(card)
    elif event == LoyaltyRules.Event.DESERT:
        await desert(card)
    else:
        await betray(card)

func refuse(card: Card) -> void:
    await card.move_to(game.player_discard.global_position, false, Vector2.ZERO)
    game.player_discard.add_card(card)

func desert(card: Card) -> void:
    CampaignState.player_deck.erase(card.card_name)
    CampaignState.lose_loyalty(card_group(card))
    await card.move_to(card.global_position + Vector2(0, -400), true)
    card.queue_free()

func betray(card: Card) -> void:
    CampaignState.lose_loyalty(card_group(card))
    await card.move_to(game.enemy_hand.global_position, false, Vector2.ONE * 0.25)
    card.set_side(GameRules.Side.ENEMY)
    game.enemy_hand.add_card(card)

func card_group(card: Card) -> String:
    return "Nobility" if RewardRules.belongs_to(card.card_name, "Nobility") else "Peasants"
