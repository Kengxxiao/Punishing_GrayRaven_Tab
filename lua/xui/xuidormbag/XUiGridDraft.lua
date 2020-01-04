local XUiGridDraft = XClass()

function XUiGridDraft:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi

    XTool.InitUiObject(self)
    self:AutoAddListener()
    self:SetSelected(false)
end

function XUiGridDraft:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridDraft:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridDraft:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridDraft:AutoAddListener()
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
end

function XUiGridDraft:OnBtnClickClick(...)
    XEventManager.DispatchEvent(XEventId.EVENT_CLICKDRAFT_GRID,  self.Data.Id, self.Data.Count, self)
end

function XUiGridDraft:SetSelected(status)
    if self.ImgSelect then 
        self.ImgSelect.gameObject:SetActive(status)
    end
end

function XUiGridDraft:IsSelected()
    return self.ImgSelect and self.ImgSelect.gameObject.activeSelf
end

function XUiGridDraft:Refresh(data)
    self.Data = data

    self:SetSelected(self.RootUi:GetGridSelected(data.Id))

    self.RImgIcon:SetRawImage(XDataCenter.ItemManager.GetItemIcon(data.Id), nil, true)
    local quality = XDataCenter.ItemManager.GetItemQuality(data.Id)
    self.RootUi:SetUiSprite(self.ImgQuality, XArrangeConfigs.GeQualityBgPath(quality))

    self.TxtDraftName.text = XDataCenter.ItemManager.GetItemName(data.Id)
    self.TxtDraftCount.text = data.Count
end

return XUiGridDraft