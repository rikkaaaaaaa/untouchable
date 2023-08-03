--[[
    untouchable tool
    a tool that disables absolutely all physgun interactions on an entity

    Copyright (C) 2023 by rikka

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
    WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
    MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
    ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
    WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
    ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
    OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]--

local NAME = "rikka_untouchable"

TOOL.Category = "Construction"
TOOL.Name = "#tool.rikka_untouchable.name"

TOOL.Information = {
    { name = "info", stage = 1 },
    { name = "left" },
    { name = "right" }
}

-- physgun pickup hook
hook.Add("PhysgunPickup", NAME, function (ply, ent)
    if ent:GetNWBool(NAME, false) then
        return false
    end
end)

hook.Add("CanPlayerUnfreeze", NAME, function (ply, ent, phys)
    if ent:GetNWBool(NAME, false) then
        return false
    end
end)

-- set untouchable status
function TOOL:LeftClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) or ent:IsPlayer() or ent:IsWorld() then return false end
    if CLIENT then return true end
    ent:SetNWBool(NAME, true)
    duplicator.StoreEntityModifier(ent, NAME, { enable = true })
    return true
end
-- clear untouchable status   
function TOOL:RightClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) or ent:IsPlayer() or ent:IsWorld() then return false end
    if CLIENT then return true end
    ent:SetNWBool(NAME, false)
    duplicator.StoreEntityModifier(ent, NAME, { enable = false })
    return true
end

if SERVER then
    -- nw bool to inform clients of touchable status
    util.AddNetworkString(NAME)

    -- registers a duplicator modifier so untouchable objects can be duped
    duplicator.RegisterEntityModifier(NAME, function (ply, ent, data)
        ent:SetNWBool(NAME, data["enable"])
    end)
else
    hook.Add("PreDrawHalos", NAME, function ()
        -- make sure we're holding the tool
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" or wep:GetMode() ~= NAME then return end

        local me = LocalPlayer()
        local trace = me:GetEyeTrace()
        local ent = trace.Entity
        if IsValid(ent) then
            local untouchable = ent:GetNWBool(NAME, false)
            local color = Color(128, 255, 128)
            if untouchable then color = Color(255, 128, 128) end
            halo.Add({ ent }, color, 7, 7, 3)
        end
    end)

    language.Add("tool.rikka_untouchable.name", "Untouchable")
    language.Add("tool.rikka_untouchable.desc", "Keep the physgun from touching an entity")
    language.Add("tool.rikka_untouchable.left", "Make the entity untouchable")
    language.Add("tool.rikka_untouchable.right", "Make the entity touchable again")
end