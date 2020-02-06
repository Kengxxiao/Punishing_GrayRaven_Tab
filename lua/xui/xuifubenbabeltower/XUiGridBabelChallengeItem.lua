local XUiGridBabelChallengeItem = XClass()
local UiButtonState = CS.UiButtonState

function XUiGridBabelChallengeItem:Ctor(ui, parentUi, index, itemType)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.ParentUi = parentUi
    self.Index = index
    self.ItemType = itemType

    XTool.InitUiObject(self)
    self.ToggleButon = self.Transform:GetComponent("XUiButton")
end

function XUiGridBabelChallengeItem:GetXUiButtonComp()
    return self.ToggleButon
end

function XUiGridBabelChallengeItem:UpdateBuff(buffTemplate, buffConfigs, index, itemType)
    self.BuffTemplate = buffTemplate
    self.BuffConfigs = buffConfigs
    if index then self.Index = index end
    if itemType then self.ItemType = itemType end
    if self.ItemType == XFubenBabelTowerConfigs.TYPE_CHALLENGE then
        self.TxtNumber.text = buffTemplate.ScoreAdd
    end
    if self.ItemType == XFubenBabelTowerConfigs.TYPE_SUPPORT then
        self.TxtNumber.text = buffTemplate.PointSub
    end
    self.RImgChallengeIconNor:SetRawImage(self.BuffConfigs.BuffBg)
    self.RImgChallengeIconPress:SetRawImage(self.BuffConfigs.BuffBg)
    self.RImgChallengeIconSelect:SetRawImage(self.BuffConfigs.BuffBg)
    self.RImgChallengeIconDisable:SetRawImage(self.BuffConfigs.BuffBg)

    local btnState = (self.ParentUi:GetBuffSelectStatus(self.BuffTemplate.Id)) and UiButtonState.Select or UiButtonState.Normal
    self.ToggleButon:SetButtonState(btnState)
end

return XUiGridBabelChallengeItem