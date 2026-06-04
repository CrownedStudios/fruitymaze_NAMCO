local DiscordRPC = {
    statusLog = "Not Initialized"
}

local rpc = require("libs.discord-rpc.discordRPC")

local fileLogger = require("scripts.util.FileLogger")

DiscordRPC.enabled = false
DiscordRPC.appId = "1511890016069222471"

function DiscordRPC.load()
    fileLogger:LogToFile("discord-rpc", "DiscordRPC Wrapper: Module loading started.")

    local success = rpc.initialize(DiscordRPC.appId)
    if success then
        DiscordRPC.enabled = true
        DiscordRPC.statusLog = "Initialized"

        fileLogger:LogToFile("discord-rpc", "DiscordRPC Wrapper: Initialization successful.")

        DiscordRPC.updateStatus()
    else
        DiscordRPC.statusLog = "Failed to initialize"

        fileLogger:LogToFile("discord-rpc", "DiscordRPC Wrapper CRITICAL: Initialization failed.")
    end
end

function DiscordRPC.draw()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print("RPC Status: " .. DiscordRPC.statusLog, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end

function DiscordRPC.update(dt)
    if not DiscordRPC.enabled then return end

    rpc.runCallbacks()
end

function DiscordRPC.updateStatus(details, state, partySize, partyMax, showTimestamp)
    if not DiscordRPC.enabled then return end

    fileLogger:LogToFile("discord-rpc", "DiscordRPC Wrapper: Processing status update request -> " .. tostring(details))

    local activityPayload = {
        details = (details and details ~= "") and details or "Browsing...",
        state = (state and state ~= "") and state or "In Menu",
        assets = {
            large_image = "orange",
            large_text = "Fruity Maze",
        }
    }

    if partySize and partyMax and partySize > 0 and partyMax > 0 then
        activityPayload.party = {
            size = { partySize, partyMax }
        }
    end

    if showTimestamp then
        activityPayload.timestamps = { start = os.time() }
    end

    rpc.updatePresence(activityPayload)
    DiscordRPC.statusLog = "Updated" .. (details and details ~= "" and " (" .. details .. ")" or "")
    fileLogger:LogToFile("discord-rpc", "DiscordRPC Wrapper: Dispatched update to socket layer.")
end

function DiscordRPC.shutdown()
    if not DiscordRPC.enabled then return end

    fileLogger:LogToFile("discord-rpc", "DiscordRPC Wrapper: Game closing, commanding shutdown.")
    rpc.shutdown()
end

return DiscordRPC
