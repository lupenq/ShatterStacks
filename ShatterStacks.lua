local SPELL_ID = 1221389
local TARGET_UNIT = "target"
local MAX_AURA_INDEX = 80

local function GetDebuffStacks(unit, spellId)
	if not unit or not UnitExists(unit) then
		return 0
	end
	for index = 1, MAX_AURA_INDEX do
		local auraData = C_UnitAuras.GetAuraDataByIndex(unit, index, "HARMFUL")
		if not auraData then
			break
		end
		if auraData.spellId == spellId then
			local stacks = auraData.applications or 0
			if stacks < 1 then
				return 1
			end
			return stacks
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
	local stacks = GetDebuffStacks(TARGET_UNIT, SPELL_ID)
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
