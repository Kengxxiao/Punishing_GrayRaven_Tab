
local ComeAcrossGamePlayer = require("XUi/XUiComeAcross/ComeAcrossGamePlayer")
local ComeAcrossEliminateGamePlayer = Class("ComeAcrossEliminateGamePlayer",ComeAcrossGamePlayer)

local TOTALGRID_LIMIT = 8

------------------需要重写的方法--------------------------------
--初始化
function ComeAcrossEliminateGamePlayer:OnPlayerInit()
    self.TotalClickTimesLimit = 0   --游戏次数
    self.AnswerIndex = 0
    self.OnPlayAddAnswer = nil
    self.super.OnPlayerInit(self)
end

--播放下一关
function ComeAcrossEliminateGamePlayer:OnPlayerNextLevel()
    self.CurAnswer = self:GetCurLevelData()
    self.TotalClickTimesLimit = self.GameData.LimitTimes

    if self.OnPlayNext then
        self.OnPlayNext(self.GameData, self.CurAnswer)
    end
end

--开始游戏
function ComeAcrossEliminateGamePlayer:OnPlayerStart()
    self.TotalClickTimesLimit = 0
    self.AnswerIndex = 0

end

--等待开始
function ComeAcrossEliminateGamePlayer:OnPlayerReadyDelay(isReadyDelay, delayTime)
    if self.OnPlayReadyDelay then
        self.OnPlayReadyDelay(isReadyDelay, delayTime)
    end
end

--等待下关
function ComeAcrossEliminateGamePlayer:OnPlayerWaitForNext(isWaiting, waitTime)
    if self.OnPlayWaitForNext then
        self.OnPlayWaitForNext(isWaiting, waitTime)
    end
end

--等待结束
function ComeAcrossEliminateGamePlayer:OnPlayerWaitForEnding(isEnding, delayTime)
    if self.OnPlayEndingDelay then
        self.OnPlayEndingDelay(isEnding, delayTime)
    end
end


--停止回调
function ComeAcrossEliminateGamePlayer:OnPlayerStop()

end

--完成回调
function ComeAcrossEliminateGamePlayer:OnPlayerFinish()
    if self.OnPlayFinish then
        self.OnPlayFinish(self.PlayResult)
    end
end


--处理消除的元素
function ComeAcrossEliminateGamePlayer:OnPlayerDealClick(id)

    local target = nil
    local targetIndex = -1
    for i, v in ipairs(self.CurAnswer) do
        if v.Index == id then
            target = v
            targetIndex = i
            break
        end
    end

    if not target then
        XLog.Error("ComeAcrossEliminateGamePlayer:OnClick 找不到Id", id)
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


    local removeCount = #removeList
    --补充元素
    for i = 1, removeCount, 1 do
        self.AnswerIndex = self.AnswerIndex + 1
        local answer = self.GameData.Answer[self.AnswerIndex]
        if answer then
            local lastIndex = #self.CurAnswer
            local lastAnswer = self.CurAnswer[lastIndex]
            table.insert(self.CurAnswer,answer)
            lastAnswer.Next = answer
            answer.Last = lastAnswer
            if self.OnPlayAddAnswer then
                self.OnPlayAddAnswer(answer)
            end
        end
    end

    --如果条件不符合
    local success = false
    local question = self.GameData.Question
    if #question <= #removeList and question[1] == target.Type then
        success = true
    end

    if success then
        self.State = ComeAcrossGamePlayer.PlayerState.ELIMINATE
        self.LastEliminate = self.Time
        self.Step = self.Step + 1
        self.TotalClickTimesLimit = self.TotalClickTimesLimit - 1
    else
        self.TotalClickTimesLimit = self.TotalClickTimesLimit - 1
    end

    if self.OnPlayClick then
        self.OnPlayClick(success, removeList)
    end

    self:OnPlayerCheckLevelFinish()
end

--检测当前关卡是否完成
function ComeAcrossEliminateGamePlayer:OnPlayerCheckLevelFinish()
    if self.Step > self.GameData.Times then
        self.PlayResult[self.LevelIndex] = 1
    elseif self.TotalClickTimesLimit == 0 then
        self.PlayResult[self.LevelIndex] = 0
    end

    self:OnPlayerStepChanged()

    if self.TotalClickTimesLimit == 0 or self.Step > self.GameData.Times then
        self.State = ComeAcrossGamePlayer.PlayerState.WAIT
        self.LevelChangeWaitTime = CS.XGame.Config:GetInt("TrustGameWaitForNextSecond")
    end
end


--每一步骤回调
function ComeAcrossEliminateGamePlayer:OnPlayerStepChanged()
    if self.OnPlayStepChange then
        self.OnPlayStepChange(self.LevelIndex,self.PlayResult,self.Step - 1,self.GameData.Times,self.TotalClickTimesLimit)
    end
end


------------------------------------------

--获取当前关卡数据
function ComeAcrossEliminateGamePlayer:GetCurLevelData()
    local gameData = self.PlayData[self.LevelIndex]

    if not gameData or #gameData.Answer < TOTALGRID_LIMIT then
        return
    end

    local curData = {}
    local lastData = nil
    for i = 1, TOTALGRID_LIMIT, 1 do
        local data = gameData.Answer[i]
        table.insert(curData, data)
        if lastData then
            data.Last = lastData
            lastData.Next = data
        end
        lastData = data
    end

    self.AnswerIndex = TOTALGRID_LIMIT
    return curData
end


return ComeAcrossEliminateGamePlayer