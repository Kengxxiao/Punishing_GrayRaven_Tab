local ComeAcrossGamePlayer = Class()

ComeAcrossGamePlayer.PlayerState = {
    STOP = 0,
    READY = 1,
    WAIT = 2,
    PLAYING = 3,
    CHANGING = 4,
    PAUSE = 5,
    ELIMINATE = 6,
    ENDING = 7,
    END = 8

}

local ELIMINATE_TIME = 0.3

function ComeAcrossGamePlayer:Ctor()

    -- -----Ui回调
    -- self.OnPlayInit = onPlayInit   -- 初始化回调
    -- self.OnPlayNext = onPlayNext   -- 下一关回调
    -- self.OnPlayWaitForNext = onPlayWaitForNext   -- 等待下一关回调
    -- self.OnPlayUpdate = onPlayUpdate   -- 等待下一关回调
    -- self.OnPlayFinish = onPlayFinish   -- 完成回调
    -- self.OnPlayStepChange = onPlayStepChange   -- 完成一步骤回调
    -- self.OnPlayClick = onPlayClick   -- 点击回调
    -- self.OnPlayReadyDelay = onPlayReadyDelay   -- 准备步骤回调
    -- self.OnPlayEndingDelay = onPlayEndingDelay   -- 结束步骤回调

    self:Init()
end

function ComeAcrossGamePlayer:Init()
    self.Time = 0           --时间线
    self.LevelIndex = 0     --当前关卡
    self.Step = 0           --当前关卡步数
    self.PlayResult = {}    --关卡结果
    self.ReadyDelay = -1    --准备延迟
    self.State = ComeAcrossGamePlayer.PlayerState.STOP --状态
    self.PlayData = nil     -- 游戏数据
    self.LevelChangeWaitTime = 0 --关卡变更的等待时间       
    self.LastEliminate = 0  -- 上次消除的时间

    self:OnPlayerInit()
end

------------------需要重写的方法--------------------------------
--初始化
function ComeAcrossGamePlayer:OnPlayerInit()
    if self.OnPlayInit then
        self.OnPlayInit()
    end
end

--播放下一关
function ComeAcrossGamePlayer:OnPlayerNextLevel()
    if self.OnPlayNext then
        self.OnPlayNext(self.GameData)
    end
end

--等待开始
function ComeAcrossGamePlayer:OnPlayerReadyDelay(isReadyDelay, delayTime)
    if self.OnPlayReadyDelay then
        self.OnPlayReadyDelay(isReadyDelay, delayTime)
    end
end

--等待下关
function ComeAcrossGamePlayer:OnPlayerWaitForNext(isWaiting, waitTime)
    if self.OnPlayWaitForNext then
        self.OnPlayWaitForNext(isWaiting, waitTime,self.PlayResult[self.LevelIndex])
    end
end

--等待结束
function ComeAcrossGamePlayer:OnPlayerWaitForEnding(isEnding, delayTime)
    if self.OnPlayEndingDelay then
        self.OnPlayEndingDelay(isEnding, delayTime)
    end
end

--更新
function ComeAcrossGamePlayer:OnPlayerUpdate(dt, time)
    if self.OnPlayUpdate then
        self.OnPlayUpdate(dt, time)
    end
end

--开始游戏
function ComeAcrossGamePlayer:OnPlayerStart()

end

--停止回调
function ComeAcrossGamePlayer:OnPlayerStop()

end

--完成回调
function ComeAcrossGamePlayer:OnPlayerFinish()
    if self.OnPlayFinish then
        self.OnPlayFinish(self.PlayResult)
    end
end

--每一步骤回调
function ComeAcrossGamePlayer:OnPlayerStepChanged()
    if self.OnPlayStepChange then
        self.OnPlayStepChange(self.LevelIndex,self.PlayResult)
    end
end


--处理消除的元素
function ComeAcrossGamePlayer:OnPlayerDealClick(id)

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
    local success = false

    if self.OnPlayClick then
        self.OnPlayClick(success, removeList)
    end
end

--检测当前关卡是否完成
function ComeAcrossGamePlayer:OnPlayerCheckLevelFinish()
    return true
end

-------------------------------------------------------
--设置数据
function ComeAcrossGamePlayer:SetPlayerData(playData)
    self.PlayData = playData
end

--开始
function ComeAcrossGamePlayer:Play()
    self.Time = 0
    self.LevelIndex = 0
    self.Step = 0
    self.LastEliminate = 0
    self.PlayResult = {}
    self.ReadyDelay = CS.XGame.Config:GetInt("TrustGameReadySecond")
    self.LevelChangeWaitTime = CS.XGame.Config:GetInt("TrustGameWaitForNextSecond")
    self.EndingDelay = CS.XGame.Config:GetInt("TrustGameWaitForEnding")
    self.State = ComeAcrossGamePlayer.PlayerState.READY

    self:OnPlayerStart()
end

--开始下一关
function ComeAcrossGamePlayer:PlayNextLevel()
    if not self.PlayData or #self.PlayData <= 0 then
        return
    end

    if self:CheckGameFinish() then
        self:Finish()
        return
    end

    self.LevelIndex = self.LevelIndex + 1
    self.Step = 1

    self.GameData = self.PlayData[self.LevelIndex]
    self.Time = 0
    self:OnPlayerNextLevel()

    if self.State ~= ComeAcrossGamePlayer.PlayerState.READY then
        self.State = ComeAcrossGamePlayer.PlayerState.PLAYING
    end
end

--等待下一关开启
function ComeAcrossGamePlayer:WaitForNext(dt)
    if self.LevelChangeWaitTime > 0 then
        self:OnPlayerWaitForNext(true, math.ceil(self.LevelChangeWaitTime))
        self.LevelChangeWaitTime = self.LevelChangeWaitTime - dt
    else
        self.LevelChangeWaitTime = 0
        self:OnPlayerWaitForNext(false, math.ceil(self.LevelChangeWaitTime))
        self.State = ComeAcrossGamePlayer.PlayerState.PLAYING
        self:PlayNextLevel()
    end
end

--等待开始
function ComeAcrossGamePlayer:WaitForStart(dt)
    if self.ReadyDelay > 0 then
        self:OnPlayerReadyDelay(true, math.ceil(self.ReadyDelay))
        self.ReadyDelay = self.ReadyDelay - dt
    else
        self.ReadyDelay = 0
        self.State = ComeAcrossGamePlayer.PlayerState.PLAYING
        self:OnPlayerReadyDelay(false, math.ceil(self.ReadyDelay))
        self:PlayNextLevel()
    end
end

--等待结束
function ComeAcrossGamePlayer:WaitForEnding(dt)
    if self.EndingDelay > 0 then
        self:OnPlayerWaitForEnding(true, math.ceil(self.EndingDelay))
        self.EndingDelay = self.EndingDelay - dt
    else
        self.EndingDelay = 0
        self.State = ComeAcrossGamePlayer.PlayerState.END
        self:OnPlayerWaitForEnding(false, math.ceil(self.EndingDelay))
        self:OnPlayerFinish()
        self:Stop()
    end
end

--更新
function ComeAcrossGamePlayer:Update(dt)
    if self.State == ComeAcrossGamePlayer.PlayerState.STOP or self.State == ComeAcrossGamePlayer.PlayerState.END then
        return
    end


    if self.State == ComeAcrossGamePlayer.PlayerState.ENDING then
        self:WaitForEnding(dt)
        return
    end

    if self:CheckGameFinish() and self.State ~= ComeAcrossGamePlayer.PlayerState.ENDING  then
        self:Finish()
        return
    end

    if self.State == ComeAcrossGamePlayer.PlayerState.WAIT then
        self:WaitForNext(dt)
        return
    end

    if self.State == ComeAcrossGamePlayer.PlayerState.READY then
        self:WaitForStart(dt)
        return
    end

    if self.State ~= ComeAcrossGamePlayer.PlayerState.PLAYING and self.State ~= ComeAcrossGamePlayer.PlayerState.ELIMINATE then
        return
    end

    --消除的时间
    if self.State == ComeAcrossGamePlayer.PlayerState.ELIMINATE and self.LastEliminate + ELIMINATE_TIME <= self.Time then
        self.State = ComeAcrossGamePlayer.PlayerState.PLAYING
    end

    self.Time = self.Time + dt
    self:OnPlayerUpdate(dt, self.Time)
end

--完成
function ComeAcrossGamePlayer:Finish()
    self.State = ComeAcrossGamePlayer.PlayerState.ENDING
end

--停止
function ComeAcrossGamePlayer:Stop()
    self.Time = 0
    self.LevelIndex = 0
    self.Step = 0
    self.PlayResult = {}
    self.State = ComeAcrossGamePlayer.PlayerState.STOP

    self:OnPlayerStop()
end

--点击到消除
function ComeAcrossGamePlayer:OnClick(id)
    if not self.GameData then
        return
    end

    if self.State ~= ComeAcrossGamePlayer.PlayerState.PLAYING then
        return
    end

    self:OnPlayerDealClick(id)
end

--检测完成
function ComeAcrossGamePlayer:CheckGameFinish()
    return #self.PlayData == #self.PlayResult
end

--消球规则
function ComeAcrossGamePlayer:FindNeighborRecursion(removeList, type, targetIndex, left, right, isNext)
    if #removeList >= 3 then
        return removeList, left, right, targetIndex
    end

    if (not right or right.Type ~= type) and (not left or left.Type ~= type) then
        return removeList, left, right, targetIndex
    end


    if isNext and right and right.Type == type then
        table.insert(removeList, right)
        right = right.Next
    elseif left and left.Type == type then
        table.insert(removeList, left)
        left = left.Last
        targetIndex = targetIndex - 1
    end

    return self:FindNeighborRecursion(removeList, type, targetIndex, left, right, not isNext)
end


return ComeAcrossGamePlayer