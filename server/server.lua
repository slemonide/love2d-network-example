local socket = require "socket"

server = {}
server.running = false
server.udp = socket.udp()
server.delayCounter = 0
server.updateRate = 10 -- how often to request updates from the clients (in units of server:update() calls)

-- Contains all currently connected clients
server.clients = {}

-- Contains objects that clients might be interested in
-- All objects are strings
server.objects = {}

-- Sends updates to clients (this also requests update from clients)
function server:updateClients()
    for _, client in ipairs(server.clients) do
        -- A crude and simple version for now
        -- TODO: improve
        for i, object in ipairs(server.objects) do
            --if (not (client.objects[i] and client.objects[i] == server.objects[i])) then
                server.udp:sendto(string.format("update %d %s", i, object), client.ip, client.port)
                client.objects[i] = server.objects[i]
            --end
        end
    end
end

function server:update()
    if (server.running) then
        local data, ip, port = server.udp:receivefrom()
        if data then
            local id, cmd, index, object = data:match("^(%S*) (%S*) (%S*) (.*)")
            if cmd == "connect" then
                if (server.clients[id]) then
                    print("Error: client is already connected")
                else
                    print("New client connected: " .. id)
                    server.clients[id] = {
                        ip = ip,
                        port = port,
                        objects = {}
                    }
                end
            elseif cmd == "disconnect" then
                print("Client " .. id .. " disconnects")
                if (not server.clients[id]) then
                    print("Error: client does not exist")
                else
                    print(id, "disconnected")
                    server.clients[id] = nil
                end
            elseif cmd == "update" then
                --print("Client " .. id .. " sends updates")
                if (not server.clients[id]) then
                    print("Error: client does not exist")
                else
                    assert(index and object)
                    index = tonumber(index)
                    print("Update from ", id)
                    --print("Setting ", index, "to", object)

                    server.objects[index] = object
                end
            else
                print("unrecognised command: ", cmd)
            end
        elseif msg_or_ip ~= 'timeout' then
            --print("Unknown network error: " .. tostring(msg))
        end

        socket.sleep(0.01)

        if (server.delayCounter > server.updateRate) then
            server:updateClients()

            server.delayCounter = 0
        else
            server.delayCounter = server.delayCounter + 1
        end
    end
end

-- Start the server
function server:start()
    math.randomseed(os.time())

    server.udp:settimeout(0)
    server.udp:setsockname('*', 12345)
    server.running = true

    print("Server started")

    while (server.running) do
        server:update()
    end
end