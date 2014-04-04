local chooser = require "mod.dialogs.GetChoice"

-- Menu definitions

function getDebugMenu(id, history)
	local d = nil
	history = history or "" -- Can't concatenate onto a nil value
	game.log("Debug menu called. id: %s, history: %s", id, history)
	-- Menus and submenus here
	if id == "BASE" then
		d = chooser.new("Choose option:", {
			{name="Misc", desc="Miscellaneous functions"},
			{name="2", desc="Two"},
			{name="3", desc="Three"},
			{name="4", desc="Four"}
		},
		function(result) getDebugMenu(result, history.." -> "..result) end)
	elseif id == "Misc" then
		d = chooser.new("Choose option:", {
			{name="classFunc", desc="Test calling class functions on objects that have overridden those functions"}
		},
		function(result) getDebugMenu(result, history.." -> "..result) end)
	-- Endpoints here as further elseif lines
	elseif id == "classFunc" then
		classFunc()
	end
	if d then game:registerDialog(d) else game.log("No dialog returned from choice tree: %s", history) end
end

-- Custom functions called above

function classFunc()
	game.player.act = function() game.log("custom act called on %s", game.player.name) mod.class.Player.act(game.player) end
end