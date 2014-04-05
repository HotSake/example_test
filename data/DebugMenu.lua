local chooser = require "mod.dialogs.GetChoice"

-- Menu definitions

function getDebugMenu(id, history)
	local d = nil
	history = history or "" -- Can't concatenate onto a nil value
	game.log("Debug menu called. id: %s, history: %s", id, history)
	---- Menus and submenus here
	--Top level menu
	if id == "BASE" then
		d = chooser.new("Choose option:", {
			{name="Misc", desc="Miscellaneous functions"},
			{name="2", desc="Two"},
			{name="3", desc="Three"},
			{name="4", desc="Four"}
		},
		function(result) getDebugMenu(result, history.." -> "..result) end)
	--Submenu for misc stuff, usually one-off tests
	elseif id == "Misc" then
		d = chooser.new("Choose option:", {
			{name="classFunc", desc="Test calling class functions on objects that have overridden those functions"},
			{name="passTable", desc="See if Shibari's initial method of checking Shield functions could work (IRC thing)"},
			{name="safeCheck", desc="Test different ways of checking or calling bullshit properties to see what crashes and what doesn't"}
		},
		function(result) getDebugMenu(result, history.." -> "..result) end)
	-- Endpoints below here as further elseif lines
	elseif id == "classFunc" then
		classFunc()
	elseif id == "passTable" then
		passTable()
	elseif id == "safeCheck" then
		safeCheck()
	end
	if d then game:registerDialog(d) else game.log("No dialog returned from choice tree: %s", history) end
end

-- Custom functions called above

function classFunc()
	game.player.act = function() game.log("custom act called on %s", game.player.name) mod.class.Player.act(game.player) end
end

-- [15:01] <Shibari> weird, why doesn't if shield then shield:check("on_block.fct", self, src, type, dam, eff) end work?  just adding .fct because I made it a table with a desc and a function now
function passTable()
	local on_block_function = function() game.log("on_block.fct resolved!") end
	local shield = {
		on_block = {fct = on_block_function}
	}
	-- Abandon thread! I see the problem, now. The entity.check function will search for "on_block.fct" as a table key, which it isn't.
end

function safeCheck()
	if type(game.player[bullshitProperty]) == "function" then
		game.log("This should seriously never work")
	else
		game.log("missing property type check evaluated to: "..type(game.player[bullshitProperty]))
	end
	game.log("Haven't crashed yet! Next safe check...")
	-- game.log("Missing property call is: "..game.player[bullshitProperty]) -- LUA error: attempt to concat nil value. Above works because type() returns string "nil"
	if game.player[bullshitProperty] == nil then
		game.log("nil value == nil")
	else
		game.log("nil value ~= nil")
	end
end
