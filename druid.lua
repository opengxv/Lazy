local L = LibStub("AceLocale-3.0"):GetLocale("Lazy")
local GetSpellCooldown  = _G.GetSpellCooldown;
local UnitPower = _G.UnitPower
local GetComboPoints = _G.GetComboPoints
local UnitDebuff = _G.UnitDebuff
local UnitAura = _G.UnitAura
local GetTalentInfo = _G.GetTalentInfo

local auto
local currentTime
local lastTime = 0
local power
local GCDIndex
local spellIndex = 0
local spellCount = 0
local spellQueue = {}
local stance = nil

local GCD = 1

if select(2, UnitClass("player")) == "DRUID" then
    LazyDruid = Lazy:NewModule(L["德鲁伊"], "AceTimer-3.0", "AceEvent-3.0" )
else
    return
end

LazyDruid.defaults = {
    autoJH = true,
    autoInterrupt = true,
};

LazyDruid.options = {
    AutoJH = {
        type = "toggle",
        name = L["自动激活"],
        get = function() return LazyDruid.db.autoJH end,
        set = function(info, val) LazyDruid.db.autoJH = val end,
    },
    AutoInterrupt = {
        type = "toggle",
        name = L["自动打断"],
        get = function() return LazyDruid.db.autoInterrupt end,
        set = function(info, val) LazyDruid.db.autoInterrupt = val end,
    },
};

LazyDruid.attackType = 0
LazyDruid.talent = 0

local actions = {
    ["player"] = {
		["回春术"] = {},
		["治疗之触"] = {},
		["野性印记"] = {},
		["荆棘术"] = {},
    },
    ["mouseover"] = {
		["回春术"] = {},
		["治疗之触"] = {},
		["野性印记"] = {},
		["荆棘术"] = {},
    },
    ["focus"] = {
    },
    ["targettarget"] = {
    },
    ["target"] = {
		["回春术"] = {},
		["治疗之触"] = {},
		["野性印记"] = {},
		["荆棘术"] = {},

        ["月火术"] = {},
        ["愤怒"] = {},
    },
    ["other"] = {
        ['攻击'] = {
            text = '/stopautorun\n/script LazyDruid.attackType = 1\n/script LazyDruid:Attack("target")',
            key = "E",
        }, 
        ['停止'] = {
            text = '/stopattack\n/stopcasting\n/script Lazy:StopCheck()',
            key = 'z',
        },
        ["治疗他人"] = {
            text = '/script LazyDruid:Heal(Lazy.targets["mouseover"])',
            key = "MOUSEWHEELDOWN",
        },
        ["自我治疗"] = {
            text = '/script LazyDruid:Heal(Lazy.player)',
            key = "MOUSEWHEELUP",
        },
    },
}

function LazyDruid:OnEnable()
    Lazy:MarkerRegisterActions(actions)
    Lazy.Mod = self

    Lazy:debug("LazyDruid:OnEnable")
end

function LazyDruid:OnDisable()
    self:CancelAllTimers()
    Lazy:debug("LazyDruid:OnDisable")
end

function LazyDruid:DoCheck(target)
    self:AttackLoop(target)
end

function LazyDruid:Heal(target)
	if target:IsHarm() then
		return
	end
	Lazy:StopCheck()
	target:UpdateAura();

	if not Lazy.combating then
		if target:GetBuff("野性印记") == 0 then
			if Lazy:Mark(target, "野性印记", true) then
				return
			end
		end
		if target:GetBuff("荆棘术") == 0 then
			if Lazy:Mark(target, "荆棘术", true) then
				return
			end
		end
	end

	if target:GetBuff("回春术") == 0 then
		if Lazy:Mark(target, "回春术", true) then
			return
		end
	end

	Lazy:Mark(target, "治疗之触", true)
end

function LazyDruid:Attack(target)
	target = "target";
	Lazy:StartCheck();
end

function LazyDruid:AttackLoop(target)
	if target:GetDebuff("月火术") < 1 then
		if Lazy:Mark(target, "月火术", true) then
			return;
		end
	end

	Lazy:Mark(target, "愤怒", true)
end

