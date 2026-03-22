local SPELL_ID = 1221389
local SPELL_NAME = (C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(SPELL_ID)) or GetSpellInfo(SPELL_ID)
local TARGET_UNIT = "target"

local function NormalizeStacks(stacks)
	if not stacks or stacks < 1 then
		return 1
	end
	return stacks
end

local function GetAuraStacks(auraData)
	if not auraData then
		return 0
	end

	return NormalizeStacks(auraData.applications or auraData.count)
end

local function GetDebuffStacks(unit)
	if not unit or not UnitExists(unit) then
		return 0
	end

	if AuraUtil and AuraUtil.FindAuraBySpellID then
		local auraData = AuraUtil.FindAuraBySpellID(SPELL_ID, unit, "HARMFUL")
		if auraData then
			return GetAuraStacks(auraData)
		end
	end

	if AuraUtil and AuraUtil.FindAuraByName and SPELL_NAME then
		local auraData = AuraUtil.FindAuraByName(SPELL_NAME, unit, "HARMFUL")
		if auraData then
			return GetAuraStacks(auraData)
		end
	end

	if C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName and SPELL_NAME then
		local auraData = C_UnitAuras.GetAuraDataBySpellName(unit, SPELL_NAME, "HARMFUL")
		if auraData then
			return GetAuraStacks(auraData)
		end
	end

	return 0
end

local function IsUnprotectedComparable(value)
	return pcall(function()
		return value == value
	end)
end

local function SafeSpellIdText(spellId)
	if spellId == nil then
		return "-"
	end

	if not IsUnprotectedComparable(spellId) then
		return "<secret>"
	end

	return tostring(spellId)
end

local function ForEachUnitAura(unit, filter, callback)
	if not AuraUtil or not AuraUtil.ForEachAura then
		return false
	end

	AuraUtil.ForEachAura(unit, filter, nil, function(auraData)
		return callback(auraData)
	end)
	return true
end

local function GetDebugAuraSpellIdsText(unit)
	if not unit or not UnitExists(unit) then
		return ""
	end

	local spellIds = {}
	local function appendSpellIds(filter)
		ForEachUnitAura(unit, filter, function(auraData)
			spellIds[#spellIds + 1] = SafeSpellIdText(auraData and auraData.spellId)
		end)
	end

	appendSpellIds("HELPFUL")
	appendSpellIds("HARMFUL")

	if #spellIds == 0 then
		return "spellId: -"
	end

	return "spellId: " .. table.concat(spellIds, ", ")
end

local frame = CreateFrame("Frame", "FrostMageTargetStacksFrame", UIParent)
frame:SetSize(1, 1)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetFrameStrata("HIGH")

local text = frame:CreateFontString(nil, "OVERLAY")
text:SetPoint("CENTER", frame, "CENTER", 0, 0)
text:SetFont("Fonts\\FRIZQT__.TTF", 56, "OUTLINE")
text:SetTextColor(0.65, 1.0, 0.35)

local debugText = frame:CreateFontString(nil, "OVERLAY")
debugText:SetPoint("LEFT", text, "RIGHT", 20, 0)
debugText:SetJustifyH("LEFT")
debugText:SetWidth(800)
debugText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
debugText:SetTextColor(1.0, 0.82, 0.0)

local function Refresh()
	if not UnitExists(TARGET_UNIT) then
		text:SetText("0")
		debugText:SetText("")
		frame:Show()
		return
	end

	local stacks = GetDebuffStacks(TARGET_UNIT)
	text:SetText(tostring(stacks))
	debugText:SetText(GetDebugAuraSpellIdsText(TARGET_UNIT))
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
