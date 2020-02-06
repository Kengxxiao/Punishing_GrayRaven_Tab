local XUiGridBabelStageGuideItem = XClass()

function XUiGridBabelStageGuideItem:Ctor(ui, stageId, stageGuideId)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.StageId = stageId
    self.StageGuideId = stageGuideId
    self.StageConfigs = XFubenBabelTowerConfigs.GetBabelStageConfigs(self.StageId)

    self.GridStageGuide = self.Transform:LoadPrefab(self.StageConfigs.StageGuidePrefab)
    self.ButtonComp = self.GridStageGuide:GetComponent("XUiButton")
    self.ButtonComp.CallBack = function() self:OnBtnStageGuideClick() end
end

function XUiGridBabelStageGuideItem:UpdateStageGuideInfo(stageId, stageGuideId)
    self.StageId = stageId
    self.StageGuideId = stageGuideId
    self.StageTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageTemplate(self.StageId)
    self.StageGuideTemplate = XFubenBabelTowerConfigs.GetBabelTowerStageGuideTemplate(self.StageGuideId)
    self.StageGuideConfigs = XFubenBabelTowerConfigs.GetStageGuideConfigs(self.StageGuideId)

    self.ButtonComp:SetNameByGroup(0, self.StageGuideConfigs.Name)
    self.ButtonComp:SetNameByGroup(1, self.StageGuideConfigs.Description)

    -- 设置锁住状态
    local isUnlock = XDataCenter.FubenBabelTowerManager.IsBabelStageGuideUnlock(self.StageId, self.StageGuideId)
    self.ButtonComp:SetDisable(not isUnlock)
end

function XUiGridBabelStageGuideItem:OnBtnStageGuideClick()
    if self.StageId and self.StageGuideId then
        -- 锁住return
        local isUnlock = XDataCenter.FubenBabelTowerManager.IsBabelStageGuideUnlock(self.StageId, self.StageGuideId)
        if not isUnlock then
            local isStageUnlock, desc = XDataCenter.FubenBabelTowerManager.IsBabelStageUnlock(self.StageId)
            if not isStageUnlock then
                XUiManager.TipMsg(desc)
            else
                XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerPassLastGuide"))
            end
            return
        end

        XLuaUiManager.Open("UiBabelTowerBase", self.StageId, self.StageGuideId)
    end
end

return XUiGridBabelStageGuideItem