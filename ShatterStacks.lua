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

	if not C_UnitAuras or not C_UnitAuras.GetAuraDataByIndex or not SPELL_NAME then
		return 0
	end

	for index = 1, MAX_AURA_INDEX do
		local auraData = C_UnitAuras.GetAuraDataByIndex(unit, index, "HARMFUL")
		if not auraData then
			break
		end

		local auraSpellName
		if auraData.spellId then
			auraSpellName = (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(auraData.spellId)) or GetSpellInfo(auraData.spellId)
		end

		if auraSpellName == SPELL_NAME then
			return NormalizeStacks(auraData.applications or auraData.count)
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
