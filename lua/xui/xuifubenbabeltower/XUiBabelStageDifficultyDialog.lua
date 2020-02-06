local XUiBabelStageDifficultyDialog = XClass()

function XUiBabelStageDifficultyDialog:Ctor(ui, uiroot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot

    XTool.InitUiObject(self)

    self.BtnClose.CallBack = function() self:OnBtnCloseClick() end
    self.BtnDetermine.CallBack = function() self:OnBtnDetermineClick() end
    self.GridGuildList = {}
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint)
end

function XUiBabelStageDifficultyDialog:OpenStageDialog(stageId)
    self.StageId = stageId
    self.GameObject:SetActiveEx(true)
    self.UiRoot:PlayAnimation("DifficultyEnable")
    self.StageTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(self.StageId)
    self.StageConfigs = XFubenBabelTowerConfigs.GetBabelStageConfigs(self.StageId)

    self.TxtTitle.text = self.StageConfigs.Name
    self.CurrentSelectIndex = nil
    self.CurrentSelectGuideId = nil
    
    local defaultIndex = 1
    for i = 1, #self.StageTemplate.StageGuideId do
        local curGuideId = self.StageTemplate.StageGuideId[i]
        if not self.GridGuildList[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.GridDifficulty)
            go.transform:SetParent(self.PanelDifficulty.transform, false)
            go.gameObject:SetActiveEx(true)
            go.name = string.format("%s%d", self.GridDifficulty.name, i)
            table.insert(self.GridGuildList, go.transform:GetComponent("XUiButton"))
        end
        local isUnlock = XDataCenter.FubenBabelTowerManager.IsBabelStageGuideUnlock(self.StageId, curGuideId)
        if isUnlock then
            defaultIndex = i
        end
    end

    for i = #self.StageTemplate.StageGuideId + 1, #self.GridGuildList do
        self.GridGuildList[i].gameObject:SetActiveEx(false)
    end
    
    self:UpdateDifficultyInfo()
    self.PanelDifficulty:Init(self.GridGuildList, function(index) self:OnStageGuildDifficultyClick(index) end)
    self.PanelDifficulty:SelectIndex(defaultIndex)
end

function XUiBabelStageDifficultyDialog:UpdateDifficultyInfo()
    for i = 1, #self.StageTemplate.StageGuideId do
        local curGuideId = self.StageTemplate.StageGuideId[i]
        local guideConfigs = XFubenBabelTowerConfigs.GetStageGuideConfigs(curGuideId)
        self.GridGuildList[i]:SetNameByGroup(0, guideConfigs.Description)
        local isUnlock = XDataCenter.FubenBabelTowerManager.IsBabelStageGuideUnlock(self.StageId, curGuideId)
        self.GridGuildList[i]:SetDisable(not isUnlock, true)
        if not isUnlock then
            local isStageUnlock, desc = XDataCenter.FubenBabelTowerManager.IsBabelStageUnlock(self.StageId)
            local lockDescription = ""
            if not isStageUnlock then
                lockDescription = desc
            else
                lockDescription = CS.XTextManager.GetText("BabelTowerPassLastGuide")
            end
            self.GridGuildList[i]:SetNameByGroup(1, lockDescription)
        end
    end
end

function XUiBabelStageDifficultyDialog:OnStageGuildDifficultyClick(index)
    if index == self.CurrentSelectIndex then return end 
    local selectedGuideId = self.StageTemplate.StageGuideId[index]
    if self.StageId and selectedGuideId then
        -- 锁住return
        local isUnlock = XDataCenter.FubenBabelTowerManager.IsBabelStageGuideUnlock(self.StageId, selectedGuideId)
        if not isUnlock then
            local isStageUnlock, desc = XDataCenter.FubenBabelTowerManager.IsBabelStageUnlock(self.StageId)
            if not isStageUnlock then
                XUiManager.TipMsg(desc)
            else
                XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerPassLastGuide"))
            end
            return
        end
    end
    self.CurrentSelectIndex = index
    self.CurrentSelectGuideId = selectedGuideId
end

function XUiBabelStageDifficultyDialog:OnBtnCloseClick()
    self.GameObject:SetActiveEx(false)
    self.UiRoot:OnPanelDifficultyClose()
end

function XUiBabelStageDifficultyDialog:OnBtnDetermineClick()
    if self.StageId and self.CurrentSelectGuideId then
        -- 锁住return
        local isUnlock = XDataCenter.FubenBabelTowerManager.IsBabelStageGuideUnlock(self.StageId, self.CurrentSelectGuideId)
        if not isUnlock then
            local isStageUnlock, desc = XDataCenter.FubenBabelTowerManager.IsBabelStageUnlock(self.StageId)
            if not isStageUnlock then
                XUiManager.TipMsg(desc)
            else
                XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerPassLastGuide"))
            end
            return
        end
    end
    XLuaUiManager.Open("UiBabelTowerBase", self.StageId, self.CurrentSelectGuideId)
    self.GameObject:SetActiveEx(false)
    self.UiRoot:OnPanelDifficultyClose()
end

return XUiBabelStageDifficultyDialog