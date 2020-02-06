local XUiDormReName = XClass()
local TextManager = CS.XTextManager
local NameLenLimit

function XUiDormReName:Ctor(ui,uiroot)
    NameLenLimit = CS.XGame.Config:GetInt("DormReNameLen")
    self.DormManager = XDataCenter.DormManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.OnBtnCancelClickCb = function() self:OnBtnCancelClick() end
    self.OnBtnConfirmClickCb = function() self:OnBtnConfirmClick() end
    self.OnReNameRespCb = function() self:OnReNameResp() end
    self.Msg = TextManager.GetText("DormReNameSuccess")
    XTool.InitUiObject(self)
    self:Init(uiroot)
    self.InputField.characterLimit = 0
end

function XUiDormReName:Init(uiroot)
    self.UiRoot = uiroot
    self.BtnReNameCancel.CallBack = self.OnBtnCancelClickCb
    self.BtnTanchuangClose.CallBack = self.OnBtnCancelClickCb
    self.TanchuangBgCloseBtn.CallBack = self.OnBtnCancelClickCb
    self.BtnReNameConfirm.CallBack = self.OnBtnConfirmClickCb
    self.BtnReNameCancel:SetName(TextManager.GetText("CancelText"))
    self.BtnReNameConfirm:SetName(TextManager.GetText("ConfirmText"))
end

function XUiDormReName:OnBtnCancelClick()
    self.GameObject:SetActive(false)
end

function XUiDormReName:OnBtnConfirmClick()
    if not self.InputField or not self.InputField.textComponent then
        return 
    end

    local newname = self.InputField.text
    local utf8Count = self.InputField.textComponent.cachedTextGenerator.characterCount - 1
    if utf8Count > NameLenLimit then
        local text = CS.XTextManager.GetText("DormNameMaxNameLengthTips",NameLenLimit)
        XUiManager.TipMsg(text, XUiManager.UiTipType.Wrong)
        return
    end
    if newname == self.Curname then
        XUiManager.TipText("DormReNameErrorNoChange",XUiManager.UiTipType.Wrong)
        return
    end
    
    if newname == "" then
        XUiManager.TipText("DormReNameErrorText",XUiManager.UiTipType.Wrong)
        return
    end
    
    if string.match(newname,"%s") then
        XUiManager.TipText("DormReNameTips",XUiManager.UiTipType.Wrong)
        return
    end

    self.Curname = newname
    self.DormManager.RequestDormitoryRename(self.ItemData,newname,self.OnReNameRespCb)
    self:OnBtnCancelClick()
end

function XUiDormReName:OnReNameResp()
    XUiManager.TipMsg(self.Msg,XUiManager.UiTipType.Success)
    self.UiRoot:SetHostelName(self.Curname)
end

-- 更新数据
function XUiDormReName:OnRefresh(itemData)
    if not itemData then
        return
    end

    self.ItemData = itemData
    self.Curname = self.DormManager.GetDormName(itemData)
    self.TxtCurName.text = self.Curname
end


return XUiDormReName
