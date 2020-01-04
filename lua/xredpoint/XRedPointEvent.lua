--[[
--红点事件个体类
RedPointEvent.id 唯一Id
RedPointEvent.conditionGroup  类型 XRedPointConditionGroup
RedPointEvent.listener  类型 XRedPointListener
RedPointEvent.node 持有的节点用于判断释放
]]--

local XRedPointEvent = XClass()

local EventHandler = function (method, eventId)
    return function(obj, ...)
        return method(obj, eventId, ...)
    end
end



--构造
function XRedPointEvent:Ctor(id,node,condition,listener,args)
    self.id = id
    self.condition = condition
    self.listener = listener
    self.node = node
    self.args = args
    self:AddConditonsChangeEvent()

    self.checkExist = nil
    
    if node.Exist then
        self.checkExist = function() return node:Exist() end
    else
        local gameObject = node.GameObject or node.gameObject or node.Transform or node.transform
        if gameObject and gameObject.Exist then
            self.checkExist = function() return gameObject:Exist() end
        end
    end
end

--检测红点条件
function XRedPointEvent:Check(args)

    if not self:CheckNode() then
        self:Release()
        return 
    end

    if self.condition then
        --如果条件参数改变，则替换
        if args then
            self.args = args
        end

        --条件检测
        local result = self.condition:Check(self.args)

        --回调


        if  self.listener then
            if self.listener.func then
                self.listener:Call(result,self.args)
            else
                self.node.gameObject:SetActive(result >= 0)
            end
        end
    end
end

--添加事件監聽
function XRedPointEvent:AddConditonsChangeEvent()
    if not self.condition then
        return 
    end

    local events = self.condition.Events

    if not events then
        return
    end

    for i, var in pairs(events) do
        XEventManager.AddEventListener(var.EventId, EventHandler(self.OnCondintionChange, var.EventId), self)
    end
end

--删除事件監聽
function XRedPointEvent:RemoveConditonsChageEvent()
    if not self.condition then
        return 
    end

    local events = self.condition.Events

    if not events then
        return 
    end

    for i,var in pairs(events) do
        XEventManager.RemoveEventListener(var.EventId, EventHandler(self.OnCondintionChange, var.EventId), self)
    end
end

--条件改变事件回调
function XRedPointEvent:OnCondintionChange(eventId,args)

    -- 分析参数
    if self.condition and self.condition.Events and self.condition.Events[eventId] then
        local element = self.condition.Events[eventId]
        if element:Equal(eventId, args) then
            self:Check()
            return
        end
    end

    if self.args == nil or args == nil then
        self:Check(args)
    elseif self.args == args and args ~= nil then
        self:Check(args)
    end
end

--检测是否已经被释放
function XRedPointEvent:CheckNode()
    if self.checkExist == nil then
        return false
    end 

    if not self.checkExist() then
        return false
    end

    return true
end

--释放
function XRedPointEvent:Release()
    self:RemoveConditonsChageEvent()
    self.checkExist = nil
    self.listener:Release()
    self.node = nil

    XRedPointManager.RemoveRedPointEventOnly(self.id)
end

return XRedPointEvent
