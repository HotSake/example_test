local Talents = require "engine.interface.ActorTalents"

function resolvers.buildSnake(body, tail, canShort)
	return {__resolver="buildSnake", __resolve_last = true, body = body, tail = tail, canShort = canShort or false}
end
function resolvers.calc.buildSnake(t, e)
	---[[
	print("BUILDING SNAKE")
	print("DUMPING RESOLVER TABLE")
	table.print(t)
	--[[print("DUMPING e")
	table.print(e)
	--]]

	-- Sanity check
	if not e.length or not t.body or not t.tail then 
		print("buildSnake: Missing required parameters")
		return nil -- Fail somehow so it doesn't spawn a head?
	end

	if not game.zone.npc_list[t.body] or not game.zone.npc_list[t.tail] then
		print("buildSnake: Invalid body or tail name")
		return nil -- Fail somehow so it doesn't spawn a head?
	end
--[[
	-- Check for complete path first
	if canShort ~= true and #snakePath ~= e.length then -- failed
		print("Failed to find snake path in "..maxTries.."tries")
		return nil -- Fail somehow so it doesn't spawn a head?
	else -- Valid snakePath. Fill in length, placing and linking body parts
		for i = 2, #bestPath do -- If just a head, skip making a body/tail
			if i < #bestPath then
				local curBody = game.zone:makeEntityByName(game.level, "actor", body)
			else
				local curBody = game.zone:makeEntityByName(game.level, "actor", tail) -- End with the tail part
			end
			-- Last minute cleanup and setting of relevant values on part before adding it to map
			-- Link to neighbors/head, set index, whatever else I can think of
			game.zone:addEntity(game.level, curBody, "actor", bestPath[i][1], bestPath[i][2])
		end
	end
	return nil
--]]
end