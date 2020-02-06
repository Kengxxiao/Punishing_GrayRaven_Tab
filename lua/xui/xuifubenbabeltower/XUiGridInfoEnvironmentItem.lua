local XUiGridInfoEnvironmentItem = XClass()

function XUiGridInfoEnvironmentItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiGridInfoEnvironmentItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

function XUiGridInfoEnvironmentItem:SetItemInfo(buffId, index)
    local buffTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffTemplate(buffId)
    local buffConfigs = XFubenBabelTowerConfigs.GetBabelBuffConfigs(buffId)
    self.TxtNumber.text = (index > 9) and index or string.format("0%d", index)
    self.TxtAmbien.text = buffConfigs.Desc
end

return XUiGridInfoEnvironmentItem