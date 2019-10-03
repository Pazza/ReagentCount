-- local references to globals
local ActionButton_Update = ActionButton_Update
local CreateFrame = CreateFrame
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerNumSlots = GetContainerNumSlots
local SPELL_REAGENTS = SPELL_REAGENTS

local tooltipFrame
local slots = {}

local getSlot = function (slot)
	if (slots[slot]) then
		return slots[slot]
	end

	slots[slot] = {}

	return slots[slot]
end

local cleanName = function (name)
	-- pull text from link
	local itemString, itemName = name:match("|H(.*)|h%[(.*)%]|h")
	return itemName or name
end

local reagentCheck = function (slot)
	tooltipFrame:SetAction(slot)
	regions = { tooltipFrame:GetRegions() }

	for i, region in pairs(regions) do
		if region:GetObjectType() == "FontString" then
			local text = region:GetText()
			if text and string.find(text, SPELL_REAGENTS) then
				local reagent = string.gsub(text, SPELL_REAGENTS, '')
				return cleanName(reagent)
			end
		end
	end

	return nil
end

local getInventoryCount = function (item)
	local toFind = cleanName(item)
	local count = 0
	for bag = 4, 0, -1 do
		local size = GetContainerNumSlots(bag)
		for slot = 1, size do
			local texture, itemCount, locked, quality, readable, lootable, itemLink = GetContainerItemInfo(bag, slot);
			if itemLink then
				if toFind == cleanName(itemLink) then
					count = count + itemCount
				end
			end
		end
	end
	return count
end



local init = function ()
	-- create tooltip frame
	tooltipFrame = CreateFrame("GameTooltip", "abReagentCount_GameTooltip", nil, "GameTooltipTemplate")
	tooltipFrame:SetOwner(WorldFrame, "ANCHOR_NONE");

	-- hook ActionButton_UpdateCount
	getglobal(hooksecurefunc("ActionButton_UpdateCount", function (self)
		local slot = getSlot(self.action)
		slot.frame = self
		slot.type = select(1, GetActionInfo(self.action))
		if (slot.type == 'spell') then
			local reagent = reagentCheck(self.action)
			if (reagent) then
				local itemCount = getInventoryCount(reagent)
				getSlot(self.action).frame.Count:SetText(itemCount)
			end
		end
	end))
end

init()