LazyDruid = Lazy:CreatePlayer("DRUID")
if not LazyDruid then
    return
end

local actions = {
    ["player"] = {
		["回春术"]      = {},
		["治疗之触"]    = {},
        ["愈合"]        = {},
        ["驱毒术"]      = {},
        ["解除诅咒"]    = {},
		["野性印记"]    = {},
        ["荆棘术"]      = {},

        ["猛虎之怒"]    = {},
        ["急奔"] = {
            stance = 3,
            key = "T"
        },
    },
    ["mouseover"] = {
		["回春术"]      = {},
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
		["回春术"]      = {},
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
            text = '/stopattack\n/stopcasting\n/script Lazy:Stop()',
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

function LazyDruid:OnInitialize()
    lazy_debug("LazyDruid:OnEnable")
    Lazy:MarkerRegisterActions(actions)
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

function LazyDruid:Heal(target)
    Lazy:Update(function()
        if target:IsHarm() then
            return
        end

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
            if Lazy:CMark(target, "野性印记") then
                return
            end
            if Lazy:CMark(target, "荆棘术") then
                return
            end
            
            if target == Lazy.player and target.hpp > 0.95 then
                return
            end
        end

        if target.hpp <= 0.6 then
            if Lazy:CMark(target, "愈合") then
                return
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

        if Lazy:CMark(target, "回春术") then
            return
        end

        if Lazy:CMark(target, "愈合") then
            return
        end

        Lazy:Mark(target, "治疗之触", true)
    end)
end

function LazyDruid:Attack(target, second)
    Lazy:Start(function()
        self.stance = GetShapeshiftForm()
        if self.stance == 0 then
            self:AcAttack(target, second)
        elseif self.stance == 1 then
            self:BearAttack(target, second)
        elseif self.stance == 3 then
            self:CatAttack(target, second)
        end
    end);
end

function LazyDruid:AcAttack(target, second)
	if target:GetDebuff("月火术") < 1 then
		if Lazy:Mark(target, "月火术", true) then
			return;
		end
	end

	Lazy:Mark(target, "愤怒", true)
end

function LazyDruid:BearAttack(target, second)
	if target:GetDebuff("挫志咆哮") < 1 then
		if Lazy:Mark(target, "挫志咆哮", true) then
			return;
		end
	end
    if second then
        if Lazy:Mark(target, "挥击", true) then
            return;
        end
    else
        if Lazy:Mark(target, "槌击", true) then
            return;
        end
    end
end

function LazyDruid:CatAttack(target, second)
	-- 	if Lazy:CMark(Lazy.player, "猛虎之怒") then
	-- 		return
	-- 	end

    if IsStealthed() then
        return
    end

    if UnitIsUnit("targettarget", "player") then
        second = nil
    end

    local cp = GetComboPoints("player", target.name)
	if cp > 4 then
        Lazy:Mark(target, "凶猛撕咬", true)
        return
    end

    if Lazy:CMark(target, "扫击") then
        return;
    end

    if second then
        if Lazy:Mark(target, "撕碎", true) then
            return
        end
    else
        if Lazy:Mark(target, "爪击", true) then
            return
        end
    end

    if Lazy:CMark(target, "精灵之火（野性）") then
        return;
    end
end 
