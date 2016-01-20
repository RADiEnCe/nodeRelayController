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

    --m:connect(CONFIG.MQTT.SERVER, 17440, 0, function(conn)

    -- predefine reactions to various things
    -- make the server scream when abruptly disconnected
    m:lwt("lwt", CONFIG.NODENAME..":abruptly disconnected", 0, 0)

    -- EVENTS
        -- on connect, subscribe
        m:on("connect", function(client) 
            m:subscribe("cmd", 1)
            m:subscribe(CONFIG.NODENAME.."/cmd", 1)
        end)
        -- on offline, reconnect
        m:on("offline", function(client)
            print ("offline..reconnecting")
            m:connect(CONFIG.MQTT.SERVER, 17440, 0)
        end)
        -- on message, parse
        m:on("message", function(client, topic, data)
            print(topic .. ':');
            print(data);
            if(topic == CONFIG.NODENAME.."/cmd")then
                print("is command topic. passing command")
                handleCommand(data)
            end
        end)

    -- wait for wifi, then connect
    tmr.alarm(0, 1000, 1, function() -- alarm id 0, every 1000ms, repeat 1
        if(wifi.sta.status() == 5)then
            tmr.stop(0) -- stop alarm 0
            print("Initializing Connection...")
            m:connect(CONFIG.MQTT.SERVER, 17440, 0)
        else
            print("nowifi. waiting 1 more second to connect mqtt")
        end
    end)
--end mqtt client

-- todo: add code to respond to get status commands
