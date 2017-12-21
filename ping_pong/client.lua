local socket = require "socket"
local udp = socket.udp()
udp:settimeout(0)
udp:setpeername("localhost", 12345)

udp:send("ping")

while (true) do
    repeat
        local data, msg = udp:receive()
        if data then
            print(data)
            udp:send("ping")
        end
    until not data
end