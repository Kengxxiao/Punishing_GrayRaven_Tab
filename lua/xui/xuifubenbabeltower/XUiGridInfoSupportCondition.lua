local XUiGridInfoSupportCondition = XClass()

function XUiGridInfoSupportCondition:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiGridInfoSupportCondition:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiGridInfoSupportCondition:SetItemInfo(conditionData)
    self.SupportConditionId = conditionData.SupportConditionId
    self.SupportConditionTemplate = XFubenBabelTowerConfigs.GetBabelTowerSupportConditonTemplate(self.SupportConditionId)

   self:RefreshItemInfos() 
end

function XUiGridInfoSupportCondition:RefreshItemInfos()
    if self.SupportConditionTemplate then
        local isSupport = self.UiRoot:CheckBabelTeamCondition(self.SupportConditionTemplate.Condition)
        local description = XFubenBabelTowerConfigs.GetConditionDescription(self.SupportConditionId)
        self.PanelActive.gameObject:SetActiveEx(isSupport)
        self.TxtUnActiveCondition.text = description
        self.TxtUnActiveChallengeGet.text = self.SupportConditionTemplate.PointAdd
        self.TxtActiveCondition.text = description
        self.TxtActiveChallengeGet.text = self.SupportConditionTemplate.PointAdd
    end
end

return XUiGridInfoSupportCondition