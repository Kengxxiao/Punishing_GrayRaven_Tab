--红点管理器
XRedPointManager = XRedPointManager or {}
require("XRedPoint/XRedPointConditions")

local RedPointEventDic = {}
local RedPointFiitterEvents = {}
local eventIdPool = 0

function XRedPointManager.Init()
    RedPointEventDic = RedPointEventDic or {}
    RedPointFiitterEvents = RedPointFiitterEvents or {}
end

--添加过滤
function XRedPointManager.AddRedPointFitterEvent(conditonId)
    if not XRedPointManager[conditonId] then
        XLog.Warning("Event type not found :" .. conditonId)
        return
    end

    RedPointFiitterEvents = RedPointFiitterEvents or {}
    RedPointFiitterEvents[conditonId] = conditonId
end

--移除过滤
function XRedPointManager.RemoveRedPointFitterEvent(conditonId)
    if not RedPointFiitterEvents or not RedPointFiitterEvents[conditonId] then
        return
    end

    RedPointFiitterEvents[conditonId] = nil
end


function XRedPointManager.GenarateEventId()
    eventIdPool = eventIdPool + 1
    return eventIdPool
end

--增加一个红点事件
function XRedPointManager.AddRedPointEvent(node,func,listener,conditionGroup,args,isCheck)

    if not node then
        XLog.Warning("该绑定节点为空，需要检查UI预设")
        return 
    end

    local eventId = XRedPointManager.GenarateEventId()

    --创建一个事件组
    local condition = XRedPointConditionGroup.New(conditionGroup)

    --创建监听者
    local pointListener = XRedPointListener.New()
    pointListener.listener = listener
    pointListener.func = func

    --创建红点事件
    local pointEvent = XRedPointEvent.New(eventId,node,condition,pointListener,args)
    RedPointEventDic[eventId] = pointEvent

    if isCheck == nil or isCheck == true then
        XRedPointManager.Check(eventId)
    end

    return eventId
end

--删除一个红点事件
function XRedPointManager.RemoveRedPointEvent(eventId)

    if RedPointEventDic == nil or not RedPointEventDic[eventId] then
        return
    end

    local pointEvent = RedPointEventDic[eventId]
    if pointEvent then
        pointEvent:Release()
    end

    RedPointEventDic[eventId] = nil
end

--删除一个红点事件
function XRedPointManager.RemoveRedPointEventOnly(eventId)
    if RedPointEventDic == nil or not RedPointEventDic[eventId] then
        return
    end

    RedPointEventDic[eventId] = nil
end

--检测红点
function XRedPointManager.Check(eventId,args)
    if not eventId or eventId <= 0 then
        return
    end

    if RedPointEventDic == nil or not RedPointEventDic[eventId] then
        return
    end

    local pointEvent = RedPointEventDic[eventId]

    if pointEvent then
        pointEvent:Check(args)
    end
end

--检测红点,直接判断不持有节点
function XRedPointManager.CheckOnce(func,listener,conditionGroup,args)
    local result = -1

    for i, v in ipairs(conditionGroup) do
        if XRedPointConditions[v] ~= nil then
            if not XRedPointManager.CheckIsFitter(v) then
                
                local r = XRedPointConditions[v].Check(args)

                if type(r) == "number" then
                    result = result + r
                elseif r == true and result == -1 then
                    result = 0
                end

            end
        end
    end

    if func then
        func(listener,result,args)
    end
end

--检测红点通过节点
function XRedPointManager.CheckByNode(node,args)
    if RedPointEventDic == nil then
        return
    end

   
    local redPointEvent = nil
    for k,v in pairs(RedPointEventDic) do
        if v:CheckNode() and v.node == node then
            redPointEvent = v
            break
        end
    end

    if redPointEvent then
        redPointEvent:Check(args)
    end
end

--检测红点过滤
function XRedPointManager.CheckIsFitter(conditionId)
    if not RedPointFiitterEvents then 
        return false
    end
  
    if not RedPointFiitterEvents[conditionId] then
        return false
    end

    return true
end

--自动释放
function XRedPointManager.AutoReleseRedPointEvent()
    if not RedPointEventDic then
        return
    end

    local removeEvents = {}
    for k,v in pairs(RedPointEventDic) do
        if not v:CheckNode() then
            table.insert(removeEvents,v)
        end
    end

    for i,v in ipairs(removeEvents) do
        XRedPointManager.RemoveRedPointEvent(v.id)
    end

    removeEvents = nil
end
