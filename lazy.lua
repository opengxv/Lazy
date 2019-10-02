Lazy = LibStub("AceAddon-3.0"):NewAddon("CastDelayBar", "AceEvent-3.0", "AceHook-3.0");
Lazy.enable = true

function Lazy:OnInitialize()
	lazy_debug("Lazy:OnInitialize")
	self:CreateMarkerFrame()
	self:CreateTimer()
end

function Lazy:CreateMarkerFrame()
	if self.markerFrame then
		return
	end
	local media = LibStub("LibSharedMedia-3.0")
	local bgFrame = {
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4}
	}
	bgFrame.bgFile = media:Fetch("background", "Blizzard Tooltip")
	bgFrame.edgeFile = media:Fetch("border", "Blizzard Tooltip")
	local bgFrame2 = {
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4}
	}
	bgFrame2.bgFile = media:Fetch("background", "Solid")
	bgFrame2.edgeFile = media:Fetch("border", "Blizzard Tooltip")

	-- Frame
	self.markerFrame = CreateFrame("Frame", "LazyMarkerFrame", UIParent)
	self.markerFrame:SetResizable(true)
	self.markerFrame:SetMinResize(90, 120)
	self.markerFrame:SetMovable(true)
	self.markerFrame:SetWidth(225)
	self.markerFrame:SetHeight(130)
	self.markerFrame:SetScript("OnSizeChanged", nil)
	self.markerFrame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0)

	-- Title
	self.markerTitle = CreateFrame("Frame", "LazyMarkerTitle", self.markerFrame)
	self.markerTitle:SetPoint("TOPLEFT", self.markerFrame, "TOPLEFT")
	self.markerTitle:SetPoint("TOPRIGHT", self.markerFrame, "TOPRIGHT")
	self.markerTitle:SetHeight(25)
	
	self.markerTitleText = self.markerTitle:CreateFontString(nil, nil, "NumberFontNormalSmall")
	self.markerTitleText:SetPoint("LEFT", self.markerTitle, "LEFT", 10, 0)
	self.markerTitleText:SetText("LazyMarker")
	self.markerTitleText:SetFont(media:Fetch("font", "NumberFontNormalSmall"), 10, "OUTLINE");
	self.markerTitleText:SetTextColor(255, 255, 255, 255);
	self.markerTitleText:SetSpacing(5);
	self.markerTitleText:SetJustifyH("LEFT")
	self.markerTitleText:SetTextColor(1, 1, 0, 0.95)

	--self.markerTitle:EnableMouse(true)
	-- self.markerTitle:SetScript("OnMouseDown", function() 
	-- 	Lazy.markerFrame:StartMoving()
	-- end)
	
	-- self.markerTitle:SetScript("OnMouseUp", function()
	-- 	Lazy.markerFrame:StopMovingOrSizing();		
	-- 	Lazy.db.profile.options.x = Lazy.markerFrame:GetLeft()
	-- 	Lazy.db.profile.options.y = Lazy.markerFrame:GetBottom()
	-- end)
	
	self.markerTitle:SetAlpha(1)
	self.markerTitle:SetBackdrop(bgFrame2)
	self.markerTitle:SetBackdropColor(0, 0, 0, 1)
	self.markerTitle:SetBackdropBorderColor(0.15, 0.3, 0.65, 1)

	-- ScrollFrame
	self.markerScrollFrame = CreateFrame("ScrollFrame", "LazyMarkerScrollFrame", self.markerFrame, "UIPanelScrollFrameTemplate")
	
	-- Message	
	self.markerMessage = CreateFrame("Frame", "LazyMarkerMessage", self.markerFrame)
	self.markerMessage:SetResizable(true)
	self.markerMessage:EnableMouse(true)
	self.markerMessage:SetPoint("TOPLEFT", self.markerTitle, "BOTTOMLEFT")
	self.markerMessage:SetPoint("TOPRIGHT", self.markerTitle, "BOTTOMRIGHT")
	self.markerMessage:SetPoint("BOTTOMLEFT", self.markerFrame, "BOTTOMLEFT")
	self.markerMessage:SetPoint("BOTTOMRIGHT", self.markerFrame, "BOTTOMRIGHT")

	self.markerMessage:SetAlpha(1)
	self.markerMessage:SetBackdrop(bgFrame)
	self.markerMessage:SetBackdropColor(0, 0, 0, 1)
	self.markerMessage:SetBackdropBorderColor(0.15, 0.3, 0.65, 1)
	
	-- Labels
	local i
	self.markerLabels = {}
	for i = 1, 5 do
		local label = self.markerMessage:CreateFontString(nil, nil, "GameFontNormal")
		self.markerLabels[i] = label
		if i == 1 then
			label:SetPoint("TOPLEFT", self.markerMessage, "TOPLEFT", 10, -5)
		else
			label:SetPoint("TOP", self.markerLabels[i - 1], "BOTTOM", 0, -5)
			label:SetPoint("LEFT", self.markerMessage, 10, 0);
		end
		label:SetJustifyH("LEFT")
	end

	self:mark0()

	self.markerQueue = {}
	self.markerHead = 1
	self.markerTail = 1
	self.markerLength = 7
	self.markerSeq = 0

	self:MarkerFillContent()
	Lazy.markerFrame:Show()
end

function Lazy:MarkerQueueInc(index)
	if index < self.markerLength then
		return index + 1
	else
		return 1
	end
end

function Lazy:MarkerFillContent()
	local index = self.markerTail
	local i
	for i = 1, 5 do
		local label = self.markerLabels[i]
		
		if index == self.markerHead then
			label:SetText("")
		else
			index = index - 1
			if index < 1 then
				index = self.markerLength
			end
			local item = self.markerQueue[index]
			if item.clicked then
				local t = item.clickTime - item.markTime
				t = t - t%0.01
				label:SetText(item.text .. ' ' .. t)
				label:SetTextColor(0, 1, 0, 1)
			else
				label:SetText(item.text)
				label:SetTextColor(1, 1, 0, 1)
			end
		end
	end
end

function Lazy:mark0(i)
	if i then
		self.marker_q = self.marker_q + 1;
		if self.marker_q >= 100 then
			self.marker_q = 0
		end
	else
		Lazy.marker_q = 0;
		i = 0
	end
	self.markerTitleText:SetText(40320540000 + self.marker_q * 100 + i)
end
