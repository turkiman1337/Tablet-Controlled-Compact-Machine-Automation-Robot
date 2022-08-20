magic = require("magic")
event = require("event")

while true do
  local _, _, from, port, _, message = event.pull("modem_message")
  magic.activate(message)
end
