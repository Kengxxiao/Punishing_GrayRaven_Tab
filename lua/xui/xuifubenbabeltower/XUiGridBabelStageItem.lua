local XUiGridBabelStageItem = XClass()
local XUiBabelMemberSmallHead = require("XUi/XUiFubenBabelTower/XUiBabelMemberSmallHead")


function XUiGridBabelStageItem:Ctor(ui, uiRoot, stageId)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    self.StageId = stageId
    XTool.InitUiObject(self)
end

function XUiGridBabelStageItem:InitBanner()
    self.BtnReset.CallBack = function() self:OnBtnResetClick() end
    self.BtnSkip.CallBack = function() self:OnBtnSkipClick() end
    self.BtnStageMask.CallBack = function() self:OnBtnStageMaskClick() end

    self.memberSmallHead = {}
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        if not self.memberSmallHead[i] then
            local headgo = CS.UnityEngine.Object.Instantiate(self.CharacterHead)
            headgo.transform:SetParent(self.PanelLocking, false)
            headgo.gameObject:SetActiveEx(false)
            table.insert(self.memberSmallHead, XUiBabelMemberSmallHead.New(headgo))
        end
    end

end

function XUiGridBabelStageItem:UpdateStageInfo(stageId)
    self.StageId = stageId
    self.StageConfigs = XFubenBabelTowerConfigs.GetBabelStageConfigs(self.StageId)
    self.StageTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(self.StageId)
    
    if not self.GridStageChapter then
        self.GridStageChapter = self.Transform:LoadPrefab(self.StageConfigs.StagePrefab)
        local uiObj = self.GridStageChapter.transform:GetComponent("UiObject")
        
        for i = 0, uiObj.NameList.Count - 1 do
            self[uiObj.NameList[i]] = uiObj.ObjList[i]
        end
        
        self:InitBanner()
    end

    self:RefreshStageBanner()
    self:RefreshBtns()
end

function XUiGridBabelStageItem:RefreshStageBanner()

    self.StageInfos = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
    self.FubenStageCfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    self.TxtChallengeName.text = self.StageConfigs.Name

    local curScore = 0
    if self.StageInfos and (not self.StageInfos.IsReset) then
        curScore = self.StageInfos.CurScore
    end
    self.TxtChallenge.text = curScore

    -- 队伍信息
    if self.StageInfos and self.StageInfos.TeamList then
        for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
            local characterId = self.StageInfos.TeamList[i]
            local isExistCharacter = (not self.StageInfos.IsReset) and characterId ~= nil and characterId ~= 0
            self.memberSmallHead[i].GameObject:SetActiveEx(isExistCharacter)
            if isExistCharacter then
                self.memberSmallHead[i]:UpdateMember(characterId)
            end
        end
    else
        for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
            self.memberSmallHead[i].GameObject:SetActiveEx(false)
        end
    end

    self:RefreshStageInfo()
end

function XUiGridBabelStageItem:RefreshStageInfo()
    local isUnlock, desc = XDataCenter.FubenBabelTowerManager.IsBabelStageUnlock(self.StageId)
    self.RImgStageNorBg:SetRawImage(self.FubenStageCfg.Icon)
    self.PanelStageOrder.gameObject:SetActiveEx(isUnlock)
    self.ImgStageNormal.gameObject:SetActiveEx(isUnlock)
    self.ImgStageLock.gameObject:SetActiveEx(not isUnlock)
    local stageServerInfo = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
    self.PanelNewChallenge.gameObject:SetActiveEx(isUnlock and (not stageServerInfo))
    self.PanelLocking.gameObject:SetActiveEx(isUnlock)

    if isUnlock and stageServerInfo and stageServerInfo.GuildId then
        self.TabZx.gameObject:SetActiveEx(XDataCenter.FubenBabelTowerManager.IsStageGuideAuto(stageServerInfo.GuildId))
    else
        self.TabZx.gameObject:SetActiveEx(false)
    end
end

function XUiGridBabelStageItem:RefreshBtns()
    if not self.StageId then
        self.BtnReset.gameObject:SetActiveEx(false)
        self.BtnSkip.gameObject:SetActiveEx(false)
        return
    end
    
    local isStageUnlock = XDataCenter.FubenBabelTowerManager.IsBabelStageUnlock(self.StageId)
    local stageInfos = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)

    if not isStageUnlock or not stageInfos then
        self.BtnReset.gameObject:SetActiveEx(false)
        self.BtnSkip.gameObject:SetActiveEx(false)
        return
    end
    self.BtnReset.gameObject:SetActiveEx(not stageInfos.IsReset)
    self.BtnSkip.gameObject:SetActiveEx(stageInfos.IsReset)
end

function XUiGridBabelStageItem:OnBtnResetClick()
    local stageInfos = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
    if not self.StageId or not stageInfos then return end
    local title = CS.XTextManager.GetText("BabelTowerResetDesc")
    local content = CS.XTextManager.GetText("BabelTowerIsResetDesc", self.StageConfigs.Name)
    XUiManager.DialogTip(title, content, XUiManager.DialogType.Normal, nil, function()
        XDataCenter.FubenBabelTowerManager.ResetBabelTowerStage(self.StageId, function()
            stageInfos.IsReset = true
            self:UpdateStageInfo(self.StageId)
            self.UiRoot:UpdateStageScores()
            XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerStageResetSucceed", self.StageConfigs.Name))
        end)
    end)
end

function XUiGridBabelStageItem:OnBtnSkipClick()
    local stageInfos = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
    if not self.StageId or not stageInfos then return end

    local finishCallBack = function()
        self:UpdateStageInfo(self.StageId)
        self.UiRoot:UpdateStageScores()
    end
    XLuaUiManager.Open("UiBabelTowerAutoFight", self.StageId, finishCallBack)
end

function XUiGridBabelStageItem:OnBtnStageMaskClick()
    self.UiRoot:OnStageClick(self.StageId, self)
end

function XUiGridBabelStageItem:SetStageItemPress(isPress)
    self.PanelPress.gameObject:SetActiveEx(isPress)
end

return XUiGridBabelStageItem