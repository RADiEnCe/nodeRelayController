require("config") -- load config
--connect to wifi
wifi.setmode(wifi.STATION)
wifi.sta.config(CONFIG.WIFI.SSID, CONFIG.WIFI.PASSWORD)

-- define hardware
--      relays
relays = require("relays")


-- prepare to parse comands
commandTable = {
    ["on"] = relays.on,
    ["off"] = relays.off,
    ["toggle"] = relays.toggle
}
function handleCommand(commandString)
    print("handling "..commandString)
    _, _, relayName, cmd = string.find(commandString, "(%w+):(%w+)")
    commandTable[cmd](relayName)
end

--mqtt client
mqttClient = require("mqclient")

-- todo: add code to respond to get status commands
