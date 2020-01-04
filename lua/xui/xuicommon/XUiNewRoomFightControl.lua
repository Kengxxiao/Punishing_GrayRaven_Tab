XUiNewRoomFightControl = XClass()
--战力限制组件
function XUiNewRoomFightControl:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiNewRoomFightControl:UpdateInfo(stageFightControlId, teamAbility, condition, stageId, teamData)
    self.TeamData = teamData
    self.StageId = stageId
    self.StageFightControlId = stageFightControlId
    self.TeamAbility = teamAbility
    self.Ex.gameObject:SetActive(false)
    self.Hard.gameObject:SetActive(false)
    self.Normal.gameObject:SetActive(false)
    self.BtnTishen.gameObject:SetActive(false)
    self.BtnTishen.CallBack = function() self:OnBtnTishen() end
    self.Result = XUiFightControlState.Normal
    local data = XFubenConfigs.GetStageFightControl(self.StageFightControlId)
    if data == nil then
        return
    end
    local showAbility = 0
    local charlist = XDataCenter.CharacterManager.GetCharacterList()
    local dis
    local recommendFight
    local showFight
    --平均战力有几个人不满足
    local avgCount
    --上阵了几个人（用于判断一个人都没上的情况）
    local teamCount = 0
    for k, v in pairs(self.TeamAbility) do
        if v > 0 then
            teamCount = teamCount + 1
        end
    end
    --最高战力，找出战力最高的
    if data.MaxRecommendFight > 0 then
        dis = CS.XTextManager.GetText("MaxRecommendFight")
        for k, v in pairs(self.TeamAbility) do
            if v and v > showAbility then
                showAbility = v
            end
        end
        showAbility = math.floor(showAbility)
        recommendFight = data.MaxRecommendFight
        showFight = data.MaxShowFight
        --平均战力(找出有几个低于AvgShowFight，找出最低的那个计算危险程度)
    elseif data.AvgRecommendFight > 0 then
        dis = CS.XTextManager.GetText("AvgRecommendFight")
        local count = 0
        local noPlayer = true
        local minAbility = 99999
        for k, v in pairs(self.TeamAbility) do
            if v > 0 then
                noPlayer = false
                if v < data.AvgShowFight then
                    count = count + 1
                end
                if v < minAbility then
                    minAbility = v
                end
            end
        end
        avgCount = count
        if noPlayer then
            showAbility = 0
        elseif count == 0 then
            showAbility = data.AvgShowFight
        else
            showAbility = minAbility
        end
        recommendFight = data.AvgRecommendFight
        showFight = data.AvgShowFight
        --显示推荐战力，找出最高战力
    elseif data.RecommendFight > 0 then
        dis = CS.XTextManager.GetText("RecommendFight")
        for k, v in pairs(charlist) do
            if v.Ability and v.Ability > showAbility then
                showAbility = v.Ability
            end
        end
        showAbility = math.floor(showAbility)
        recommendFight = data.RecommendFight
        showFight = data.ShowFight
    end

    self.TxtNormalControlName.text = dis
    self.TxtHardControlName.text = dis
    self.TxtExControlName.text = dis
    if condition then--不满足条件直接极度困难
        --极度困难
        if showAbility < recommendFight then
            self.Ex.gameObject:SetActive(true)
            self.BtnTishen.gameObject:SetActiveEx(teamCount > 0)
            if data.MaxRecommendFight > 0 then
                self.TxtExCurFight.text = CS.XTextManager.GetText("MaxCurRecommendFight", showAbility)
            elseif data.AvgRecommendFight > 0 then
                if teamCount > 0 then
                    self.TxtExCurFight.text = CS.XTextManager.GetText("AvgCurRecommendFight", avgCount)
                else
                    self.TxtExCurFight.text = CS.XTextManager.GetText("FightConditionError")
                end
            elseif data.RecommendFight > 0 then
                self.TxtExCurFight.text = CS.XTextManager.GetText("MaxCurRecommendFight", showAbility)
            end
            self.TxtExMaxFight.text = showFight
            self.Result = XUiFightControlState.Ex
        --困难
        elseif showAbility >= recommendFight and showAbility < showFight then
            self.Hard.gameObject:SetActive(true)
            self.BtnTishen.gameObject:SetActiveEx(teamCount > 0)
            if data.MaxRecommendFight > 0 then
                self.TxtHardCurFight.text = CS.XTextManager.GetText("MaxCurRecommendFight", showAbility)
            elseif data.AvgRecommendFight > 0 then
                if teamCount > 0 then
                    self.TxtHardCurFight.text = CS.XTextManager.GetText("AvgCurRecommendFight", avgCount)
                else
                    self.TxtHardCurFight.text = CS.XTextManager.GetText("FightConditionError")
                end
            elseif data.RecommendFight > 0 then
                self.TxtHardCurFight.text = CS.XTextManager.GetText("MaxCurRecommendFight", showAbility)
            end
            self.TxtHardMaxFight.text = showFight
            self.Result = XUiFightControlState.Hard
        --普通(不显示)
        elseif showAbility >= showFight then
        end
    else
        self.Ex.gameObject:SetActive(true)
        self.TxtExCurFight.text = CS.XTextManager.GetText("FightConditionError")
        self.TxtExMaxFight.text = showFight
        self.Result = XUiFightControlState.Ex
    end
    self.ShowAbility = showAbility
    return self.Result
end

function XUiNewRoomFightControl:OnBtnTishen()
    XLuaUiManager.Open("UiPromotionWay", self.ShowAbility, self.TeamData, self.StageFightControlId, self.StageId)
end