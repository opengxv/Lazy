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
local InFight
local spellIndex = 0
local spellCount = 0
local spellQueue = {}
local stance = nil

local XXZJ
local MHZN
local GCD = 1
local XL
local GL
local QXZZ
local YMPX
local LSZ
local YHS
local TJ
local HHGLZ
local AMSKL

local YMPX_T = 4            --补野蛮咆哮剩余时间
local GL_T = 28 * 0.3       --补割裂的剩余时间
local XL_T = 15 * 0.3       --补斜掠的剩余时间
local YHS_T = 16 * 0.3      --补月火术的剩余时间
local TJ_T = 15 * 0.3       --补痛击的剩余时间
local cp                    --攻击点数
-- 天赋
local JCLR  --剑齿利刃
local YZL   --月之灵
local JCCS  --锯齿创伤
local YMHK  --野蛮挥砍


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
        ["割裂"] = {},
        ["斜掠"] = {},
        ["凶猛撕咬"] = {},
        ["撕碎"] = {},
        ["月火术"] = {},
        ["迎头痛击"] = {},
        ["裂伤"] = {},
        ["割碎"] = {},
        ["重殴"] = {},
        ["阿莎曼的狂乱"] = {},
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
            text = '/stopattack\n/stopcasting\n/script LazyDruid:StopCheck()',
            key = 'z',
        },
    },
}

function LazyDruid:OnEnable()
    Lazy:MarkerRegisterActions(actions)
    Lazy.Mod = self
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("UNIT_SPELLCAST_FAILED")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    Lazy:debug("LazyDruid:OnEnable")
end

function LazyDruid:OnDisable()
    self:CancelAllTimers()
    Lazy:debug("LazyDruid:OnDisable")
end

function LazyDruid:PLAYER_TARGET_CHANGED(self)
    --Lazy:debug("target changed")
    LazyDruid:StopCheck()
end

function LazyDruid:PLAYER_REGEN_DISABLED(self)
    InFight = true
    YZL = select(5, GetTalentInfo(1, 3, GetActiveSpecGroup()))
    JCLR = select(5, GetTalentInfo(6, 1, GetActiveSpecGroup()))
    JCCS = select(5, GetTalentInfo(6, 2, GetActiveSpecGroup()))
    YMHK = select(5, GetTalentInfo(7, 3, GetActiveSpecGroup()))

    if JCCS then
        GL_T = 28 * 0.3 * (1 - 0.33)
        XL_T = 15 * 0.3 * (1 - 0.33)
        TJ_T = 15 * 0.3 * (1 - 0.33)
    else
        GL_T = 28 * 0.3
        XL_T = 15 * 0.3
        TJ_T = 15 * 0.3
    end
    GCDIndex = Lazy:GetSpellIndex("横扫")
end

function LazyDruid:PLAYER_REGEN_ENABLED(self)
    --Lazy:debug("leave combat")
    InFight = false
    LazyDruid:StopCheck()
end

function LazyDruid:UNIT_SPELLCAST_FAILED(self, unit, spellName, spellRank)
    if (unit ~= 'player') then return end
    Lazy:debug(spellName .. " failed")
end

function LazyDruid:UNIT_SPELLCAST_SUCCEEDED(self, unit, spellName, spellRank)
    return
    --[[
    if (unit ~= 'player') then return end

    if spellName == "割裂" or spellName == "斜掠" then
        if XXZJ > 0 then
            Lazy:debug(spellName .. "->血爪")
        else
            Lazy:debug(spellName)
        end
    elseif spellName == "斜掠" then
        if XXZJ > 0 then
            Lazy:debug(spellName .. "->血爪")
        end 
    end]]
end


function LazyDruid:DoCheck()
    LazyDruid:AttackLoop("target")
end


function LazyDruid:StopCheck()
    lastTime = 0
    self.IsBoss = nil
    auto = false
    Lazy:StopCheck()
end

function LazyDruid:RebuildStance(s)
    stance = s
    Lazy.spellMap = {}
    for i = 1, MAX_SPELLS, 1 do
        local name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not name then
            break
        end
        local _, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(i, "spell")
        if spellID then
            Lazy.spellMap[spellID] = name
        end 
    end
    Lazy.spellMap[77758] = "痛击"
end 

function LazyDruid:Update(index, actionId, start)
    if not auto or not InFight then
        return
    end 
    currentTime = GetTime()

    if index == 1 then
        spellIndex = 1
        spellCount = 0
    elseif index == 2 and LazyDruid.attackType ~= 1 then
        return
    elseif index == 3 and LazyDruid.attackType ~= 2 then
        return
    elseif index > 3 then
        if currentTime - lastTime > 0.05 then
            lastTime = currentTime
            if LazyDruid.db.autoInterrupt then
                local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target")
                if name and not notInterruptible and endTime / 1000 - currentTime <= 2 then
                    if Lazy:Mark("target", "迎头痛击", true) then return end
                end
            end 

            if LazyDruid.attackType == 3 then
                self:AttackLoop("target")
                return
            end 
        end

        local s = GetShapeshiftForm()
        if not stance or stance ~= s then
            self:RebuildStance(s)
        end 
        while (spellIndex <= spellCount) do
            local spellId = spellQueue[spellIndex]
            local spell = Lazy.spellMap[spellId]
            if spell then
                if stance == 2 and LazyDruid.attackType == 2 then
                    if spell == "撕碎" then
                        local name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", "痛击"); 
                        if name and expirationTime and isMine == "player" then
                            TJ = expirationTime - currentTime
                        else 
                            TJ = 0
                        end
                        if TJ < 3 then
                            spell = "痛击"
                        else 
                            spell = "横扫"
                        end 
                    end 
                end 

                if spellId ~= 210722 or (Lazy:IsBoss() or self.IsBoss) then
                    if actions.player[spell] then
                        if Lazy:Mark("player", spell, true) then 
                            return 
                        end 
                    else
                        if Lazy:Mark("target", spell, true) then 
                            return 
                        end
                    end 
                end 
            else 
                Lazy:debug("unknown " .. spellId)
            end
            spellIndex = spellIndex + 1
        end
        return
    end 

    if not actionId then
        return
    end 

    if type(actionId) ~= "number" then
        return
    end 

    if not start then
        start = currentTime
    end 

    if start <= currentTime then
        spellCount = spellCount + 1
        spellQueue[spellCount] = actionId;
    end 
end 

function LazyDruid:Attack(target)
	Lazy:debug("bbbbbbbbbbbbbbbbbbbbbbb")
	Lazy:mark(10);
	Lazy:debug("bbbbbbbbbbbbbbbbbbbbbbb2")
	Lazy:debug(Lazy.marker);

    GCDIndex = Lazy:GetSpellIndex("横扫")
    if not GCDIndex then
        return
    end 
    auto = true
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
    local start, duration, enable = GetSpellCooldown(GCDIndex, BOOKTYPE_SPELL)
    if not (start and duration and enable == 1 and (start == 0 or start + duration <= currentTime)) then
        return
    end

    power = UnitPower("player")

    if LazyDruid.attackType ~= 3 then
        if not Lazy:IsHarm(target) then
            LazyDruid:StopCheck()
            return
        end
    end 

    local stance = GetShapeshiftForm()
    if stance == 2 then
        LazyDruid:AttackCatLoop(target);
    elseif stance == 1 then
        LazyDruid:AttackBearLoop(target);
    end
end

function LazyDruid:AttackCatLoop(target)
    cp = GetComboPoints("player", "target")
    if not cp then
        cp = 0
    end 

    local name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable, start, enabled

    start, duration, enabled = GetSpellCooldown("猛虎之怒");
    if duration then 
        MHZN = duration + start - currentTime
    else
        MHZN = 30
    end

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", "斜掠"); 
    if name and expirationTime and isMine == "player" then
        XL = expirationTime - currentTime
    else 
        XL = 0
    end	

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", "割裂"); 
    if name and expirationTime and isMine == "player" then
        GL = expirationTime - currentTime
    else 
        GL = 0
    end

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", "月火术"); 
    if name and expirationTime and isMine == "player" then
        YHS = expirationTime - currentTime
    else 
        YHS = 0
    end

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", "痛击"); 
    if name and expirationTime and isMine == "player" then
        TJ = expirationTime - currentTime
    else 
        TJ = 0
    end

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitAura("player", "节能施法"); 
    if name and expirationTime then
        QXZZ = expirationTime - currentTime
    else 
        QXZZ = 0
    end

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitAura("player", "野蛮咆哮"); 
    if name and expirationTime then
        YMPX = expirationTime - currentTime
    else 
        YMPX = 0
    end	

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitAura("player", "掠食者的迅捷"); 
    if name and expirationTime then
        LSZ = expirationTime - currentTime
    else 
        LSZ = 0
    end	

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitAura("player", "血腥爪击"); 
    if name and expirationTime then
        XXZJ = expirationTime - currentTime
    else 
        XXZJ = 0
    end	

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitAura("player", "火红割裂者"); 
    if name then
        HHGLZ = 1
    else 
        HHGLZ = 0
    end	

    start, duration, enabled = GetSpellCooldown("阿莎曼的狂乱")
    if start and duration and enabled == 1 and (start == 0 or start + duration <= currentTime) then 
        AMSKL = 1
    else
        AMSKL = 0
    end

    if LazyDruid.db.autoInterrupt then
        local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target")
        if name and not notInterruptible and endTime / 1000 - currentTime <= 2 then
            if Lazy:Mark("target", "迎头痛击") then return end
        end
    end

    if LazyDruid.attackType == 3 then
        if YMPX < YMPX_T then
            if cp >= 1 then
                YMPX_T = (cp + 1) * 1.2
                if Lazy:Mark("player", "野蛮咆哮", true) then return end
            end
        end

        if XXZJ == 0 and LSZ > GCD then 
            if Lazy:Mark("player", "愈合", true) then 
                return
            end 
        end 

        if cp >= 5 then
            if Lazy:Mark("player", "割裂", true) then return end
        end 

        if TJ < 1 then
            if Lazy:Mark("player", "痛击", true) then return end
        else
            if YMHK then
                if GetSpellCharges("野蛮挥砍") > 0 then
                    if Lazy:Mark("player", "野蛮挥砍", true) then return end
                end 
            else
                if Lazy:Mark("player", "横扫", true) then return end
            end
        end
        return
    end 

    local spell, ismine, nocheck = LazyDruid:CatNextSpell()
    if spell then
        if spell == "野蛮咆哮" then
            YMPX_T = (cp + 1) * 1.2
        end 
        if ismine then
            if Lazy:Mark("player", spell, not nocheck) then return end
        else
            if Lazy:Mark("target", spell, not nocheck) then return end
        end

        if MHZN < 1 and power < 35 then
            Lazy:Mark("player", "猛虎之怒")
        end
    end
end

function LazyDruid:CatNextSpell()
    --if YMPX == 0 and cp >= 2 then return "野蛮咆哮", true end 

    if cp >= 5 then
        if YMPX <= YMPX_T then return "野蛮咆哮", true end 

        if GL == 0 then
            if XXZJ == 0 and LSZ > GCD then return "愈合", true end 
            return "割裂"
        elseif JCLR then
            if GL < GL_T or power >= 50 then
                if XXZJ == 0 and LSZ > GCD then return "愈合", true end 
                return "凶猛撕咬"
            end 
        elseif GL < GL_T then
            if XXZJ == 0 and LSZ > GCD then return "愈合", true end 
            return "割裂"
        end

        if HHGLZ > 0 then
            return "割碎", false
        end 
    elseif GL == 0 and cp >= 2 then
        if YMPX < GCD then return "野蛮咆哮", true end 
    end 

    if LSZ > GCD and LSZ < GCD * 2 then
        return "愈合", true
    end 

    if XL <= XL_T then
        --if XXZJ == 0 and LSZ > GCD then return "愈合", true end 
        return "斜掠"
    end

    if AMSKL == 1 and (Lazy:IsBoss() or self.IsBoss) then
        return "阿莎曼的狂乱"
    end 

    if YZL and YHS <= YHS_T then
        return "月火术"
    end 

    if LazyDruid.attackType == 1 then
        if cp >= 5 and QXZZ > 0 and TJ <= TJ_T then
            return "痛击", true
        end 
        if cp >= 5 and (GL + 1 <= GL_T or YMPX + 1 <= YMPX_T) and power < 60 then
            return
        end 
        return "撕碎"
    elseif LazyDruid.attackType == 2 then
        if TJ < TJ_T then
            return "痛击", true
        else
            if YMHK then
                if GetSpellCharges("野蛮挥砍") > 0 then
                    return "野蛮挥砍", true
                else
                    return "撕碎"
                end
            else 
                return "横扫", true
            end 
        end
    elseif LazyDruid.attackType == 3 then
        return "撕碎"
    end
end


function LazyDruid:AttackBearLoop(target)
    if IsStealthed() then 
        LazyDruid:StopCheck()
        return
    end

    local TJ = 0
    local YHS = 0
    local TZ = 0

    if LazyDruid.db.autoInterrupt then
        local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("target")
        if name and not notInterruptible then
            if Lazy:Mark("target", "迎头痛击", true) then
                return
            end
        end
    end

    local name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", "月火术"); 
    if name and expirationTime and isMine == "player" then
        YHS = expirationTime - currentTime
    end

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitDebuff("target", "痛击"); 
    if name and expirationTime and isMine == "player" then
        TJ = expirationTime - currentTime
    end

    name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitAura("player", "铁鬃"); 
    if name and expirationTime then
        if count >= 3 then
            TZ = expirationTime - currentTime
        end 
    end

    if TZ < 1 then
        if Lazy:Mark("player", "铁鬃", true) then
            return
        end
    end 

    local selfHealthValue = UnitHealth("player")
    local selfHealthMax = UnitHealthMax("player")
    local selfHealth = selfHealthValue * 100 / selfHealthMax

    if selfHealth <= 90 then
        if Lazy:Mark("player", "狂暴回复", true) then
            return
        end
    end 
    
    if LazyDruid.attackType == 1 then
        if YHS > 1 or TJ > 1 then
            if Lazy:Mark("target", "裂伤", true) then
                return
            end
        end 
    end 

    if Lazy:Mark("player", "痛击", true) then
        return
    end

    if LazyDruid.attackType == 1 then
        if YHS < 1 then
            if Lazy:Mark("target", "月火术", true) then
                return
            end
        end 
    end 

    if Lazy:Mark("player", "横扫", true) then
        return
    end
end


