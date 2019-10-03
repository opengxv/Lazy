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
	"SHIFT-CTRL-F1",					-- 121
	"SHIFT-CTRL-F2",					-- 122
	"SHIFT-CTRL-F3",					-- 123
	"SHIFT-CTRL-F5",					-- 125
	"SHIFT-CTRL-F6",					-- 126
	"SHIFT-CTRL-F7",					-- 127
	"SHIFT-CTRL-F8",					-- 128
	"SHIFT-CTRL-F9",					-- 129
	"SHIFT-CTRL-F10",					-- 130
	"SHIFT-CTRL-F11",					-- 131
	"SHIFT-CTRL-F12",					-- 132
	"SHIFT-ALT-F1",						-- 121
	"SHIFT-ALT-F2",						-- 122
	"SHIFT-ALT-F3",						-- 123
	"SHIFT-ALT-F5",						-- 125
	"SHIFT-ALT-F6",						-- 126
	"SHIFT-ALT-F7",						-- 127
	"SHIFT-ALT-F8",						-- 128
	"SHIFT-ALT-F9",						-- 129
	"SHIFT-ALT-F10",					-- 130
	"SHIFT-ALT-F11",					-- 131
	"SHIFT-ALT-F12",					-- 132
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

local SetBinding = _G.SetBinding
local SetBindingClick = _G.SetBindingClick

local function LazyMarker_PreClick(self, button)
	if Lazy.markerCurrentButton and self == Lazy.markerCurrentButton then
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
				else
					button:SetAttribute("type", "spell")
					button:SetAttribute("spell", name)
					button:SetAttribute("unit", k)
				end
				if preclick then
					button:SetScript("PreClick", LazyMarker_PreClick)
				end
				SetBinding(key)
				SetBindingClick(key, bname, 1);
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
end

function Lazy:Rebinding()
	for k, v in pairs(self.actions) do
		SetBinding(v.key)
		SetBindingClick(v.key, v.button)
	end
end

function Lazy:Start(func)
	if self.callback then
		return
	end
	self.callback = func

	if self.player.OnStart then
		self.player:OnStart();
	end
end 

function Lazy:Stop()
	if not self.callback then
		return
	end
    self.callback = nil
	if self.player.OnStop then
		self.player:OnStop();
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

	if self.markerCurrentButton then
		if prefix == self.markerCurrentTarget and self.now - self.markerCurrentButtonTime < 0.5 then
			return true
		end
	end

	Lazy.markerSeq = Lazy.markerSeq + 1;
	self.markerCurrentButton = s.button
	self.markerCurrentButtonTime = self.now;
	self.markerCurrentTarget = prefix;
	self.markerCurrentSeq = Lazy.markerSeq;

	if not uname then
		uname = UnitName(prefix)
		if not uname then
			return
		end
	end

	if not self.markerQueue[self.markerTail] then
		self.markerQueue[self.markerTail] = {}
	end
	self.markerQueue[self.markerTail].text = spell.name .. "=>" .. uname
	self.markerQueue[self.markerTail].clicked = false
	self.markerQueue[self.markerTail].markTime = self.now
	self.buttons[s.button] = self.markerQueue[self.markerTail]

	self.markerTail = self:MarkerQueueInc(self.markerTail)
	if self.markerTail == self.markerHead then
		self.markerHead = self:MarkerQueueInc(self.markerHead)
	end
	self:MarkerFillContent()
	self:mark0(s.index)
	self.gcd_time = self.now + 0.5
	return true
end

function Lazy:CMark(target, spell, time)
	if not time then
		time = 0
	end

	if target:IsHarm() then
		if target:GetDebuff(spell) <= time then
			if Lazy:Mark(target, spell, true) then
				return true
			end
		end
	else
		if target:GetBuff(spell) <= time then
			if Lazy:Mark(target, spell, true) then
				return true
			end
		end
	end
end

function Lazy:START_AUTOREPEAT_SPELL()
end 

function Lazy:PLAYER_REGEN_DISABLED()
	self.combating = true;
end

function Lazy:PLAYER_REGEN_ENABLED()
	self.combating = false;
    Lazy:Stop()
end

function Lazy:PLAYER_TARGET_CHANGED()
    Lazy:Stop()
end

function Lazy:UNIT_SPELLCAST_CHANNEL_START(self, unit, spellName, spellRank, spellCastIndex)
    if (unit ~= 'player') then return end
end

function Lazy:UNIT_SPELLCAST_CHANNEL_STOP(self, unit, spellName, spellRank, spellCastIndex)
    if (unit ~= 'player') then return end
end

function Lazy:UNIT_SPELLCAST_SENT(event, unit, spell, rank, target)
	if (unit ~= 'player') then return end
	self.gcd_time = GetTime() + 1
	-- lazy_debug("UNIT_SPELLCAST_SENT")
end

function Lazy:UNIT_SPELLCAST_START(event, unit)
	if (unit ~= 'player') then return end
	-- lazy_debug("UNIT_SPELLCAST_START")
end

function Lazy:UNIT_SPELLCAST_SUCCEEDED(event, unit)
	if (unit ~= 'player') then return end
	-- lazy_debug("UNIT_SPELLCAST_SUCCEEDED")
end

function Lazy:UNIT_SPELLCAST_STOP(event, unit)
	if unit ~="player" then return end
	-- lazy_debug("UNIT_SPELLCAST_STOP")
end

function Lazy:UNIT_SPELLCAST_FAILED(event, unit)
	if unit ~= "player" then return end
	-- lazy_debug("UNIT_SPELLCAST_FAILED")
end

function Lazy:UNIT_SPELLCAST_DELAYED(event, unit)
    if unit ~= "player" then return end
end

function Lazy:UNIT_SPELLCAST_INTERRUPTED(event, unit)
    if unit ~= 'player' then return end
end

function Lazy:CreateTimer()
	if not self.player then
		return
	end

	self:HookScript(self.markerFrame, "OnUpdate", "OnUpdate")
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

	self.spells = {}
	self.targets = {
		player = self.player,
		target = LazyUnit:new("target"),
		mouseover = LazyUnit:new("mouseover"),
	};
	self.target = self.targets["target"];
	self.mouseover = self.targets["mouseover"];

	self.gcd_time = 0

	self.player:OnInitialize()
end

function Lazy:CreatePlayer(class)
	if select(2, UnitClass("player")) == class then
		self.player = LazyUnit:new("player")
		return self.player
	end
end

function Lazy:OnUpdate()
	self:Update()
end

function Lazy:Update(func)
	self.now = GetTime();
	self.player.now = self.now

	if self.callback or func then
		if self.now < self.gcd_time then
			return
		end
		local spell, displayName, icon, startTime, endTime, isTradeSkill, castID, notInterruptible = CastingInfo("player")
		if spell then 
			return
		end

		for k, v in pairs(self.targets) do
			v:UpdateAura()
		end

		if func then
			func()
		elseif self.callback then
		    if self.callback() then
				Lazy:Stop();
			end
		end
	end
end
