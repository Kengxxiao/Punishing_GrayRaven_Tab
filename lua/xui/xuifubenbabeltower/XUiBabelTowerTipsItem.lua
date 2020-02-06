local XUiBabelTowerTipsItem = XClass()

function XUiBabelTowerTipsItem:Ctor(ui, itemType)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.ItemType = itemType

    XTool.InitUiObject(self)
end

function XUiBabelTowerTipsItem:RefreshBuffInfo(buffInfo, itemType)
    self.BuffInfo = buffInfo
    self.ItemType = itemType

    self.BuffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(self.BuffInfo.BufferId)
    self.BuffGroupTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffGroupTemplate(self.BuffInfo.GroupId)
    self.BuffConfigs = XFubenBabelTowerConfigs.GetBabelBuffConfigs(self.BuffInfo.BufferId)
    self.BuffGroupConfigs = XFubenBabelTowerConfigs.GetBabelBuffGroupConfigs(self.BuffInfo.GroupId)

    self.RImgBuff:SetRawImage(self.BuffConfigs.BuffBg)
    if self.ItemType == XFubenBabelTowerConfigs.TYPE_CHALLENGE then
        self.TxtPoint.text = self.BuffTemplate.ScoreAdd
    end

    if self.ItemType == XFubenBabelTowerConfigs.TYPE_SUPPORT then
        self.TxtPoint.text = self.BuffTemplate.PointSub
    end
    self.TxtLv.text = CS.XTextManager.GetText("BabelTowerLevelDesc", self:GetBuffLv(self.BuffInfo.BufferId))
end

function XUiBabelTowerTipsItem:GetBuffLv(buffId)
    local index = 1
    for i = 1, #self.BuffGroupTemplate.BuffId do
        if buffId == self.BuffGroupTemplate.BuffId[i] then
            index = i
            break
        end
    end
    return self.BuffGroupConfigs.BuffLv[index] or 0
end

return XUiBabelTowerTipsItem