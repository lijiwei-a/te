local Event=require("event")
local modem=component.modem
aliveComputer={}

local function handleScanComputer(_,_,remote,port,_,...)
    msg={...}
    if port~=1337 then
      return
    end
    if msg[2]==nil then
      return
    end
    if msg[1]=="PING" then
      modem.send(remote,1337,"PONG",msg[2])
      return
    end
    if msg[1]=="PONG" then
      table.insert(aliveComputer,remote)
      return
    end
end

function sendPingPacket()
  aliveComputer={}
  modem.broadcast(1337,"PING",math.random(math.pow(2,63)))
end
if modem then
  modem.open(1337)
  Event.listen("modem_message",handleScanComputer)
  sendPingPacket()
end