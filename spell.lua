
LazySpell = {};

function LazySpell:new(name)
	local spell = {};
	setmetatable(spell, self)
	self.__index = self
	spell.name = name;

	spell.costs = lazy_clone(GetSpellPowerCost(name), true)
	spell.cost_count = #spell.costs
	return spell;
end

function LazySpell:Ready()
	if IsUsableSpell(self.name) then
		local start, duration, enable = GetSpellCooldown(self.name)
        if start and duration and enable then
			return (start == 0 or start + duration <= Lazy.now) and enable == 1
        end
	end
end
