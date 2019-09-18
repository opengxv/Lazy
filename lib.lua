local L = LibStub("AceLocale-3.0"):GetLocale("Lazy")

function Lazy:debug(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 192, 0, 192, 0)
end

Lazy._spells = {}
function Lazy:GetSpellIndex(spell)
	local index = 0
	local count = 0
	local i;
	local result = self._spells[spell];

	if result ~= nil then
		return result.index, result.texture, result.count
	end

	for i = 1, MAX_SPELLS, 1 do
		local name, rank = GetSpellBookItemName(i, BOOKTYPE_SPELL)
		if not name then
			break
		end
		local fullname
		if rank then
			fullname = name .. "(" .. rank .. ")";
		else
			fullname = name
		end

		local match = strfind(fullname, spell, 1, true);
		if match then
			if index == 0 then
				index = i
				count = 1
			else
				count = count + 1
			end
		else
			if index ~= 0 then
				break
			end
		end
	end
	
	if index == 0 then
		return
	end

	result = {}
	result.index = index;
	result.count = count;
	result.texture = GetSpellTexture(index, 0)
	self._spells[spell] = result;
	return result.index, result.texture, result.count
end

function Lazy:UnitBuff(unit, spell, mineOnly)
	local index, texture = self:GetSpellIndex(spell)

	if index or texture then
		local i
		for i = 1, 40, 1 do
			local name, rank, iconTexture, count, debufftype, duration, left, isMine = UnitBuff(unit, i);
			if not name or not iconTexture then
				break
			end
			if texture == iconTexture and (not mineOnly or (isMine == "player")) then
				if count == 0 then
					count = 1
				end
				if not left then
					left = 0
				else
					left = left - GetTime();
				end
				return count, left
			end
		end
	end
	return 0, 0
end

function Lazy:UnitBuffByName(unit, spell, mineOnly)
	local i
	for i = 1, 40, 1 do
		local name, rank, iconTexture, count, debuffType, duration, left, isMine = UnitBuff(unit, i);
		if not name or not iconTexture then
			break
		end
		if name == spell and (not mineOnly or (isMine == "player")) then
			if count == 0 then
				count = 1
			end
			if not left then
				left = 0
			else
				left = left - GetTime()
			end
			return count, left
		end
	end
	return 0, 0
end

function Lazy:UnitDebuff(unit, spell, mineOnly)
	local index, texture = self:GetSpellIndex(spell)

	if index or texture then
		local i
		for i = 1, 40, 1 do
			local name, rank, iconTexture, count, debuffType, duration, left, isMine = UnitDebuff(unit, i);
			if not name or not iconTexture then
				break
			end
			if texture == iconTexture and (not mineOnly or isMine) then
				if count == 0 then
					count = 1
				end
				if not left then
					left = 0
				end
				return count, left
			end
		end
	end
	return 0, 0
end

function Lazy:UnitDebuffByName(unit, spell, mineOnly)
	local i
	for i = 1, 40, 1 do
		local name, rank, iconTexture, count, debuffType, duration, left, isMine = UnitDebuff(unit, i);
		if not name or not iconTexture then
			break
		end
		if name == spell and (not mineOnly or isMine) then
			if count == 0 then
				count = 1
			end
			if not left then
				left = 0
			end
			return count, left
		end
	end
	return 0, 0
end

function Lazy:Castable(spell, target)
    --[[
   local index = self:GetSpellIndex(spell)
	 if index then
      if IsUsableSpell(index, BOOKTYPE_SPELL) then
        local start, duration, enable = _G.GetSpellCooldown(index, BOOKTYPE_SPELL)
        if start and duration and enable then
            return (start == 0 or start + duration <= GetTime()) and enable == 1
        end
      end
   end]]
    local index = self:GetSpellIndex(spell)
      if index then
       if IsUsableSpell(index, BOOKTYPE_SPELL) then
         local start, duration, enable = _G.GetSpellCooldown(index, BOOKTYPE_SPELL)
         if start and duration and enable then
             return (start == 0 or start + duration <= GetTime()) and enable == 1
         end
       end
    end
end

--[[if true or IsUsableSpell(index, BOOKTYPE_SPELL) then
			if spell ~= "横扫(猎豹形态)" and target then
				local range = IsSpellInRange(index, BOOKTYPE_SPELL, target)
				if range == nil or range == 0 then
					return false
				end
			end  

			local start, duration, enable = GetSpellCooldown(spell, BOOKTYPE_SPELL)
			if ((start == 0 or start + duration <= GetTime()) and enable == 1) then
				local t = GetTime()
				if Lazy.casting_spell and Lazy.casting_end_time and casting_delay_time and t < Lazy.casting_end_time then
					if t > Lazy.casting_end_time - Lazy.casting_delay_time then
						return true
					else
						return false
					end
				else
					return true
				end
        return true;
			end
		end
	end
  return false
]]

function Lazy:ItemUsable(spell, trinket)
	local item, _,_,_,_,_,_,_,_, texture = GetItemInfo(spell)
	if not item or not texture then
		return nil
	end

	if trinket then
		local texture2 = GetInventoryItemTexture("player", 13)
		if not texture2 or texture2 ~= texture then
			texture2 = GetInventoryItemTexture("player", 14)
			if not texture2 or texture2 ~= texture then
				return nil
			end
		end
	end

	local start, duration, enable = GetItemCooldown(item)
	if enable == 1 and (start == 0 or start + duration <= GetTime())  then
		return item
	end
	return nil
end

function Lazy:UnitMana(target)
	return 100 * UnitMana(target) / UnitManaMax(target)
end

function Lazy:UnitHealth(target)
	return UnitHealth(target) * 100 / UnitHealthMax(target)
end

function Lazy:Healable(target)
	if UnitExists(target) and
		 UnitIsFriend("player", target) and
		 UnitIsVisible(target) and
		 not UnitIsDeadOrGhost(target) then
		 return true
	end
	return false
end

function Lazy:IsHarm(target)
	if UnitExists(target) and
		 not UnitIsFriend("player", target) and
		 UnitIsVisible(target) and
		 not UnitIsDeadOrGhost(target) then
		 return true
	end
	return false
end

function Lazy:CancelAllForm(check)
	local i
	for i = 1, 40, 1 do
		local name, rank, iconTexture, count, duration, left = UnitBuff("player", i);
		if not name or not iconTexture then
			break
		end

		if self.forms[name] then
			if check then
				if not self:Castable(check, "player") then
					return
				end
			end
			CancelPlayerBuff(name)
			return
		end
	end
end

function Lazy:UpdateDamageCheckRange()
	ConsoleExec('SET CombatLogRangeParty "200"')
	ConsoleExec('SET CombatLogRangeParty "200"')
	ConsoleExec('SET CombatLogRangePartyPet "200"')
	ConsoleExec('SET CombatLogRangeFriendlyPlayers "200"')
	ConsoleExec('SET CombatLogRangeFriendlyPlayersPets "200"')
	ConsoleExec('SET CombatLogRangeHostilePlayers "200"')
	ConsoleExec('SET CombatLogRangeHostilePlayersPets "200"')
	ConsoleExec('SET CombatLogRangeCreature "200"')
	Lazy:debug("Damage check range has updated to 200")
end

function Lazy:InBattlefields()
	inInstance, instanceType = IsInInstance()
	return instanceType=="pvp"
end


