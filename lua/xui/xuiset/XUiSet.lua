local XUiSet = XLuaUiManager.Register(XLuaUi, "UiSet")

local PANEL_INDEX = {
    Instruction = 1,
    Sound = 2,
    Graphics = 3,
    Fight = 4,
    Push = 5,
    Other = 6,
}
function XUiSet:OnAwake()
    XTool.InitUiObject(self)
    self:AddListener()
    self.BtnRetreat.CallBack = function() self:OnBtnRetreat() end
end

function XUiSet:AddListener()
    self:RegisterClickEvent(self.BtnSave, self.OnBtnSaveClick)
    self:RegisterClickEvent(self.BtnDefault, self.OnBtnDefaultClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end

function XUiSet:OnStart(isFight)
    self.IsFight = isFight
    --区分战斗中设置和主页面设置内容
    if self.IsFight then
        self.BtnMainUi.gameObject:SetActiveEx(false)
        self.PanelAsset.gameObject:SetActiveEx(false)
        self.BtnGraphics.gameObject:SetActiveEx(false)
        self.BtnInstruction.gameObject:SetActiveEx(true)
    else
        self.BtnMainUi.gameObject:SetActiveEx(true)
        self.PanelAsset.gameObject:SetActiveEx(true)
        self.BtnGraphics.gameObject:SetActiveEx(true)
        self.BtnInstruction.gameObject:SetActiveEx(false)
        self.BtnRetreat.gameObject:SetActiveEx(false)
    end
    
    if self.IsFight then
        if CS.XFight.IsRunning then
            CS.XFight.Instance:Pause()
        end
        -- int index = CS.XFight.GetClientRole().Npc.Index;
        -- Portraits[index].Select();
        -- XUiAnimationManager.PlayUi(Ui, ANIM_BEGIN, null, null);
        -- TxtScheme.text = XCustomUi.Instance.SchemeName;
    end

    self.IsStartAnimation = true
    self.SubPanels = {}
    if not self.IsFight then
        self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    end
    local tabGroup = {
        [PANEL_INDEX.Instruction] = self.BtnInstruction,
        [PANEL_INDEX.Sound] = self.BtnVoice,
        [PANEL_INDEX.Graphics] = self.BtnGraphics,
        [PANEL_INDEX.Fight] = self.BtnFight,
        [PANEL_INDEX.Push] = self.BtnPush,
        [PANEL_INDEX.Other] = self.BtnOther,
    }
    self.PanelTabToggles:Init(tabGroup, function(index) self:SwitchSubPanel(index) end)
    local defaultIndex
    if self.IsFight then
        defaultIndex = PANEL_INDEX.Instruction
    else
        defaultIndex = PANEL_INDEX.Sound
    end
    self.PanelTabToggles:SelectIndex(defaultIndex)
    self.TipTitle = CS.XTextManager.GetText("TipTitle")
    self.TipContent = CS.XTextManager.GetText("SettingCheckSave")

    XCameraHelper.SetUiCameraParam(self.Name)
end

function XUiSet:OnDestroy()
    if self.SubPanels[PANEL_INDEX.Fight] then
        self.SubPanels[PANEL_INDEX.Fight]:OnDestroy()
    end
end

function XUiSet:OnDisable()
    if self.CurShowIndex and self.SubPanels[self.CurShowIndex] then
        self.SubPanels[self.CurShowIndex]:HidePanel()
    end
    if self.IsFight then
        if CS.XFight.IsRunning then
            CS.XFight.Instance:Resume()
        end
    end
end

function XUiSet:OnEnable()
    if self.CurShowIndex and self.SubPanels[self.CurShowIndex] then
        self.SubPanels[self.CurShowIndex]:ShowPanel()
    end
end

function XUiSet:OnBtnSaveClick(...)
    self:Save()
    XUiManager.TipText("SettingSave")
end

function XUiSet:OnBtnRetreat(...)
    local title = CS.XTextManager.GetText("TipTitle")
    local content = CS.XTextManager.GetText("FightExitMsg")
    local confirmCb = function()
        if CS.XFight.IsRunning then
            CS.XFight.Instance.AutoExitFight = true
            CS.XFight.Instance:Exit(true)
        end
        self:Close()
    end
    XUiManager.DialogTip(title, content, XUiManager.DialogType.Normal, nil, confirmCb)
end

function XUiSet:OnBtnDefaultClick(...)
    self.SubPanels[self.SelectedIndex]:ResetToDefault()
end

function XUiSet:OnBtnBackClick(...)
    self:CheckSave(function()
        self:Close()
    end)
end

function XUiSet:OnBtnMainUiClick(...)
    self:CheckSave(function()
        XLuaUiManager.RunMain()
    end)
end

function XUiSet:InitSubPanel(index)
    if index == PANEL_INDEX.Instruction then
        if self.PanelInstructionObj == nil then
            self.PanelInstructionObj = self.PanelInstruction:LoadPrefab(XUiConfigs.GetComponentUrl("UiSetPanelInstruction"))
        end
        self.SubPanels[PANEL_INDEX.Instruction] = XUiInstruction.New(self.PanelInstructionObj, self)
    elseif index == PANEL_INDEX.Sound then
        if self.PanelVoiceSetObj == nil then
            self.PanelVoiceSetObj = self.PanelVoiceSet:LoadPrefab(XUiConfigs.GetComponentUrl("UiSetPanelVoiceSet"))
        end
        self.SubPanels[PANEL_INDEX.Sound] = XUiPanelVoiceSet.New(self.PanelVoiceSetObj, self)
    elseif index == PANEL_INDEX.Graphics then
        if self.PanelGraphicsSetObj == nil then
            self.PanelGraphicsSetObj = self.PanelGraphicsSet:LoadPrefab(XUiConfigs.GetComponentUrl("UiSetPanelGraphicsSet"))
        end
        self.SubPanels[PANEL_INDEX.Graphics] = XUiPanelGraphicsSet.New(self.PanelGraphicsSetObj, self)
    elseif index == PANEL_INDEX.Fight then
        if self.PanelFightSetObj == nil then
            self.PanelFightSetObj = self.PanelFightSet:LoadPrefab(XUiConfigs.GetComponentUrl("UiSetPanelFightSet"))
        end
        self.SubPanels[PANEL_INDEX.Fight] = XUiPanelFightSet.New(self.PanelFightSetObj, self)
    elseif index == PANEL_INDEX.Push then
        if self.PanelPushSetObj == nil then
            self.PanelPushSetObj = self.PanelPushSet:LoadPrefab(XUiConfigs.GetComponentUrl("UiSetPanelPushSet"))
        end
        self.SubPanels[PANEL_INDEX.Push] = XUiPanelPushSet.New(self.PanelPushSetObj, self)
    elseif index == PANEL_INDEX.Other then
        if self.PanelOtherObj == nil then
            self.PanelOtherObj = self.PanelOther:LoadPrefab(XUiConfigs.GetComponentUrl("UiSetPanelOther"))
        end
        self.SubPanels[PANEL_INDEX.Other] = XUiPanelOtherSet.New(self.PanelOtherObj, self)
    end
end

function XUiSet:SwitchSubPanel(index)
    if not self.SubPanels[index] then
        self:InitSubPanel(index)
    end

    self:CheckSave(function()
        self:ShowSubPanel(index)
    end)
    self:PlayAnimation("AnimQieHuanEnable")
end

function XUiSet:ShowSubPanel(index)
    self.SelectedIndex = index
    for i, panel in pairs(self.SubPanels) do
        if (i == index) then
            self.CurShowIndex = index
            panel:ShowPanel()
        else
            panel:HidePanel()
        end
    end
    self.BtnRetreat.gameObject:SetActiveEx(self.IsFight)
    if index == PANEL_INDEX.Instruction then
        self.BtnSave.gameObject:SetActiveEx(false)
        self.BtnDefault.gameObject:SetActiveEx(false)
    elseif index == PANEL_INDEX.Fight then
    else
        self.BtnSave.gameObject:SetActive(true)
        self.BtnDefault.gameObject:SetActive(true)
        if self.IsStartAnimation then
            self.IsStartAnimation = false
            self.BtnDefaultAnmation:EnableAnim(XUiButtonState.Normal)
            self.BtnSaveAnmation:EnableAnim(XUiButtonState.Normal)
        end
    end
end

function XUiSet:Save()
    self.SubPanels[self.SelectedIndex]:SaveChange()
end

function XUiSet:Cancel()
    self.SubPanels[self.SelectedIndex]:CancelChange()
end

function XUiSet:CheckUnSaveData()
    if self.SelectedIndex and self.SubPanels[self.SelectedIndex]:CheckDataIsChange() then
        return true
    else
        return false
    end
end

function XUiSet:UpdateSpecialScreenOff()
    if self.SafeAreaContentPane then
        self.SafeAreaContentPane:UpdateSpecialScreenOff()
    end
end

function XUiSet:CheckSave(cb)
    local isUnSave = self:CheckUnSaveData()
    if isUnSave then
        local cancelCb = function()
            self:Cancel()
            if cb then cb() end
        end
        local confirmCb = function()
            self:Save()
            if cb then cb() end
        end
        self:TipDialog(cancelCb, confirmCb)
    else
        if cb then cb() end
    end
end

function XUiSet:TipDialog(cancelCb, confirmCb)
    CsXUiManager.Instance:Open("UiDialog", self.TipTitle, self.TipContent, XUiManager.DialogType.Normal, cancelCb, confirmCb)
end