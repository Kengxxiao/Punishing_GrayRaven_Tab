local XUiGridElement = XClass()

function XUiGridElement:Ctor(ui,parent,rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self.RootUi = rootUi
    self.IsClick = false

    self:InitAutoScript()
end

function XUiGridElement:SetSmallGridContent(gridType)
    local tab = XComeAcrossConfig.GetComeAcrossGridConfigById(gridType)


    self.ImgGray.gameObject:SetActive(false)
    self.ImgNormal.gameObject:SetActive(true)
    self.ImgError.gameObject:SetActive(false)

    self.RootUi:SetUiSprite(self.ImgNormal,tab.SmallIcon)
    self.RootUi:SetUiSprite(self.ImgGray,tab.SmallIcon)
    self.RootUi:SetUiSprite(self.ImgError,tab.SmallIcon)
    self.BtnElement.gameObject:SetActive(false)
    self.GridType = gridType

end


function XUiGridElement:SetBigGridContent(answer)
    local tab = XComeAcrossConfig.GetComeAcrossGridConfigById(answer.Type)
    if not tab then
        return
    end

    
    self.ImgGray.gameObject:SetActive(false)
    self.ImgNormal.gameObject:SetActive(true)
    self.ImgError.gameObject:SetActive(false)

    self.RootUi:SetUiSprite(self.ImgNormal,tab.BigIcon)
    self.RootUi:SetUiSprite(self.ImgGray,tab.BigIcon)
    self.RootUi:SetUiSprite(self.ImgError,tab.BigIcon)
    self.ImgNormal.gameObject:SetActive(true)
    self.GridType = answer.Type
    self.Index = answer.Index
end


function XUiGridElement:SetGray()
    self.ImgGray.gameObject:SetActive(true)
    self.ImgNormal.gameObject:SetActive(false)
    self.ImgError.gameObject:SetActive(false)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridElement:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridElement:AutoInitUi()
    self.ImgNormal = XUiHelper.TryGetComponent(self.Transform, "ImgNormal", "Image")
    self.ImgGray = XUiHelper.TryGetComponent(self.Transform, "ImgGray", "Image")
    self.ImgError = XUiHelper.TryGetComponent(self.Transform, "ImgError", "Image")
    self.BtnElement = XUiHelper.TryGetComponent(self.Transform, "BtnElement", "Button")
    self.PanelEffect = XUiHelper.TryGetComponent(self.Transform, "PanelEffect", nil)
end

function XUiGridElement:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridElement:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridElement:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridElement:AutoAddListener()
    self:RegisterClickEvent(self.BtnElement, self.OnBtnElementClick)
end
-- auto

function XUiGridElement:OnBtnElementClick(eventData)
    self.Parent.GamePlayer:OnClick(self.Index)
end

function XUiGridElement:OnEliminate(callback)
    if self.IsClick then
        return
    end
        
    self.PanelEffect.gameObject:SetActive(true)
    self.IsClick = true
    self.Timer = CS.XScheduleManager.Schedule(function()
        self.PanelEffect.gameObject:SetActive(false)

        if callback then
            callback()
        end
    end, 300, 1, 0)

end

return XUiGridElement
