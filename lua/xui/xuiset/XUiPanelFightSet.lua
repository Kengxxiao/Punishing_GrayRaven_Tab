XUiPanelFightSet = XClass()

local NpcOperationKey = CS.NpcOperationKey
local XInputManager = CS.XInputManager

function XUiPanelFightSet:Ctor(ui, set)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Set = set
    XTool.InitUiObject(self)
    self.PanelSetKeyTip.gameObject:SetActiveEx(false)
    self:GetDataThenLoadSchemeName()
    self:RegisterCustomUiEvent()
    self.KeyPos = {
        MainKey = 1,
        SubKey = 2,
    }
    self.PageType =    {
        Touch = 1, --触摸设置
        GameController = 2, --外接设备键位设置
    }
    self.KeySetType = {
        Xbox = 1,
        Ps4 = 2,
    }
    self.CurSelectBtn = nil
    self.CurSelectKey = nil

    self.DynamicJoystick = XDataCenter.SetManager.DynamicJoystick
    self.TempDynamicJoystick = self.DynamicJoystick

    self.BtnTabGroup:Init({ self.BtnTabTouch, self.BtnTabGameController }, function(index) self:OnTabClick(index) end)
    self.PatternGroup:Init({ self.BtnXbox, self.BtnPS4 }, function(index) self:OnPatternGroupClick(index) end)

    self.JoystickGroup:Init({ self.TogStatic, self.TogDynamic }, nil)
    self.JoystickGroup:SelectIndex(self.DynamicJoystick + 1)
    self.TogStatic.CallBack = function() self:OnTogStaticJoystickClick() end
    self.TogDynamic.CallBack = function() self:OnTogDynamicJoystickClick() end
    self.BtnCustomUi.CallBack = function() self:OnBtnCustomUiClick() end
    self.TogEnableJoystick.CallBack = function() self:OnTogEnableJoystickClick() end
    self.BtnCloseInput.CallBack = function() self:OnBtnCloseInputClick() end

    self:InitButtons()

    self.SliderCameraMoveSensitivity.value = XInputManager.GetCameraMoveSensitivity()
    XUiHelper.RegisterSliderChangeEvent(self, self.SliderCameraMoveSensitivity, self.OnSliSensitivityValueChanged)

    if XInputManager.EnableInputJoystick then
        self.TogEnableJoystick:SetButtonState(XUiButtonState.Select)
        self.PanelKeySet.gameObject:SetActiveEx(true)
        self.ObjDisableJoyStick.gameObject:SetActiveEx(false)
        self.Set.BtnDefault.gameObject:SetActiveEx(true)
    else
        self.TogEnableJoystick:SetButtonState(XUiButtonState.Normal)
        self.PanelKeySet.gameObject:SetActiveEx(false)
        self.ObjDisableJoyStick.gameObject:SetActiveEx(true)
        self.Set.BtnDefault.gameObject:SetActiveEx(false)
    end
    self.BtnTabGroup:SelectIndex(self.PageType.Touch)
    self.PatternGroup:SelectIndex(XInputManager.GetKeySetType())
    XInputManager.CheckIsPsControl()
    local behaviour = self.GameObject:AddComponent(typeof(CS.XLuaBehaviour))
    if self.Update then
        behaviour.LuaUpdate = function() self:Update() end
    end

    self.CustomUi.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.CustomUi))
end

function XUiPanelFightSet:InitButtons()
    self:InitButton(NpcOperationKey.MoveUp, self.BtnKeyMoveUp, function() self:OnBtnKeyMoveUp() end)
    self:InitButton(NpcOperationKey.MoveDown, self.BtnKeyMoveDown, function() self:OnBtnKeyMoveDown() end)
    self:InitButton(NpcOperationKey.MoveLeft, self.BtnKeyMoveLeft, function() self:OnBtnKeyMoveLeft() end)
    self:InitButton(NpcOperationKey.MoveRight, self.BtnKeyMoveRight, function() self:OnBtnKeyMoveRight() end)

    self:InitButton(NpcOperationKey.CameraMoveUp, self.BtnKeyCameraMoveUp, function() self:OnBtnKeyCameraMoveUp() end)
    self:InitButton(NpcOperationKey.CameraMoveDown, self.BtnKeyCameraMoveDown, function() self:OnBtnKeyCameraMoveDown() end)
    self:InitButton(NpcOperationKey.CameraMoveLeft, self.BtnKeyCameraMoveLeft, function() self:OnBtnKeyCameraMoveLeft() end)
    self:InitButton(NpcOperationKey.CameraMoveRight, self.BtnKeyCameraMoveRight, function() self:OnBtnKeyCameraMoveRight() end)

    self:InitButton(NpcOperationKey.NormalAttackKey, self.BtnKeyNormalAttackKey, function() self:OnBtnKeyNormalAttackKey() end)
    self:InitButton(NpcOperationKey.DodgeKey, self.BtnKeyDodgeKey, function() self:OnBtnKeyDodgeKey() end)
    self:InitButton(NpcOperationKey.ExSkillKey, self.BtnKeyExSkillKey, function() self:OnBtnKeyExSkillKey() end)
    self:InitButton(NpcOperationKey.ChangeNpcIndex1, self.BtnKeyChangeNpcIndex1, function() self:OnBtnKeyChangeNpcIndex1() end)
    self:InitButton(NpcOperationKey.ChangeNpcIndex2, self.BtnKeyChangeNpcIndex2, function() self:OnBtnKeyChangeNpcIndex2() end)

    self:InitButton(NpcOperationKey.BallIndex1, self.BtnKeyBallIndex1, function() self:OnBtnKeyBallIndex1() end)
    self:InitButton(NpcOperationKey.BallIndex2, self.BtnKeyBallIndex2, function() self:OnBtnKeyBallIndex2() end)
    self:InitButton(NpcOperationKey.BallIndex3, self.BtnKeyBallIndex3, function() self:OnBtnKeyBallIndex3() end)
    self:InitButton(NpcOperationKey.BallIndex4, self.BtnKeyBallIndex4, function() self:OnBtnKeyBallIndex4() end)
    self:InitButton(NpcOperationKey.BallIndex5, self.BtnKeyBallIndex5, function() self:OnBtnKeyBallIndex5() end)
    self:InitButton(NpcOperationKey.BallIndex6, self.BtnKeyBallIndex6, function() self:OnBtnKeyBallIndex6() end)
    self:InitButton(NpcOperationKey.BallIndex7, self.BtnKeyBallIndex7, function() self:OnBtnKeyBallIndex7() end)
    self:InitButton(NpcOperationKey.BallIndex8, self.BtnKeyBallIndex8, function() self:OnBtnKeyBallIndex8() end)
end

function XUiPanelFightSet:OnSliSensitivityValueChanged()
    XInputManager.SetCameraMoveSensitivity(self.SliderCameraMoveSensitivity.value)
end

function XUiPanelFightSet:Update()
    if self.CurSelectBtn and self.CurSelectKey and XInputManager.GetCurEditKeyNum() > 0 then
        self.TxtInput.text = XInputManager.GetCurEditKeyString() .. CS.XTextManager.GetText("SetInputFirstKey")
        --self.CurSelectBtn:SetName(XInputManager.GetCurEditKeyString() .. CS.XTextManager.GetText("SetInputFirstKey"))
    end
end

function XUiPanelFightSet:InitButton(keyCode, targetBtn, cb)
    targetBtn.CallBack = cb
    targetBtn:SetName(XInputManager.GetKeyCodeString(keyCode))
    local recommendKey = XInputManager.GetRecommendKeyIcoPath(keyCode)

    local ImgGamePad1 = targetBtn.gameObject.transform:Find("GroupRecommend/ImgGamePad1"):GetComponent("Image")
    local TxtPlus = targetBtn.gameObject.transform:Find("GroupRecommend/TxtPlus")
    local ImgGamePad2 = targetBtn.gameObject.transform:Find("GroupRecommend/ImgGamePad2"):GetComponent("Image")
    if recommendKey.Count == 0 then
        ImgGamePad1.gameObject:SetActiveEx(false)
        TxtPlus.gameObject:SetActiveEx(false)
        ImgGamePad2.gameObject:SetActiveEx(false)
    elseif recommendKey.Count == 1 then
        self.Set:SetUiSprite(ImgGamePad1, recommendKey[0])
        ImgGamePad1.gameObject:SetActiveEx(true)
        TxtPlus.gameObject:SetActiveEx(false)
        ImgGamePad2.gameObject:SetActiveEx(false)
    else
        ImgGamePad1.gameObject:SetActiveEx(true)
        TxtPlus.gameObject:SetActiveEx(true)
        ImgGamePad2.gameObject:SetActiveEx(true)
        self.Set:SetUiSprite(ImgGamePad1, recommendKey[0])
        self.Set:SetUiSprite(ImgGamePad2, recommendKey[1])
    end
end

function XUiPanelFightSet:EditKey(keyCode, targetBtn)
    if self.CurSelectBtn and self.CurSelectKey then
        --self.CurSelectBtn:SetButtonState(XUiButtonState.Normal)
        --self.CurSelectBtn:SetName(XInputManager.GetKeyCodeString(self.CurSelectKey))
    end
    XInputManager.EndEdit()
    local cb = function()
        self.CurSelectBtn = nil
        self.CurSelectKey = nil
        targetBtn:SetName(XInputManager.GetKeyCodeString(keyCode))
        --targetBtn:SetButtonState(XUiButtonState.Normal)
        self.PanelSetKeyTip.gameObject:SetActiveEx(false)
    end
    --targetBtn:SetButtonState(XUiButtonState.Select)
    --targetBtn:SetName(CS.XTextManager.GetText("SetInputStart"))
    self.TxtInput.text = CS.XTextManager.GetText("SetInputStart")
    self.TxtFunction.text = targetBtn.gameObject.transform:Find("Text"):GetComponent("Text").text
    XInputManager.StartEditKey(keyCode, cb)
    self.PanelSetKeyTip.gameObject:SetActiveEx(true)
    self.CurSelectBtn = targetBtn
    self.CurSelectKey = keyCode
end
--Move
function XUiPanelFightSet:OnBtnKeyMoveUp()
    self:EditKey(NpcOperationKey.MoveUp, self.BtnKeyMoveUp)
end

function XUiPanelFightSet:OnBtnKeyMoveDown()
    self:EditKey(NpcOperationKey.MoveDown, self.BtnKeyMoveDown)
end

function XUiPanelFightSet:OnBtnKeyMoveLeft()
    self:EditKey(NpcOperationKey.MoveLeft, self.BtnKeyMoveLeft)
end

function XUiPanelFightSet:OnBtnKeyMoveRight()
    self:EditKey(NpcOperationKey.MoveRight, self.BtnKeyMoveRight)
end
--Camera
function XUiPanelFightSet:OnBtnKeyCameraMoveUp()
    self:EditKey(NpcOperationKey.CameraMoveUp, self.BtnKeyCameraMoveUp)
end

function XUiPanelFightSet:OnBtnKeyCameraMoveDown()
    self:EditKey(NpcOperationKey.CameraMoveDown, self.BtnKeyCameraMoveDown)
end

function XUiPanelFightSet:OnBtnKeyCameraMoveLeft()
    self:EditKey(NpcOperationKey.CameraMoveLeft, self.BtnKeyCameraMoveLeft)
end

function XUiPanelFightSet:OnBtnKeyCameraMoveRight()
    self:EditKey(NpcOperationKey.CameraMoveRight, self.BtnKeyCameraMoveRight)
end
--Other
function XUiPanelFightSet:OnBtnKeyNormalAttackKey()
    self:EditKey(NpcOperationKey.NormalAttackKey, self.BtnKeyNormalAttackKey)
end

function XUiPanelFightSet:OnBtnKeyDodgeKey()
    self:EditKey(NpcOperationKey.DodgeKey, self.BtnKeyDodgeKey)
end

function XUiPanelFightSet:OnBtnKeyExSkillKey()
    self:EditKey(NpcOperationKey.ExSkillKey, self.BtnKeyExSkillKey)
end

function XUiPanelFightSet:OnBtnKeyChangeNpcIndex1()
    self:EditKey(NpcOperationKey.ChangeNpcIndex1, self.BtnKeyChangeNpcIndex1)
end

function XUiPanelFightSet:OnBtnKeyChangeNpcIndex2()
    self:EditKey(NpcOperationKey.ChangeNpcIndex2, self.BtnKeyChangeNpcIndex2)
end
--SkillBox
function XUiPanelFightSet:OnBtnKeyBallIndex1()
    self:EditKey(NpcOperationKey.BallIndex1, self.BtnKeyBallIndex1)
end

function XUiPanelFightSet:OnBtnKeyBallIndex2()
    self:EditKey(NpcOperationKey.BallIndex2, self.BtnKeyBallIndex2)
end

function XUiPanelFightSet:OnBtnKeyBallIndex3()
    self:EditKey(NpcOperationKey.BallIndex3, self.BtnKeyBallIndex3)
end

function XUiPanelFightSet:OnBtnKeyBallIndex4()
    self:EditKey(NpcOperationKey.BallIndex4, self.BtnKeyBallIndex4)
end

function XUiPanelFightSet:OnBtnKeyBallIndex5()
    self:EditKey(NpcOperationKey.BallIndex5, self.BtnKeyBallIndex5)
end

function XUiPanelFightSet:OnBtnKeyBallIndex6()
    self:EditKey(NpcOperationKey.BallIndex6, self.BtnKeyBallIndex6)
end

function XUiPanelFightSet:OnBtnKeyBallIndex7()
    self:EditKey(NpcOperationKey.BallIndex7, self.BtnKeyBallIndex7)
end

function XUiPanelFightSet:OnBtnKeyBallIndex8()
    self:EditKey(NpcOperationKey.BallIndex8, self.BtnKeyBallIndex8)
end

function XUiPanelFightSet:OnTabClick(index)
    self.CurPageType = index
    self:UpdateFunctionBtn()
end

function XUiPanelFightSet:UpdateFunctionBtn()
    if self.CurPageType == self.PageType.Touch then
        self.Set.BtnSave.gameObject:SetActiveEx(true)
        self.Set.BtnDefault.gameObject:SetActiveEx(false)
        self.PanelTouch.gameObject:SetActiveEx(true)
        self.PanelGameController.gameObject:SetActiveEx(false)
    elseif self.CurPageType == self.PageType.GameController then
        self.Set.BtnSave.gameObject:SetActiveEx(false)
        if XInputManager.EnableInputJoystick then
            self.Set.BtnDefault.gameObject:SetActiveEx(true)
        else
            self.Set.BtnDefault.gameObject:SetActiveEx(false)
        end
        self.PanelTouch.gameObject:SetActiveEx(false)
        self.PanelGameController.gameObject:SetActiveEx(true)
    end
end

function XUiPanelFightSet:OnPatternGroupClick(index)
    if XInputManager.GetKeySetType() ~= index then
        XInputManager.SetKeySetType(index)
        self:InitButtons()
    end
end

function XUiPanelFightSet:ShowPanel()
    self:UpdateFunctionBtn()
    self.IsShow = true
    self.GameObject:SetActive(true)
end

function XUiPanelFightSet:HidePanel()
    XInputManager.EndEdit()
    self.IsShow = false
    self.GameObject:SetActive(false)
end

function XUiPanelFightSet:OnTogStaticJoystickClick()
    self.TempDynamicJoystick = 0
end

function XUiPanelFightSet:OnTogDynamicJoystickClick()
    self.TempDynamicJoystick = 1
end

function XUiPanelFightSet:CheckDataIsChange()
    return self.DynamicJoystick ~= self.TempDynamicJoystick
end

function XUiPanelFightSet:SaveChange()
    if self.TempDynamicJoystick ~= self.DynamicJoystick then
        self.DynamicJoystick = self.TempDynamicJoystick
        XDataCenter.SetManager.SetDynamicJoystick(self.DynamicJoystick)
        CS.UnityEngine.PlayerPrefs.SetInt("DynamicJoystick", self.DynamicJoystick)
        CS.UnityEngine.PlayerPrefs.Save()
    end
end

function XUiPanelFightSet:CancelChange()
    self.TempDynamicJoystick = self.DynamicJoystick
    self.JoystickGroup:SelectIndex(self.DynamicJoystick + 1)
end

function XUiPanelFightSet:ResetToDefault()
    XInputManager.DefaultSetting()
    self:InitButtons()
end

function XUiPanelFightSet:OnTogEnableJoystickClick()
    XInputManager.SetEnableInputJoystick(self.TogEnableJoystick:GetToggleState())
    if XInputManager.EnableInputJoystick then
        self.PanelKeySet.gameObject:SetActiveEx(true)
        self.ObjDisableJoyStick.gameObject:SetActiveEx(false)
        self.Set.BtnDefault.gameObject:SetActiveEx(true)
    else
        self.PanelKeySet.gameObject:SetActiveEx(false)
        self.ObjDisableJoyStick.gameObject:SetActiveEx(true)
        self.Set.BtnDefault.gameObject:SetActiveEx(false)
    end
end

function XUiPanelFightSet:OnBtnCloseInputClick()
    XInputManager.EndEdit()
    self.PanelSetKeyTip.gameObject:SetActiveEx(false)
end

function XUiPanelFightSet:OnBtnCustomUiClick()
    if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.CustomUi) then
        return
    end
    XLuaUiManager.Open("UiFightCustom")
end

function XUiPanelFightSet:GetDataThenLoadSchemeName()
    CS.XCustomUi.Instance:GetData(function()
        self:LoadSchemeName()
    end)
end

function XUiPanelFightSet:LoadSchemeName()
    self.TxtScheme.text = CS.XCustomUi.Instance.SchemeName
end

function XUiPanelFightSet:RegisterCustomUiEvent()
    self.Func = handler(self, self.LoadSchemeName)
    CsXGameEventManager.Instance:RegisterEvent(CS.XUiFightCustom.OnCustomUiSchemeNameChanged, self.Func)
end

function XUiPanelFightSet:RemoveCustomUiEvent()
    CsXGameEventManager.Instance:RemoveEvent(CS.XUiFightCustom.OnCustomUiSchemeNameChanged, self.Func)
    self.Func = nil
end

function XUiPanelFightSet:OnDestroy()
    self:RemoveCustomUiEvent()
end