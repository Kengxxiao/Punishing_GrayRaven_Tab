local XUiPanelGame = XClass()
local XUiGridElement = require("XUi/XUiComeAcross/XUiGridElement")

function XUiPanelGame:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self:Init()
end

function XUiPanelGame:Init()
    self.SmallPool = self.PanelPoolSmall:GetComponent("XUnityPoolSingle")
    self.BigPool = self.PanelAnsPool:GetComponent("XUnityPoolSingle")
    self.QuePanel = {}
    self.QuePanel[1] = self.PanelQue_1
    self.QuePanel[2] = self.PanelQue_2
    self.QuePanel[3] = self.PanelQue_3

    self.TickPanel = {}
    local XUiPanelTick = require("XUi/XUiComeAcross/XUiPanelTick")
    self.TickPanel[1] = XUiPanelTick.New(self.PanelTick_1)
    self.TickPanel[2] = XUiPanelTick.New(self.PanelTick_2)
    self.TickPanel[3] = XUiPanelTick.New(self.PanelTick_3)

    self.PanelTime.gameObject:SetActive(false)
    self.PanelReady.gameObject:SetActive(false)
    self.PanelQuestion.gameObject:SetActive(false)
    self.PanelAnswer.gameObject:SetActive(false)
    self.PanelResult.gameObject:SetActive(false)
    self.PanelScore.gameObject:SetActive(false)    
    
    local gamePlayer = require("XUi/XUiComeAcross/ComeAcrossClickGamePlayer").New()

    --gamePlayer.OnPlayInit = onPlayInit   -- 初始化回调
    gamePlayer.OnPlayNext = handler(self,self.OnPlayNext)   -- 下一关回调
    gamePlayer.OnPlayWaitForNext = handler(self,self.OnPlayWaitForNext)   -- 等待下一关回调
    gamePlayer.OnPlayUpdate =  handler(self,self.OnPlayUpdate)   -- 等待下一关回调
    gamePlayer.OnPlayFinish =  handler(self,self.OnPlayFinish)     -- 完成回调
    gamePlayer.OnPlayStepChange = handler(self,self.OnPlayStepChange)    -- 完成一步骤回调
    gamePlayer.OnPlayClick = handler(self,self.OnPlayClick)     -- 点击回调
    gamePlayer.OnPlayReadyDelay =  handler(self,self.OnPlayReadyDelay)    -- 准备步骤回调
    gamePlayer.OnPlayEndingDelay =  handler(self,self.OnPlayEndingDelay)    -- 结束步骤回调

    self.GamePlayer = gamePlayer

    self.CountDown = -1
end

--设置游戏数据
function XUiPanelGame:SetupGameData(data)
    if not data then
        return
    end

    self.CurData = data
end

--解释表数据
function XUiPanelGame:ParserGameData(data)
    local gameLevels = data.TypeOfGames

    local curGamelevel = {}
    for i, v in ipairs(gameLevels) do
        local game = {}
        game.Question = {}
        local question = v.Question
        local group = string.Split(question, "|")
        if group and #group >= 0 then
            for index, var in ipairs(group) do
                game.Question[index] = {}
                for i = 1, #var, 1 do
                    local idx = tonumber(string.sub(var, i, i))
                    table.insert(game.Question[index], idx)
                end
            end
        end

        game.Answer = {}
        local lastAnswer = nil
        for i = 1, #v.Answer, 1 do
            local idx = tonumber(string.sub(v.Answer, i, i))
            local answer = {}
            answer.Index = i
            answer.Type = idx
            if lastAnswer then
                answer.Last = lastAnswer
                lastAnswer.Next = answer
            end

            lastAnswer = answer
            table.insert(game.Answer, answer)
        end

        game.Tab = v
        game.Time = v.Time
        table.insert(curGamelevel, game)
    end

    return curGamelevel
end
-------------------------------------------

--准备阶段
function XUiPanelGame:OnPlayReadyDelay(IsReady, countDown)

    if  self.CountDown == countDown then
        return 
    end

    self.CountDown = countDown

    if not IsReady then
        self.PanelTime.gameObject:SetActive(not IsReady)
        self.PanelQuestion.gameObject:SetActive(not IsReady)
        self.PanelAnswer.gameObject:SetActive(not IsReady)
        self.PanelScore.gameObject:SetActive(not IsReady)
    end

    self.PanelReady.gameObject:SetActive(IsReady)
    if self.CountDown > 1 then
        self.TxtCountDown.text = tostring(countDown -1)
    else
        self.TxtCountDown.text = CS.XTextManager.GetText("ComeAcrossStart")
    end

    --XUiHelper.PlayAnimation(self.RootUi, "UiComeAcrossGame1ReadyBegin")
end


 --结束步骤回调
function XUiPanelGame:OnPlayEndingDelay(isEnding, countDown)
    if  self.CountDown == countDown then
        return 
    end

    self.CountDown = countDown

    self.PanelResult.gameObject:SetActive(isEnding)

    self.TxtResult.text = CS.XTextManager.GetText("ComeAcrossGameEnd")
    self.TxtResultDesc.text = string.format(CS.XTextManager.GetText("ComeAcrossEnd"),countDown) 

    --XUiHelper.PlayAnimation(self.RootUi, "UiComeAcrossGame1ResultBegin")
end


--设置Ui
function XUiPanelGame:OnPlayNext(gameData)
    self.SliderTime.value = 1
    self.SmallPool:DespawnAll()
    self.BigPool:DespawnAll()
    self.AnswerGirds = {}
    self.QuestionGirds = {}

    local question = gameData.Question
    local questionGirds = {}
    if question then
        for i, v in ipairs(question) do
            if not v or #v <= 0 then
                break
            end

            questionGirds[i] = {}
            local lastGrid = nil

            for index, var in ipairs(v) do
                local grid = self.SmallPool:Spawn()
                grid.transform:SetParent(self.QuePanel[i], false)
                grid:SetActive(true)
                local gridElement = XUiGridElement.New(grid, self, self.RootUi)
                gridElement:SetSmallGridContent(var)
                table.insert(questionGirds[i], gridElement)
            end
        end
    end


    local answer = gameData.Answer
    local answerGirds = {}

    if answer then
        local lastGrid = nil
        for index, var in ipairs(answer) do
            local grid = self.BigPool:Spawn()
            grid.transform:SetParent(self.PanelLayout, false)
            grid:SetActive(true)

            local gridElement = XUiGridElement.New(grid, self, self.RootUi)
            gridElement:SetBigGridContent(var)
            answerGirds[var.Index] = gridElement
        end
    end

    self.AnswerGirds = answerGirds
    self.QuestionGirds = questionGirds

end

--更新进度条
function XUiPanelGame:OnPlayUpdate(curtime, timeLimit)
    if curtime >= timeLimit then
        curtime = timeLimit
    end

    self.SliderTime.value = 1 - curtime / timeLimit
end

--完成
function XUiPanelGame:OnPlayFinish(result)
    self.RootUi:OnFinish(result)
end

--等待下一关
function XUiPanelGame:OnPlayWaitForNext(IsWait, countDown, times)

    if  self.CountDown == countDown then
        return 
    end

    self.CountDown = countDown


    self.PanelResult.gameObject:SetActive(IsWait)
    self.TxtResultDesc.text = string.format(CS.XTextManager.GetText("ComeAcrossNext"),countDown) 

end


--完成一个关卡
function XUiPanelGame:OnPlayStepChange(idx,results,isTimeOut)
    if not results then
        return
    end

    local result = results[idx]
    if self.TickPanel[idx] then
        self.TickPanel[idx]:SetResult(result)
    end

    if isTimeOut then
        self.TxtResult.text = CS.XTextManager.GetText("ComeAcrossTimeout")
    else
        self.TxtResult.text = result == 1 and CS.XTextManager.GetText("ComeAcrossRight") or CS.XTextManager.GetText("ComeAcrossWrong") 
    end

    --XUiHelper.PlayAnimation(self.RootUi, "UiComeAcrossGame1ResultBegin")
end


--点击回调
function XUiPanelGame:OnPlayClick(success,removeList, step)
    if not removeList then
        return
    end

    for i, v in ipairs(removeList) do
        local grid = self.AnswerGirds[v.Index]
        if grid then
            grid:OnEliminate(function()
                self.AnswerGirds[v.Index] = nil
                self.BigPool:Despawn(grid.GameObject)
            end)
        end
    end


    for i = 1, step,1 do
        if self.QuestionGirds[i] then
            for idx, var in ipairs(self.QuestionGirds[i]) do
                var:SetGray()
            end
        end
    end
end

----------------------------------------------------

--开始
function XUiPanelGame:Play()
    self.GameData = self:ParserGameData(self.CurData)
    self.GamePlayer:SetPlayerData(self.GameData)
    self:Reset()

    self.RootUi.Transform:PlayLegacyAnimation("UiComeAcrossGame1Begin",function()
        self.GamePlayer:Play()
    end)
end

--更新
function XUiPanelGame:Update(dt)
    if self.GamePlayer then
        self.GamePlayer:Update(dt)
    end
end

--重置
function XUiPanelGame:Reset()
    for i, v in ipairs(self.TickPanel) do
        v.GameObject:SetActive(i <= self.CurData.GameConfig.Count)
        v:Reset()
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelGame:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelGame:AutoInitUi()
    self.PanelScore = self.Transform:Find("PanelScore")
    self.Panel = self.Transform:Find("PanelScore/Panel")
    self.PanelTick_1 = self.Transform:Find("PanelScore/Panel/PanelTick_1")
    self.PanelTick_2 = self.Transform:Find("PanelScore/Panel/PanelTick_2")
    self.PanelTick_3 = self.Transform:Find("PanelScore/Panel/PanelTick_3")
    self.PanelResult = self.Transform:Find("PanelScore/PanelResult")
    self.TxtResult = self.Transform:Find("PanelScore/PanelResult/TxtResult"):GetComponent("Text")
    self.TxtResultDesc = self.Transform:Find("PanelScore/PanelResult/TxtResultDesc"):GetComponent("Text")
    self.PanelQuestion = self.Transform:Find("PanelQuestion")
    self.PanelA = self.Transform:Find("PanelQuestion/Panel")
    self.PanelQue_1 = self.Transform:Find("PanelQuestion/Panel/PanelQue_1")
    self.PanelQue_2 = self.Transform:Find("PanelQuestion/Panel/PanelQue_2")
    self.PanelQue_3 = self.Transform:Find("PanelQuestion/Panel/PanelQue_3")
    self.PanelPoolSmall = self.Transform:Find("PanelQuestion/PanelPoolSmall")
    self.PanelAnswer = self.Transform:Find("PanelAnswer")
    self.PanelLayout = self.Transform:Find("PanelAnswer/PanelLayout")
    self.PanelAnsPool = self.Transform:Find("PanelAnswer/PanelAnsPool")
    self.PanelTime = self.Transform:Find("PanelTime")
    self.SliderTime = self.Transform:Find("PanelTime/SliderTime"):GetComponent("Slider")
    self.PanelReady = self.Transform:Find("PanelReady")
    self.TxtCountDown = self.Transform:Find("PanelReady/TxtCountDown"):GetComponent("Text")
end

function XUiPanelGame:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelGame:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelGame:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelGame:AutoAddListener()
end
-- auto



return XUiPanelGame