local component = require("component")
local event = require("event")
local modem = component.modem
local serialization = require("serialization")



local messageHistory = {}

local accounts = {}

print(component.modem.address)
modem.setStrength(9999)


modem.open(999)


local exit = true
while exit do
    local _, _, from, port, _, message = event.pull("modem_message")
    --print("Recived: " .. tostring(message) .. "from" .. tostring(from))
    print(tostring(message))
    local inMessage = serialization.unserialize(tostring(message))
    print("Recived: " .. inMessage[1] .. "from" .. tostring(from))

    if inMessage[1]=="LOCATEBLOCKBOOKSERVER" then
        modem.send(from,999,serialization.serialize({"BLOCKBOOKADDRESS",component.modem.address}))
    end

    if inMessage[1]=="LOGIN" then
        
    end

    if inMessage[1]=="GETPOSTLIST" then
        modem.send(from,999,serialization.serialize(messageHistory))
    end
    if inMessage[1]== "MAKEPOST" then
        table.insert(messageHistory,1,{inMessage[2],inMessage[3]})
    end
end
