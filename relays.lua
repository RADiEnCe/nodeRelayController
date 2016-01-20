local relays = {} -- module interface

local rel = {["a"] = 6, ["b"] = 7, ["c"] = 5, ["d"] = 8}; -- define list of relays. Key: name. Value: gpio index

for k, v in pairs(rel) do
    gpio.mode(rel[k], gpio.OUTPUT)
end

function relays.on(name)
    gpio.write(rel[name], gpio.HIGH);
end

function relays.off(name)
    gpio.write(rel[name], gpio.LOW);
end

function relays.toggle(name)
    if(gpio.read(rel[name]) == 0)then 
        gpio.write(rel[name], gpio.HIGH);
    else
        gpio.write(rel[name], gpio.LOW);
    end
end

function relays.MQSendStatus(client)

end

return relays
