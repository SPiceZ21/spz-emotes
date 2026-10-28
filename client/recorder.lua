-- client/recorder.lua — /emoterecord: renders the menu thumbnails.
--
-- Admin only (checked on the server). Plays each emote on your own ped in front
-- of a fixed camera, waits for the pose to settle, takes a screenshot with
-- screenshot-basic and sends it to the server, which saves it as
-- ui/previews/<key>.jpg. Restart spz-emotes afterwards so the new files are
-- served to clients.
--
-- Stand somewhere open with a plain backdrop first; the HUD and radar are
-- hidden while it runs, other resources' screens are not.
--
--   /emoterecord          every emote that has no thumbnail
--   /emoterecord all      every emote, overwriting
--   /emoterecord <key>    one emote

local recording = false

local SETTLE_MS = 1600      -- time into the clip the frame is taken
local CAM_DIST  = 2.6
local CAM_FOV   = 40.0

local function shot()
    local p = promise.new()
    exports["screenshot-basic"]:requestScreenshot({ encoding = "jpg", quality = 0.82 }, function(data) p:resolve(data) end)
    return Citizen.Await(p)
end

local function pose(e, ped)
    if e.scenario then
        TaskStartScenarioInPlace(ped, e.scenario, 0, true)
    elseif e.shared then
        Emote.playClip(ped, e.shared.dict, e.shared.a, 1)
    else
        Emote.playClip(ped, e.dict, e.anim, 1)
    end
end

RegisterNetEvent("spz-emotes:record", function(keys)
    if recording or type(keys) ~= "table" or #keys == 0 then return end
    if GetResourceState("screenshot-basic") ~= "started" then
        return Emote.notify("screenshot-basic isn't running", "error")
    end
    recording = true
    Emote.stop(true)

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    local base = GetEntityCoords(ped)
    local fwd  = GetEntityForwardVector(ped)
    local camPos = base + fwd * CAM_DIST + vector3(0.0, 0.0, 0.35)
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camPos.x, camPos.y, camPos.z, 0.0, 0.0, 0.0, CAM_FOV, false, 0)
    PointCamAtCoord(cam, base.x, base.y, base.z + 0.05)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)

    local hide = true
    CreateThread(function()
        while hide do HideHudAndRadarThisFrame(); Wait(0) end
    end)

    Emote.notify(("Recording %d previews — don't touch anything"):format(#keys))
    local done = 0
    for _, key in ipairs(keys) do
        local e = Emotes[key]
        if e and not e.clipset and not e.mood then
            ClearPedTasksImmediately(ped)
            pose(e, ped)
            Wait(SETTLE_MS)
            local data = shot()
            if type(data) == "string" and data:find("^data:image") then
                TriggerLatentServerEvent("spz-emotes:savePreview", 250000, key, data)
                done = done + 1
            end
            Wait(250)
        end
    end

    ClearPedTasksImmediately(ped)
    hide = false
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
    FreezeEntityPosition(ped, false)
    recording = false
    Emote.notify(("Recorded %d previews. Restart spz-emotes to serve them."):format(done), "success")
end)

exports("IsRecording", function() return recording end)
