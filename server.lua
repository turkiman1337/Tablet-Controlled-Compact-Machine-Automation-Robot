local component = require("component")
local sides = require("sides")
local thread = require("thread")
local event = require("event")

local modem = component.modem
local rs = component.block_refinedstorage_interface
local tunnel = component.tunnel

modem.open(69)
modem.setStrength(20)

--Gets status from the Robot and forwards it to the Tablet
local stRbt = thread.create(function()
while true do
local _, _, from, port, _, message = event.pull("modem_message")
print("got "..message.." from "..from.." on port "..port)
if(port==69)
   then
tunnel.send(message)
end
end
end)

-- Gets config from the Tablet and forwards it to the Robot
local stTblt = thread.create(function()
local channel = tunnel.getChannel()
while (true) do
local _, _, from, _, _, message = event.pull("modem_message")
if (from == channel) then
modem.broadcast(68, message)
end
end
end)
