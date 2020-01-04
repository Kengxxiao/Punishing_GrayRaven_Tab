local XUiGridLikeInfo = XClass()

function XUiGridLikeInfo:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridLikeInfo:Refresh(config)
    local charLevelConfig = XDataCenter.DormManager.GetCharRecoveryCurLevel(config.CharacterId)
    local isCur = charLevelConfig and charLevelConfig.Pre == config.Pre
    self.ImgNormal.gameObject:SetActive(not isCur)
    self.ImgCurrent.gameObject:SetActive(isCur)
    self.TxtDesc.text = config.Description
end

return XUiGridLikeInfo