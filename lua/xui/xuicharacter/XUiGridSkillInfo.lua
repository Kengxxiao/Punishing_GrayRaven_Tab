XUiGridSkillInfo = XClass()

function XUiGridSkillInfo:Ctor(ui, skill)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:UpdateData(skill)
end

function XUiGridSkillInfo:SetIndex(index)
    self.Index = index
end

function XUiGridSkillInfo:UpdateData(skill)
    self.Skill = skill
    self.TxtSkillName.text = skill.config.Name
    self.TxtSkillLevel.text = skill.totalLevel
    self.TxtSkillDesc.text = skill.config.Intro
end

function XUiGridSkillInfo:SetSubInfo(level, index, resonanceLevel)
    if resonanceLevel and resonanceLevel > 0 then
        self.TxtSkillLevel.text = CS.XTextManager.GetText("WeaponLevel", level, resonanceLevel)
    else
        self.TxtSkillLevel.text = level
    end
    self.TxtSkillDesc.text = self.Skill.subSkills[index].config.Intro
    self.TxtSkillName.text = self.Skill.subSkills[index].config.Name
end