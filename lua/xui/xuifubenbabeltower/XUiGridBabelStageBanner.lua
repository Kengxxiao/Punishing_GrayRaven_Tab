local XUiGridBabelStageBanner = XClass()
local XUiBabelMemberSmallHead = require("XUi/XUiFubenBabelTower/XUiBabelMemberSmallHead")
local XUiGridBabelStageGuideItem = require("XUi/XUiFubenBabelTower/XUiGridBabelStageGuideItem")


function XUiGridBabelStageBanner:Ctor(ui, uiRoot, stageId)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    self.StageId = stageId

    XTool.InitUiObject(self)
end

function XUiGridBabelStageBanner:InitBanner()
    self.BtnReset.CallBack = function() self:OnBtnResetClick() end
    self.BtnSkip.CallBack = function() self:OnBtnSkipClick() end

    self.memberSmallHead = {}
    for i = 1, XFubenBabelTowerConfigs.MAX_TEAM_MEMBER do
        if not self.memberSmallHead[i] then
            local headgo = CS.UnityEngine.Object.Instantiate(self.CharacterHead)
            headgo.transform:SetParent(self.PanelLocking, false)
            headgo.gameObject:SetActiveEx(false)
            table.insert(self.memberSmallHead, XUiBabelMemberSmallHead.New(headgo))
        end
    end

    if not self.StageTemplate then return end
    self.StageGuideList = {}
    for i = 1, #self.StageTemplate.StageGuideId do
        local stageGuideId = self.StageTemplate.StageGuideId[i]
        if not self.StageGuideList[i] then
            local go = self.PanelTaskList:Find(string.format("Stage%d", i))
            table.insert(self.StageGuideList, XUiGridBabelStageGuideItem.New(go, self.StageId, stageGuideId))
        end
    end

end

function XUiGridBabelStageBanner:UpdateStageInfo(stageId)
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
    self:RefreshStageLockInfo()
    self:RefreshBtns()
end

function XUiGridBabelStageBanner:RefreshStageBanner()

    self.StageInfos = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
    self.TxtStageName.text = self.StageConfigs.Name

    local curScore = 0
    if self.StageInfos and (not self.StageInfos.IsReset) then
        curScore = self.StageInfos.CurScore
    end
    self.TxtLevelNumber.text = curScore

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

    -- 指引关卡
    for i = 1, #self.StageTemplate.StageGuideId do
        self.StageGuideList[i]:UpdateStageGuideInfo(self.StageId, self.StageTemplate.StageGuideId[i])
    end
end

function XUiGridBabelStageBanner:RefreshStageLockInfo()
    if not self.StageId then
        self.ImgEmpty.gameObject:SetActiveEx(false)
        return
    end
    local isUnlock, description = XDataCenter.FubenBabelTowerManager.IsBabelStageUnlock(self.StageId)
    self.ImgEmpty.gameObject:SetActiveEx(false)
    self.TxtNone.text = description
end

function XUiGridBabelStageBanner:RefreshBtns()
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

function XUiGridBabelStageBanner:OnBtnResetClick()
    local stageInfos = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
    if not self.StageId or not stageInfos then return end
    local title = CS.XTextManager.GetText("BabelTowerResetDesc")
    local content = CS.XTextManager.GetText("BabelTowerIsResetDesc", self.StageConfigs.Name)
    XUiManager.DialogTip(title, content, XUiManager.DialogType.Normal, nil, function()
        XDataCenter.FubenBabelTowerManager.ResetBabelTowerStage(self.StageId, function()
            stageInfos.IsReset = true
            self:UpdateStageInfo(self.StageId)
            self.UiRoot:UpdateStageScores()
        end)
    end)
end

function XUiGridBabelStageBanner:OnBtnSkipClick()
    local stageInfos = XDataCenter.FubenBabelTowerManager.GetBabelTowerStageInfo(self.StageId)
    if not self.StageId or not stageInfos then return end

    local finishCallBack = function()
        self:UpdateStageInfo(self.StageId)
        self.UiRoot:UpdateStageScores()
    end
    XLuaUiManager.Open("UiBabelTowerAutoFight", self.StageId, finishCallBack)
end

return XUiGridBabelStageBanner