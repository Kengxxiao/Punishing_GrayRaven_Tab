local XUiPanelComeAcrossReward = XClass()

function XUiPanelComeAcrossReward:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
    self.RewardPool = self.PanelRewardBig:GetComponent("XUnityPoolSingle")

end

function XUiPanelComeAcrossReward:SetupReward(gameData, result)
    self.TxtFavorAdd.text = "+" .. result.TrustExp
    self.Parent:SetUiSprite(self.ImgRoleA, XDataCenter.CharacterManager.GetCharHalfBodyBigImage(gameData.Character.Id))
    local rewards = result.RewardGoodsList

    self.RewardPool:DespawnAll()
    for i = 1, #rewards, 1 do
        local ui = self.RewardPool:Spawn()
        local grid = XUiGridCommon.New(self.Parent, ui)
        grid:Refresh(rewards[i])
    end

    local favor = XDataCenter.FavorabilityManager.GetCharacterTrustExpById(gameData.Character.Id)
    local curFavorabilityTableData = XDataCenter.FavorabilityManager.GetFavorabilityTableData(gameData.Character.Id)
    self.SliderFavor.value = favor/curFavorabilityTableData.Exp
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelComeAcrossReward:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelComeAcrossReward:AutoInitUi()
    self.BtnRewardBg = self.Transform:Find("BtnRewardBg"):GetComponent("Button")
    self.PanelRewardInfo = self.Transform:Find("GameObject/PanelRewardInfo")
    self.PanelRole = self.Transform:Find("GameObject/PanelRewardInfo/PanelRole")
    self.ImgRoleA = self.Transform:Find("GameObject/PanelRewardInfo/PanelRole/ImgRole"):GetComponent("Image")
    self.PanelFavor = self.Transform:Find("GameObject/PanelRewardInfo/PanelFavor")
    self.TxtFavorAdd = self.Transform:Find("GameObject/PanelRewardInfo/PanelFavor/TxtFavorAdd"):GetComponent("Text")
    self.SliderFavor = self.Transform:Find("GameObject/PanelRewardInfo/PanelFavor/SliderFavor"):GetComponent("Slider")
    self.PanelRewardBig = self.Transform:Find("GameObject/PanelRewardInfo/PanelRewardBig")
    self.PanelMaskA = self.Transform:Find("PanelMask")
end

function XUiPanelComeAcrossReward:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelComeAcrossReward:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelComeAcrossReward:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelComeAcrossReward:AutoAddListener()
    self:RegisterClickEvent(self.BtnRewardBg, self.OnBtnRewardBgClick)
end
-- auto
function XUiPanelComeAcrossReward:OnBtnRewardBgClick(eventData)
    self.Parent:Close()
end

return XUiPanelComeAcrossReward