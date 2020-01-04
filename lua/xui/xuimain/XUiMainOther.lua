XUiMainOther = XClass()

function XUiMainOther:Ctor(rootUi)
    self.Transform = rootUi.PanelOther.gameObject.transform
    XTool.InitUiObject(self)
    self.RootUi = rootUi
    self.SignBoard = XUiPanelSignBoard.New(self.PanelSignBoard, self.RootUi, XUiPanelSignBoard.SignBoardOpenType.MAIN)
    self.ScreenShot = XUiPanelSceenShot.New(self.PanelSceenShot, self.RootUi, self.BtnScreenShot)

    --ClickEvent
    self.BtnScreenShot.CallBack = function() self:OnBtnScreenShot() end
    --RedPoint
end

function XUiMainOther:OnEnable()
    if self.SignBoard then
        local displayCharacterId = XDataCenter.DisplayManager.GetDisplayChar().Id
        self.SignBoard:SetDisplayCharacterId(displayCharacterId)
        self.SignBoard:OnEnable()
    end
end

function XUiMainOther:OnDisable()
    if self.SignBoard then
        self.SignBoard:OnDisable()
    end
end

function XUiMainOther:OnDestroy()
    if self.SignBoard then
        self.SignBoard:OnDestroy()
    end
end

--拍照分享按钮
function XUiMainOther:OnBtnScreenShot()
    XEventManager.DispatchEvent(XEventId.EVENT_PHOTO_ENTER)

    self.BtnScreenShot.gameObject:SetActive(false)
    self.RootUi:SetBtnWelfareTagActive(false)
    self.RootUi:PlayAnimation("AnimOutto", function() 
        self.PanelSceenShot.gameObject:SetActive(true)
        self.ScreenShot:Show()
     end)
end