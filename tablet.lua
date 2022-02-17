local component = require("component")
local gpu = component.gpu
gpu.setResolution(80,25)
local gui = require("gui")
local event = require("event")
local thread = require("thread")
local tunnel = component.tunnel

gui.checkVersion(2,5)
 
local prgName = "compactmgr"
local version = "v1.0"
 
-- Begin: Callbacks
local function button_0_callback(guiID, buttonID)
   if(status=="complete" or status=="ready") then
    tunnel.send("giant.cfg")
end
end
 
local function button_1_callback(guiID, buttonID)
if(status=="complete" or status=="ready") then
    tunnel.send("normal.cfg")
end
end
 
local function exitButtonCallback(guiID, id)
   local result = gui.getYesNo("", "Do you really want to exit?", "")
   if result == true then
      gui.exit()
   end
   gui.displayGui(mainGui)
   refresh()
end
-- End: Callbacks
 
-- Begin: Menu definitions
mainGui = gui.newGui(1, 2, 79, 23, true)
frame_0 = gui.newFrame(mainGui, 25, 3, 25, 5, "Giant Machine")
frame_1 = gui.newFrame(mainGui, 25, 11, 25, 5, "Normal Machine")
button_0 = gui.newButton(mainGui, 32, 5, "Request", button_0_callback)
button_1 = gui.newButton(mainGui, 32, 13, "Request", button_1_callback)
label_0 = gui.newLabel(mainGui, 31, 19, "status", 0x0, 0xff0000, 11)
exitButton = gui.newButton(mainGui, 73, 23, "exit", exitButtonCallback)
-- End: Menu definitions
 
gui.clearScreen()
gui.setTop("Compact Machine Manager")
gui.setBottom("")
 
--Status
local status = "ready"

--Threads
local t = thread.create(function()
while true do
local _, _, _, _, _, message = event.pull("modem_message")
status=message
end
end)
    
-- Main loop
while true do
   gui.runGui(mainGui)
   gui.setText(mainGui, label_0, status, true)
end
