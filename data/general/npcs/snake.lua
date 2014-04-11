local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SNAKE_HEAD",
	type = "monster", subtype = "serpent",
	display = "H", color=colors.WHITE,
	length = 3,
	desc = [[An enormous serpent!]],
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	stats = { str=5, dex=5, con=5 },
	combat_armor = 0,
}

newEntity{
	define_as = "BASE_NPC_SNAKE_BODY",
	type = "monster", subtype = "serpent",
	display = "o", color=colors.WHITE,
	desc = [[A length of the serpent's body]],
	stats = { str=5, dex=5, con=5 },
	combat_armor = 0,
}

newEntity{ base = "BASE_NPC_SNAKE_HEAD",
	define_as = "snakeHead",
	name = "snake head", color=colors.GREEN,
	level_range = {1, 1}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngrange(20,30),
	combat = { dam=2 },
	length = resolvers.rngrange(3,9),
	resolvers.buildSnake("snakeBody", "snakeBody", false),
}

newEntity{ base = "BASE_NPC_SNAKE_BODY",
	define_as = "snakeBody",
	name = "snake body", color=colors.GREEN,
	level_range = {1,1}, exp_worth = 0,
	max_life = resolvers.rngrange(20,30),
	combat = { dam=2 },
}