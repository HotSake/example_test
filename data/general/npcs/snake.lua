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
	snakeData = {},
}

newEntity{
	define_as = "BASE_NPC_SNAKE_BODY",
	type = "monster", subtype = "serpent",
	display = "o", color=colors.WHITE,
	desc = [[A length of the serpent's body]],
	stats = { str=5, dex=5, con=5 },
	combat_armor = 0,
	snakeData = {},
}

newEntity{
	define_as = "BASE_NPC_SNAKE_TAIL",
	type = "monster", subtype = "serpent",
	display = "o", color=colors.WHITE,
	desc = [[The serpent's tail]],
	stats = { str=5, dex=5, con=5 },
	combat_armor = 0,
	snakeData = {},
}

newEntity{ base = "BASE_NPC_SNAKE_HEAD",
	define_as = "simpleSnakeHead",
	name = "snake head", color=colors.RED,
	level_range = {1, 1}, exp_worth = 1,
	max_life = resolvers.rngrange(20,30),
	combat = { dam=2 },
	allowedParts = {body={"simpleSnakeBody"},tail={"simpleSnakeTail"}},
}

newEntity{ base = "BASE_NPC_SNAKE_BODY",
	define_as = "simpleSnakeBody",
	name = "snake body", color=colors.ORANGE,
	level_range = {1,1}, exp_worth = 0,
	max_life = resolvers.rngrange(20,30),
	combat = { dam=2 },
}

newEntity{ base = "BASE_NPC_SNAKE_TAIL",
	define_as = "simpleSnakeTail",
	name = "snake tail", color=colors.YELLOW,
	level_range = {1,1}, exp_worth = 0,
	max_life = resolvers.rngrange(20,30),
	combat = { dam=2 },
}