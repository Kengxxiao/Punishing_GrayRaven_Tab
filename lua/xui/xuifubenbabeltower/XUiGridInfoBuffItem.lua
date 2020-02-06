local XUiGridInfoBuffItem = XClass()

function XUiGridInfoBuffItem:Ctor(ui, buffId, itemType)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.BuffId = buffId
    self.ItemType = itemType

    XTool.InitUiObject(self)
    self:Refresh(self.BuffId, self.ItemType)
end

-- 需要区分支援、挑战
function XUiGridInfoBuffItem:Refresh(buffId, itemType)
    self.BuffId = buffId
    self.ItemType = itemType
    self.BuffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(self.BuffId)
    self.BuffConfigs = XFubenBabelTowerConfigs.GetBabelBuffConfigs(self.BuffId)

    self.TxtDetails.text = self.BuffConfigs.Desc
    self.RImgChallengeIcon:SetRawImage(self.BuffConfigs.BuffBg)
    if self.ItemType == XFubenBabelTowerConfigs.TYPE_CHALLENGE then
        self.TxtNumber.text = self.BuffTemplate.ScoreAdd
    end

    if self.ItemType == XFubenBabelTowerConfigs.TYPE_SUPPORT then
        self.TxtNumber.text = self.BuffTemplate.PointSub
    end
end

return XUiGridInfoBuffItem