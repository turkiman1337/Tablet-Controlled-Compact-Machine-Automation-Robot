component = require("component")
magic = require("magic")
event = require("event")
modem = component.modem
thread = require("thread")

while true do
local _, _, from, port, _, message = event.pull("modem_message")
magic.activate(message)
end
