local XUiGridResonanceSkill = require("XUi/XUiEquipResonanceSkill/XUiGridResonanceSkill")

local XUiEquipResonanceSkillPreview = XLuaUiManager.Register(XLuaUi, "UiEquipResonanceSkillPreview")

function XUiEquipResonanceSkillPreview:OnAwake()
    self:InitAutoScript()

    self.GridResonanceSkill.gameObject:SetActive(false)
end

function XUiEquipResonanceSkillPreview:OnStart(rootUi)
    self.RootUi = rootUi
end

function XUiEquipResonanceSkillPreview:OnEnable()
    self:UpdateCharacterName()
    self:UpdateSkillPreviewScroll()
end

function XUiEquipResonanceSkillPreview:UpdateCharacterName()
    local charConfig = XCharacterConfigs.GetCharacterTemplate(self.RootUi.SelectCharacterId)
    self.TxtCharacterName.text = charConfig.Name
    self.TxtCharacterNameOther.text = charConfig.TradeName
end

function XUiEquipResonanceSkillPreview:UpdateSkillPreviewScroll()
    self.ResonanceSkillGrids = self.ResonanceSkillGrids or {}
    local skillIndex = 0
    local preSkillInfoList = XDataCenter.EquipManager.GetResonancePreSkillInfoList(self.RootUi.EquipId, self.RootUi.SelectCharacterId, self.RootUi.Pos)

    for _, skillInfo in pairs(preSkillInfoList) do
        skillIndex = skillIndex + 1
        if not self.ResonanceSkillGrids[skillIndex] then
            local item = CS.UnityEngine.Object.Instantiate(self.GridResonanceSkill)  -- 复制一个item
            local grid = XUiGridResonanceSkill.New(item, self.RootUi.EquipId)
            grid.Transform:SetParent(self.PanelCharacterContent, false)
            self.ResonanceSkillGrids[skillIndex] = grid
        end

        self.ResonanceSkillGrids[skillIndex].GameObject:SetActive(true)
        self.ResonanceSkillGrids[skillIndex]:Refresh(skillInfo)
    end

    for i = skillIndex + 1,#self.ResonanceSkillGrids do
        self.ResonanceSkillGrids[i].GameObject:SetActive(false)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiEquipResonanceSkillPreview:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiEquipResonanceSkillPreview:AutoInitUi()
    self.PanelCharacterContent = self.Transform:Find("SafeAreaContentPane/PaneResonanceSkillScroll/Viewport/PanelCharacterContent")
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
    self.TxtCharacterName = self.Transform:Find("SafeAreaContentPane/TxtCharacterName"):GetComponent("Text")
    self.GridResonanceSkill = self.Transform:Find("SafeAreaContentPane/PaneResonanceSkillScroll/Viewport/GridResonanceSkill")
    self.TxtCharacterNameOther = self.Transform:Find("SafeAreaContentPane/TxtCharacterNameOther"):GetComponent("Text")
end

function XUiEquipResonanceSkillPreview:AutoAddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end
-- auto
function XUiEquipResonanceSkillPreview:OnBtnCloseClick(eventData)
    self:Close()
end