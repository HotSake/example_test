local Dialog = require "engine.ui.Dialog"
local Talents = require "engine.interface.ActorTalents"
local SurfaceZone = require "engine.ui.SurfaceZone"
local Stats = require "engine.interface.ActorStats"
local TextzoneList = require "engine.ui.TextzoneList"
local Textzone = require "engine.ui.Textzone"
local Button = require "engine.ui.Button"
local ImageList = require "engine.ui.ImageList"
local Player = require "mod.class.Player"
local UI = require "engine.ui.Base"
local List = require "engine.ui.List"


module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
self.player = actor
Dialog.init(self, "Feats", math.max(900, game.w*0.8), game.h*0.6)
self:generateLists()

self.c_points = Textzone.new{width=self.iw, height = 30, text = "Available feat points: "..self.player.feat_point}	
self.c_learned = List.new{width=250, nb_items=#self.list_learned, height = self.ih*0.8, list=self.list_learned, fct=function(item) self:use(item) end, select=function(item,sel) self:on_select(item,sel) end, scrollbar=true}
self.c_avail = List.new{width=250, nb_items=#self.list_avail, height = self.ih*0.8, list=self.list_avail, fct=function(item) self:use(item) end, select=function(item,sel) self:on_select(item,sel) end, scrollbar=true}
self.c_barred = List.new{width=250, nb_items=#self.list_barred, height = self.ih*0.8, list=self.list_barred, fct=function(item) self:use(item) end, select=function(item,sel) self:on_select(item,sel) end, scrollbar=true}
self.c_desc = TextzoneList.new{width=self.iw/4-20, height = 400, text="Hello from description"}

self.c_bonus = Button.new{text="Bonus feats", fct=function() self:onBonus() end}

self:loadUI{
{left=0, top=0, ui = self.c_points},
{left=0, top=40, ui = self.c_bonus},
{left=0, top=90, ui=self.c_learned},
{left=250, top=90, ui=self.c_avail},
{left=500, top=90, ui=self.c_barred},
{left=750, top=0, ui=self.c_desc}
}
self:setFocus(self.c_avail)
-- self:setupUI(false, true)
self:setupUI()


self.key:addBind("EXIT", function() game:unregisterDialog(self) end)
self:on_select(self.list_avail[1])
end

function _M:use(item)
if self.player.feat_point > 0 then
local t = item.talent
local tid = item.talent.id
--Have we already learned it?
if self.player:getTalentLevelRaw(tid) >= t.points then
return nil
end

-- Alright, lets learn it if we can
local learned = self.player:learnTalent(item.talent.id) --returns false if not learned due to requirements
if learned then
self.player.feat_point = self.player.feat_point - 1
self:update()
end
end
end

function _M:on_select(item,sel)
if self.c_desc then self.c_desc:switchItem(item, item.desc) end
self.selection = sel	
end

function _M:update()
local sel = self.selection
-- game.log(""..self.selection)
self:generateLists() -- Slow! Should just update the one changed and sort again
self.c_points.text = "Available feat points: "..self.player.feat_point
self.c_points:generate()
self.c_learned.list = self.list_learned
self.c_avail.list = self.list_avail
self.c_barred.list = self.list_barred
self.c_learned:generate()
self.c_avail:generate()
self.c_barred:generate()
-- if sel then self.c_list:select(sel) end
end

function _M:generateLists()
self:generateLearned()
self:generateAvail()
self:generateBarred()
end


function _M:generateLearned()
local player = game.player
    local list = {}
    for tid, _ in pairs(player.talents_def) do
local t = player:getTalentFromId(tid)
        if t.is_feat and player:knowTalent(t) then
         --if we haven't learned it, and it is a class feat, dont show it in feat list
         local tt = player:getTalentTypeFrom(t.type[1])
         if not tt.passive or player:knowTalent(t) then
local tid
local color
if player:knowTalent(t) then color = {255,255,255} i = 1
elseif player:canLearnTalent(t) then color = {0,187,187} i = 2
else color = {100, 100, 100} i = 3
end
local d = "#GOLD#"..t.name.."#LAST#\n"
s = player:getTalentReqDesc(t.id):toString()
d = d..s.."\n#WHITE#"
if t.acquired then d = d.."#PINK#"..t.acquired.."#LAST#\n\n" end
d = d..t.info(player,t)
list[#list+1] = {name=t.name, color = color, desc=d, talent=t, i = i}
end
        end
    end
    self.list_learned = list
    --Sort it alphabetically
    table.sort(self.list_learned, function (a,b)
     return a.name < b.name
    end)

end

function _M:generateAvail()
local player = game.player
    local list = {}
    for tid, _ in pairs(player.talents_def) do
local t = player:getTalentFromId(tid)
        if t.is_feat and player:canLearnTalent(t) and not player:knowTalent(t) then
         --if we haven't learned it, and it is a class feat, dont show it in feat list
         local tt = player:getTalentTypeFrom(t.type[1])
         if not tt.passive or player:knowTalent(t) then
local tid
local color
if player:knowTalent(t) then color = {255,255,255} i = 1
elseif player:canLearnTalent(t) then color = {0,187,187} i = 2
else color = {100, 100, 100} i = 3
end
local d = "#GOLD#"..t.name.."#LAST#\n"
s = player:getTalentReqDesc(t.id):toString()
d = d..s.."\n#WHITE#"
if t.acquired then d = d.."#PINK#"..t.acquired.."#LAST#\n\n" end
d = d..t.info(player,t)
list[#list+1] = {name=t.name, color = color, desc=d, talent=t, i = i}
end
        end
    end
    self.list_avail = list
    --Sort it alphabetically
    table.sort(self.list_avail, function (a,b)
     return a.name < b.name
    end)

end

function _M:generateBarred()
local player = game.player
    local list = {}
    for tid, _ in pairs(player.talents_def) do
local t = player:getTalentFromId(tid)
        if t.is_feat and not player:knowTalent(t) and not player:canLearnTalent(t) then
         --if we haven't learned it, and it is a class feat, dont show it in feat list
         local tt = player:getTalentTypeFrom(t.type[1])
         if not tt.passive or player:knowTalent(t) then
local tid
local color
if player:knowTalent(t) then color = {255,255,255} i = 1
elseif player:canLearnTalent(t) then color = {0,187,187} i = 2
else color = {100, 100, 100} i = 3
end
local d = "#GOLD#"..t.name.."#LAST#\n"
s = player:getTalentReqDesc(t.id):toString()
d = d..s.."\n#WHITE#"
if t.acquired then d = d.."#PINK#"..t.acquired.."#LAST#\n\n" end
d = d..t.info(player,t)
list[#list+1] = {name=t.name, color = color, desc=d, talent=t, i = i}
end
        end
    end
    self.list_barred = list
    --Sort it by whetever we have/can/cannot learn it, then alphabetically
    table.sort(self.list_barred, function (a,b)
      return a.name < b.name
    end)

end

function _M:onBonus()
game:unregisterDialog(self)
    game:registerDialog(require("mod.dialogs.BonusFeatDialog").new(game.player))
end