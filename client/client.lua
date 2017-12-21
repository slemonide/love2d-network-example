local socket = require "socket"

client = {}
client.connected = false
client.address, client.port = "localhost", 12345

client.id = tostring(math.random(99999))
client.objects = {} -- Objects known to the client
client.updates = {} -- Objects to tell the server about

-- Converts given object to string
function client:toString(object)
    return object -- TODO: finish
end

-- Turn string into an object
function client:toObject(string)
    return string -- TODO: finish
end

function client:connect()
    client.udp = socket.udp()
    client.udp:settimeout(0)
    client.udp:setpeername(client.address, client.port)
    print("Connecting to server", client.address, "at", client.port)

    client.id = tostring(math.random(99999))

    client.udp:send(string.format("%s %s $", client.id, 'connect'))

    client.connected = true

    while (client.connected) do
        if (math.random() > 0.99) then
            client.updates[math.random(9999)] = tostring(math.random(99999))
        end

        for index, update in ipairs(client.updates) do
            if (client.objects[i] and client.objects[i] ~= update) then
                print("Ignoring update", index, update)
            else
                client.udp:send(string.format("%s %s %d %s", client.id, 'update', index, client:toString(update)))
            end
        end

        repeat
            local data, msg = client.udp:receive()
            if data then
                local cmd, index, object = data:match("^(%S*) (%S*) (.*)")
                if cmd == 'update' then
                    assert(index and object)
                    index = tonumber(index)
                    object = client:toObject(object)

                    client.objects[index] = object
                    if (client.updates[index] and client.updates[index] == object) then
                        client.updates[index] = nil
                    end
                else
                    print("unrecognised command: " .. cmd)
                end
            elseif msg ~= 'timeout' then
                print("Network error: " .. tostring(msg))
            end
        until not data
    end
end