local XUiGridResonanceSkill = require("XUi/XUiEquipResonanceSkill/XUiGridResonanceSkill")
local XUiEquipResonanceSelectAfter = XLuaUiManager.Register(XLuaUi, "UiEquipResonanceSelectAfter")

function XUiEquipResonanceSelectAfter:OnAwake()
    self:InitAutoScript()
    self.PanelWeapon = self:GetSceneRoot().transform:FindTransform("PanelWeapon")
end

function XUiEquipResonanceSelectAfter:OnStart(equipId, pos, characterId)
    self.CharacterId = characterId
    self.EquipId = equipId
    self.Pos = pos

    self:InitClassifyPanel()
end

function XUiEquipResonanceSelectAfter:OnEnable()
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiEquip_ResonanceSelectAfter)
    self:UpdateResonanceSkillGrids()
end

function XUiEquipResonanceSelectAfter:OnDestroy()
    if self.Resource then
        CS.XResourceManager.Unload(self.Resource)
        self.Resource = nil
    end
end

function XUiEquipResonanceSelectAfter:OnGetEvents()
    return { XEventId.EVENT_EQUIP_RESONANCE_ACK_NOTYFY }
end

function XUiEquipResonanceSelectAfter:OnNotify(evt, ...)
    local args = { ... }
    local equipId = args[1]
    if equipId ~= self.EquipId then return end

    if evt == XEventId.EVENT_EQUIP_RESONANCE_ACK_NOTYFY then
        self:Close()
    end
end

function XUiEquipResonanceSelectAfter:InitClassifyPanel()
    self.FxUiLihuiChuxian01.gameObject:SetActive(false)
    if XDataCenter.EquipManager.IsClassifyEqual(self.EquipId, XEquipConfig.Classify.Weapon) then
        local modelConfig = XDataCenter.EquipManager.GetWeaponModelCfgByEquipId(self.EquipId, self.Name)
        if modelConfig then
            XModelManager.LoadWeaponModel(modelConfig.ModelName, self.PanelWeapon, modelConfig.TransfromConfig, function(model)
                local rotate = self.PanelWeapon:GetComponent("XAutoRotation")
                if rotate then
                    rotate.Target = model.transform
                end
            end, self.CharacterId, self.EquipId)
        end
        self.PanelWeapon.gameObject:SetActive(true)
        self.PanelAwareness.gameObject:SetActive(false)
    elseif XDataCenter.EquipManager.IsClassifyEqual(self.EquipId, XEquipConfig.Classify.Awareness) then
        local equip = XDataCenter.EquipManager.GetEquip(self.EquipId)
        local resource = CS.XResourceManager.Load(XDataCenter.EquipManager.GetEquipLiHuiPath(equip.TemplateId, equip.Breakthrough))
        local texture = resource.Asset
        self.MeshLihui.sharedMaterial:SetTexture("_MainTex", texture)
        if self.Resource then
            CS.XResourceManager.Unload(self.Resource)
        end
        self.Resource = resource
        CS.XScheduleManager.Schedule(function()
            if XTool.UObjIsNil(self.FxUiLihuiChuxian01) then return end
            self.FxUiLihuiChuxian01.gameObject:SetActive(true)
        end, 0, 1, 500)

        self.PanelAwareness.gameObject:SetActive(true)
        self.PanelWeapon.gameObject:SetActive(false)
    end
end

function XUiEquipResonanceSelectAfter:UpdateResonanceSkillGrids()
    self.TxtSlot.text = CS.XTextManager.GetText("EquipResonancePosText", self.Pos)
    
    self.ResonanceSkillGridOld = self.ResonanceSkillGridOld or XUiGridResonanceSkill.New(self.GridResonanceSkill, self.EquipId, self.Pos)
    self.ResonanceSkillGridNew = self.ResonanceSkillGridNew or XUiGridResonanceSkill.New(self.GridResonanceSkillA, self.EquipId, self.Pos)

    local unconfirmedSkillInfo = XDataCenter.EquipManager.GetUnconfirmedResonanceSkillInfo(self.EquipId, self.Pos)
    local bindCharacterId = XDataCenter.EquipManager.GetUnconfirmedResonanceBindCharacterId(self.EquipId, self.Pos)

    if not XDataCenter.EquipManager.CheckEquipPosUnconfirmedResonanced(self.EquipId, self.Pos) then
        self.ResonanceSkillGridNew:Refresh()

        self.BtnConfirm.gameObject:SetActive(true)
        self.BtnChange.gameObject:SetActive(false)
        self.PanelSlotOld.gameObject:SetActive(false)
        self:PlayAnimation("RImgLihui")
    else
        self.ResonanceSkillGridOld:Refresh()
        self.ResonanceSkillGridNew:Refresh(unconfirmedSkillInfo, bindCharacterId)

        self.BtnConfirm.gameObject:SetActive(false)
        self.BtnChange.gameObject:SetActive(true)
        self.PanelSlotOld.gameObject:SetActive(true)
        self:PlayAnimation("ContianerEnable")
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiEquipResonanceSelectAfter:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiEquipResonanceSelectAfter:AutoInitUi()
    self.PanelSlotNew = self.Transform:Find("SafeAreaContentPane/Contianer/Layout/PanelSlotNew")
    self.GridResonanceSkillA = self.Transform:Find("SafeAreaContentPane/Contianer/Layout/PanelSlotNew/GridResonanceSkill")
    self.RImgResonanceSkillA = self.Transform:Find("SafeAreaContentPane/Contianer/Layout/PanelSlotNew/GridResonanceSkill/RImgResonanceSkill"):GetComponent("RawImage")
    self.BtnChange = self.Transform:Find("SafeAreaContentPane/Contianer/Layout/PanelSlotNew/BtnChange"):GetComponent("Button")
    self.BtnConfirm = self.Transform:Find("SafeAreaContentPane/Contianer/Layout/PanelSlotNew/BtnConfirm"):GetComponent("Button")
    self.PanelSlotOld = self.Transform:Find("SafeAreaContentPane/Contianer/Layout/PanelSlotOld")
    self.GridResonanceSkill = self.Transform:Find("SafeAreaContentPane/Contianer/Layout/PanelSlotOld/GridResonanceSkill")
    self.RImgResonanceSkill = self.Transform:Find("SafeAreaContentPane/Contianer/Layout/PanelSlotOld/GridResonanceSkill/RImgResonanceSkill"):GetComponent("RawImage")
    self.TxtSlot = self.Transform:Find("SafeAreaContentPane/Contianer/Layout/PanelSlotOld/TxtSlot"):GetComponent("Text")
    self.BtnRemain = self.Transform:Find("SafeAreaContentPane/Contianer/Layout/PanelSlotOld/BtnRemain"):GetComponent("Button")
    self.PanelAwareness = self.Transform:Find("SafeAreaContentPane/Left/PanelAwareness")
    self.PanelCharacter = self.Transform:Find("SafeAreaContentPane/Left/PanelCharacter")
end

function XUiEquipResonanceSelectAfter:AutoAddListener()
    self:RegisterClickEvent(self.BtnChange, self.OnBtnChangeClick)
    self:RegisterClickEvent(self.BtnConfirm, self.OnBtnConfirmClick)
    self:RegisterClickEvent(self.BtnRemain, self.OnBtnRemainClick)
end
-- auto
function XUiEquipResonanceSelectAfter:OnBtnConfirmClick(eventData)
    self:Close()
end

function XUiEquipResonanceSelectAfter:OnBtnChangeClick(eventData)
    XDataCenter.EquipManager.ResonanceConfirm(self.EquipId, self.Pos, true)
end

function XUiEquipResonanceSelectAfter:OnBtnRemainClick(eventData)
    XDataCenter.EquipManager.ResonanceConfirm(self.EquipId, self.Pos, false)
end