local Talents = require "engine.interface.ActorTalents"

function resolvers.buildSnake(length, body, tail, canShort)
	return {__resolver="buildSnake", __resolve_last = true, body = body, tail = tail, canShort = canShort or false}
end
function resolvers.calc.buildSnake(t, e)
	---[[
	print("BUILDING SNAKE")
	print("DUMPING RESOLVER TABLE")
	table.print(t)
	print("DUMPING e")
	table.print(e)
	--]]

	-- Sanity check
	if not e.length or not t.body or not t.tail then 
		print("buildSnake: Missing required parameters")
		return nil -- Fail somehow so it doesn't spawn a head?
	end

	if not self.npc_list[t.body] or not self.npc_list[t.tail] then
		print("buildSnake: Invalid body or tail name")
		return nil -- Fail somehow so it doesn't spawn a head?
	end

	-- Time to do work!
	-- First, use the length of the snake to draw out an accessible path for its body by random walk. Will only fail it paints itself into a corner.
	-- If it fails to place after a set number of attempts, then fail spawning.
	local snakePath = {}
	local bestPath = {}
	local maxTries = 10

	for pathTries = 1, maxTries do
		snakePath = {{e.x, e.y}}

		for i = 2, e.length do -- Planning each part
			local adjCoords = table.shuffle(util.adjacentCoords(snakePath[#snakePath]))

			-- Iterate over randomized adjacent coordinates, checking if they're open and not part of the path.
			for _, tryCoord in pairs(adjCoords) do
				-- Check tryCoord for obstruction or path part
				if coordTestStuff then
					snakePath[i] = tryCoord -- Add tryCoord to path
					break -- Stop checking adjacent coords
				end
			end

			if #snakePath ~= i then -- Failed to find an open space (i is the number of the new coord. If we found an open space, then there would be i entries in snakePath)
				break
			end
		end

		if #snakePath ~= e.length then -- try must have failed. Keep longest path and try again
			if #snakePath > #bestPath then bestPath = snakePath end -- Save longest path in case we can fall short
			pathTries = pathTries + 1
		else -- snakePath complete. Break the while loop and move on
			print("Found complete snake path in "..pathTries.." tries")
			bestPath = snakePath
			break
		end
	end

	-- Check for complete path first
	if canShort == false and #snakePath ~= e.length then -- failed
		print("Failed to find snake path in "..maxTries.."tries")
		return nil -- Fail somehow so it doesn't spawn a head?
	else -- Valid snakePath. Fill in length, placing and linking body parts
		for i = 2, #bestPath do -- If just a head, skip making a body/tail
			if i < #bestPath then
				local curBody = currentZone:makeEntityByName(game.level, "actor", body)
			else
				local curBody = currentZone:makeEntityByName(game.level, "actor", tail) -- End with the tail part
			end
			-- Last minute cleanup and setting of relevant values on part before adding it to map
			-- Link to neighbors/head, set index, whatever else I can think of
			currentZone:addEntity(game.level, curBody, "actor", bestPath[i][1], bestPath[i][2])
		end
	end
	return nil
end