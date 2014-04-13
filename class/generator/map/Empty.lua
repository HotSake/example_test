-- Default Empty roomer, except that it makes about 1/3 of the floor spaces a spot

require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = zone.grid_list
	self.floor = self:resolve("floor") or self:resolve(".")
	self.up = self:resolve("up")
	self.spots = {}
end

function _M:generate()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		self.map(i, j, Map.TERRAIN, self.floor)
		if i > 1 and j > 1 and rng.percent(33) then
			table.insert(self.spots, {x=i, y=j})
		end
	end end
	-- Always starts at 1, 1
	self.map(1, 1, Map.TERRAIN, self.up)
	self.map.room_map[1][1].special = "exit"
	return 1, 1, nil, nil, self.spots
end