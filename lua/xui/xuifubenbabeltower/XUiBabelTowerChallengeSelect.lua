local XUiBabelTowerChallengeSelect = XClass()

function XUiBabelTowerChallengeSelect:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiBabelTowerChallengeSelect:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiBabelTowerChallengeSelect:SetItemData(chooseItem, buffType)
    self.ChooseItem = chooseItem
    self.BuffId = chooseItem.SelectBuffId
    self.BuffType = buffType
    self.BuffConfigs = XFubenBabelTowerConfigs.GetBabelBuffConfigs(self.BuffId)
    self.BuffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(self.BuffId)
    
    self.TxtDescribe.text = string.format("%s\n%s", self.BuffConfigs.Name, self.BuffConfigs.Desc)
    if self.BuffType == XFubenBabelTowerConfigs.TYPE_CHALLENGE then
        self.TxtNumber.text = self.BuffTemplate.ScoreAdd
    end
    if self.BuffType == XFubenBabelTowerConfigs.TYPE_SUPPORT then
        self.TxtNumber.text = self.BuffTemplate.PointSub
    end
    self.RImgChallengeIcon:SetRawImage(self.BuffConfigs.BuffBg)
end


return XUiBabelTowerChallengeSelect