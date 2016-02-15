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

function relays.setState(state)
    -- can take either a relay status table or a json string

    -- convert string to table. do nothing to table
    if(type(state) ~= "table") then
        if(type(state) ~= "string") then print("Error setting Json state: state not string or table")
        else
            local decodeSuccess, decodeRet = pcall(function() return cjson.decode(state) end)
            if(decodeSuccess) then
                state = decodeRet
            else
                print("Invalid Json string: "..state)
                return
            end
        end
    end
    
    for name, on in pairs(state) do
        if(rel[name] and (on == 1 or on == 0)) then -- only set if there's a relay to set and the status is valid
            gpio.write(rel[name], on)
        end
    end
end

return relays
