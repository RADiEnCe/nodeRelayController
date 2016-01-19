-- every setting is taken from the table in config.lua
-- passes command strings to global function handleCommand(commandString)
-- commad topic: cmd and nodeID/cmd

m = mqtt.Client(CONFIG.NODENAME, 15, CONFIG.MQTT.USERNAME, CONFIG.MQTT.PASSWORD)
-- function for connection and reconnection. executed once on start and on offline
MQConnect = function()
    m:connect(CONFIG.MQTT.SERVER, 17440, 0, function(conn)
    print("reconnected")
    m:subscribe(CONFIG.NODENAME.."/cmd",1, function(conn) print("subscribed to "..CONFIG.NODENAME.."/cmd")
    m:subscribe("cmd", 1, function(conn) print("subscribe success to ".."cmd" end)
end

-- predefine reactions to various things
m:lwt("lwt", CONFIG.NODENAME.."ABRUPTLY DISCONNECTED. THIS IS A LWT", 0, 0)
m:on("connect", function(con) print ("connected") end)
-- reconnect when offline
m:on("offline", function(con)
    print ("offline..reconnecting")
    MQConnect()
end)
end)
m:on("message", function(conn, topic, data)
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
        m:connect(CONFIG.MQTT.SERVER, 17440, 0, function(conn) -- and connect and subscribe
            print ("connected to server")
            m:subscribe(CONFIG.NODENAME.."/cmd",0, function(conn) print("subscribe success") end)
        end)
     else
        print("nowifi. waiting 1 more second to connect mqtt")
    end
end)

return m
