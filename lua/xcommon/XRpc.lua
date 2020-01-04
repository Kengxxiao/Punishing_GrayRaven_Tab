XRpc = XRpc or {}

local handlers = {}

function XRpc.Do(name, content)
    local handler = handlers[name]
    if handler == nil then
        XLog.Error("XRpc Do error, handler not exist, name: " .. name)
        return
    end

    local request, error = XMessagePack.Decode(content)
    if request == nil then
        XLog.Error("XRpc Do error, content decode error, error: " .. error)
        return
    end

    handler(request)
end

setmetatable(XRpc, {
    __newindex = function(_, name, handler)
        if type(name) ~= "string" then
            XLog.Error("XRpc register handler error, name type not string, type: " .. type(name))
            return
        end

        if type(handler) ~= "function" then
            XLog.Error("XRpc register handler error, handler type not function, type: " .. type(handler))
            return
        end

        if handlers[name] == nil then
            handlers[name] = handler
        else
            XLog.Error("XRpc register handler repeat, name: " .. name)
        end
    end,
})

XRpc.TestRequest = function(request)
    XLog.Warning(request);
end
