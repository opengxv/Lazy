
LazyUnit = {
};

function LazyUnit:new(name)
	local unit = {};
	setmetatable(unit, self)
	self.__index = self
	unit.name = name;
	--unit.guid = UnitGUID(name);
	return unit;
end

function LazyUnit:UpdateAura()
	self.buffs = {};
	self.debuffs = {};
	for i=1, 40 do
		local name, icon, count, debuffType, duration, expirationTime, casterUnit, canStealOrPurge, shouldConsolidate, spellID, canApply, isBossAura, isCastByPlayer = UnitAura(self.name, i, "HARMFUL")
		if name and expirationTime then
			if not self.debuffs[name] then
				self.debuffs[name] = {}
			end
			self.debuffs[name].count = count;
			self.debuffs[name].time = expirationTime or 0;
		end	
	end

	for i=1, 40 do
		local name, icon, count, debuffType, duration, expirationTime, casterUnit, canStealOrPurge, shouldConsolidate, spellID, canApply, isBossAura, isCastByPlayer = UnitAura(self.name, i, "HELPFUL")
		if name and expirationTime and isCastByPlayer then
			local buff = self.buffs[name]
			if not buff then
				buff = {}
				self.buffs[name] = buff;
			end
			buff.count = count;
			buff.time = expirationTime or 0;
		end	
	end
	self.hp = UnitHealth(self.name) or 0
	self.max_hp = UnitHealthMax(self.name) or 1
	self.hpp = self.hp / self.max_hp
end

function LazyUnit:GetBuff(name)
	local buff = self.buffs[name]
	if not buff then
		return 0
	end
	return buff.time - Lazy.now, buff.count
end

function LazyUnit:GetDebuff(name)
	if not self.debuffs[name] then
		return 0
	else 
		return 10, 1
	end

	local n = self.debuffs[name].time - Lazy.now, self.debuffs[name].count
	return n
end

function LazyUnit:IsHarm()
	return UnitExists(self.name) and not UnitIsDeadOrGhost(self.name) and UnitIsVisible("player", self.name) and not UnitIsFriend("player", self.name);
end

function LazyUnit:Castable(spell, target)
	if not spell:Ready() then
		return
	end

	if not (UnitCanAttack(self.name, target.name) or UnitCanAssist(self.name, target.name)) then
		return
	end
	for i = 1, spell.cost_count do
		cost = spell.costs[i];

		if cost.cost > UnitPower(self.name, cost.type) then
			return false;
		end
	end
	return true;
end
