XEventManager = XEventManager or {}

local ListenersMap = {}
local DelayRemoveMap = {}
local IsRunning = false

function XEventManager.AddEventListener(eventId, func, obj)
    local listenerList = ListenersMap[eventId]
    if (not listenerList) then
        listenerList = {}
    end

    local funcList = listenerList[func]
    if (obj) then
        if (not funcList) then
            funcList = {}
        end
        funcList[obj] = obj
        listenerList[func] = funcList
    else
        listenerList[func] = func
    end

    ListenersMap[eventId] = listenerList
    return { eventId, func, obj }
end

function XEventManager.RemoveEventListener(eventId, func, obj)
    if IsRunning then
        DelayRemoveMap[eventId] = DelayRemoveMap[eventId] or {}
        DelayRemoveMap[eventId][func] = DelayRemoveMap[eventId][func] or {}
        if obj then
            DelayRemoveMap[eventId][func][obj] = true
        else
            DelayRemoveMap[eventId][func][func] = true
        end
        return 
    end
    local listenerList = ListenersMap[eventId]
    if (not listenerList) then
        return
    end

    local funcList = listenerList[func]
    if (obj) then
        if (not funcList) then
            return
        end
        funcList[obj] = nil
        listenerList[func] = funcList
    else
        listenerList[func] = nil
    end

    ListenersMap[eventId] = listenerList
end

function XEventManager.RemoveAllListener()
    ListenersMap = {}
end

function XEventManager.DispatchEvent(eventId, ...)
    local listenerList = ListenersMap[eventId]
    if (not listenerList) then
        return
    end
    IsRunning = true
    for f, listener in pairs(listenerList) do
        if (type(listener) == "table") then
            for _, obj in pairs(listener) do
                if not DelayRemoveMap[eventId] or not DelayRemoveMap[eventId][f] or not DelayRemoveMap[eventId][f][obj] or not DelayRemoveMap[eventId][f][f] then
                    f(obj, ...)
                end
            end
        else
            if not DelayRemoveMap[eventId] or not DelayRemoveMap[eventId][f] or not DelayRemoveMap[eventId][f][f] then
                f(...)
            end
        end
    end
    IsRunning = false
    if next(DelayRemoveMap) then
        for rmId , rmEventList in pairs(DelayRemoveMap) do
            for rmF , rmFunclist in pairs(rmEventList) do
                for obj , _ in pairs(rmFunclist) do
                    if obj == rmF then
                        XEventManager.RemoveEventListener(rmId, rmF)
                    else
                        XEventManager.RemoveEventListener(rmId, rmF, obj)
                    end
                end
            end
        end
        DelayRemoveMap = {}
    end
end

------ 添加节点的绑定 --------
local NodeEventBindRecord = {}

function XEventManager.BindEvent(node, eventId, func, obj )
    if not NodeEventBindRecord[node] then
        NodeEventBindRecord[node] = {}
    end
    local checkExist
    if node.Exist then
        checkExist = function() return node:Exist() end
    else
        local gameObject = node.GameObject or node.gameObject or node.Transform or node.transform
        if gameObject and gameObject.Exist then
            checkExist = function() return gameObject:Exist() end
        end
    end
    local handler
    if checkExist then
        handler = XEventManager.AddEventListener(eventId, function(...)
            if not checkExist() then
                XEventManager.UnBindEvent(node)
            else
                if obj then
                    func(obj, ...)
                else
                    func(...)
                end
            end
        end)
    else
        handler = XEventManager.AddEventListener(eventId, func, obj)
    end
    table.insert(NodeEventBindRecord[node], handler)
    return handler
end

function XEventManager.UnBindEvent(node)
    if NodeEventBindRecord[node] then
        for _,v in ipairs(NodeEventBindRecord[node]) do
            XEventManager.RemoveEventListener(table.unpack(v))
        end
        NodeEventBindRecord[node] = nil
    end
end