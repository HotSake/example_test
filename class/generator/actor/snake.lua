--[[
Specialized generator for multitile snakelike actors.
Finds a path for the actor to spawn on, places the parts, and links them.

Used ToME sandworm generator for inspiration
]]

require "engine.class"
local Map = require "engine.Map"
local Random = require "engine.generator.actor.Random"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, spots)
	engine.Generator.init(self, zone, map, level, spots)
	self.data = level.data.generator.actor
	self.random = Random.new(zone, map, level, spots)
end

function _M:generate()
	-- Make the random generator place normal actors
	self.random:generate()

	--??? DEBUG
	--table.print(self.data)
	--print("DUMPING self.spots")
	--table.print(self.spots)

	-- Generate and place snakes. self.data.snakeData holds snake params from zone.lua file
	local used= {}
	local goodSpot = false
	local s, idx = "", ""
	local snakePath = {}
	local maxTries = 10 -- Max tries for finding a snakePath from a given spot
	local nb_snakes = rng.range(self.data.nb_snakes[1],self.data.nb_snakes[2])

	for i = 1, nb_snakes do -- For each snake...
		while not goodSpot do -- Find a useable spot
			goodSpot = false -- Initialize goodSpot flag
			s, idx = rng.table(self.spots) -- Get a random spot
			while used[idx] do s, idx = rng.table(self.spots) end -- If spot is used, get another random spot until you get an unused spot
			used[idx] = true -- Mark this spot used. Good or bad, we want it invalidated for future spawns
			snakePath = self:findPath(s, self.data.snakeData.length, maxTries, self.data.snakeData.canShort) -- Get valid snakePath from this spot, or confirmation that it's bad
			if snakePath[1] ~= false then -- good spot
				goodSpot = true
				local snakeType = rng.table(self.data.snakeData.snakeList)
				self:placeSnake(snakePath, snakeType)
			end
		end -- Keep trying to find a useable spot
	end -- Place next snake
end

-- Find a path for the snake's body to spawn along, starting at the head.
-- @param s The map generator spot to spawn on
-- @param length The desired length of the snake, including the head
-- @param maxTries How many times to try to find a path using the random walk
-- @param canShort If a path of the desired length cannot be found, should we accept the next longest path found in the attempt
-- @return An array consisting of a set of coords for the snake's body or a single element table containing false
function _M:findPath(s, length, maxTries, canShort)
	if not s.x or not s.y then print("snake.lua:canPlace - Did not receive x and y coords to check: "..s.x or "missing"..", "..s.y or "missing") return {false} end
	local length = length
	local maxTries = maxTries
	local canShort = canShort
	local bestPath = {}
	local snakePath = {}

	local x, y = util.findFreeGrid(s.x, s.y, 5, true, {[Map.ACTOR]=true}) -- Get a free starting point around the spot
	if not x or not y then print("snake.lua:canPlace - Did not find free grid to start around: "..s.x or "missing"..", "..s.y or "missing") return {false} end

	for pathTries = 1, maxTries do
		table.insert(snakePath,{x, y}) -- Start with the starting point. Can always place the head there

		for i = 2, length do -- Planning each part
			local adjCoords = table.shuffle(util.adjacentCoords(snakePath[#snakePath][1], snakePath[#snakePath][2]))

			-- Iterate over randomized adjacent coordinates, checking if they're open and not already part of the path.
			for _, tryCoord in pairs(adjCoords) do
				-- Check tryCoord for obstruction or path part
				if self:gridClear({x=tryCoord[1],y=tryCoord[2]}) and not self:pathContains(snakePath, tryCoord) then
					-- TODO: insert check on spaces at adjacent angles to ensure snake isn't crossing itself
					table.insert(snakePath,tryCoord) -- Add tryCoord to path
					break -- Stop checking adjacent coords
				end
			end

			if #snakePath ~= i then -- Failed to find an open space (i is the number of the new coord. If we found an open space, then there would be i entries in snakePath)
				break
			end
		end

		if #snakePath ~= length then -- try must have failed. Keep longest path and try again
			if #snakePath > #bestPath then bestPath = snakePath end -- Save longest path in case we can fall short
			pathTries = pathTries + 1
		else -- snakePath complete. Break the while loop and move on
			print("Found complete length "..length.." snake path in "..pathTries.." tries")
			bestPath = snakePath
			break
		end
	end

	if #snakePath == length or canShort == true then -- Either we met the length requirement or we don't care anyway
		if #snakePath < length then
			print("Found length "..#snakePath.." path (desired: "..length..") in "..(pathTries-1).." tries.")
		end
		return snakePath
	else
		return {false} -- generate() will check snakePath[1] to see if good path. Must return a table with at least 1 element
	end
end

function _M:placeSnake(snakePath, snakeType)
	local snakePath = snakePath
	local snakeType = snakeType
	local snakePartList = {}

	local m = self.zone:makeEntityByName(self.level, "actor", snakeType) -- Make the head first
	table.insert(snakePartList,m) -- Keep a list of all actors comprising the snake
	m.snakeData["head"]=snakePartList[1] -- Tell the head who the head is
	local bodies = m.allowedParts.body -- Head defs contain lists of allowed parts
	local tails = m.allowedParts.tail

	--[[ Debug stuff
	print("DUMPING bodies")
	table.print(bodies)
	print("DUMPING tails")
	table.print(tails)
	print("DUMPING #snakePartList + names")
	print(#snakePartList)
	for _,part in pairs(snakePartList) do
		print(part.name)
	end
	--]]

	self.zone:addEntity(self.level, m, "actor", snakePath[1][1], snakePath[1][2]) -- Place the head
	---[[
	for i = 2, #snakePath do
		local body = ""
		if i < #snakePath then
			body = rng.table(bodies) -- Pick a body if not last
		else
			body = rng.table(tails) -- Pick a tail if last
		end

		local m = self.zone:makeEntityByName(self.level, "actor", body)
		if not m then print("Failed to makeEntityByName: "..body) return end
		if self.data.snakeData.headOnly == true then -- headOnly means that the snake parts are not presented to the player as units. Their names and tooltips reflect the head's.
			m.name = snakePartList[1].name -- Copy the head's name
			-- TODO: alter tooltip code to show head's tooltip instead
		else
			if i < #snakePath then
				m.name = "Segment "..i-1
			else
				m.name = "Tail"
			end
		end
		table.insert(snakePartList,m)
		m.snakeData["head"]=snakePartList[1] -- Tell this part who the head is
		m.snakeData["up"]=snakePartList[i-1] -- Tell this part who its neighbor toward the head is
		snakePartList[i-1].snakeData["down"]=m -- Tell this part's up neighbor who its new down neighbor is
		self.zone:addEntity(self.level, m, "actor", snakePath[i][1], snakePath[i][2])
	end
	--]]
end

function _M:gridClear(s)
	-- Added isBound check to stop tracing paths outside the level
	if game.level.map:checkEntity(s.x, s.y, game.level.map.TERRAIN, "block_move") or game.level.map(s.x, s.y, Map.ACTOR) or not game.level.map:isBound(s.x, s.y) then
		return false
	else
		return true
	end
end

function _M:pathContains(path, grid)
	for _, pathGrid in pairs(path) do
		if pathGrid[1] == grid[1] and pathGrid[2] == grid[2] then return true end
	end
	return false
end