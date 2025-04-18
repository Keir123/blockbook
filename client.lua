local component = require("component")
local event = require("event")
local term = require("term")
local modem = component.modem
local serialization = require("serialization")
local name="NULL"

ServerAddress = ""
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

function getServerIp()
    modem.broadcast(999,serialization.serialize({"LOCATEBLOCKBOOKSERVER"}))
    local response=true
    while response do
        local _, _, from, port, _, message = event.pull("modem_message")
        print("Recived: " .. tostring(message) .. "from" .. tostring(from))
        local inMessage = serialization.unserialize(tostring(message))
        if (inMessage[1]=="BLOCKBOOKADDRESS") then
            response=false
            ServerAddress=inMessage[2]
        end
    end
end

function drawPost()
end


getServerIp()
term.write("Enter Username: ")
name = term.read()

print("Recived: " .. tostring(getPostList()))
makePost("Test123")
print("Recived: " .. tostring(getPostList()))


