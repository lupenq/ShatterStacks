local SPELL_ID = 1221389
local SPELL_NAME = (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(SPELL_ID)) or GetSpellInfo(SPELL_ID)
local TARGET_UNIT = "target"
local MAX_AURA_INDEX = 80

local function NormalizeStacks(stacks)
	if not stacks or stacks < 1 then
		return 1
	end
	return stacks
end

local function GetDebuffStacks(unit)
	if not unit or not UnitExists(unit) then
		return 0
	end

	if AuraUtil and AuraUtil.FindAuraBySpellID then
		local auraData = AuraUtil.FindAuraBySpellID(SPELL_ID, unit, "HARMFUL")
		if auraData then
			return NormalizeStacks(auraData.applications or auraData.count)
		end
	end

	if SPELL_NAME and AuraUtil and AuraUtil.FindAuraByName then
		local auraName, _, count = AuraUtil.FindAuraByName(SPELL_NAME, unit, "HARMFUL")
		if auraName then
			return NormalizeStacks(count)
		end
	end

	for index = 1, MAX_AURA_INDEX do
		local auraName, _, count, _, _, _, _, _, _, spellId = UnitDebuff(unit, index)
		if not auraName then
			break
		end
		if spellId == SPELL_ID or (SPELL_NAME and auraName == SPELL_NAME) then
			return NormalizeStacks(count)
		end
	end

	return 0
end

local frame = CreateFrame("Frame", "FrostMageTargetStacksFrame", UIParent)
frame:SetSize(1, 1)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetFrameStrata("HIGH")

local text = frame:CreateFontString(nil, "OVERLAY")
text:SetPoint("CENTER", frame, "CENTER", 0, 0)
text:SetFont("Fonts\\FRIZQT__.TTF", 56, "OUTLINE")
text:SetTextColor(0.7, 0.85, 1.0)

local function Refresh()
	if not UnitExists(TARGET_UNIT) then
		text:SetText("0")
		frame:Show()
		return
	end
	local stacks = GetDebuffStacks(TARGET_UNIT)
	text:SetText(tostring(stacks))
	frame:Show()
end

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterUnitEvent("UNIT_AURA", TARGET_UNIT)
frame:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_TARGET_CHANGED" or event == "UNIT_AURA" then
		Refresh()
	end
end)

Refresh()
