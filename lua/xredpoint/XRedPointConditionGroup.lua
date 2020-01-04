--XRedPointConditionGroup 條件組
--XRedPointConditionGroup.Conditions 存的是KEY[k1,k2......] 只要有一个条件满足就有红点
--XRedPointConditionGroup.Events 需要监听的事件[.....]
local XRedPointConditionGroup = XClass()

--构成
function XRedPointConditionGroup:Ctor(conditions)
    self.Conditions = conditions
    self.Events = {}
    if conditions and #conditions > 0 then
        for idx,var in ipairs(conditions) do
            self:GetSubConditions(var)
        end 
    end
end

--递归获取需要监听的事件
function XRedPointConditionGroup:GetSubConditions(conditionId)
    local condition = XRedPointConditions[conditionId]
    if condition then
        --收集子事件
        if condition.GetSubEvents then
            local events = condition.GetSubEvents()
            if events then
                for idx, var in ipairs(events) do
                    self:AddConditions(var)
                end 
            end
        end

        --收集子条件
        if condition.GetSubConditions then
            local subConditions = condition.GetSubConditions()
            if subConditions then
                for idx,var in ipairs(subConditions) do
                    self:GetSubConditions(var)
                end 
            end
        end

    end
end

--添加一个子事件
function XRedPointConditionGroup:AddConditions(element)
    if not element then
        return 
    end

    if self.Events[element.EventId] then
        -- XLog:Warning("RedPoint Condition Events Repeated!!!"..element.EventId)
        return 
    end

    self.Events[element.EventId] = element
end

--条件组检测 返回 0 代表true ,大于0 代表有数量 ，-1就是条件不满足
function XRedPointConditionGroup:Check(args)
    if not self.Conditions or #self.Conditions <= 0 then
        return -1
    end

    local result = -1

    for i, v in ipairs(self.Conditions) do
        if XRedPointConditions[v] ~= nil then
            if not XRedPointManager.CheckIsFitter(v) then --检测需要过滤的红点事件
                local r = XRedPointConditions[v].Check(args)
                -- 0 代表true ,大于0 代表有数量 ，-1就是条件不满足
                if type(r) == "number" then
                    if result >= 0 or r <= 0 then
                        result =  result + r
                    else
                        result = r
                    end
                elseif r == true and result == -1 then
                    result = 0
                end

            end
        end
    end

    return result
end

return XRedPointConditionGroup