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
    ["toggle"] = relays.toggle,
    ["status"] = relays.MQSendStatus
}

function handleCommand(commandString)
    print("handling "..commandString)
    _, _, relayName, cmd = string.find(commandString, "(%w+):(%w+)")
    commandTable[cmd](relayName)
end

--mqtt client
    -- every setting is taken from the table in config.lua
    -- passes command strings to global function handleCommand(commandString)
    -- commad topic: cmd and nodeID/cmd
    m = mqtt.Client(CONFIG.NODENAME, 120, CONFIG.MQTT.USERNAME, CONFIG.MQTT.PASSWORD)
    mqConnected = false
    --m:connect(CONFIG.MQTT.SERVER, 17440, 0, function(conn)

    -- predefine reactions to various things
    -- make the server scream when abruptly disconnected
    m:lwt("lwt", CONFIG.NODENAME..":abruptly disconnected", 0, 0)

    do
        local wifiRetryCount = 0  -- add 1000 seconds to retry timer every time 
        function tryToConnect()
            -- wait for wifi, then connect
            tmr.alarm(0, 1000*wifiRetryCount + 10, 0, function() -- alarm id 0, every 1000ms, no repeat
                if(wifi.sta.status() == 5)then
                    wifiRetryCount = 0
                    if (not mqConnected)then
                        m:connect(CONFIG.MQTT.SERVER, 17440, 0)
                    end
                else
                    wifiRetryCount = wifiRetryCount + 1
                    print()
                    tryToConnect()
                end
            end)
        end
    end
    -- EVENTS
        -- on connect, subscribe
        m:on("connect", function(client) 
            m:subscribe("cmd", 1)
            m:subscribe(CONFIG.NODENAME.."/jset", 1)
            m:subscribe(CONFIG.NODENAME.."/cmd", 1, print("subscribed"))
            mqConnected = true
        end)
        -- on offline, reconnect
        m:on("offline", function(client)
            print ("offline..reconnecting")
            mqConnected = false
            tryToConnect()
        end)
        -- on message, parse
        m:on("message", function(client, topic, data)
            print(topic .. ':');
            print(data);
            if(topic == CONFIG.NODENAME.."/cmd")then
                print("is command topic. passing command")
                handleCommand(data)
            elseif(topic == CONFIG.NODENAME.."/jset")then
                print("is jsonCommand topic. passing command")
                relays.setState(data)
            end
        end)

tryToConnect()

tmr.alarm(1, 600000, 1, tryToConnect) -- alarm id 1. try to connect every 10min

--end mqtt client

-- todo: add code to respond to get status commands
