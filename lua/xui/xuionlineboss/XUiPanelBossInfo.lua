XUiPanelBossInfo = XClass()
local PrePageSkillCount = 5

function XUiPanelBossInfo:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)

    self.SkillPanels = {
        self.PanelSkillBox1,
        self.PanelSkillBox2,
        self.PanelSkillBox3,
        self.PanelSkillBox4,
        self.PanelSkillBox5,
    }
    self.CurPage = 1
    self:InitGrids()

    XUiHelper.RegisterClickEvent(self, self.BtnNext, self.OnBtnNextClick)
end

function XUiPanelBossInfo:InitGrids()
    self.SkillPanelGrids = {}
    for i = 1, PrePageSkillCount, 1 do
        local ui = self.SkillPanels[i]
        local grid = XUiPanelSkillBox.New(ui, self, i)
        self.SkillPanelGrids[i] = grid
    end
end

function XUiPanelBossInfo:OnBtnNextClick(...)
    self.CurPage = self.CurPage + 1
    self.CurPage = self.CurPage > self.MaxPage and 1 or self.CurPage
    self:Refresh()
end

function XUiPanelBossInfo:SetData(section)
    self.Section = section
    self.CurPage = 1
    self.MaxPage = math.ceil(#self.Section.SkillName / PrePageSkillCount)
    self.BtnNext.gameObject:SetActive(self.MaxPage > 1)
    self:Refresh()
end

function XUiPanelBossInfo:Refresh()
    local offset = PrePageSkillCount * (self.CurPage - 1)
    for i = 1, PrePageSkillCount, 1 do
        local skillName = self.Section.SkillName[i + offset]
        local desc = self.Section.SkillDes[i + offset]
        local grid = self.SkillPanelGrids[i]
        if skillName and desc then
            grid:Refresh(skillName, desc)
            grid:SetActive(true)
        else
            grid:SetActive(false)
        end
    end
end

return XUiPanelBossInfo