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
		["回春术"]      = {stance = 0},
		["治疗之触"]    = {stance = 0},
        ["愈合"]        = {stance = 0},
        ["驱毒术"]      = {stance = 0},
        ["解除诅咒"]    = {stance = 0},
		["野性印记"]    = {stance = 0},
        ["荆棘术"]      = {stance = 0},

        ["猛虎之怒"]    = {stance = 3},
        ["急奔"] = {
            stance = 3,
            key = "T"
        },
    },
    ["mouseover"] = {
		["回春术"]      = {stance = 0},
		["治疗之触"] = {},
        ["愈合"] = {},
        ["驱毒术"] = {},
        ["解除诅咒"] = {},

		["野性印记"] = {},
        ["荆棘术"] = {},
        ["槌击"] = {},
        ["挥击"] = {},
        ["挫志咆哮"] = {},
        ["爪击"] = {},
        ["撕扯"] = {},
        ["扫击"] = {},
        ["精灵之火（野性）"] = {},

    },
    ["focus"] = {
    },
    ["targettarget"] = {
    },
    ["target"] = {
		["回春术"]      = {stance = 0},
		["治疗之触"] = {},
        ["愈合"] = {},
        ["驱毒术"] = {},
        ["解除诅咒"] = {},
        ["野性印记"] = {},
        
		["荆棘术"] = {},
        ["月火术"] = {},
        ["愤怒"] = {},

        ["槌击"] = {},
        ["挥击"] = {},
        ["挫志咆哮"] = {},
        ["爪击"] = {},
        ["撕扯"] = {},
        ["撕碎"] = {},
        ["扫击"] = {},
        ["毁灭"] = {},
        ["凶猛撕咬"] = {},
        ["精灵之火（野性）"] = {},
        ["突袭"] = {},
    },
    ["other"] = {
        ['攻击'] = {
            text = '/cast [stealth,exists,nohelp,stance:3] 突袭\n/startattack [nostealth]\n/script LazyDruid:Attack(Lazy.target)',
            key = "E",
        }, 
        ['攻击2'] = {
            text = '/cast [stealth,exists,nohelp,stance:3] 毁灭\n/startattack [nostealth]\n/script LazyDruid:Attack(Lazy.target, true)',
            key = "Q",
        }, 
        ['停止'] = {
            text = '/stopattack\n/stopcasting\n/script Lazy:StopCheck()',
            key = 'z',
        },
        ['熊形态'] = {
            --text = '/cast [nostance:1] 熊形态; [stance:1] 野性冲锋(熊形态)',
            text = '/script Lazy:Stop()\n/stopcasting\n/cancelaura 水栖形态\n/cancelaura 猎豹形态\n/cancelaura 旅行形态\n/cast [nostance:1] 巨熊形态; [stance:1] 巨熊形态',
            key = 'R',
        },
        ['海豹形态'] = {
            text = '/script Lazy:Stop()\n/stopcasting\n/cancelaura 巨熊形态\n/cancelaura 猎豹形态\n/cancelaura 旅行形态\n/cast [swimming]水栖形态\n/cast [noswimming]旅行形态',
            key = 'C',
        },
        ['猎豹形态'] = {
            text = '/script Lazy:Stop()\n/stopcasting\n/cancelaura 巨熊形态\n/cancelaura 水栖形态\n/cancelaura 旅行形态\n/cast [stance:3] 潜行\n/cast [nostance:3] 猎豹形态',
            key = 'F',
        },
        ["治疗他人"] = {
            text = '/script Lazy:Stop()\n/cancelaura 巨熊形态\n/cancelaura 水栖形态\n/cancelaura 猎豹形态\n/cancelaura 旅行形态\n/script LazyDruid:Heal(Lazy.mouseover)',
            key = "MOUSEWHEELDOWN",
        },
        ["自我治疗"] = {
            text = '/script Lazy:Stop()\n/cancelaura 巨熊形态\n/cancelaura 水栖形态\n/cancelaura 猎豹形态\n/cancelaura 旅行形态\n/script LazyDruid:Heal(Lazy.player)',
            key = "MOUSEWHEELUP",
        },
        ["骑乘"] = {
            text = '/cancelaura 猎豹形态\n/cancelaura 巨熊形态\n/cancelaura 水栖形态\n/cancelaura 旅行形态\n/cast 条纹夜刃豹缰绳',
            key = "F5",
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
    self.stance = GetShapeshiftForm()
    if self.stance == 0 then
        self:AttackLoop(target)
    elseif self.stance == 1 then
        self:BearAttackLoop(target)
    elseif self.stance == 3 then
        self:CatAttackLoop(target)
    end
end

function LazyDruid:CancelAura(index)
    if index == 0 then
        return '/cancelaura 猎豹形态\n/cancelaura 巨熊形态\n/cancelaura 水栖形态\n/cancelaura 旅行形态\n'
    elseif index == 1 then
        return '/cancelaura 猎豹形态\n/cancelaura 水栖形态\n/cancelaura 旅行形态\n'
    elseif index == 2 then
        return '/cancelaura 猎豹形态\n/cancelaura 巨熊形态\n/cancelaura 旅行形态\n'
    elseif index == 3 then
        return '/cancelaura 巨熊形态\n/cancelaura 水栖形态\n/cancelaura 旅行形态\n'
    elseif index == 4 then
        return '/cancelaura 猎豹形态\n/cancelaura 巨熊形态\n/cancelaura 水栖形态\n'
    end
end

function LazyDruid:Perform(str)
    return true
end 

function LazyDruid:Heal(target)
	if target:IsHarm() then
        return
	end
	Lazy:StopCheck()
	target:UpdateAura();
	Lazy.player:UpdateAura();

    if target.hpp >= 0.7 then
        if target.poison then
            if 	Lazy:Mark(target, "驱毒术", true) then
                return
            end
        end
        if target.curse then
            if 	Lazy:Mark(target, "解除诅咒", true) then
                return
            end
        end
    end

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
        
        if target == Lazy.player and target.hpp > 0.95 then
            return
        end
    end

    if target.hpp <= 0.6 then
        if target:GetBuff("愈合") == 0 then
            if Lazy:Mark(target, "愈合", true) then
                return
            end
        end
    end 

    if target.hpp <= 0.3 then
        if 	Lazy:Mark(target, "治疗之触", true) then
            return
        end
    end

    if target.poison then
        if 	Lazy:Mark(target, "驱毒术", true) then
            return
        end
    end
    if target.curse then
        if 	Lazy:Mark(target, "解除诅咒", true) then
            return
        end
    end

	if target:GetBuff("回春术") == 0 then
		if Lazy:Mark(target, "回春术", true) then
			return
		end
	end

	if target:GetBuff("愈合") == 0 then
		if Lazy:Mark(target, "愈合", true) then
			return
		end
	end

	Lazy:Mark(target, "治疗之触", true)
end

function LazyDruid:Attack(target, second)
    self.second = second
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

function LazyDruid:BearAttackLoop(target)
	if target:GetDebuff("挫志咆哮") < 1 then
		if Lazy:Mark(target, "挫志咆哮", true) then
			return;
		end
	end
    if self.second then
        if Lazy:Mark(target, "挥击", true) then
            return;
        end
    else
        if Lazy:Mark(target, "槌击", true) then
            return;
        end
    end
end

function LazyDruid:CatAttackLoop(target)
	-- if Lazy.player:GetBuff("猛虎之怒") == 0 then
	-- 	if Lazy:Mark(Lazy.player, "猛虎之怒", true) then
	-- 		return
	-- 	end
	-- end

    if IsStealthed() then
        return
    end

    if UnitIsUnit("targettarget", "player") then
        self.second = nil
    end

	if not Lazy.combating and target:GetDebuff("精灵之火（野性）") < 1 then
		if Lazy:Mark(target, "精灵之火（野性）", true) then
			return;
		end
	end

    local cp = GetComboPoints("player", target.name)
	if cp > 4 then
        Lazy:Mark(target, "凶猛撕咬", true)
        return
    end

	if Lazy.combating and target:GetDebuff("扫击") < 1 then
		if Lazy:Mark(target, "扫击", true) then
			return;
		end
	end

    if self.second then
        if Lazy:Mark(target, "撕碎", true) then
            return
        end
    else
        if Lazy:Mark(target, "爪击", true) then
            return
        end
    end

    if target:GetDebuff("精灵之火（野性）") < 1 then
		if Lazy:Mark(target, "精灵之火（野性）", true) then
			return;
		end
	end

end 
