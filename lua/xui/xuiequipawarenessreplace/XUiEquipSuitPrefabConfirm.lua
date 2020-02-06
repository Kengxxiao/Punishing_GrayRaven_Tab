local XUiEquipSuitPrefabConfirm = XLuaUiManager.Register(XLuaUi, "UiEquipSuitPrefabConfirm")

function XUiEquipSuitPrefabConfirm:OnAwake()
    self:AutoAddListener()
end

function XUiEquipSuitPrefabConfirm:OnStart(content, confirmCb)
    self.TxtContent.text = content
    self.ConfirmCb = confirmCb
end

function XUiEquipSuitPrefabConfirm:AutoAddListener()
    self.BtnClose.CallBack = function() self:Close() end
    self.BtnTanchuangClose.CallBack = function() self:Close() end
    self.BtnNameCancel.CallBack = function() self:Close() end
    self.BtnNameSure.CallBack = function()
        self.ConfirmCb()
        self:Close()
    end
end