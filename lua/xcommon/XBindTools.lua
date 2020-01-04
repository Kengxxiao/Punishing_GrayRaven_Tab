local rawget = rawget
local rawset = rawset
local getmetatable = getmetatable
local setmetatable = setmetatable

XBindTool = XBindTool or {}

local oldIpairs = ipairs
local oldPairs = pairs

ipairs = function(arr)
    local meta_t = getmetatable(arr)
    if meta_t and meta_t.__ipairs then
        return meta_t.__ipairs(arr)
    end
    return oldIpairs(arr)
end

pairs = function(arr)
    local meta_t = getmetatable(arr)
    if meta_t and meta_t.__pairs then
        return meta_t.__pairs(arr)
    end
    return oldPairs(arr)
end

local function InitBind(obj)
    if rawget(obj, "___isBinded") then return end
    
    local store = {}
    for key, v in pairs(obj) do
        v = rawget(obj, key)
        if v ~= nil then
            store[key] = v
            obj[key] = nil
        end
    end

    local meta_t = getmetatable(obj)
    if meta_t then setmetatable(store, meta_t) end

    setmetatable(obj, {
        __index = function(t, index)
            local ret = rawget(obj, index)
            if ret ~= nil then return ret end
            return store[index]
        end,
        __newindex = function(t, index, v)
            local event = rawget(obj, "___bind_event")
            local old_v = store[index]
            store[index] = v
            if old_v ~= v then
                if event and event[index] then
                    event[index].running = true
                    for key, func in pairs(event[index].callList) do
                        if not event[index].removeList[key] then
                            func(v, old_v)
                        end
                    end
                    event[index].running = nil
                    if next(event[index].removeList) then
                        for removeIndex, _ in pairs(event[index].removeList) do
                            event[index].callList[removeIndex] = nil
                        end
                        event[index].removeList = {}
                    end
                end
            end
        end,
        __ipairs = function(t)
            return oldIpairs(store)
        end,
        __pairs = function(t)
            return oldPairs(store)
        end
    })

    rawset(obj, "___isBinded", true)
    rawset(obj, "___bind_store", store)
    rawset(obj, "___bind_event", {})
    rawset(obj, "___bind_id", 0)
end

function XBindTool.BindAttr(obj, attr, callback)
    InitBind(obj)

    local event = rawget(obj, "___bind_event")
    local id = rawget(obj, "___bind_id")
    event[attr] = event[attr] or { callList = {}, removeList = {} }
    id = id + 1
    rawset(obj, "___bind_id", id)
    event[attr].callList[id] = callback
    
    local value = obj[attr]
    if value ~= nil then
        callback(value)
    end
    return { obj = obj, attr = attr, id = id }
end

function XBindTool.GetBindInfo(val)
    if type(val) ~= "table" then return val, false end
    if not rawget(val, "___isBinded") then return val, false end
    return rawget(val, "___bind_store"), true
end

function XBindTool.UnBind(handle)
    local event = rawget(handle.obj, "___bind_event")
    if event and event[handle.attr] then
        if event[handle.attr].running then
            event[handle.attr].removeList[handle.id] = true
        else
            event[handle.attr].callList[handle.id] = nil
        end
    end
end

function XBindTool.UnBindObj(obj)
    local event = rawget(obj, "___bind_event")
    if event then
        for _, attrListener in pairs(event) do
            if attrListener.running then
                for key, _ in pairs(attrListener.callList) do
                    attrListener.removeList[key] = true
                end
            end
        end
        rawset(obj, "___bind_event", {})
    end
end

local NodeBindInfoRecord = {}

function XBindTool.BindNode(node, obj, attr, func, unbindFunc)
    if not NodeBindInfoRecord[node] then
        NodeBindInfoRecord[node] = {}
    end
    local bindInfo = NodeBindInfoRecord[node]
    bindInfo[obj] = bindInfo[obj] or { length = 0, record = {} }
    local checkExist
    if node.Exist then
        checkExist = function() return node:Exist() end
    else
        local gameObject = node.GameObject or node.gameObject or node.Transform or node.transform
        if gameObject and gameObject.Exist then
            checkExist = function() return gameObject:Exist() end
        end
    end
    local handle
    if checkExist then
        handle = XBindTool.BindAttr(obj, attr, function(...)
            if not checkExist() then
                XBindTool.UnBindNode(node)
                if unbindFunc then
                    unbindFunc()
                end
            else
                func(...)
            end
        end)
    else
        handle = XBindTool.BindAttr(obj, attr, func)
    end

    bindInfo[obj].record[handle.id] = handle
    bindInfo[obj].length = bindInfo[obj].length + 1
    return handle
end

function XBindTool.UnBindNode(node)
    local bindInfo = NodeBindInfoRecord[node]
    if bindInfo then
        for key, val in pairs(bindInfo) do
            for _, item in pairs(val.record) do
                XBindTool.UnBind(item)
            end
            bindInfo[key] = nil
        end
        NodeBindInfoRecord[node] = nil
    end
end

function XBindTool:UnBindNodeHandler(node, handle)
    local bindInfo = NodeBindInfoRecord[node]
    if not bindInfo then return end
    local obj = handle.obj
    if bindInfo and bindInfo[obj] then
        XBindTool.UnBind(handle)
        bindInfo[obj].length = bindInfo[obj].length - 1
        bindInfo[obj].record[handle.id] = nil
        if bindInfo[obj].length == 0 then
            bindInfo[obj] = nil
        end
    end
end