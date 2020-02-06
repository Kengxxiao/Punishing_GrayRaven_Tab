local XUiGridResonanceSkill = require("XUi/XUiEquipResonanceSkill/XUiGridResonanceSkill")

local XUiEquipResonanceSkill = XLuaUiManager.Register(XLuaUi, "UiEquipResonanceSkill")

function XUiEquipResonanceSkill:OnAwake()
    self:InitAutoScript()
end

function XUiEquipResonanceSkill:OnStart(equipId, rootUi)
    self.EquipId = equipId
    self.RootUi = rootUi
    self.GridResonanceSkills = {}
    self.DescriptionTitle = CS.XTextManager.GetText("EquipResonanceExplainTitle")
    self.Description = string.gsub(CS.XTextManager.GetText("EquipResonanceExplain"), "\\n", "\n")
end

function XUiEquipResonanceSkill:OnEnable()
    self:UpdateResonanceSkills()
end

function XUiEquipResonanceSkill:OnGetEvents()
    return { XEventId.EVENT_EQUIP_RESONANCE_ACK_NOTYFY }
end

function XUiEquipResonanceSkill:OnNotify(evt, ...)
    local args = { ... }
    local equipId = args[1]
    local pos = args[2]
    if equipId ~= self.EquipId then return end

    if evt == XEventId.EVENT_EQUIP_RESONANCE_ACK_NOTYFY then
        self:UpdateResonanceSkill(pos)
    end
end

function XUiEquipResonanceSkill:UpdateResonanceSkills()
    local count = 1
    local resonanceSkillNum = XDataCenter.EquipManager.GetResonanceSkillNum(self.EquipId)
    for pos = 1, resonanceSkillNum do
        self:UpdateResonanceSkill(pos)
        self["PanelSkill" .. pos].gameObject:SetActive(true)
        count = count + 1
    end
    for pos = count, XEquipConfig.MAX_RESONANCE_SKILL_COUNT do
        self["PanelSkill" .. pos].gameObject:SetActive(false)
    end
end

function XUiEquipResonanceSkill:UpdateResonanceSkill(pos)
    if XDataCenter.EquipManager.CheckEquipPosResonanced(self.EquipId, pos) then
        if not self.GridResonanceSkills[pos] then
            local item = CS.UnityEngine.Object.Instantiate(self.GridResonanceSkill)  -- 复制一个item
            self.GridResonanceSkills[pos] = XUiGridResonanceSkill.New(item, self.EquipId, pos)
            self.GridResonanceSkills[pos].Transform:SetParent(self["PanelSkill" .. pos], false)
        end

        self.GridResonanceSkills[pos]:Refresh()
        self.GridResonanceSkills[pos].GameObject:SetActive(true)
        self["PanelNoSkill" .. pos].gameObject:SetActive(false)
    else
        if self.GridResonanceSkills[pos] then
            self.GridResonanceSkills[pos].GameObject:SetActive(false)
        end
        self["PanelNoSkill" .. pos].gameObject:SetActive(true)
    end
    self["BtnResonance" .. pos].transform:SetAsLastSibling()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiEquipResonanceSkill:InitAutoScript()
    self:AutoAddListener()
end

function XUiEquipResonanceSkill:AutoAddListener()
    self:RegisterClickEvent(self.BtnResonance1, self.OnBtnResonance1Click)
    self:RegisterClickEvent(self.BtnResonance2, self.OnBtnResonance2Click)
    self:RegisterClickEvent(self.BtnResonance3, self.OnBtnResonance3Click)
    self:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClick)
end
-- auto
function XUiEquipResonanceSkill:OnBtnResonance3Click(eventData)
    self:OnBtnResonanceClick(3)
end

function XUiEquipResonanceSkill:OnBtnResonance1Click(eventData)
    self:OnBtnResonanceClick(1)
end

function XUiEquipResonanceSkill:OnBtnResonance2Click(eventData)
    self:OnBtnResonanceClick(2)
end

function XUiEquipResonanceSkill:OnBtnHelpClick(eventData)
    XUiManager.UiFubenDialogTip(self.DescriptionTitle, self.Description)
end

function XUiEquipResonanceSkill:OnBtnResonanceClick(pos)
    self:PlayAnimation("PanelSkill" .. pos, function ()
        if XDataCenter.EquipManager.CheckEquipPosUnconfirmedResonanced(self.EquipId, pos) then
            XLuaUiManager.Open("UiEquipResonanceSelectAfter", self.EquipId, pos, self.RootUi.CharacterId)
        else
            self.RootUi:FindChildUiObj("UiEquipResonanceSelect"):Refresh(pos)
            self.RootUi:FindChildUiObj("UiEquipResonanceSelectEquip"):Reset()
            self.RootUi:OpenOneChildUi("UiEquipResonanceSelect", self.EquipId, self.RootUi)
        end
    end)
end