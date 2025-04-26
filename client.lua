local component = require("component")
local event = require("event")
local term = require("term")
local modem = component.modem
local serialization = require("serialization")
local gpu = component.gpu
local name="NULL"

local screenWidth, screenHeight = gpu.getViewport()
local postOffset = 0



ServerAddress = ""
print(component.modem.address)

modem.setStrength(9999)

modem.open(999)


function getPostList()
    local outMessage = {"GETPOSTLIST"}
    modem.send(ServerAddress,999,serialization.serialize(outMessage))
    local response=true
    local postList=nil
    while response do
        local _, _, from, port, _, message = event.pull("modem_message")
        --print("Recived: " .. tostring(message) .. "from" .. tostring(from))
        if (from==ServerAddress) then
            response=false
            postList=serialization.unserialize(message)
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
        --print("Recived: " .. tostring(message) .. "from" .. tostring(from))
        local inMessage = serialization.unserialize(tostring(message))
        if (inMessage[1]=="BLOCKBOOKADDRESS") then
            response=false
            ServerAddress=inMessage[2]
        end
    end
end

function drawPost(post,y,totalOffset) --author, name
   local oldBackground = gpu.getBackground()
   local offset = ((screenHeight/10)*y)+2
   gpu.setBackground(0x2a3d56)
   gpu.fill(1,offset,screenWidth,(screenHeight/10)," ")
   gpu.set(1,offset+1,post[1])
   gpu.set(1,offset+2,tostring(totalOffset))
   gpu.set(1,offset+3,post[2])
   gpu.setBackground(oldBackground)
end

function drawPostList(posts,offset)
    term.clear()
    drawTitleBar(1)
    for i = 1, 8 do
        if posts[i+offset]==nil then
            break
        end
        drawPost(posts[i+offset],i-1,i+offset)
    end
end

function drawAccountView()
    term.clear()
    drawTitleBar(0)
    gpu.set(screenHeight/2,3,"Press Space to exit")
end

function drawCreateView()
    term.clear()
    drawTitleBar(2)
    --gpu.set(screenWidth/2,2,"CREATE VIEW")
    print()
    print("Leave empty to go back")
    local postContent = term.read()
    postContent= string.sub(postContent,1,-2)
    if postContent=="" then
        return
    end
    makePost(postContent)
end

function drawTitleBar(index)
    local titles = {"Account","Home","Create"}
    for i=0, 2 do
        gpu.setBackground(0x000000)
        if index==i then
            gpu.setBackground(0x2a3d56)
        end
        gpu.fill((screenWidth/3)*i,1,screenWidth/3,1," ")
        gpu.set((screenWidth/3)*i,1,titles[i+1])
    end
    gpu.setBackground(0x000000)
end

gpu.fill(1,1,screenWidth,screenHeight, " ")
getServerIp()
term.write("Enter Username: ")
name = term.read()
name = string.sub(name,1,-2)
local postList = getPostList()
drawPostList(postList,postOffset)


local clientState = 1 -- 0 account view
                      -- 1 main view
                      -- 2 create view

local newState =false
local postList = getPostList()

while true do
    local keyboardAddress, char, code, playerName = event.pull("key_down")
    if code==97 then -- left tab
        clientState =clientState -1
        if clientState<0 then
            clientState=0
        end
        postOffset=0
    end
    if code==100 then -- right tab
        clientState =clientState +1
        if clientState>2 then
            clientState=2
        end
        postOffset=0
    end
    if code==119 and clientState == 1 then -- scroll up
        postOffset=postOffset-8
        if postOffset<0 then
            postOffset=0
        end
    end
    if code==115 and clientState == 1 then -- scroll down
        if postOffset+8<#postList then
            postOffset= postOffset+8
        end
    end
    if code==114 and clientState == 1 then --refresh
        postList = getPostList()
        postOffset=0
    end
    if code==32 and  clientState == 0 then
        break
    end

    if clientState == 0 then
        drawAccountView()
    end

    if clientState == 1 then
        drawPostList(postList,postOffset)
    end
    
    if clientState == 2 then
        drawCreateView()
        clientState=1
        drawPostList(postList,postOffset)
    end

end

term.clear()

