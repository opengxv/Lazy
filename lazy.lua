
Lazy = LibStub("AceAddon-3.0"):NewAddon("Lazy", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Lazy")
local BossIDs = LibStub("LibBossIDs-1.0")
local bossIDs = BossIDs.BossIDs

Lazy.options = {
	name = "Lazy",
	handler = Lazy,
	type = "group",
	args = {
		["options"] = {
			type = "group",
			name = L["常規"],
			args = {
				[L["陆地坐骑"]] = {
					type = "input",
					name = L["陆地坐骑"],
					get = function() return Lazy.db.profile.options.landMount end,
					set = function(info, val) 
						Lazy.db.profile.options.landMount = string.trim(val)
						Lazy:UpdateMount()
					end,
				},
				[L["飞行坐骑"]] = {
					type = "input",
					name = L["飞行坐骑"],
					get = function() return Lazy.db.profile.options.flyMount end,
					set = function(info, val) 
						Lazy.db.profile.options.flyMount = string.trim(val) 
						Lazy:UpdateMount()
					end,
				},
				[L["重置Marker窗口"]] = {
					type = "execute",
					name = L["重置Marker窗口"],
					func = function ()
						Lazy:UpdateMarkerFramePos()
					end,
				},
			},
		},
	}
}

Lazy.defaults = {
	profile = {
		modules = {},
		options = {
			flyMount = "",
			landMount = "",
			x = nil,
			y = nil,
		}
	},
}

function Lazy:ShowConfig()
	local AceConfig = LibStub("AceConfigDialog-3.0")
 	AceConfig:SetDefaultSize("Lazy", 500, 550)
	AceConfig:Open("Lazy", configFrame)
end
Lazy.OpenMenu = Lazy.ShowConfig

function Lazy:OnInitialize()	
	for k, v in Lazy:IterateModules() do
		if v.defaults then
			local name = v:GetName()
			if not v.defaults then
				v.defaults = {}
			end
			v.defaults.___enabled___ = true
			Lazy.defaults.profile.modules[name] = v.defaults
		end
	end
	self.db = LibStub:GetLibrary("AceDB-3.0"):New("LazyDB", self.defaults)
	
	for k, v in Lazy:IterateModules() do
		v.db = self.db.profile.modules[v:GetName()]
		v:SetEnabledState(v.db.___enabled___)
	end

	for k, v in Lazy:IterateModules() do
		if v.options then
			local name = v:GetName()
			Lazy.options.args[name] = {}
			Lazy.options.args[name].type = "group"
			Lazy.options.args[name].name = name
			Lazy.options.args[name].args = v.options
			Lazy.options.args[name].args.___enabled___ = {
				type = "toggle",
				name = L["启用"],
				order = 0,
				arg = {moduleName = name},
				get = function(info)
					if info.arg and info.arg.moduleName then
						local module = Lazy:GetModule(info.arg.moduleName, true)
						if module then
							return module:IsEnabled()
						end
					end
					return false
				end,
				set = function(info, val) 
					if info.arg and info.arg.moduleName then
						local module = Lazy:GetModule(info.arg.moduleName, true)
						if module then
							module.db.___enabled___ = val
							if val then
								module:Enable()
							else
								module:Disable()
							end
						end
					end
				end,
			}
		end
	end

	Lazy.options.args.config = {
		type = "execute",
		name = "Configure",
		desc = "Open the configuration dialog",
		func = Lazy.ShowConfig,
		guiHidden = true
	}

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Lazy", Lazy.options, {"lazy"})
	
	self.selfName = UnitName("player")
end

function Lazy:UnitID(target)
    local guid =  UnitGUID(target)
    if not guid then
        return
    end 
    return tonumber(({('-'):split(guid)})[6])
end 

function Lazy:IsBoss(target)
    if not target then
        target = "target"
    end 
    local classif = UnitClassification(target);
    if not classif then
        return
    end

    if classif == "worldboss" or classif == "rareelite" then
        if UnitLevel("target") > UnitLevel("player") then
            return true
        end 
    end 

    local id =  Lazy:UnitID(target)
    if not id then
        return
    end 
    return bossIDs[id]
end 

function Lazy:MarkBoss(target)
    if not target then
        target = "target"
    end 
    local id =  Lazy:UnitID(target)
    if not id then
        return
    end 
    Lazy:debug(id)
end 

function Lazy:OnEnable()
	self:CreateMarkerFrame()
end

function Lazy:OnDisable()
    self:CancelAllTimers()
end

Lazy.marker = 40320541000;
Lazy.marker_q = 0;

function Lazy:mark0(i)
    self.marker_q = self.marker_q + 1;
    if self.marker_q >= 100 then
        self.marker_q = 0
    end
    self.marker = 40320540000 + self.marker_q * 100 + i
	self.watchTitleText:SetText(self.marker)
end

