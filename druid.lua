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
        ["愈合"] = {},
        ["猛虎之怒"] = {},
        ["求生本能"] = {},
        ["生命绽放"] = {},
        ['狂暴'] = {},
        ['铁鬃'] = {},
        ["痛击"] = {},
        ["横扫"] = {},
        ['狂暴回复'] = {},
        ["野蛮咆哮"] = {},
        ['野蛮挥砍'] = {},
        },
    ["mouseover"] = {
    },
    ["focus"] = {
    },
    ["targettarget"] = {
    },
    ["target"] = {
        ["月火术"] = {},
        ["愤怒"] = {},
    },
    ["other"] = {
        ['熊形态'] = {
            text = '/cast [nostance:1] 熊形态; [stance:1] 野性冲锋',
            key = 'R',
        },
        ['旅行形态'] = {
            text = "/cast 旅行形态",
            key = 'C',
        },
        ['猎豹形态'] = {
            text = '/cast [nostance:2] 猎豹形态;[nocombat] 潜行',
            key = 'F',
        },
	    ['猎豹冲锋'] = {
            text = string.format('/cast 野性位移'),
            key = 'G',
        },
        ['急奔'] = {
            text = string.format('/cast 急奔'),
            key = 'T',
        },
        ['攻击'] = {
            text = '/startattack [nostealth]\n/cast [stealth] 斜掠\n/script LazyDruid.attackType = 1\n/script LazyDruid:Attack("target")',
            key = "E",
        }, 
        ['AOE'] = {
            text = '/startattack [nostealth]\n/cast [stealth] 斜掠\n/script LazyDruid.attackType = 2\n/script LazyDruid:Attack("target")',
            key = "Q",
        }, 
        ['AOE2'] = {
            text = '/cleartarget\n/targetenemy\n/startattack [nostealth]\n/script LazyDruid.attackType = 3\n/script LazyDruid:Attack("target")',
            key = "V",
        }, 
        ['蛮力猛击'] = {
            text = '/cast 蛮力猛击',
            key = '`',
        },
        ['鼠标月火术'] = {
            text = '/cast [@mouseover,exists,nohelp]月火术',
            key = 'MOUSEWHEELDOWN',
        },
        ['IsBoss'] = {
            text = '/script Lazy:MarkBoss()',
            key = '=',
        },
        ['停止'] = {
            text = '/stopattack\n/stopcasting\n/script Lazy:StopCheck()',
            key = 'z',
        },
    },
}

function LazyDruid:OnEnable()
    Lazy:MarkerRegisterActions(actions)
    Lazy.Mod = self
    self:RegisterEvent("PLAYER_REGEN_DISABLED")

    Lazy:debug("LazyDruid:OnEnable")
end

function LazyDruid:OnDisable()
    self:CancelAllTimers()
    Lazy:debug("LazyDruid:OnDisable")
end

function LazyDruid:PLAYER_REGEN_DISABLED(self)
    GCDIndex = Lazy:GetSpellIndex("横扫")
end

function LazyDruid:DoCheck(target)
    self:AttackLoop(target)
end

function LazyDruid:Attack(target)
	target = "target";
	Lazy:debug("start")
	Lazy:StartCheck();

    --[[
    if LazyDruid.attackType ~= 3 then
        if not Lazy:IsHarm(target) then
            return
        end
    end 

    local stance = GetShapeshiftForm()
    self:AttackLoop(target)
    Lazy:StartCheck()
    ]]
end

function LazyDruid:AttackLoop(target)
    --local start, duration, enable = GetSpellCooldown(GCDIndex, BOOKTYPE_SPELL)
    --if not (start and duration and enable == 1 and (start == 0 or start + duration <= currentTime)) then
    --    return
    --end
	if target:GetDebuff("月火术") < 1 then
		if Lazy:Mark("target", "月火术", true) then
			return;
		end
	end

	Lazy:Mark("target", "愤怒", true)
end

