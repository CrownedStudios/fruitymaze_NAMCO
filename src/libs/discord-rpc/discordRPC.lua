-- crwn/ hell

local socket = require("socket")
local json = require("libs.json.json")

local fileLogger = require("scripts.util.FileLogger")

local RPC = {}
local client = nil
local seq = 0

function RPC.initialize(appId)
    fileLogger:LogToFile("discord-rpc", "RPC Socket: Attempting WebSocket connection to Discord on port 6463...")

    client = socket.tcp()
    client:settimeout(1.0)

    if not client:connect("127.0.0.1", 6463) then
        fileLogger:LogToFile("discord-rpc",
            "RPC Socket CRITICAL: Could not connect to Discord port 6463. Is Discord running?")
        client:close()
        client = nil
        return false
    end

    local handshake = table.concat({
        "GET /?v=1&client_id=" .. appId .. " HTTP/1.1",
        "Host: 127.0.0.1:6463",
        "Upgrade: websocket",
        "Connection: Upgrade",
        "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==",
        "Origin: https://discord.com",
        "Sec-WebSocket-Version: 13",
        "", ""
    }, "\r\n")

    client:send(handshake)

    local status_line, err = client:receive("*l")
    if not status_line or not status_line:find("101 Switching Protocols") then
        fileLogger:LogToFile("discord-rpc",
            "RPC Socket CRITICAL: Discord rejected handshake: " .. tostring(status_line or err))
        client:close()
        client = nil
        return false
    end

    while true do
        local line = client:receive("*l")
        if not line or line == "" then break end
    end

    fileLogger:LogToFile("discord-rpc", "RPC Socket: WebSocket handshake accepted! Pipeline upgraded successfully.")
    client:settimeout(0)
    return true
end

function RPC.send(payload)
    if not client then return end

    local data = json.encode(payload)
    fileLogger:LogToFile("discord-rpc", "RPC Socket Outbound WebSocket Payload: " .. data)

    local len = #data
    local header

    if len <= 125 then
        header = love.data.pack("string", ">B B", 0x81, len + 128)
    else
        header = love.data.pack("string", ">B B I2", 0x81, 254, len)
    end

    local mask = "\0\0\0\0"

    client:send(header .. mask .. data)
end

function RPC.updatePresence(presence)
    seq = seq + 1
    local msg = {
        cmd = "SET_ACTIVITY",
        args = {
            pid = love.system.getPID and love.system.getPID() or 9999,
            activity = presence
        },
        nonce = tostring(seq)
    }
    RPC.send(msg)
end

function RPC.runCallbacks()
    if not client then return end

    local data, _, partial = client:receive(2048)
    local inbound = data or partial

    if inbound and #inbound > 2 then
        local json_start = inbound:find("{")
        if json_start then
            local json_str = inbound:sub(json_start)
            fileLogger:LogToFile("discord-rpc", "RPC Socket Inbound Response: " .. json_str)
        end
    end
end

function RPC.shutdown()
    if client then
        fileLogger:LogToFile("discord-rpc", "RPC Socket: Closing connection cleanly.")
        client:close()
        client = nil
    end
end

return RPC
