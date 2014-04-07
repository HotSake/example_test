local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SNAKE_HEAD",
	type = "monster", subtype = "serpent",
	display = "H", color=colors.WHITE,
	desc = [[An enormous serpent!]],

	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	length = 3,
	stats = { str=5, dex=5, con=5 },
	combat_armor = 0,
}

newEntity{ base = "BASE_NPC_SNAKE_HEAD",
	name = "snake head", color=colors.GREEN,
	level_range = {1, 1}, exp_worth = 1,
	rarity = 4,
	--max_life = 8,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=2 },
	resolvers.buildSnake("length", "body", "tail"),
}