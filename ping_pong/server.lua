local socket = require "socket"
local udp = socket.udp()
udp:settimeout(0)
udp:setsockname('*', 12345)

while (true) do
    local data, ip, port = udp:receivefrom()
    if (data) then
        print(data)
        udp:sendto("pong", ip, port)
    end
end