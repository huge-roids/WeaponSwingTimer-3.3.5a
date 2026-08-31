local addon_name, addon_data = ...

addon_data.utils = {}

-- Sends the given message to the chat frame with the addon name in front.
addon_data.utils.PrintMsg = function(msg)
	chat_msg = "|cFF00FFB0" .. addon_name .. ": |r" .. msg
	DEFAULT_CHAT_FRAME:AddMessage(chat_msg)
end

-- Rounds the given number to the given step.
-- If num was 1.17 and step was 0.1 then this would return 1.1
addon_data.utils.SimpleRound = function(num, step)
    return floor(num / step) * step
end

-- WotLK 3.3.5 texture objects have no SetColorTexture method (added in Legion).
-- Teach it to every texture via the shared Texture metatable so all other files
-- can keep calling :SetColorTexture(r, g, b, a) unmodified on either client.
do
    local probe = UIParent:CreateTexture(nil, "BACKGROUND")
    local texture_methods = getmetatable(probe).__index
    if not texture_methods.SetColorTexture then
        texture_methods.SetColorTexture = function(self, r, g, b, a)
            self:SetTexture(r, g, b, a)
        end
    end
    probe:SetTexture(nil)
end

-- ---------------------------------------------------------------------------
-- 3.3.5 (WotLK) API compatibility helpers
-- ---------------------------------------------------------------------------
-- True when running on a client whose spellcast events carry no spellID.
-- spellID was added to UNIT_SPELLCAST_* in patch 4.0.1, so its absence is a
-- reliable marker for the 3.3.5 argument layout throughout this addon.
addon_data.utils.is_wotlk = (CombatLogGetCurrentEventInfo == nil)

-- GetSpellInfo's return order differs between clients:
--   3.3.5:  name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange
--   modern: name, rank, icon, castTime, minRange, maxRange, spellID
-- Returns a consistent (name, cast_time_seconds, spell_id) on either client.
-- cast_time is normalized to SECONDS; the raw API reports milliseconds.
addon_data.utils.GetSpellInfoCompat = function(spell)
    if spell == nil then
        return nil, nil, nil
    end
    if addon_data.utils.is_wotlk then
        local name, _, _, _, _, _, cast_time = GetSpellInfo(spell)
        if name == nil then
            return nil, nil, nil
        end
        -- 3.3.5 gives no spellID; resolve it from our own lookup where possible.
        local spell_id = nil
        if type(spell) == "number" then
            spell_id = spell
        else
            spell_id = addon_data.utils.SpellIdFromName(name)
        end
        return name, (cast_time or 0) / 1000, spell_id
    else
        local name, _, _, cast_time, _, _, spell_id = GetSpellInfo(spell)
        if name == nil then
            return nil, nil, nil
        end
        return name, (cast_time or 0) / 1000, spell_id
    end
end

-- Reverse lookup used only on 3.3.5, where events hand us a spell NAME but the
-- addon's internal tables are keyed by spell ID. Populated by the hunter module.
addon_data.utils.name_to_spell_id = {}

addon_data.utils.SpellIdFromName = function(name)
    if name == nil then
        return nil
    end
    return addon_data.utils.name_to_spell_id[name]
end

-- Rounds a virtual-pixel size so it lands exactly on a physical pixel boundary
-- at the current UI scale. Without this a bar texture and the backdrop behind it
-- can round to different physical sizes, leaving a 1px dark line along one edge
-- at certain width/height values.
addon_data.utils.SnapToPixel = function(size)
    if size == nil then
        return nil
    end
    local scale = UIParent:GetEffectiveScale()
    if not scale or scale <= 0 then
        return size
    end
    local snapped = math.floor((size * scale) + 0.5) / scale
    -- Never collapse a visible element below one physical pixel.
    local min_size = 1 / scale
    if snapped < min_size then
        snapped = min_size
    end
    return snapped
end

-- 3.3.5's CheckButton:GetChecked() returns 1 / nil rather than true / false.
-- Storing that nil into a settings table DELETES the key, so on the next login
-- LoadSettings sees it missing and restores the default - which is why unticked
-- boxes came back ticked. Always persist a real boolean.
addon_data.utils.IsChecked = function(checkbox)
    if checkbox and checkbox:GetChecked() then
        return true
    end
    return false
end

-- Older builds stored checkbox state as the raw GetChecked() result, which on
-- 3.3.5 is 1 / nil rather than true / false. Coerce any leftover numeric value
-- back to a boolean so existing SavedVariables files heal themselves.
-- (Keys that were deleted by a stored nil are unrecoverable - they are
-- indistinguishable from "never set" - and fall back to the default.)
addon_data.utils.NormalizeSettings = function(settings, defaults)
    if not settings or not defaults then
        return
    end
    for key, default_value in pairs(defaults) do
        if type(default_value) == "boolean" and type(settings[key]) == "number" then
            settings[key] = (settings[key] ~= 0)
        end
    end
end
