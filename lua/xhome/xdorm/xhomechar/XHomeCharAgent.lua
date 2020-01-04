local XHomeCharAgent = XLuaBehaviorManager.RegisterAgent(XLuaBehaviorAgent, "HomeCharacter")

function XHomeCharAgent:OnAwake(...)
    self.Path = {}
end

function XHomeCharAgent:SetHomeCharObj(homeCharObj)
    self.HomeCharObj = homeCharObj
end

--状态改变
function XHomeCharAgent:ChangeStatus(state)
    self.HomeCharObj:ChangeStatus(state)
end

--状态机改变
function XHomeCharAgent:ChangeStateMachine(state)
    self.HomeCharObj:ChangeStateMachine(state)
end

--获取属性 例如心情值
function XHomeCharAgent:GetAtrributeValue(attributeKey)
    return self.HomeCharObj:GetAtrributeValue(attributeKey)
end

--播放动作
function XHomeCharAgent:DoAction(actionId,needFadeCross,crossDuration)
    self.HomeCharObj:DoAction(actionId,needFadeCross,crossDuration)
end

--显示特定气泡
function XHomeCharAgent:ShowBubble(id,callback)
    self.HomeCharObj:ShowBubble(id,callback)
end

--显示随机气泡
function XHomeCharAgent:ShowRandomBubble(callback)
    self.HomeCharObj:ShowRandomBubble(callback)
end

--隐藏气泡
function XHomeCharAgent:HideBubble()
    self.HomeCharObj:HideBubble()
end

--寻路
function XHomeCharAgent:DoPathFind(minDistance,maxDistance)
    local path = self.HomeCharObj:DoPathFind(minDistance,maxDistance)
    return true
end

--显示特效
function XHomeCharAgent:PlayEffect(effectId, bindWorldPos)
    self.HomeCharObj:PlayEffect(effectId, bindWorldPos)
end

--隐藏特效
function XHomeCharAgent:HideEffect()
    self.HomeCharObj:HideEffect()
end

--检测交互
function XHomeCharAgent:CheckFurnitureInteract()
    return self.HomeCharObj:CheckFurnitureInteract()
end

--检测事件完成
function XHomeCharAgent:CheckEventCompleted(completeType,callback)
    return self.HomeCharObj:CheckEventCompleted(completeType,callback)
end

--家具交互
function XHomeCharAgent:InteractFurniture()
    return self.HomeCharObj:InteractFurniture()
end

--家具交互动画
function XHomeCharAgent:PlayInteractFurnitureAnimation()
    return self.HomeCharObj:PlayInteractFurnitureAnimation()
end

--检测人物交互
function XHomeCharAgent:CheckCharacterInteracter()
    return self.HomeCharObj:CheckCharacterInteracter()
end

--获取爱抚类型
function XHomeCharAgent:GetFondleType()
    return self.HomeCharObj:GetFondleType()
end

--出列爱抚类型
function XHomeCharAgent:DequeueFondleType()
    return self.HomeCharObj:DequeueFondleType()
end

--到达家具交互
function XHomeCharAgent:ReachFurniture()
    self.HomeCharObj:ReachFurniture()
end

--检测能否取消家具交互
function XHomeCharAgent:CheckDisInteractFurniture()
    return self.HomeCharObj:CheckDisInteractFurniture()
end

--显示奖励
function XHomeCharAgent:ShowEventReward()
    self.HomeCharObj:ShowEventReward()
end

--检测是否在家具上方
function XHomeCharAgent:CheckRayCastFurnitureNode()
   return self.HomeCharObj:CheckRayCastFurnitureNode()
end

--获取状态
function XHomeCharAgent:GetState()
    return self.HomeCharObj:GetState()
end

--检测事件存在
function XHomeCharAgent:CheckEventExist(eventId)
    return self.HomeCharObj:CheckEventExist(eventId)
end

--检测是否正在播放指定动画
function XHomeCharAgent:CheckIsPlayingAnimation(animationName)
    return self.HomeCharObj:CheckIsPlayingAnimation(animationName)
end

--设置是否阻挡
function XHomeCharAgent:SetObstackeEnable(obstackeEnable)
    self.HomeCharObj:SetObstackeEnable(obstackeEnable)
end

--爱抚结束
function XHomeCharAgent:DequeueFondleType()
    self.HomeCharObj:DequeueFondleType()
end

--朝向交互家具
function XHomeCharAgent:SetForwardToFurniture(forward)
    return self.HomeCharObj:SetForwardToFurniture(forward)
end

--获取ID
function XHomeCharAgent:GetId()
    return self.HomeCharObj.Id
end

-- --设置停留点偏移
-- function XHomeCharAgent:SetStayOffset()
--     return self.HomeCharObj:SetStayPosOffest()
-- end

--设置构造体交互开关
function XHomeCharAgent:SetCharInteractTrigger(isOn)
    return self.HomeCharObj:SetCharInteractTrigger(isOn)
end

-- 检测构造体是否在坐标索引上
function XHomeCharAgent:CheckCharInteractPosByIndex(index)
    return self.HomeCharObj:CheckCharInteractPosByIndex(index)
end
