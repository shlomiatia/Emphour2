extends RefCounted

const DATA := {
    "starting_decks": {
        "act_1": ["Archer", "Mantlet", "Stakes", "Light Cavalry", "Light Cavalry", "Militia", "Militia", "Militia", "Militia"],
        "act_2": ["Archer", "Crossbowman", "Mantlet", "Stakes", "Horse Archer", "Light Cavalry", "Axeman", "Swordman", "Spearman", "Foot Knight", "Lancer", "Heavy Cavalry", "Knight"],
        "default_enemy": ["Archer", "Militia", "Militia"]
    },
    "cities": {
        "Act 1 City 1": {"slots": 3, "deck": ["Light Cavalry", "Militia", "Militia", "Militia", "Militia"]},
        "Act 1 City 2": {"slots": 3, "count": 10, "value": 10, "exclude": ["Knight", "Foot Knight", "Lancer", "Heavy Cavalry", "Crossbowman"]},
        "Act 1 City 3": {"slots": 3, "count": 9, "value": 11, "exclude": ["Knight", "Foot Knight", "Lancer", "Heavy Cavalry", "Crossbowman"]},
        "Act 1 City 4": {"slots": 3, "count": 9, "value": 13, "exclude": ["Knight", "Knight", "Foot Knight", "Lancer", "Heavy Cavalry", "Crossbowman"]},
        "Act 1 City 5": {"slots": 4, "count": 12, "value": 16, "exclude": ["Knight"]},
        "Act 1 Boss": {"slots": 4, "count": 11, "value": 17, "nobility_count": 4, "nobility_value": 11, "peasants_count": 11, "peasants_value": 17},
        "Act 2 City 1": {"slots": 4, "count": 11, "value": 19},
        "Act 2 City 2": {"slots": 4, "count": 14, "value": 21},
        "Act 2 City 3": {"slots": 4, "count": 14, "value": 23},
        "Act 2 City 4": {"slots": 4, "count": 14, "value": 25},
        "Act 2 City 5": {"slots": 5, "count": 14, "value": 27},
        "Act 2 Boss": {"slots": 5, "count": 14, "value": 29}
    },
    "tiers": {
        "1": ["Archer", "Mantlet", "Stakes", "Militia"],
        "2": ["Crossbowman", "Horse Archer", "Light Cavalry", "Axeman", "Swordman", "Spearman"],
        "3": ["Foot Knight", "Lancer", "Heavy Cavalry"],
        "4": ["Knight"]
    },
    "tier_1_weights": {"Militia": 2, "Archer": 2, "Stakes": 1, "Mantlet": 1},
    "rewards": {
        "Act1_Peasants_1": ["new:1"],
        "Act1_Peasants_2": ["upgrade:1:2:exclude:Crossbowman"],
        "Act1_Peasants_3": ["new:2:exclude:Crossbowman"],
        "Act1_Peasants_4": ["new:Crossbowman"],
        "Act1_Peasants_5": ["upgrade:1:Crossbowman"],
        "Act1_Nobility_1": ["new:2:exclude:Crossbowman"],
        "Act1_Nobility_2": ["upgrade:1:2:exclude:Crossbowman"],
        "Act1_Nobility_3": ["upgrade:2:3"],
        "Act1_Nobility_4": ["upgrade:1:3"],
        "Act1_Nobility_5": ["upgrade:3:4"],
        "Act1Boss_Peasants_1": ["new:Crossbowman"],
        "Act1Boss_Peasants_2": ["upgrade:1:Crossbowman"],
        "Act1Boss_Nobility_1": ["upgrade:2:4"],
        "Act1Boss_Nobility_2": ["new:4"],
        "Act2_Ally_1": ["new:1"],
        "Act2_Ally_2": ["upgrade:1:2:exclude:Crossbowman", "new:2:exclude:Crossbowman"],
        "Act2_Ally_3": ["upgrade:1:Crossbowman", "new:Crossbowman"],
        "Act2_Ally_4": ["upgrade:2:3", "new:3"],
        "Act2_Ally_5": ["upgrade:3:4"],
        "Act2_War_1": ["upgrade:1:2:exclude:Crossbowman", "new:2:exclude:Crossbowman"],
        "Act2_War_2": ["upgrade:1:Crossbowman", "new:Crossbowman"],
        "Act2_War_3": ["upgrade:2:3", "new:3"],
        "Act2_War_4": ["upgrade:3:4"],
        "Act2_War_5": ["upgrade:2:4", "new:4"]
    },
    "upgrades": {
        "Militia": "all", "Archer": "Horse Archer,Crossbowman", "Mantlet": "Swordman", "Stakes": "Spearman",
        "Light Cavalry": "Lancer,Heavy Cavalry,Knight", "Spearman": "all", "Swordman": "all",
        "Horse Archer": "Lancer,Heavy Cavalry,Knight", "Axeman": "all", "Foot Knight": "all", "Lancer": "all", "Heavy Cavalry": "all"
    },
    "loyalty_chances": {
        "-1": [5, 0, 0], "-2": [10, 5, 0], "-3": [15, 10, 5], "-4": [20, 15, 10], "-5": [25, 20, 15]
    }
}
