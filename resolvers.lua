local Talents = require "engine.interface.ActorTalents"

function resolvers.buildSnake(length, body, tail)
	return {__resolver="buildSnake", __resolve_last = true, length = length, body = body, tail = tail}
end
function resolvers.calc.buildSnake(t, e)
	print("DUMPING RESOLVER TABLE")
	table.print(t)
	print("DUMPING e.length")
	print(e.length)
	return nil
end