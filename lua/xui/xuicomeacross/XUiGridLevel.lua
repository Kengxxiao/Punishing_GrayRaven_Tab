local XUiGridLevel = XClass()

function XUiGridLevel:Ctor(ui,parent,index)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.Parent = parent
    self.Index = index 

    self.StarPool = self.PanelStar:GetComponent("XUnityPoolSingle")

end

function XUiGridLevel:SetGridLevelContent(data)
    self.Data = data

    local position = data.Position
    self.TxtName.text = position.Name

    local game = data.GameConfig
    local gameType = game.Type
    local star = game.Difficult

    self.StarPool:DespawnAll()
    for i = 1,star,1 do
        local starObject = self.StarPool:Spawn()
    end

    local gameTypeCfg = XComeAcrossConfig.GetComeAcrossTypeConfigById(gameType)
    self.Parent:SetUiSprite(self.ImgType,gameTypeCfg.Icon)
    self.Parent:SetUiSprite(self.ImgHead, XDataCenter.CharacterManager.GetCharRoundnessHeadIcon(data.Character.Id))

end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridLevel:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridLevel:AutoInitUi()
    self.PanelStar = XUiHelper.TryGetComponent(self.Transform, "PanelStar", nil)
    self.ImgStar = XUiHelper.TryGetComponent(self.Transform, "PanelStar/ImgStar", "Image")
    self.TxtName = XUiHelper.TryGetComponent(self.Transform, "Image/TxtName", "Text")
    self.ImgType = XUiHelper.TryGetComponent(self.Transform, "Image/ImgType", "Image")
    self.ImgHead = XUiHelper.TryGetComponent(self.Transform, "ImgHead", "Image")
    self.BtnEnter = XUiHelper.TryGetComponent(self.Transform, "BtnEnter", "Button")
end

function XUiGridLevel:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridLevel:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridLevel:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridLevel:AutoAddListener()
    self:RegisterClickEvent(self.BtnEnter, self.OnBtnEnterClick)
end
-- auto

function XUiGridLevel:OnBtnEnterClick(eventData)
    
    XDataCenter.ComeAcrossManager.ReqTrustGamePlayRequest(function()
        CsXUiManager.Instance:Open("UiComeAcrossGame",self.Data)
    end)
end

return XUiGridLevel
