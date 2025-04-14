local component = require("component")
local event = require("event")
local term = require("term")
local modem = component.modem
local serialization = require("serialization")
local name="NULL"

ServerAddress = "04a06fa8-e415-4c7b-b32e-d1cfd0c9a97a"
print(component.modem.address)

modem.open(999)


function getPostList()
    local outMessage = {"GETPOSTLIST"}
    modem.send(ServerAddress,999,serialization.serialize(outMessage))
    local response=true
    local postList=nil
    while response do
        local _, _, from, port, _, message = event.pull("modem_message")
        print("Recived: " .. tostring(message) .. "from" .. tostring(from))
        if (from==ServerAddress) then
            response=false
            postList=message
        end
    end
    return postList
end

function makePost(post)
    local outMessage = {"MAKEPOST",name,post}
    modem.send(ServerAddress,999,serialization.serialize(outMessage))
end
term.write("Enter Username: ")
name = term.read()

print("Recived: " .. tostring(getPostList()))
makePost("Test123")
print("Recived: " .. tostring(getPostList()))


