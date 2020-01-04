local XUiGridArenaStage = XClass()

function XUiGridArenaStage:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridArenaStage:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridArenaStage:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridArenaStage:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridArenaStage:AutoAddListener()
    self:RegisterClickEvent(self.BtnStage, self.OnBtnStageClick)
    self:RegisterClickEvent(self.BtnLock, self.OnBtnLockClick)
end

function XUiGridArenaStage:OnBtnLockClick(eventData)
    XUiManager.TipMsg(CS.XTextManager.GetText("ArenaConnotPassTip"))
end

function XUiGridArenaStage:OnBtnStageClick(eventData)
    XLuaUiManager.Open("UiEnterFight", XFubenExploreConfigs.NodeTypeEnum.Arena, nil, nil, nil, nil, function()
        self.AreaCfg = XArenaConfigs.GetArenaAreaStageCfgByAreaId(self.AreaId)
        if not self.CurIndex then
            return
        end
    
        if not self.AreaCfg then
            return
        end
    
        XDataCenter.ArenaManager.SetEnterAreaStageInfo(self.AreaId, self.CurIndex)
        XLuaUiManager.Open("UiNewRoomSingle", self.AreaCfg.StageId[self.CurIndex])
    end, self.StageId, self.AreaId)  
end

function XUiGridArenaStage:Refresh(index, curIndex, score, stageId, areaId)
    if not index then
        return
    end
    self.StageId = stageId
    self.AreaId = areaId
    self.CurIndex = index
    local config = XArenaConfigs.GetArenaStageConfig(stageId)
    self.TxtScore.text = CS.XTextManager.GetText("AreanaStaSocre", score)
    self.RImgBg:SetRawImage(config.BgIconSmall)
    self.ImgDifficulty:SetRawImage(config.DifficuIocn)
    self.TxtTitle.text = config.Name

    if index <= curIndex then
        self.BtnLock.gameObject:SetActive(false)
        self.TxtScore.gameObject:SetActive(true)
    else
        self.BtnLock.gameObject:SetActive(true)
        self.TxtScore.gameObject:SetActive(false)
    end
end

return XUiGridArenaStage
