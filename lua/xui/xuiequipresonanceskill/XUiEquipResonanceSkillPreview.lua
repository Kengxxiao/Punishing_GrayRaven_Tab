local XUiGridResonanceSkill = require("XUi/XUiEquipResonanceSkill/XUiGridResonanceSkill")

local XUiEquipResonanceSkillPreview = XLuaUiManager.Register(XLuaUi, "UiEquipResonanceSkillPreview")

function XUiEquipResonanceSkillPreview:OnAwake()
    self:AutoAddListener()

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

function XUiEquipResonanceSkillPreview:AutoAddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end

function XUiEquipResonanceSkillPreview:OnBtnCloseClick(eventData)
    self:Close()
end