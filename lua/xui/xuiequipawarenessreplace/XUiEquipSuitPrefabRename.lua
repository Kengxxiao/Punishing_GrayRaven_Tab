local CSXTextManagerGetText = CS.XTextManager.GetText
local MaxNameLength = CS.XGame.Config:GetInt("EquipSuitPrefabNameLength")

local XUiEquipSuitPrefabRename = XLuaUiManager.Register(XLuaUi, "UiEquipSuitPrefabRename")

function XUiEquipSuitPrefabRename:OnAwake()
    self:AutoAddListener()
end

function XUiEquipSuitPrefabRename:OnStart(confirmCb)
    self.ConfirmCb = confirmCb
end

function XUiEquipSuitPrefabRename:AutoAddListener()
    self.BtnClose.CallBack = function() self:Close() end
    self.BtnTanchuangClose.CallBack = function() self:Close() end
    self.BtnNameSure.CallBack = function() self:OnBtnNameSure() end
    self.BtnNameCancel.CallBack = function() self:Close() end
end

function XUiEquipSuitPrefabRename:OnBtnNameSure()
    local editName = string.gsub(self.InFSigm.text, "^%s*(.-)%s*$", "%1")
    if string.len(editName) > 0 then
        local utf8Count = self.InFSigm.textComponent.cachedTextGenerator.characterCount - 1
        if utf8Count > MaxNameLength then
            XUiManager.TipError(CSXTextManagerGetText("MaxNameLengthTips", MaxNameLength))
            return
        end

        self.ConfirmCb(editName)
        self:Close()
    else
        XUiManager.TipError(CSXTextManagerGetText("EquipSuitPrefabRenameLengthError"))
    end
end

