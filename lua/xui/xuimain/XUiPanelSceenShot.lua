XUiPanelSceenShot = XClass()

function XUiPanelSceenShot:Ctor(ui, parent, screenShotBtn)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self.PhotoFlashlamp.gameObject:SetActive(false)
    self.BtnBack.gameObject:SetActive(false)
    self.BtnPhoto.gameObject:SetActive(false)

    self.Parent = parent
    self.ScreenShotBtn = screenShotBtn
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSceenShot:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelSceenShot:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelSceenShot:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end


function XUiPanelSceenShot:Show()
    self.BtnHide.gameObject:SetActive(true)
end

function XUiPanelSceenShot:AutoAddListener()
    self:RegisterClickEvent(self.BtnHide, self.OnBtnHideClick)
    self:RegisterClickEvent(self.BtnPhoto, self.OnBtnPhotoClick)
    self:RegisterClickEvent(self.BtnWeChat, self.OnBtnWeChatClick)
    self:RegisterClickEvent(self.BtnBlog, self.OnBtnBlogClick)
    self:RegisterClickEvent(self.BtnQQ, self.OnBtnQQClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackAClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end
-- auto
function XUiPanelSceenShot:OnBtnHideClick(eventData)
    XEventManager.DispatchEvent(XEventId.EVENT_PHOTO_LEAVE)
    self.GameObject:SetActive(false)
    self.BtnHide.gameObject:SetActive(false)
    --self.Parent:ResetState()
    self.Parent:PlayAnimation("AnimInto", function()
        self.ScreenShotBtn.gameObject:SetActive(true)
        XEventManager.DispatchEvent(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN)
    end)
end

function XUiPanelSceenShot:OnBtnPhotoClick(eventData)
    self:HideAllForPhoto()
    self:TakePhoto()
end

--隐藏Ui截屏
function XUiPanelSceenShot:HideAllForPhoto()
    self.BtnHide.gameObject:SetActive(false)
    self.BtnPhoto.gameObject:SetActive(false)

    self.TxtLevel.text = XPlayer.Name
    self.TxtLevel.text = XPlayer.Level
    self.TxtId.text = XPlayer.Id

    self.PanelPhoto.gameObject:SetActive(true)
end


function XUiPanelSceenShot:TakePhoto()
    CS.XTool.CaptureScreenshotAsTexture(self.RImgPic, handler(self, self.ShowAllForPhoto))
end


function XUiPanelSceenShot:ShowAllForPhoto(filePath)
    self.PhotoFlashlamp.gameObject:SetActive(true)

    self.Parent:PlayAnimation("AnimPanelSceenShotSceenShot", function()
        self.PanelPhoto.gameObject:SetActive(false)
        self.BtnBack.gameObject:SetActive(true)
        self.PhotoFlashlamp.gameObject:SetActive(false)

        XUiManager.TipSuccess(CS.XGame.ClientConfig:GetString("PhotoSave"));
    end)
end

function XUiPanelSceenShot:OnBtnOpenAClick(eventData)

end

function XUiPanelSceenShot:OnBtnBackAClick(eventData)

    self.BtnBack.gameObject:SetActive(false)
    self.PanelPhoto.gameObject:SetActive(false)

    self.BtnHide.gameObject:SetActive(true)
    self.BtnPhoto.gameObject:SetActive(true)

    self.RImgPic.gameObject:SetActive(false)
    CS.UnityEngine.Object.Destroy(self.RImgPic.texture)
    self.RImgPic.texture = nil
end

function XUiPanelSceenShot:OnBtnMainUiClick(eventData)
    self.BtnBack.gameObject:SetActive(false)
    self.PanelPhoto.gameObject:SetActive(false)

    self.BtnHide.gameObject:SetActive(true)
    self.BtnPhoto.gameObject:SetActive(true)

    self.RImgPic.gameObject:SetActive(false)
    CS.UnityEngine.Object.Destroy(self.RImgPic.texture)
    self.RImgPic.texture = nil
end

function XUiPanelSceenShot:OnBtnWeChatClick(eventData)

end

function XUiPanelSceenShot:OnBtnBlogClick(eventData)

end

function XUiPanelSceenShot:OnBtnQQClick(eventData)

end

return XUiPanelSceenShot