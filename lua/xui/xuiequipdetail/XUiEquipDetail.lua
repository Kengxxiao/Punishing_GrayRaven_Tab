local CSTextManager = CS.XTextManager

local XUiEquipDetail = XLuaUiManager.Register(XLuaUi, "UiEquipDetail")

XUiEquipDetail.BtnTabIndex = {
    Detail = 1,
    Strengthen = 2,
    Resonance = 3,
}

function XUiEquipDetail:OnAwake()
    self:InitAutoScript()

    self.TabGroup = {
        self.BtnDetail,
        self.BtnStrengthen,
        self.BtnResonance,
    }
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.PanelTabGroup:Init(self.TabGroup, function(tabIndex) self:OnClickTabCallBack(tabIndex) end)
end

--参数isPreview为true时是装备详情预览，传templateId进来
--characterId只有需要判断武器共鸣特效时才传
function XUiEquipDetail:OnStart(equipId, isPreview, characterId)
    self.IsPreview = isPreview
    self.EquipId = equipId
    self.CharacterId = characterId
    self.TemplateId = isPreview and self.EquipId or XDataCenter.EquipManager.GetEquipTemplateId(equipId)

    local sceneRoot = self:GetSceneRoot().transform
    self.PanelWeapon = sceneRoot:FindTransform("PanelWeapon")
    self.PanelWeaponPlane = sceneRoot.parent.parent:FindTransform("Plane")
    self.PanelWeaponPlane.gameObject:SetActive(false)

    self.PanelTabGroup:SelectIndex(XUiEquipDetail.BtnTabIndex.Detail)
    self:InitTabBtnState()
    self:UpdateStrengthenBtn()

    self.BtnStrengthenMax.CallBack = function ()
        XUiManager.TipMsg(CSTextManager.GetText("EquipStrengthenMaxLevel")) 
    end

    self.PanelAsset.gameObject:SetActiveEx(not isPreview)
end

function XUiEquipDetail:OnEnable()
    self:InitClassifyPanel()
end

function XUiEquipDetail:OnDestroy()
    self.PanelWeaponPlane.gameObject:SetActive(true)
    if self.Resource then
       CS.XResourceManager.Unload(self.Resource)
       self.Resource = nil
    end
end

function XUiEquipDetail:OnGetEvents()
    return { XEventId.EVENT_EQUIP_STRENGTHEN_NOTYFY, XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY, XEventId.EVENT_EQUIP_CAN_BREAKTHROUGH_TIP_CLOSE }
end

function XUiEquipDetail:OnNotify(evt, ...)
    local args = { ... }
    local equipId = args[1]
    if self.IsPreview or equipId ~= self.EquipId then return end

    if evt == XEventId.EVENT_EQUIP_STRENGTHEN_NOTYFY then
        if XDataCenter.EquipManager.IsReachBreakthroughLevel(equipId) and XDataCenter.EquipManager.IsMaxBreakthrough(equipId) then
            self.PanelTabGroup:SelectIndex(XUiEquipDetail.BtnTabIndex.Detail)
            self:UpdateStrengthenBtn()
            return
        end
    elseif evt == XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY then
        self:UpdateStrengthenBtn()
        self:InitClassifyPanel()
    elseif evt == XEventId.EVENT_EQUIP_CAN_BREAKTHROUGH_TIP_CLOSE then
        if not equipId then return end
        self:UpdateStrengthenBtn()
        self:OpenOneChildUi("UiEquipBreakThrough", self.EquipId, self)
    end
end

function XUiEquipDetail:InitClassifyPanel()
    self.FxUiLihuiChuxian01.gameObject:SetActive(false)
    if XDataCenter.EquipManager.IsClassifyEqualByTemplateId(self.TemplateId, XEquipConfig.Classify.Weapon) then
        local breakthroughTimes = not self.IsPreview and XDataCenter.EquipManager.GetBreakthroughTimes(self.EquipId) or 0
        local modelConfig = XDataCenter.EquipManager.GetWeaponModelCfg(self.TemplateId, self.Name, breakthroughTimes)
        if modelConfig then
            XModelManager.LoadWeaponModel(modelConfig.ModelName, self.PanelWeapon, modelConfig.TransfromConfig, function(model)
                local rotate = self.PanelWeapon:GetComponent("XAutoRotation")
                if rotate then
                    rotate.Target = model.transform
                end
            end, self.CharacterId, self.EquipId)
        end
        self.PanelWeapon.gameObject:SetActive(true)
        self.ImgLihuiMask.gameObject:SetActive(false)
    elseif XDataCenter.EquipManager.IsClassifyEqualByTemplateId(self.TemplateId, XEquipConfig.Classify.Awareness) then
        local breakthroughTimes = not self.IsPreview and XDataCenter.EquipManager.GetBreakthroughTimes(self.EquipId) or 0

        local resource = CS.XResourceManager.Load(XDataCenter.EquipManager.GetEquipLiHuiPath(self.TemplateId, breakthroughTimes))
        local texture = resource.Asset
        self.MeshLihui.sharedMaterial:SetTexture("_MainTex", texture)
        if self.Resource then
            CS.XResourceManager.Unload(self.Resource)
        end
        self.Resource = resource
        CS.XScheduleManager.Schedule(function()
            self.FxUiLihuiChuxian01.gameObject:SetActive(true)
        end, 0, 1, 500)

        self.PanelWeapon.gameObject:SetActive(false)
    end
end

function XUiEquipDetail:InitTabBtnState()
    if self.IsPreview then
        self.PanelTabGroup.gameObject:SetActive(false)
        return
    end

    self.BtnStrengthen.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.EquipStrengthen))
    self.BtnResonance.gameObject:SetActiveEx(not XFunctionManager.CheckFunctionFitter(XFunctionManager.FunctionName.EquipResonance) and XDataCenter.EquipManager.CanResonanceByTemplateId(self.TemplateId))

    self.BtnStrengthen:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.EquipStrengthen))
    self.BtnResonance:SetDisable(not XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.EquipResonance))
end

function XUiEquipDetail:UpdateStrengthenBtn()
    if self.IsPreview then
        return
    end
    local equipId = self.EquipId

    if XDataCenter.EquipManager.CanBreakThrough(equipId) then
        self.BtnStrengthen:SetNameByGroup(0, CSTextManager.GetText("EquipBreakthroughBtnTxt1"))
        self.BtnStrengthen:SetNameByGroup(1, CSTextManager.GetText("EquipBreakthroughBtnTxt2"))
    else
        self.BtnStrengthen:SetNameByGroup(0, CSTextManager.GetText("EquipStrengthenBtnTxt1"))
        self.BtnStrengthen:SetNameByGroup(1, CSTextManager.GetText("EquipStrengthenBtnTxt2"))
    end

    local isMaxLevel = XDataCenter.EquipManager.IsMaxBreakthrough(equipId) and XDataCenter.EquipManager.IsReachBreakthroughLevel(equipId)
    self.BtnStrengthen.gameObject:SetActive(not isMaxLevel)
    self.BtnStrengthenMax.gameObject:SetActive(isMaxLevel)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiEquipDetail:InitAutoScript()
    self:AutoAddListener()
end

function XUiEquipDetail:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainClick)
    self:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClick)
end
-- auto
function XUiEquipDetail:OnBtnBackClick(eventData)
    if XLuaUiManager.IsUiShow("UiEquipResonanceSelect") then
        self:OpenOneChildUi("UiEquipResonanceSkill", self.EquipId, self)
    else
        self:Close()
    end
end

function XUiEquipDetail:OnBtnMainClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiEquipDetail:OnClickTabCallBack(tabIndex)
    if tabIndex == XUiEquipDetail.BtnTabIndex.Detail then
        self:OpenOneChildUi("UiEquipDetailChild", self.EquipId, self.IsPreview)
        self.ImgLihuiMask.gameObject:SetActive(false)
    elseif tabIndex == XUiEquipDetail.BtnTabIndex.Strengthen then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.EquipStrengthen) then
            return
        end

        if XDataCenter.EquipManager.CanBreakThrough(self.EquipId) then
            self:OpenOneChildUi("UiEquipBreakThrough", self.EquipId, self)
        else
            self:OpenOneChildUi("UiEquipStrengthen", self.EquipId, self)
        end
        self.ImgLihuiMask.gameObject:SetActive(true)
    elseif tabIndex == XUiEquipDetail.BtnTabIndex.Resonance then
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.EquipResonance) then
            return
        end

        self:OpenOneChildUi("UiEquipResonanceSkill", self.EquipId, self)
        self.ImgLihuiMask.gameObject:SetActive(false)
    end
end

function XUiEquipDetail:OnBtnHelpClick(eventData)
    local keyStr = XDataCenter.EquipManager.IsClassifyEqualByTemplateId(self.TemplateId, XEquipConfig.Classify.Weapon) and "EquipWeapon" or "EquipAwareness"
    XUiManager.ShowHelpTip(keyStr)
end