XUiPanelOtherSet = XClass()
local XUiSafeAreaAdapter = CS.XUiSafeAreaAdapter
local SetConfigs = XSetConfigs
local SetManager
local MaxOff

function XUiPanelOtherSet:Ctor(ui,parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    SetManager = XDataCenter.SetManager
    MaxOff = CS.XGame.ClientConfig:GetFloat("SpecialScreenOff")
    XTool.InitUiObject(self)
    self:InitUi()
end

function XUiPanelOtherSet:InitUi()
    self.IsChange = false
    self.TabObs = {}
    self.TabObs[1] = self.TogGraphics_0
    self.TabObs[2] = self.TogGraphics_1
    self.TabObs[3] = self.TogGraphics_2
    self.TabObs[4] = self.TogGraphics_3
    self.TGroupResolution:Init(self.TabObs, function(tab) self:TabSkip(tab) end)
    self:AddListener()
end

function XUiPanelOtherSet:AddListener()
    self.OnSliderValueCb = function(value) self:OnSliderValueChanged(value) end
    self.OnTogFriEffectsValueCb = function(value) self:OnTogFriEffectsValueChanged(value) end
    self.OnTogFriNumValueCb = function(value) self:OnTogFriNumValueChanged(value) end
    self.Slider.onValueChanged:AddListener(self.OnSliderValueCb)
    self.TogFriEffects.onValueChanged:AddListener(self.OnTogFriEffectsValueCb)
    self.TogFriNum.onValueChanged:AddListener(self.OnTogFriNumValueCb)
end

function XUiPanelOtherSet:Getcache()
    self.SelfNumState = XSaveTool.GetData(SetConfigs.SelfNum) or SetConfigs.SelfNumEnum.Middle
    self.FriendNumState = XSaveTool.GetData(SetConfigs.FriendNum) or SetConfigs.FriendNumEnum.Close
    self.FriendEffectEnumState = XSaveTool.GetData(SetConfigs.FriendEffect) or SetConfigs.FriendEffectEnum.Open
    self.ScreenOffValue = XSaveTool.GetData(XSetConfigs.ScreenOff) or 0
    self.TGroupResolution:SelectIndex(self.SelfNumState)
    self.TogFriEffects.isOn = self.FriendEffectEnumState == SetConfigs.FriendNumEnum.Open
    self.TogFriNum.isOn = self.FriendNumState == SetConfigs.FriendNumEnum.Open
    local v = tonumber(self.ScreenOffValue) 
    self.IsFirstSlider = true
    self.Slider.value = v
    self.SaveSelfNumState = self.SelfNumState
    self.SaveFriendNumState = self.FriendNumState
    self.SaveFriendEffectEnumState = self.FriendEffectEnumState
    self.SaveScreenOffValue = self.ScreenOffValue
end

function XUiPanelOtherSet:TabSkip(tab)
    self.CurSelfNumKey = SetConfigs.SelfNumKeyIndexConfig[tab]
    self.SelfNumState = tab
    if self.IsPassTab then
        self.IsPassTab = false
        return 
    end
    if not self.IsFirstTab then
        self.IsFirstTab = true
    else
        self.IsChange = self.SelfNumState ~= self.SaveSelfNumState
    end
end

function XUiPanelOtherSet:ResetToDefault()
    self.IsChange = self:IsDefaultChange()
    self.SelfNumState = SetConfigs.SelfNumEnum.Middle
    self.FriendNumState = SetConfigs.FriendNumEnum.Close
    self.FriendEffectEnumState = SetConfigs.FriendEffectEnum.Open
    self.TogFriEffects.isOn = self.FriendEffectEnumState == SetConfigs.FriendNumEnum.Open
    self.TogFriNum.isOn = self.FriendNumState == SetConfigs.FriendNumEnum.Open
    self.IsPassTab = true
    self.TGroupResolution:SelectIndex(self.SelfNumState)
    self.ScreenOffValue = 0
    self.Slider.value = 0
end

function XUiPanelOtherSet:IsDefaultChange()
    local f = (self.SaveSelfNumState ~= SetConfigs.SelfNumEnum.Middle) or (self.SaveFriendNumState ~= SetConfigs.FriendNumEnum.Close) or (self.SaveFriendEffectEnumState ~= SetConfigs.FriendEffectEnum.Open) or (self.SaveScreenOffValue ~= self.Slider.value)
    return f
end

function XUiPanelOtherSet:SaveChange()
    self.IsChange = false
    self.SaveSelfNumState = self.SelfNumState
    self.SaveFriendNumState = self.FriendNumState
    self.SaveFriendEffectEnumState = self.FriendEffectEnumState
    self.SaveScreenOffValue = self.ScreenOffValue

    SetManager.SaveSelfNum(self.SelfNumState)
    SetManager.SaveFriendNum(self.FriendNumState)
    SetManager.SaveFriendEffect(self.FriendEffectEnumState)
    SetManager.SaveScreenOff(self.ScreenOffValue)

    SetManager.SetOwnFontSizeByTab(self.SelfNumState)
    SetManager.SetAllyDamage(self.FriendNumState == SetConfigs.FriendNumEnum.Open)
    SetManager.SetAllyEffect(self.FriendEffectEnumState == SetConfigs.FriendEffectEnum.Open)
end

function XUiPanelOtherSet:CheckDataIsChange()    
    return self.IsChange
end

function XUiPanelOtherSet:CancelChange( ... )
    self.ScreenOffValue = self.SaveScreenOffValue
    self:SetSliderValueChanged(self.SaveScreenOffValue)
end

function XUiPanelOtherSet:OnSliderValueChanged(value)
    if value < 0 then
        return 
    end

    if self.IsFirstSlider then
        self.IsFirstSlider = false
        return 
    end
    self.ScreenOffValue = value
    self.IsChange = self.ScreenOffValue ~= self.SaveScreenOffValue
    self:SetSliderValueChanged(value)
    SetManager.SetAdaptorScreenChange()
end

function XUiPanelOtherSet:SetSliderValueChanged(value)
    local value = tonumber(value)
    XUiSafeAreaAdapter.SetSpecialScreenOff(value * MaxOff)
    if self.Parent then
        self.Parent:UpdateSpecialScreenOff()
    end
end

function XUiPanelOtherSet:OnTogFriEffectsValueChanged(value)
    local v = SetConfigs.FriendEffectEnum.Close
    if value then
        v = SetConfigs.FriendEffectEnum.Open
    end
    self.FriendEffectEnumState = v
    self.IsChange = self.FriendEffectEnumState ~= self.SaveFriendEffectEnumState
end

function XUiPanelOtherSet:OnTogFriNumValueChanged(value)
    local v = SetConfigs.FriendNumEnum.Close
    if value then
        v = SetConfigs.FriendNumEnum.Open
    end
    self.FriendNumState = v
    self.IsChange = self.FriendNumState ~= self.SaveFriendNumState
end

function XUiPanelOtherSet:ShowPanel()
    self.GameObject:SetActive(true)
    if self.Parent then
        self.Adaptation.gameObject:SetActiveEx(not self.Parent.IsFight)
    end
    self:Getcache()
    self.IsShow = true
    self.IsChange = false
end

function XUiPanelOtherSet:HidePanel()
    self.IsShow = false
    self.IsChange = false
    self.GameObject:SetActive(false)
end
