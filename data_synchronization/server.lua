local socket = require "socket"
local serpent = require("serpent")
local udp = socket.udp()
udp:settimeout(0)
udp:setsockname('*', 12345)

local world = {}
local clients = {}

for x = 1, 60 do
    if (not world[x]) then
        world[x] = {}
    end
    for y = 1, 11 do
        world[x][y] = (math.random() > 0.9 and "#" or " ")
    end
end

while (true) do
    local data, ip, port = udp:receivefrom()
    if (data) then
        local id, cmd, parms = data:match("^(%S*) (%S*) (.*)")
        if (cmd == "connect") then
            clients[id] = {
                ip = ip,
                port = port
            }
        elseif (cmd == "set") then
            local x, y, state = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*) (%S*)$")
            assert(x and y) -- validation is better, but asserts will serve.
            x, y = tonumber(x), tonumber(y)

            world[x][y] = state
        else
            print("Unknown command:", data)
        end
    end

    for _, client in pairs(clients) do
        udp:sendto(serpent.dump(world, {name = 'world'}), client.ip, client.port)
    end
end