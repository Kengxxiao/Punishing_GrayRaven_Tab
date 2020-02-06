local XUiPanelEliminateGame = XClass()
local XUiGridElement = require("XUi/XUiComeAcross/XUiGridElement")

function XUiPanelEliminateGame:Ctor(ui,rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self:Init()
end

function XUiPanelEliminateGame:Init()
    self.SmallPool = self.PanelPoolSmall:GetComponent("XUnityPoolSingle")
    self.BigPool = self.PanelAnsPool:GetComponent("XUnityPoolSingle")
    self.QuePanel = {}
    self.AddingList = {}

    self.TickPanel = {}
    local XUiPanelTick = require("XUi/XUiComeAcross/XUiPanelTick")
    self.TickPanel[1] = XUiPanelTick.New(self.PanelTick_1)
    self.TickPanel[2] = XUiPanelTick.New(self.PanelTick_2)
    self.TickPanel[3] = XUiPanelTick.New(self.PanelTick_3)

    self.PanelTimes.gameObject:SetActive(false)
    self.PanelReady.gameObject:SetActive(false)
    self.PanelQuestion.gameObject:SetActive(false)
    self.PanelAnswer.gameObject:SetActive(false)
    self.PanelResult.gameObject:SetActive(false)
    self.PanelScore.gameObject:SetActive(false)

    local gamePlayer = require("XUi/XUiComeAcross/ComeAcrossEliminateGamePlayer").New()

    gamePlayer.OnPlayNext = handler(self,self.OnPlayNext)   -- 下一关回调
    gamePlayer.OnPlayWaitForNext = handler(self,self.OnPlayWaitForNext)   -- 等待下一关回调
    gamePlayer.OnPlayAddAnswer =  handler(self,self.OnPlayAddAnswer)   -- 添加元素
    gamePlayer.OnPlayFinish =  handler(self,self.OnPlayFinish)     -- 完成回调
    gamePlayer.OnPlayStepChange = handler(self,self.OnPlayStepChange)    -- 完成一步骤回调
    gamePlayer.OnPlayClick = handler(self,self.OnPlayClick)     -- 点击回调
    gamePlayer.OnPlayReadyDelay =  handler(self,self.OnPlayReadyDelay)    -- 准备步骤回调
    gamePlayer.OnPlayEndingDelay =  handler(self,self.OnPlayEndingDelay)    -- 结束步骤回调


    self.GamePlayer = gamePlayer
    self.CountDown = -1
end


--准备倒计时
function XUiPanelEliminateGame:OnPlayReadyDelay(IsReady,countDown)

    if  self.CountDown == countDown then
        return 
    end

    self.CountDown = countDown

    if not IsReady then
        self.PanelTimes.gameObject:SetActive(not IsReady)
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

    --XUiHelper.PlayAnimation(self.RootUi, "UiComeAcrossGame2ReadyBegin")
end

--等待下一关
function XUiPanelEliminateGame:OnPlayWaitForNext(IsWait,countDown,times)
    if  self.CountDown == countDown then
        return 
    end

    self.CountDown = countDown

    self.PanelResult.gameObject:SetActive(IsWait)
    self.TxtResultDesc.text = string.format(CS.XTextManager.GetText("ComeAcrossNext"),countDown) 
end


--设置Ui
function XUiPanelEliminateGame:OnPlayNext(gameData,answer)
    self.SmallPool:DespawnAll()
    self.BigPool:DespawnAll()
    self.AnswerGirds = {}
    self.QuestionGirds = {}

    local question = gameData.Question
    local questionGirds = {}
    if question then
        for index, var in ipairs(question) do
            local grid = self.SmallPool:Spawn()
            grid.transform:SetParent(self.Panel, false)
            grid:SetActive(true)
            local gridElement = XUiGridElement.New(grid, self, self.RootUi)
            gridElement:SetSmallGridContent(var)
            table.insert(questionGirds, gridElement)
        end
    end


    local answerGirds = {}

    if answer then
        for index, var in ipairs(answer) do
            local grid = self.BigPool:Spawn()
            grid.transform:SetParent(self.PanelLayout, false)
            grid:SetActive(true)

            local gridElement = XUiGridElement.New(grid, self, self.RootUi)
            gridElement:SetBigGridContent(var)
            answerGirds[var.Index] = gridElement
        end
    end


    self.TxtTimes.text = string.format( "%s/%s",0, gameData.Times)
    self.TxtTimesLeft.text = gameData.LimitTimes


    self.AnswerGirds = answerGirds
    self.QuestionGirds = questionGirds
end

--追加
function XUiPanelEliminateGame:OnPlayAddAnswer(answer)
    local grid = self.BigPool:Spawn()
    grid.transform:SetParent(self.PanelLayout, false)
    grid:SetActive(false)
    
    local gridElement = XUiGridElement.New(grid, self, self.RootUi)
    gridElement:SetBigGridContent(answer)
    self.AddingList[answer.Index] = gridElement
    self.AnswerGirds[answer.Index] = gridElement
end

--点击回调
function XUiPanelEliminateGame:OnPlayClick(success, removeList)
    if not removeList then
         return
    end 


    for i,v in ipairs(removeList) do
         local grid = self.AnswerGirds[v.Index]
         if grid then
             grid:OnEliminate(function()
                self.AnswerGirds[v.Index] = nil
                self.BigPool:Despawn(grid.GameObject)

                for k,v in pairs(self.AddingList) do
                    v.GameObject:SetActive(true)
                end

                self.AddingList = {}
            end)
         end
    end
 end


--完成一个关卡
function XUiPanelEliminateGame:OnPlayStepChange(idx,results,step,totalStep,times)
    if not results then
        return
    end

    local result = results[idx]
    if self.TickPanel[idx] then
        self.TickPanel[idx]:SetResult(result)
    end

    self.TxtTimes.text = string.format( "%s/%s",step,totalStep)
    self.TxtTimesLeft.text = times
    
    self.TxtResult.text = result == 1 and CS.XTextManager.GetText("ComeAcrossRight") or CS.XTextManager.GetText("ComeAcrossWrong") 

    -- XUiHelper.PlayAnimation(self.RootUi, "UiComeAcrossGame2ResultBegin",nil,function()
    --     XUiHelper.PlayAnimation(self.RootUi, "UiComeAcrossGame2TimesBegin")
    -- end)
    --XUiHelper.PlayAnimation(self.RootUi, "UiComeAcrossGame2TimesBegin")
end


 --结束步骤回调
 function XUiPanelEliminateGame:OnPlayEndingDelay(isEnding, countDown)
    if  self.CountDown == countDown then
        return 
    end

    self.CountDown = countDown

    self.PanelResult.gameObject:SetActive(isEnding)

    self.TxtResult.text = CS.XTextManager.GetText("ComeAcrossGameEnd")
    self.TxtResultDesc.text = string.format(CS.XTextManager.GetText("ComeAcrossEnd"),countDown) 
end

--完成 
function XUiPanelEliminateGame:OnPlayFinish(result)
    self.RootUi:OnFinish(result)
end


--------------------------------------------------------
--解释表数据
function XUiPanelEliminateGame:ParserGameData(data)
    local gameLevels = data.TypeOfGames

    local curGamelevel = {}
    for i, v in ipairs(gameLevels) do
        local game = {}
        game.Question = {}
        local question = v.Question
        for i = 1, #question, 1 do
            local idx = tonumber(string.sub(question, i, i))
            table.insert(game.Question, idx)
        end

        game.Answer = {}
        for i = 1, #v.Answer, 1 do
            local idx = tonumber(string.sub(v.Answer, i, i))
            local answer = {}
            answer.Index = i
            answer.Type = idx

            table.insert(game.Answer, answer)
        end

        game.Tab = v
        game.Times = v.Times
        game.LimitTimes = v.LimitTimes
        table.insert(curGamelevel, game)
    end

    return curGamelevel
end


--开始
function XUiPanelEliminateGame:Play()
    self.GameData = self:ParserGameData(self.CurData)
    self.GamePlayer:SetPlayerData(self.GameData)
    self:Reset()

    self.RootUi.Transform:PlayLegacyAnimation("UiComeAcrossGame2Begin",function()
        self.GamePlayer:Play()
    end)
end

--更新
function XUiPanelEliminateGame:Update(dt)
    if self.GamePlayer then
        self.GamePlayer:Update(dt)
    end
end

--重置
function XUiPanelEliminateGame:Reset()
    for i,v in ipairs(self.TickPanel) do
        v.GameObject:SetActive(i <= self.CurData.GameConfig.Count)
        v:Reset()
    end
end

--设置游戏数据
function XUiPanelEliminateGame:SetupGameData(data)
    if not data then
        return
    end

    self.CurData = data
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelEliminateGame:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelEliminateGame:AutoInitUi()
    self.PanelScore = self.Transform:Find("PanelScore")
    self.Panel = self.Transform:Find("PanelScore/Panel")
    self.PanelTick_1 = self.Transform:Find("PanelScore/Panel/PanelTick_1")
    self.PanelTick_2 = self.Transform:Find("PanelScore/Panel/PanelTick_2")
    self.PanelTick_3 = self.Transform:Find("PanelScore/Panel/PanelTick_3")
    self.TxtTimes = self.Transform:Find("PanelScore/Text/TxtTimes"):GetComponent("Text")
    self.PanelResult = self.Transform:Find("PanelScore/PanelResult")
    self.TxtResult = self.Transform:Find("PanelScore/PanelResult/TxtResult"):GetComponent("Text")
    self.TxtResultDesc = self.Transform:Find("PanelScore/PanelResult/TxtResultDesc"):GetComponent("Text")
    self.PanelQuestion = self.Transform:Find("PanelQuestion")
    self.Panel = self.Transform:Find("PanelQuestion/Panel")
    self.PanelPoolSmall = self.Transform:Find("PanelQuestion/PanelPoolSmall")
    self.PanelAnswer = self.Transform:Find("PanelAnswer")
    self.PanelLayout = self.Transform:Find("PanelAnswer/PanelLayout")
    self.PanelAnsPool = self.Transform:Find("PanelAnswer/PanelAnsPool")
    self.PanelTimes = self.Transform:Find("PanelTimes")
    self.TxtTimesLeft = self.Transform:Find("PanelTimes/TxtTimesLeft"):GetComponent("Text")
    self.PanelReady = self.Transform:Find("PanelReady")
    self.TxtCountDown = self.Transform:Find("PanelReady/TxtCountDown"):GetComponent("Text")
end

function XUiPanelEliminateGame:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelEliminateGame:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelEliminateGame:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelEliminateGame:AutoAddListener()
end
-- auto

return XUiPanelEliminateGame
