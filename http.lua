--init http server
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)

        --parse request
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        local _on,_off = "","";

        --execute command
        handleCommand(_GET.nrel, _GET.cmd);

        --prepare response
        sortedNames = {}
        for k, v in pairs(rel) do table.insert(sortedNames, k) end
        table.sort(sortedNames)
        local buf = "<h1> ESP8266 Web Server</h1>";
        for k, v in pairs(sortedNames) do
            buf = buf .. string.format("<p>Relay %s <a href=\"?nrel=%s&cmd=ON\"><button>ON</button></a>&nbsp;<a href=\"?nrel=%s&cmd=OFF\"><button>OFF</button></a></p>", v, v, v);
        end
        
        --send responle and close client
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
