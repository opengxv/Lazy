local keys = {
	"CTRL-1",							-- 1
	"CTRL-2",							-- 2
	"CTRL-3",							-- 3
	"CTRL-4",							-- 4
	"CTRL-5",							-- 5
	"CTRL-6",							-- 6
	"CTRL-7",							-- 7
	"CTRL-8",							-- 8
	"CTRL-9",							-- 9
	"CTRL-0",							-- 10
	"ALT-1",							-- 19
	"ALT-2",							-- 20
	"ALT-3",							-- 21
	"ALT-4",							-- 22
	"ALT-5",							-- 23
	"ALT-6",							-- 24
	"ALT-7",							-- 25
	"ALT-8",							-- 26
	"ALT-9",							-- 27
	"ALT-0",							-- 28
	"ALT-F1",							-- 79
	"ALT-F2",							-- 80
	"ALT-F3",							-- 81
	"ALT-F5",							-- 83
	"ALT-F6",							-- 84
	"ALT-F7",							-- 85
	"ALT-F8",							-- 86
	"ALT-F9",							-- 87
	"ALT-F10",							-- 88
	"ALT-F11",							-- 89
	"ALT-F12",							-- 90
	"CTRL-F1",							-- 91
	"CTRL-F2",							-- 92
	"CTRL-F3",							-- 93
	"CTRL-F4",							-- 94
	"CTRL-F5",							-- 95
	"CTRL-F6",							-- 96
	"CTRL-F7",							-- 97
	"CTRL-F8",							-- 98
	"CTRL-F9",							-- 99
	"CTRL-F10",							-- 100
	"CTRL-F11",							-- 101
	"CTRL-F12",							-- 102
	"ALT-CTRL-1",						-- 103
	"ALT-CTRL-2",						-- 104
	"ALT-CTRL-3",						-- 105
	"ALT-CTRL-4",						-- 106
	"ALT-CTRL-5",						-- 107
	"ALT-CTRL-6",						-- 108
	"ALT-CTRL-7",						-- 109
	"ALT-CTRL-8",						-- 110
	"ALT-CTRL-9",						-- 111
	"ALT-CTRL-0",						-- 112
	"ALT-CTRL-F1",						-- 121
	"ALT-CTRL-F2",						-- 122
	"ALT-CTRL-F3",						-- 123
	"ALT-CTRL-F5",						-- 125
	"ALT-CTRL-F6",						-- 126
	"ALT-CTRL-F7",						-- 127
	"ALT-CTRL-F8",						-- 128
	"ALT-CTRL-F9",						-- 129
	"ALT-CTRL-F10",						-- 130
	"ALT-CTRL-F11",						-- 131
	"ALT-CTRL-F12",						-- 132
	"SHIFT-CTRL-F1",						-- 121
	"SHIFT-CTRL-F2",						-- 122
	"SHIFT-CTRL-F3",						-- 123
	"SHIFT-CTRL-F5",						-- 125
	"SHIFT-CTRL-F6",						-- 126
	"SHIFT-CTRL-F7",						-- 127
	"SHIFT-CTRL-F8",						-- 128
	"SHIFT-CTRL-F9",						-- 129
	"SHIFT-CTRL-F10",						-- 130
	"SHIFT-CTRL-F11",						-- 131
	"SHIFT-CTRL-F12",						-- 132
	"SHIFT-ALT-F1",						-- 121
	"SHIFT-ALT-F2",						-- 122
	"SHIFT-ALT-F3",						-- 123
	"SHIFT-ALT-F5",						-- 125
	"SHIFT-ALT-F6",						-- 126
	"SHIFT-ALT-F7",						-- 127
	"SHIFT-ALT-F8",						-- 128
	"SHIFT-ALT-F9",						-- 129
	"SHIFT-ALT-F10",						-- 130
	"SHIFT-ALT-F11",						-- 131
	"SHIFT-ALT-F12",						-- 132
	"SHIFT-CTRL-1",						-- 103
	"SHIFT-CTRL-2",						-- 104
	"SHIFT-CTRL-3",						-- 105
	"SHIFT-CTRL-4",						-- 106
	"SHIFT-CTRL-5",						-- 107
	"SHIFT-CTRL-6",						-- 108
	"SHIFT-CTRL-7",						-- 109
	"SHIFT-CTRL-8",						-- 110
	"SHIFT-CTRL-9",						-- 111
	"SHIFT-CTRL-0",						-- 112
}

local L = LibStub("AceLocale-3.0"):GetLocale("Lazy")
local seq = 0
local mount_button
local auto_fish = false

Lazy.options.args.ShowMarkerWindow = {
		type = "toggle",
		name = L["显示Marker窗口"],
		get = function() return Lazy.db.profile.showMarkerWindow end,
		set = function(info, val) 
			Lazy.db.profile.showMarkerWindow = val 
			if not Lazy.markerFrame then
				return
			end
			
			if val then
				Lazy:MarkerFillContent()
				Lazy.markerFrame:Show()
			else
				Lazy.markerFrame:Hide()
			end
		end,
}

Lazy.defaults.profile.showMarkerWindow = true
local nop_key_index = 1
local nop_time = GetTime()
Lazy.casting_spell = nil

function Lazy:UpdateMarkerFramePos(x, y)
	Lazy.db.profile.options.x = x
	Lazy.db.profile.options.y = y

	if not self.markerFrame then
		return
	end

	self.markerFrame:ClearAllPoints() 
	if Lazy.db.profile.options.x and Lazy.db.profile.options.y then
		self.markerFrame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", Lazy.db.profile.options.x, Lazy.db.profile.options.y)
	else
		self.markerFrame:SetPoint("CENTER", UIParent, "CENTER")
	end
end

function Lazy:CreateWatchFrame()
	if self.watchFrame then
		return
	end

	local media = LibStub("LibSharedMedia-3.0")
	local bgFrame = {
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4}
	}
	bgFrame.bgFile = media:Fetch("background", "Solid")
	--bgFrame.edgeFile = media:Fetch("border", "Blizzard Tooltip")

	-- Frame
	self.watchFrame = CreateFrame("Frame", "LazyWatchFrame", UIParent)
	self.watchFrame:SetResizable(true)
	self.watchFrame:SetMinResize(90, 120)
	self.watchFrame:SetMovable(true)
	self.watchFrame:SetWidth(80)
	self.watchFrame:SetHeight(21)
	self.watchFrame:SetScript("OnSizeChanged", nil)
	self.watchFrame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 50)

	self.watchFrame:SetAlpha(1)
	self.watchFrame:SetBackdrop(bgFrame)
	self.watchFrame:SetBackdropColor(0, 0, 0, 1)
	self.watchFrame:SetBackdropBorderColor(0.15, 0.3, 0.65, 1)

	self.watchTitleText = self.watchFrame:CreateFontString(nil, nil, "NumberFontNormalSmall")
	self.watchTitleText:SetFont(media:Fetch("font", "NumberFontNormalSmall"), 10, "OUTLINE");
	self.watchTitleText:SetTextColor(255, 255, 255, 255);
	self.watchTitleText:SetSpacing(5);
	self.watchTitleText:SetPoint("TOPLEFT", self.watchFrame, "TOPLEFT", 8, -5)
	self.watchTitleText:SetText("40320541000")

	self.watchFrame:Show()
end

function Lazy:CreateMarkerFrame()
	Lazy:CreateWatchFrame();

	if self.markerFrame then
		return
	end

	local media = LibStub("LibSharedMedia-3.0")
	local bgFrame = {
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4}
	}
	bgFrame.bgFile = media:Fetch("background", "Blizzard Tooltip")
	bgFrame.edgeFile = media:Fetch("border", "Blizzard Tooltip")

	-- Frame
	self.markerFrame = CreateFrame("Frame", "LazyMarkerFrame", UIParent)
	self.markerFrame:SetResizable(true)
	self.markerFrame:SetMinResize(90, 120)
	self.markerFrame:SetMovable(true)
	self.markerFrame:SetWidth(225)
	self.markerFrame:SetHeight(130)
	self.markerFrame:SetScript("OnSizeChanged", nil)
	self:UpdateMarkerFramePos(Lazy.db.profile.options.x, Lazy.db.profile.options.y)

	-- Title
	self.markerTitle = CreateFrame("Frame", "LazyMarkerTitle", self.markerFrame)
	self.markerTitle:SetPoint("TOPLEFT", self.markerFrame, "TOPLEFT")
	self.markerTitle:SetPoint("TOPRIGHT", self.markerFrame, "TOPRIGHT")
	self.markerTitle:SetHeight(25)
	self.markerTitle:EnableMouse(true)
	
	self.markerTitleText = self.markerTitle:CreateFontString(nil, nil, "GameFontNormal")
	self.markerTitleText:SetPoint("LEFT", self.markerTitle, "LEFT", 10, 0)
	self.markerTitleText:SetText("LazyMarker")

	self.markerTitleText:SetJustifyH("LEFT")
	self.markerTitleText:SetTextColor(1, 1, 0, 0.95)

	self.markerTitle:SetScript("OnMouseDown", function() 
		Lazy.markerFrame:StartMoving()
	end)
	
	self.markerTitle:SetScript("OnMouseUp", function()
		Lazy.markerFrame:StopMovingOrSizing();		
		Lazy.db.profile.options.x = Lazy.markerFrame:GetLeft()
		Lazy.db.profile.options.y = Lazy.markerFrame:GetBottom()
	end)
	
	self.markerTitle:SetAlpha(1)
	self.markerTitle:SetBackdrop(bgFrame)
	self.markerTitle:SetBackdropColor(0, 0, 0, 1)
	self.markerTitle:SetBackdropBorderColor(0.15, 0.3, 0.65, 1)

	-- ScrollFrame
	self.markerScrollFrame = CreateFrame("ScrollFrame", "LazyMarkerScrollFrame", self.markerFrame, "UIPanelScrollFrameTemplate")
	
	-- Message	
	self.markerMessage = CreateFrame("Frame", "LazyMarkerMessage", self.markerFrame)
	self.markerMessage:SetResizable(true)
	self.markerMessage:EnableMouse(true)
	self.markerMessage:SetPoint("TOPLEFT", self.markerTitle, "BOTTOMLEFT")
	self.markerMessage:SetPoint("TOPRIGHT", self.markerTitle, "BOTTOMRIGHT")
	self.markerMessage:SetPoint("BOTTOMLEFT", self.markerFrame, "BOTTOMLEFT")
	self.markerMessage:SetPoint("BOTTOMRIGHT", self.markerFrame, "BOTTOMRIGHT")

	self.markerMessage:SetAlpha(1)
	self.markerMessage:SetBackdrop(bgFrame)
	self.markerMessage:SetBackdropColor(0, 0, 0, 1)
	self.markerMessage:SetBackdropBorderColor(0.15, 0.3, 0.65, 1)
	
	-- Labels
	local i
	self.markerLabels = {}
	for i = 1, 5 do
		local label = self.markerMessage:CreateFontString(nil, nil, "GameFontNormal")
		self.markerLabels[i] = label
		if i == 1 then
			label:SetPoint("TOPLEFT", self.markerMessage, "TOPLEFT", 10, -5)
		else
			label:SetPoint("TOP", self.markerLabels[i - 1], "BOTTOM", 0, -5)
			label:SetPoint("LEFT", self.markerMessage, 10, 0);
		end
		label:SetJustifyH("LEFT")
	end

	self.markerQueue = {}
	self.markerHead = 1
	self.markerTail = 1
	self.markerLength = 7

	if self.db.profile.showMarkerWindow then
		self:MarkerFillContent()
		Lazy.markerFrame:Show()
	else
		Lazy.markerFrame:Hide()
	end

  self:ScheduleTimer("MarkerTimer", 1);
  self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
  self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
  self:RegisterEvent("UNIT_SPELLCAST_START")
  self:RegisterEvent("UNIT_SPELLCAST_STOP")
  self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
  self:RegisterEvent("UNIT_SPELLCAST_FAILED")
  self:RegisterEvent("UNIT_SPELLCAST_DELAYED")
  self:RegisterEvent("UNIT_SPELLCAST_SENT")
  self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
  self:RegisterEvent("PLAYER_REGEN_ENABLED")
  self:RegisterEvent("PLAYER_REGEN_DISABLED")
  self:RegisterEvent("PLAYER_TARGET_CHANGED")
  self:RegisterEvent("START_AUTOREPEAT_SPELL")
  
  self:InitCheck();
end

function Lazy:MarkerQueueInc(index)
	if index < self.markerLength then
		return index + 1
	else
		return 1
	end
end

function Lazy:MarkerFillContent()
	if not Lazy.db.profile.showMarkerWindow then
		return
	end
	
	local index = self.markerTail
	local i
	for i = 1, 5 do
		
		local label = self.markerLabels[i]
		
		if index == self.markerHead then
			label:SetText("")
		else
			index = index - 1
			if index < 1 then
				index = self.markerLength
			end
			local item = self.markerQueue[index]
			if item.clicked then
				label:SetText(item.text .. ' ' .. (item.clickTime - item.markTime))
				label:SetTextColor(0, 1, 0, 1)
			else
				label:SetText(item.text)
				label:SetTextColor(1, 1, 0, 1)
			end
		end
	end
end

local function LazyMarker_PreClick(self, button)
	if Lazy.markerCurrentSeq == seq then
		--___lazy_mark_reset__()
	end

	if ___lazy_marker___ and Lazy.markerCurrentButton and self == Lazy.markerCurrentButton then
		Lazy.markerCurrentButton = nil;
	end
	local item = Lazy.buttons[self]
	if item then
		if not item.clicked then
			item.clicked = true
			item.clickTime = GetTime()
            Lazy:MarkerFillContent()
		end
		Lazy.buttons[self] = nil
	end
end

function Lazy:nop()
end

function Lazy:MarkerRegisterActions(actions)
	if self.boundKeys then
		for k, v in pairs(self.boundKeys) do
			SetBinding(k)
		end
	end

	self.boundKeys = {}
	self.actions = {}
	self.buttons = {}
	SetBinding("A", "STRAFELEFT");
	SetBinding("D", "STRAFERIGHT");
	SetBinding("ALT-R", "REPLY");
	SetBinding("UP", "CAMERAZOOMIN");
	SetBinding("DOWN", "CAMERAZOOMOUT");

	local kindex = 1
	local kname = 1
	local text, enabled, check, key, index, button

    for k, v in pairs(actions) do
		local name, param
		for name, param in pairs(v) do
			if param then
				text = param.text
				key = param.key
				enabled = param.enabled
				check = param.check
				key = param.key
			end
			
			if enabled == nil then
				enabled = true
			elseif type(enabled) == "function" then
				enabled = enabled()
			end

			local preclick
			if enabled then
				--if not text then
				--	text = string.format("/CAST [target=%s] %s", k, name)
				--end
				if not key then
					key = keys[kindex]
					index = kindex
					kindex = kindex + 1
					preclick = true
				else
					index = 0
				end
				
				local aname = k .. name
				local bname = "LazyActionButton_" .. kname
				kname = kname + 1
				button = _G.CreateFrame("Button", bname, _G.UIParent, "SecureActionButtonTemplate")
				button:Hide()
				if text then
					button:SetAttribute("type", "macro")
					button:SetAttribute("macrotext", text)
					--Lazy:debug("bind[" .. k .. "]: " .. text .. " to " .. key)
				else
					button:SetAttribute("type", "spell")
					button:SetAttribute("spell", name)
					button:SetAttribute("unit", k)
					--Lazy:debug("bind[" .. k .. "]: " .. name .. " to " .. key)
				end
				if preclick then
					button:SetScript("PreClick", LazyMarker_PreClick)
				end
				SetBinding(key)
				SetBindingClick(key, bname);
				self.actions[aname] = {}
				self.actions[aname].button = button
				self.actions[aname].index = index
				self.actions[aname].check = check
				self.actions[aname].key = key
				self.boundKeys[key] = true
				self.buttons[button] = nil
			end
		end
	end

	button = CreateFrame("Button", "LazyActionButton__nop", UIParent, "SecureActionButtonTemplate")
	button:Hide()
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", "/script Lazy:nop()")
	nop_key_index = kindex
	key = keys[kindex]
	SetBinding(key)
	SetBindingClick(key, "LazyActionButton__nop");

	if not mount_button then
		mount_button = CreateFrame("Button", "LazyActionButton__mount", UIParent, "SecureActionButtonTemplate")
		mount_button:Hide()
	end

	Lazy:UpdateMount()
end


function Lazy:InitCheck()
	self.spells = {}
	self.targets = {
		player = LazyUnit:new("player"),
		target = LazyUnit:new("target"),
		mouseover = LazyUnit:new("mouseover"),
	};
	self.player = self.targets["player"];
	self.target = self.targets["target"];
	self.mouseover = self.targets["mouseover"];
end

function Lazy:StartCheck()
	if self.Checked then
		return
	end
	self.Checked = true

	if Lazy.Mod.StartCheck then
		Lazy.Mod:StartCheck();
	end
end 

function Lazy:StopCheck()
	if not self.Checked then
		return
	end
    Lazy.Checked = false
	if Lazy.Mod.StopCheck then
		Lazy.Mod:StopCheck();
	end
end 

function Lazy:Stop()
	return self:StopCheck()
end

function Lazy:DoCheck()
	Lazy.now = GetTime();

	local spell, displayName, icon, startTime, endTime, isTradeSkill, castID, notInterruptible = CastingInfo("player")
	if spell then 
		return
	end

	if (self.casting) then
		if (Lazy.now > self.endTime) then
			self.casting = nil;
            return;
        end
		return;
	end 

	if self.Checked then
		local target = self.targets["target"];
		if not target:IsHarm() then
			Lazy:StopCheck();
			return;
		end
		target:UpdateAura();

		if self.Mod.DoCheck then
		    if self.Mod:DoCheck(target) then
				Lazy:StopCheck();
			end
		end
	end
end 


function Lazy:GetSpell(spellName) 
	local spell = self.spells[spellName];
	if not spell then
		spell = LazySpell:new(spellName);
		self.spells[spellName] = spell;
	end
	return spell;
end

--
function Lazy:Mark(target, spell, check, uname)
	local prefix = target.name;
	local s = self.actions[prefix .. spell]
	if not s then
		return false
	end

	spell = self:GetSpell(spell);
	if not spell then
		return false;
	end

	if check then
		if s.check == nil then
			if not self.player:Castable(spell, target) then
				return false;
			end
		else
			if not s.check() then
				return false
			end
		end
	end
	
	local t = GetTime()
	if self.markerCurrentButton then
		if prefix == self.markerCurrentTarget and t - self.markerCurrentButtonTime < 0.5 then
			return true
		end
	end
	
	seq = seq + 1;
	self.markerCurrentButton = s.button
	self.markerCurrentButtonTime = t;
	self.markerCurrentTarget = prefix;
	self.markerCurrentSeq = seq;

    if self.db.profile.showMarkerWindow then
        if not uname then
            uname = UnitName(prefix)
            if not uname then
                return false
            end
        end

        if not self.markerQueue[self.markerTail] then
	    	self.markerQueue[self.markerTail] = {}
	    end
	    self.markerQueue[self.markerTail].text = spell.name .. "=>" .. uname
	    self.markerQueue[self.markerTail].clicked = false
		self.markerQueue[self.markerTail].markTime = t
	    self.buttons[s.button] = self.markerQueue[self.markerTail]
	
	    self.markerTail = self:MarkerQueueInc(self.markerTail)
	    if self.markerTail == self.markerHead then
		    self.markerHead = self:MarkerQueueInc(self.markerHead)
	    end
		self:MarkerFillContent()
	end

	nop_time = GetTime()
	Lazy:mark0(s.index)
	return true
end

function Lazy:UpdateMount()
	if not mount_button then
		return
	end

	local s
	if Lazy.db.profile.options.landMount == "" then
		Lazy.db.profile.options.landMount = nil
	end

	if Lazy.db.profile.options.flyMount == "" then
		Lazy.db.profile.options.flyMount = nil
	end

	if not Lazy.db.profile.options.landMount and not Lazy.db.profile.options.flyMount then
		s = ""
	elseif not Lazy.db.profile.options.landMount then
		s = string.format("/use [flyable,nocombat] %s", Lazy.db.profile.options.flyMount)
	elseif not Lazy.db.profile.options.flyMount then
		s = string.format("/use [outdoors,nocombat] %s", Lazy.db.profile.options.landMount)
	else
		s = string.format("/use [flyable,nocombat] %s; [outdoors,nocombat] %s", Lazy.db.profile.options.flyMount, Lazy.db.profile.options.landMount)
	end

	mount_button:SetAttribute("type", "macro")
	mount_button:SetAttribute("macrotext", s)
    SetBinding("F5")
    SetBindingClick("F5", "LazyActionButton__mount");
end

function Lazy:START_AUTOREPEAT_SPELL()
	Lazy:debug("START_AUTOREPEAT_SPELL")
end 

function Lazy:PLAYER_REGEN_DISABLED()
    --Lazy:debug("leave combat")
	self.combating = true;
end

function Lazy:PLAYER_REGEN_ENABLED()
    --Lazy:debug("leave combat")
	self.combating = false;
    Lazy:StopCheck()
end

function Lazy:PLAYER_TARGET_CHANGED()
    --Lazy:debug("target changed")
    Lazy:StopCheck()
end

function Lazy:UNIT_SPELLCAST_CHANNEL_START(self, unit, spellName, spellRank, spellCastIndex)
	--Lazy:debug("UNIT_SPELLCAST_CHANNEL_START")
    if (unit ~= 'player') then return end
    auto_fish = false
end

function Lazy:UNIT_SPELLCAST_CHANNEL_STOP(self, unit, spellName, spellRank, spellCastIndex)
	--Lazy:debug("UNIT_SPELLCAST_CHANNEL_START")
    if (unit ~= 'player') then return end
    if (spellName ~= L["钓鱼"]) then return end
    auto_fish = true
end

function Lazy:UNIT_SPELLCAST_SENT(event, unit, spell, rank, target)
    if (unit ~= 'player') then return end
	--Lazy:debug("UNIT_SPELLCAST_SENT ")
	self.sendTime = GetTime()
	self.endTime = self.sendTime + 1
	self.casting = true
end

function Lazy:UNIT_SPELLCAST_START(event, unit)
    if (unit ~= 'player') then return end
	--Lazy:debug("UNIT_SPELLCAST_START")
    local spellName, _, _,startTime, endTime = CastingInfo(unit);
    self.startTime = startTime / 1000;
    self.endTime = endTime / 1000;
    self.casting = true;
    self.spellName = spellName;

    if not self.sendTime then return end
end

function Lazy:UNIT_SPELLCAST_SUCCEEDED(event, unit)
    if (unit ~= 'player') then return end
	--Lazy:debug("UNIT_SPELLCAST_SUCCEEDED ")
end

function Lazy:UNIT_SPELLCAST_STOP(event, unit)
	if unit ~="player" then return end
	--Lazy:debug("UNIT_SPELLCAST_STOP")
	if self.casting then
		self.targetName = nil;
		self.casting = nil;
	end
end

function Lazy:UNIT_SPELLCAST_FAILED(event, unit)
    if unit ~= "player" then return end
	--Lazy:debug("UNIT_SPELLCAST_FAILED")
    self.targetName = nil;
    self.casting = nil;
end

function Lazy:UNIT_SPELLCAST_DELAYED(event, unit)
    if unit ~= "player" then return end
	--Lazy:debug("UNIT_SPELLCAST_DELAYED")
    local oldStart = self.startTime;
    local spellName,_,text,startTime,endTime = CastingInfo(unit);
    if not startTime then self.delay = 0 return end

    startTime = startTime/1000;
    endTime = endTime/1000;
    self.startTime = startTime;
    self.endTime = endTime;
    self.spellName = spellName;
end

function Lazy:UNIT_SPELLCAST_INTERRUPTED(event, unit)
    if unit ~= 'player' then return end
	--Lazy:debug("UNIT_SPELLCAST_INTERRUPTED")
    self.targetName = nil;
    self.casting = nil;
    self.channeling = nil;
    self.fadeOut = true;
end

function Lazy:DoFish()
	auto_fish = false
	if not IsShiftKeyDown() then
	   	Lazy:Mark("player", L["钓鱼"], false)
	end
end

function Lazy:MarkerTimer()
	local t = GetTime()

	if auto_fish then
		Lazy:DoFish()
	end

	if t - 	nop_time > 120 then
		--Lazy:mark(nop_key_index)
		nop_time = t
	end

	Lazy:DoCheck();
	self:ScheduleTimer("MarkerTimer", 0.2);
end

