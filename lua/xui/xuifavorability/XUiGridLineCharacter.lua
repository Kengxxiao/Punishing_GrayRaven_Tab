local XUiGridLikeRoleItem = require("XUi/XUiFavorability/XUiGridLikeRoleItem")
XUiGridLineCharacter = XClass(XUiGridLikeRoleItem)

function XUiGridLineCharacter:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridLineCharacter:RefreshAssist()
    self.ImgAssist.gameObject:SetActive(XDataCenter.DisplayManager.GetDisplayChar().Id == self.CharacterData.Id)
end

function XUiGridLineCharacter:IsRed()
    return false
end

return XUiGridLineCharacter