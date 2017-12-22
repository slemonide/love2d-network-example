local socket = require "socket"
local udp = socket.udp()
udp:settimeout(0)
udp:setpeername("localhost", 12345)

local id = tostring(math.random(99999))
local updateNum = 0
udp:send(string.format("%s %s $", id, 'connect'))

local function main ()
    math.randomseed(os.time())
    while (true) do
        repeat
            local data, msg = udp:receive()
            if data then
                local next_id, cmd, parms = data:match("^(%S*) (%S*) (.*)")
                print(updateNum, data:sub(0, 30))
                updateNum = updateNum + 1
            end
        until not data

        if (math.random() > 0.99999) then
            local msg = ""

            for i = 1, 1000 do
                msg = msg .. tostring(math.random(99999999))
            end

            udp:send(string.format("%s %s %s", id, 'set', msg))
        end
    end
end

main()