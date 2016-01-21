local relays = {} -- module interface

local rel = {["a"] = 5, ["b"] = 6, ["c"] = 7, ["d"] = 8}; -- define list of relays. Key: name. Value: gpio index

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

function relays.getJsonStatus()
    local currentRelayStatus = {}                  -- temporary holder
    for name, idx in pairs(rel) do          -- iterate over all relays
        currentRelayStatus[name] = gpio.read(idx)  -- gpio read status. 1 on, 0 off
    end
    return cjson.encode(currentRelayStatus)        -- encode in json string and return
end

function relays.setJsonStatus(jsonString)
    local targetRelayStatus = cjson.decode(jsonString)
    for name, status in pairs(targetRelayStatus) do
        if(rel[name] and (status == 1 or status == 0)) then -- only set if there's a relay to set and the status is valid
            gpio.write(rel[name], status)
        end
    end
end

return relays
