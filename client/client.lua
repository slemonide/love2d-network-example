local socket = require "socket"

client = {}
client.connected = false
client.address, client.port = "localhost", 12345

client.id = tostring(math.random(99999))
client.objects = {} -- Objects known to the client
client.updates = {} -- Objects to tell the server about
-- note: all objects are strings

function client:connect()
    math.randomseed(os.time())

    client.udp = socket.udp()
    client.udp:settimeout(0)
    client.udp:setpeername(client.address, client.port)
    print("Connecting to server", client.address, "at", client.port)

    client.id = tostring(math.random(99999))

    client.udp:send(string.format("%s %s $ $", client.id, 'connect'))

    client.connected = true

    while (client.connected) do
        if (math.random() > 0.9999999) then
            client.updates[math.random(9999)] = tostring(math.random(99999))
        end

        for index, update in ipairs(client.updates) do
            if (client.objects[i] and client.objects[i] ~= update) then
                print("Ignoring update", index, update)
            else
                client.udp:send(string.format("%s %s %d %s", client.id, 'update', index, update))
            end
        end

        repeat
            local data, msg = client.udp:receive()
            if data then
                print("Data received")
                local cmd, index, object = data:match("^(%S*) (%S*) (.*)")
                if cmd == 'update' then
                    assert(index and object)
                    index = tonumber(index)
                    object = client:toObject(object)

                    client.objects[index] = object
                    print("Setting", index, "to", object)
                    if (client.updates[index] and client.updates[index] == object) then
                        client.updates[index] = nil
                    end
                else
                    print("unrecognised command: " .. cmd)
                end
            elseif msg ~= 'timeout' then
                error("Network error: " .. tostring(msg))
            end
        until not data
    end
end