local ComeAcrossGamePlayer = require("XUi/XUiComeAcross/ComeAcrossGamePlayer")
local ComeAcrossClickGamePlayer = Class("ComeAcrossClickGamePlayer",ComeAcrossGamePlayer)

------------------需要重写的方法--------------------------------
--初始化
function ComeAcrossClickGamePlayer:OnPlayerInit()
    self.TotalTimeLimit = 0   --游戏时间限制
    self.super.OnPlayerInit(self)
end

--播放下一关
function ComeAcrossClickGamePlayer:OnPlayerNextLevel()
    self.TotalTimeLimit = self.GameData.Time
    self.super.OnPlayerNextLevel(self)
end

--开始游戏
function ComeAcrossClickGamePlayer:OnPlayerStart()
    self.TotalTimeLimit = 0
end

--等待开始
function ComeAcrossClickGamePlayer:OnPlayerReadyDelay(isReadyDelay, delayTime)
    if self.OnPlayReadyDelay then
        self.OnPlayReadyDelay(isReadyDelay, delayTime)
    end
end

--等待下关
function ComeAcrossClickGamePlayer:OnPlayerWaitForNext(isWaiting, waitTime)
    if self.OnPlayWaitForNext then
        self.OnPlayWaitForNext(isWaiting, waitTime)
    end
end

--等待结束
function ComeAcrossClickGamePlayer:OnPlayerWaitForEnding(isEnding, delayTime)
    if self.OnPlayEndingDelay then
        self.OnPlayEndingDelay(isEnding, delayTime)
    end
end

--更新
function ComeAcrossClickGamePlayer:OnPlayerUpdate(dt, time)
    if self.OnPlayUpdate then
        self.OnPlayUpdate(self.Time, self.TotalTimeLimit)
    end

    if self.Time >= self.TotalTimeLimit then
        self.State = ComeAcrossGamePlayer.PlayerState.WAIT
        self:TimeOut()
    end
end

--停止回调
function ComeAcrossClickGamePlayer:OnPlayerStop()

end

--完成回调
function ComeAcrossClickGamePlayer:OnPlayerFinish()
    if self.OnPlayFinish then
        self.OnPlayFinish(self.PlayResult)
    end
end


--处理消除的元素
function ComeAcrossClickGamePlayer:OnPlayerDealClick(id)

    local target = nil
    local targetIndex = -1
    for i, v in ipairs(self.GameData.Answer) do
        if v.Index == id then
            target = v
            targetIndex = i
            break
        end
    end

    if not target then
        XLog.Error("ComeAcrossClickGamePlayer:OnClick 找不到Id", id)
        return
    end

    local removeList = {}
    local last = target.Last
    local next = target.Next

    table.insert(removeList, target)
    removeList, last, next, targetIndex = self:FindNeighborRecursion(removeList, target.Type, targetIndex, last, next, true)

    if removeList and #removeList >= targetIndex then
        for index = 1,#removeList,1 do
            table.remove(self.GameData.Answer,targetIndex)
        end
    end

    if last then
        last.Next = next
    end

    if next then
        next.Last = last
    end

    --如果条件不符合
    local success = false
    local question = self.GameData.Question[self.Step]
    if #question == #removeList and question[1] == target.Type then
        success = true
    end


    if self.OnPlayClick then
        self.OnPlayClick(success, removeList,self.Step)
    end

    if success then
        self.State = ComeAcrossGamePlayer.PlayerState.ELIMINATE
        self.LastEliminate = self.Time
        self.Step = self.Step + 1
        self:OnPlayerCheckLevelFinish()
    else
        self.PlayResult[self.LevelIndex] = 0
        self:OnPlayerStepChanged()
        self.State = ComeAcrossGamePlayer.PlayerState.WAIT
        self.LevelChangeWaitTime = CS.XGame.Config:GetInt("TrustGameWaitForNextSecond")
    end

end

--检测当前关卡是否完成
function ComeAcrossClickGamePlayer:OnPlayerCheckLevelFinish()
    if self.Step > #self.GameData.Question then
        self.PlayResult[self.LevelIndex] = 1
        self:OnPlayerStepChanged()
        self.State = ComeAcrossGamePlayer.PlayerState.WAIT
        self.LevelChangeWaitTime = CS.XGame.Config:GetInt("TrustGameWaitForNextSecond")
    end
end


--每一步骤回调
function ComeAcrossGamePlayer:OnPlayerStepChanged(isTimeOut)
    if self.OnPlayStepChange then
        self.OnPlayStepChange(self.LevelIndex,self.PlayResult,isTimeOut)
    end
end


------------------------------------------
--超时
function ComeAcrossClickGamePlayer:TimeOut()
    self.PlayResult[self.LevelIndex] = 0
    self:OnPlayerStepChanged(true)
    self.State = ComeAcrossGamePlayer.PlayerState.WAIT
    self.LevelChangeWaitTime =  CS.XGame.Config:GetInt("TrustGameWaitForNextSecond")
end



return ComeAcrossClickGamePlayer