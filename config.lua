-- config.lua — spz-emotes
Config = {}

Config.MenuKey    = "O"      -- opens the menu (rebindable: Settings > Key Bindings > FiveM)
Config.CancelKey  = "X"      -- stops the current emote
Config.Command    = "emotes" -- /emotes opens the menu; /e <name> plays one directly

-- Shared emotes (handshake, hug, ...): how close the other player must be,
-- and how long they have to accept.
Config.SharedRange   = 3.0
Config.SharedTimeout = 12     -- seconds

-- Who may run /emoterecord (renders the preview thumbnails into ui/previews).
Config.RecordAce = "spz.admin"
