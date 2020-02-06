local ComponentScriptPath = "XUi/XUiFubenMainLineChapter/%s"

local stringFormat = string.format

local XUiGridStage = XClass()

function XUiGridStage:Ctor(rootUi, ui, cb, fubenType)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.ClickCb = cb
    self.Components = {}
    self.FubenType = fubenType
    self:InitAutoScript()
    self:OnEnable()
end

function XUiGridStage:OnEnable()
    if self.Stage then
        self:UpdateFightControl()
    end

    if self.Enabled then
        return
    end

    self.Enabled = true
end

function XUiGridStage:OnDisable()
    if not self.Enabled then
        return
    end

    for _, component in pairs(self.Components) do
        if component.OnDisable then component:OnDisable() end
    end

    self.Enabled = false
end

--[[设置组件显隐，第一次设置显示时若组件不存在则加载组件prefab]]
--componentName:组件名称字符串
--isActive:是否显示
--notScript:是否不需要加载组件脚本
function XUiGridStage:SetComponentActive(componentName, isActive, notScript, ...)
    local component = self.Components[componentName]
    local go = component and (component.GameObject or component.gameObject)
    if not XTool.UObjIsNil(go) then
        go:SetActiveEx(isActive)

        if isActive then
            if component.OnEnable then component:OnEnable(...) end
            if self.Stage and component.UpdateStageId then
                component:UpdateStageId(self.Stage.StageId)
            end
        else
            if component.OnDisable then component:OnDisable() end
        end
    elseif isActive then
        local parent = self[componentName .. "Parent"]
        if XTool.UObjIsNil(parent) then return end
        local prefab = self.Obj:Instantiate(componentName, parent.gameObject)
        if XTool.UObjIsNil(prefab) then return end

        local scriptPath = stringFormat(ComponentScriptPath, "XUi" .. componentName)
        if notScript then
            self.Components[componentName] = prefab
        else
            component = require(scriptPath).New(prefab, ...)
            self.Components[componentName] = component
            if component.OnEnable then component:OnEnable(...) end
        end
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridStage:InitAutoScript()
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridStage:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridStage:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridStage:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridStage:AutoAddListener()
    self:RegisterClickEvent(self.BtnStage, self.OnBtnStageClick)
end
-- auto
function XUiGridStage:OnBtnStageClick()
    if self.ClickCb then
        self.ClickCb(self)
    end

    local stageId = self.Stage.StageId
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)

    if self.FubenType == XFubenConfigs.FUBENTYPE_NORMAL then
        self:NormalStageClick(stageId, stageCfg, stageInfo)
    elseif self.FubenType == XFubenConfigs.FUBENTYPE_PREQUEL then
        self:PrequelStageClick(stageId, stageCfg, stageInfo)
    end
end

function XUiGridStage:NormalStageClick(stageId, stageCfg, stageInfo)
    if stageCfg.StageType == XFubenConfigs.STAGETYPE_STORY or stageCfg.StageType == XFubenConfigs.STAGETYPE_STORYEGG then

    elseif stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHT or stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG then

    end
end

function XUiGridStage:PrequelStageClick(stageId, stageCfg, stageInfo)
    --普通副本格子点击
    if stageCfg.StageType == XFubenConfigs.STAGETYPE_STORY or stageCfg.StageType == XFubenConfigs.STAGETYPE_STORYEGG then
        if not XDataCenter.PrequelManager.CheckPrequelStageOpen(stageId) then
            if stageCfg.RequireLevel > 0 and XPlayer.Level < stageCfg.RequireLevel then
                XUiManager.TipError(CS.XTextManager.GetText("TeamLevelToOpen", stageCfg.RequireLevel))
                return
            end
            for _, conditionId in pairs(stageCfg.ForceConditionId or {}) do
                local ret, desc = XConditionManager.CheckCondition(conditionId)
                if not ret then
                    XUiManager.TipError(desc)
                    return
                end
            end
            return
        end

        if stageInfo.Passed then
            self.RootUi:OnEnterStory(stageId, function()
                if CS.Movie.XMovieManager.Instance:CheckMovieExist(stageCfg.BeginStoryId) then
                    CS.Movie.XMovieManager.Instance:PlayById(stageCfg.BeginStoryId, function()
                        XDataCenter.PrequelManager.UpdateShowChapter(stageId)
                    end)
                end
            end)
        else
            self.RootUi:OnEnterStory(stageId, function()
                XDataCenter.PrequelManager.FinishStoryRequest(stageId, function(res)
                    if CS.Movie.XMovieManager.Instance:CheckMovieExist(stageCfg.BeginStoryId) then
                        CS.Movie.XMovieManager.Instance:PlayById(stageCfg.BeginStoryId, function()
                            self.RootUi:RefreshRegional()
                            XDataCenter.PrequelManager.UpdateShowChapter(stageId)
                        end)
                    end
                end)
            end)
        end
        --前传战斗点击
    elseif stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHT or stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG then
        if not XDataCenter.PrequelManager.CheckPrequelStageOpen(stageId) then
            if stageCfg.RequireLevel > 0 and XPlayer.Level < stageCfg.RequireLevel then
                XUiManager.TipError(CS.XTextManager.GetText("TeamLevelToOpen", stageCfg.RequireLevel))
                return
            end
            for _, conditionId in pairs(stageCfg.ForceConditionId or {}) do
                local ret, desc = XConditionManager.CheckCondition(conditionId)
                if not ret then
                    XUiManager.TipError(desc)
                    return
                end
            end
            return
        end

        self.RootUi:OnEnterFight(stageId, function()
            XDataCenter.FubenManager.EnterPrequelFight(stageId)
        end)
    end
end

function XUiGridStage:UpdateStageMapGrid(stage, chapterOrderId)
    self.Stage = stage
    self.ChapterOrderId = chapterOrderId
    self:Refresh()
end

function XUiGridStage:Refresh()
    if not self.Enabled then return end

    local stageId = self.Stage.StageId
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
    local nextStageInfo = XDataCenter.FubenManager.GetStageInfo(stageInfo.NextStageId)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)



    if stageCfg.StageType == XFubenConfigs.STAGETYPE_COMMON then
        self:SetNormalStage(stageInfo, nextStageInfo, stageCfg, stageId, stageCfg.StageType)
    else
        if self.FubenType == XFubenConfigs.FUBENTYPE_NORMAL then    
            --[主线副本/据点战/支线活动]
            self:SetNormalStage(stageInfo, nextStageInfo, stageCfg, stageId, stageCfg.StageType)
        elseif self.FubenType == XFubenConfigs.FUBENTYPE_PREQUEL then    
            --[前传]
            self:SetPrequelStage(stageId, stageInfo, stageCfg.StageType)
        end
    end


end

function XUiGridStage:SetPrequelStage(stageId, stageInfo, stageType)
    if stageType == XFubenConfigs.STAGETYPE_STORY then
        local isStageUnlock = XDataCenter.PrequelManager.CheckPrequelStageOpen(stageId)
        self:SetComponentActive("PanelFightActive", false)
        self:SetComponentActive("PanelFightUnactive", false)
        self:SetComponentActive("PanelStoryActive", isStageUnlock, nil, stageId, self.ChapterOrderId)
        self:SetComponentActive("PanelStoryUnactive", not isStageUnlock, nil, stageId, self.ChapterOrderId)
        self:SetComponentActive("PanelHideTagNor", false)
        self:SetComponentActive("PanelHideTagLock", false)
        self:SetComponentActive("PanelKill", stageInfo.Passed, true)
        self:SetComponentActive("PanelHideStageNor", false)

        -- 迁移位置测试
        self:AdjustStoryPanelKillPosition(self.Components["PanelStoryActive"], self.Components["PanelKill"])

    elseif stageType == XFubenConfigs.STAGETYPE_FIGHT then
        local isStageUnlock = XDataCenter.PrequelManager.CheckPrequelStageOpen(stageId)
        self:SetComponentActive("PanelStoryActive", false)
        self:SetComponentActive("PanelStoryUnactive", false)
        self:SetComponentActive("PanelFightActive", isStageUnlock, nil, stageId, function()
            self:OnBtnStageClick()
        end)
        self:SetComponentActive("PanelFightUnactive", not isStageUnlock, true)
        self:SetComponentActive("PanelHideTagNor", false)
        self:SetComponentActive("PanelHideTagLock", false)
        self:SetComponentActive("PanelKill", stageInfo.Passed, true)
        self:SetComponentActive("PanelHideStageNor", false)

        -- 迁移位置测试
        self:AdjustFightPanelKillPosition(self.Components["PanelFightActive"], self.Components["PanelKill"])

    elseif stageType == XFubenConfigs.STAGETYPE_FIGHTEGG then
        local isStageUnlock = XDataCenter.PrequelManager.CheckPrequelStageOpen(stageId)
        self:SetComponentActive("PanelHideStageNor", isStageUnlock, nil, stageId, self.RootUi)
        self:SetComponentActive("PanelHideTagNor", false)
        self:SetComponentActive("PanelHideTagLock", false)
        self:SetComponentActive("PanelStoryActive", false)
        self:SetComponentActive("PanelStoryUnactive", false)
        self:SetComponentActive("PanelFightActive", false)
        self:SetComponentActive("PanelFightUnactive", false)

    elseif stageType == XFubenConfigs.STAGETYPE_STORYEGG then
        local isStageUnlock = XDataCenter.PrequelManager.CheckPrequelStageOpen(stageId)
        self:SetComponentActive("PanelHideTagNor", isStageUnlock, false, stageId, self.RootUi)
        self:SetComponentActive("PanelHideTagLock", not isStageUnlock, true, stageId, self.RootUi)
        self:SetComponentActive("PanelStoryActive", false)
        self:SetComponentActive("PanelStoryUnactive", false)
        self:SetComponentActive("PanelFightActive", false)
        self:SetComponentActive("PanelFightUnactive", false)
        self:SetComponentActive("PanelHideStageNor", false)
    end
end

function XUiGridStage:AdjustStoryPanelKillPosition(storyUi, panelkillUi)
    if not storyUi or not panelkillUi then return end
    if storyUi["GetKillPos"] then
        panelkillUi.transform.position = storyUi:GetKillPos()
    end
end

function XUiGridStage:AdjustFightPanelKillPosition(fightUi, panelkillUi)
    if not fightUi or not panelkillUi then return end
    if fightUi["GetKillPos"] then
        panelkillUi.transform.position = fightUi:GetKillPos()
    end
end

function XUiGridStage:SetNormalStage(stageInfo, nextStageInfo, stageCfg, stageId, stageType)
    local IsEgg = false
    if stageType == XFubenConfigs.STAGETYPE_FIGHTEGG or stageType == XFubenConfigs.STAGETYPE_STORYEGG then
        IsEgg = true
    end

    if stageType == XFubenConfigs.STAGETYPE_STORY or stageType == XFubenConfigs.STAGETYPE_STORYEGG then
        if stageInfo.Unlock then
            self:SetStoryStageActive()
            if (not (nextStageInfo and nextStageInfo.Unlock or stageInfo.Passed)) and not IsEgg then
                self:SetComponentActive("PanelEffect", true, true)
            end
        else
            self:SetStoryStageLock()
        end
        
    elseif stageType == XFubenConfigs.STAGETYPE_FIGHT or stageType == XFubenConfigs.STAGETYPE_FIGHTEGG or stageType == XFubenConfigs.STAGETYPE_COMMON then

        if stageInfo.Unlock then
            self:SetStageActive()
            if (not (nextStageInfo and nextStageInfo.Unlock or stageInfo.Passed)) and not IsEgg then
                self:SetComponentActive("PanelEffect", true, true)
            end
        elseif stageInfo.IsOpen then
            self:SetStageLock()
        end

        local stagePassed
        if XDataCenter.BfrtManager.CheckStageTypeIsBfrt(stageId) then
            stagePassed = XDataCenter.BfrtManager.IsGroupPassedByStageId(stageId)
            self:SetComponentActive("PanelKill", stagePassed, true)
        else
            stagePassed = stageInfo.Passed
        end
        if stageInfo.Type == XDataCenter.FubenManager.StageType.ActivtityBranch then
            self:SetComponentActive("PanelKill", stagePassed, true)
        end

        local rewardTipId = stageCfg.RewardTipId or 0
        self:SetComponentActive("PanelRewardTips", rewardTipId ~= 0, nil, self.RootUi, stageId)

        self:SetComponentActive("PanelAutoFight", stageCfg.AutoFightId > 0, nil, stageId)

        self:SetComponentActive("PanelStoryActive", false)
        self:SetComponentActive("PanelStoryUnactive", false)

        --赏金任务
        local IsBountyTaskPreFight, task = XDataCenter.BountyTaskManager.CheckBountyTaskPreFight(stageId)
        self:SetComponentActive("PanelBountyTaskInGrid", IsBountyTaskPreFight and task.Status ~= XDataCenter.BountyTaskManager.BountyTaskStatus.AcceptReward, nil, task)

        --战力警告
        self:UpdateFightControl()
    end

    if not IsEgg then
        if self.ImageNorHideBg then
            self.ImageNorHideBg.gameObject:SetActive(false)
        end
        if self.Line then
            self.Line.gameObject:SetActive(false)
        end
    end
end

function XUiGridStage:UpdateFightControl()
    local stageId = self.Stage.StageId
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)

    local clearFightControl = true
    if stageInfo.Unlock and not stageInfo.Passed then
        if stageCfg.FightControlId > 0 then
            local data = XFubenConfigs.GetStageFightControl(stageCfg.FightControlId)
            local charlist = XDataCenter.CharacterManager.GetCharacterList()
            local maxAbility = 0
            for k, v in pairs(charlist) do
                if v.Ability and v.Ability > maxAbility then
                    maxAbility = v.Ability
                end
            end
            if maxAbility < data.RecommendFight then
                self:SetComponentActive("PanelStageFightControlHard", false)
                self:SetComponentActive("PanelStageFightControlEx", true, true)
                clearFightControl = false
            elseif maxAbility >= data.RecommendFight and maxAbility < data.ShowFight then
                self:SetComponentActive("PanelStageFightControlHard", true, true)
                self:SetComponentActive("PanelStageFightControlEx", false)
                clearFightControl = false
            end
        end
    end
    if clearFightControl then
        self:SetComponentActive("PanelStageFightControlEx", false)
        self:SetComponentActive("PanelStageFightControlHard", false)
    end
end

function XUiGridStage:SetStageTypePanelActive(isActive)
    if isActive then
        local stageId = self.Stage.StageId
        if XDataCenter.BfrtManager.CheckStageTypeIsBfrt(stageId) then
            self:SetComponentActive("PanelEchelon", true, nil, stageId)
            self:SetComponentActive("PanelStars", false)
        else
            local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
            self:SetComponentActive("PanelStars", true, nil, stageInfo.StarsMap)
            self:SetComponentActive("PanelEchelon", false)
        end
    else
        self:SetComponentActive("PanelStars", false)
        self:SetComponentActive("PanelEchelon", false)
    end
end

function XUiGridStage:SetStoryStageSelect()
    local tmp_2 = self.Stage.StageType == XFubenConfigs.STAGETYPE_STORY or self.Stage.StageType == XFubenConfigs.STAGETYPE_STORYEGG and self.FubenType == XFubenConfigs.FUBENTYPE_NORMAL
    if not (tmp_2) then return end
    self:SetComponentActive("PanelStorySelected", true,nil, self.Stage.StageId, self.ChapterOrderId)
    self:SetComponentActive("PanelStoryActive", false)
    self:SetComponentActive("PanelStoryUnactive",false)
    self:SetComponentActive("PanelEffect", false)
end

function XUiGridStage:SetStoryStageActive()
    local tmp_2 = self.Stage.StageType == XFubenConfigs.STAGETYPE_STORY or self.Stage.StageType == XFubenConfigs.STAGETYPE_STORYEGG and self.FubenType == XFubenConfigs.FUBENTYPE_NORMAL
    if not (tmp_2) then return end
    self:SetComponentActive("PanelStoryActive", true, nil, self.Stage.StageId, self.ChapterOrderId)
    self:SetComponentActive("PanelStoryUnactive", false)
    self:SetComponentActive("PanelStorySelected", false)
    self:SetComponentActive("PanelEffect", false)
end

function XUiGridStage:SetStoryStageLock()
    local tmp_2 = self.Stage.StageType == XFubenConfigs.STAGETYPE_STORY or self.Stage.StageType == XFubenConfigs.STAGETYPE_STORYEGG and self.FubenType == XFubenConfigs.FUBENTYPE_NORMAL
    if not (tmp_2) then return end
    self:SetComponentActive("PanelStoryUnactive", true, nil, self.Stage.StageId, self.ChapterOrderId)
    self:SetComponentActive("PanelStoryActive", false)
    self:SetComponentActive("PanelStorySelected", false)
    self:SetComponentActive("PanelEffect", false)
end

function XUiGridStage:SetStageSelect()
    local tmp_1 = self.Stage.StageType == XFubenConfigs.STAGETYPE_COMMON
    local tmp_2 = self.Stage.StageType == XFubenConfigs.STAGETYPE_FIGHT or self.Stage.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG and self.FubenType == XFubenConfigs.FUBENTYPE_NORMAL
    if not (tmp_1 or tmp_2) then return end

    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.Stage.StageId)
    if stageInfo.Type == XDataCenter.FubenManager.StageType.ActivtityBranch then return end
    self:SetComponentActive("PanelStageSelected", true, nil, self.Stage.StageId, self.ChapterOrderId)
    self:SetComponentActive("PanelStageActive", false)
    self:SetComponentActive("PanelStageLock", false)
    self:SetComponentActive("PanelEffect", false)
    self:SetStageTypePanelActive(true)
end

function XUiGridStage:SetStageActive()
    local tmp_1 = self.Stage.StageType == XFubenConfigs.STAGETYPE_COMMON
    local tmp_2 = self.Stage.StageType == XFubenConfigs.STAGETYPE_FIGHT or self.Stage.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG and self.FubenType == XFubenConfigs.FUBENTYPE_NORMAL
    if not (tmp_1 or tmp_2) then return end

    self:SetComponentActive("PanelStageActive", true, nil, self.Stage.StageId, self.ChapterOrderId)
    self:SetComponentActive("PanelStageLock", false)
    self:SetComponentActive("PanelStageSelected", false)
    self:SetComponentActive("PanelEffect", false)
    self:SetStageTypePanelActive(true)
end

function XUiGridStage:SetStageLock()
    local tmp_1 = self.Stage.StageType == XFubenConfigs.STAGETYPE_COMMON
    local tmp_2 = self.Stage.StageType == XFubenConfigs.STAGETYPE_FIGHT or self.Stage.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG and self.FubenType == XFubenConfigs.FUBENTYPE_NORMAL
    if not (tmp_1 or tmp_2) then return end

    self:SetComponentActive("PanelStageLock", true, nil, self.Stage.StageId, self.ChapterOrderId)
    self:SetComponentActive("PanelStageActive", false)
    self:SetComponentActive("PanelStageSelected", false)
    self:SetComponentActive("PanelRewardTips", false)
    self:SetComponentActive("PanelEffect", false)
    self:SetStageTypePanelActive(false)
end

return XUiGridStage