-- server/main.lua — shared-emote routing and preview saving.

local RES = GetCurrentResourceName()

-- ── Shared emotes ────────────────────────────────────────────────────────────
-- pending[target][from] = { key, at } so an answer can only accept a request
-- that was really made.
local pending = {}

local function nameOf(src) return GetPlayerName(src) or ("Player %d"):format(src) end

local function near(a, b)
    local pa, pb = GetPlayerPed(a), GetPlayerPed(b)
    if pa == 0 or pb == 0 then return false end
    return #(GetEntityCoords(pa) - GetEntityCoords(pb)) <= (Config.SharedRange + 2.0)
        and GetPlayerRoutingBucket(a) == GetPlayerRoutingBucket(b)
end

RegisterNetEvent("spz-emotes:sharedRequest", function(target, key)
    local src = source
    target = tonumber(target)
    local e = Emotes[key]
    if not target or target == src or not GetPlayerName(target) or not e or not e.shared then return end
    if not near(src, target) then return end
    pending[target] = pending[target] or {}
    pending[target][src] = { key = key, at = os.time() }
    TriggerClientEvent("spz-emotes:sharedAsk", target, src, nameOf(src), key)
end)

RegisterNetEvent("spz-emotes:sharedAnswer", function(from, key, accepted)
    local src = source
    from = tonumber(from)
    local req = from and pending[src] and pending[src][from]
    if not req or req.key ~= key then return end
    pending[src][from] = nil
    if os.time() - req.at > Config.SharedTimeout then accepted = false end
    if not accepted or not GetPlayerName(from) or not near(src, from) then
        if GetPlayerName(from) then TriggerClientEvent("spz-emotes:sharedDeclined", from, nameOf(src)) end
        return
    end
    TriggerClientEvent("spz-emotes:sharedPlay", from, key, "a", src)
    TriggerClientEvent("spz-emotes:sharedPlay", src, key, "b", from)
end)

AddEventHandler("playerDropped", function()
    pending[source] = nil
end)

-- ── Preview recorder ─────────────────────────────────────────────────────────

local recorders = {}   -- [src] = true while their /emoterecord run is allowed to save

RegisterCommand("emoterecord", function(src, args)
    if src == 0 or not IsPlayerAceAllowed(src, Config.RecordAce) then return end
    local arg = args[1] and args[1]:lower()
    local keys = {}
    for key, e in pairs(Emotes) do
        if not e.clipset and not e.mood then
            local exists = LoadResourceFile(RES, ("ui/previews/%s.jpg"):format(key)) ~= nil
            if arg == "all" or arg == key or (not arg and not exists) then keys[#keys + 1] = key end
        end
    end
    table.sort(keys)
    if #keys == 0 then
        return TriggerClientEvent("ox_lib:notify", src, { title = "Emotes", description = "Every emote already has a preview (use /emoterecord all)", type = "inform" })
    end
    recorders[src] = true
    TriggerClientEvent("spz-emotes:record", src, keys)
end, false)

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64decode(s)
    s = s:gsub("[^" .. B64 .. "=]", "")
    return (s:gsub(".", function(c)
        if c == "=" then return "" end
        local n = B64:find(c, 1, true) - 1
        local bits = ""
        for i = 6, 1, -1 do bits = bits .. (n % 2 ^ i - n % 2 ^ (i - 1) > 0 and "1" or "0") end
        return bits
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(b)
        if #b ~= 8 then return "" end
        local c = 0
        for i = 1, 8 do c = c + (b:sub(i, i) == "1" and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

RegisterNetEvent("spz-emotes:savePreview", function(key, data)
    local src = source
    if not recorders[src] or not IsPlayerAceAllowed(src, Config.RecordAce) then return end
    if type(key) ~= "string" or not Emotes[key] or type(data) ~= "string" then return end
    local b64 = data:match("^data:image/jpe?g;base64,(.+)$")
    if not b64 then return end
    local ok = SaveResourceFile(RES, ("ui/previews/%s.jpg"):format(key), b64decode(b64), -1)
    if not ok then print(("^1[spz-emotes] could not save preview for %s^7"):format(key)) end
end)

AddEventHandler("playerDropped", function()
    recorders[source] = nil
end)
