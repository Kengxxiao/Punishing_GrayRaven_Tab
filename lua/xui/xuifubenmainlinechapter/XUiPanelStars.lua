local MaxStarCount = 3

local XUiPanelStars = XClass()

function XUiPanelStars:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

function XUiPanelStars:OnEnable(starsMap)
    self:SetStarActive(starsMap)
end

function XUiPanelStars:SetStarActive(starsMap)
    for i = 1, MaxStarCount do
        local isShow = starsMap[i]
        self["Img" .. i].gameObject:SetActive(isShow)
        self["ImgDis" .. i].gameObject:SetActive(not isShow)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelStars:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelStars:AutoInitUi()
    self.ImgDis2 = self.Transform:Find("Star2/ImgDis2"):GetComponent("Image")
    self.Img1 = self.Transform:Find("Star1/Img1"):GetComponent("Image")
    self.ImgDis1 = self.Transform:Find("Star1/ImgDis1"):GetComponent("Image")
    self.Img2 = self.Transform:Find("Star2/Img2"):GetComponent("Image")
    self.ImgDis3 = self.Transform:Find("Star3/ImgDis3"):GetComponent("Image")
    self.Img3 = self.Transform:Find("Star3/Img3"):GetComponent("Image")
end

function XUiPanelStars:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelStars:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelStars:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelStars:AutoAddListener()
end
-- auto
return XUiPanelStars