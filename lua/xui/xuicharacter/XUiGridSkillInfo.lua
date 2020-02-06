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
    local config = self.Skill.subSkills[index]
    if resonanceLevel and resonanceLevel > 0 then
        local gradeConfig = XCharacterConfigs.GetSkillGradeConfig(config.SubSkillId, level--[[] + resonanceLevel]]) --kkkttt 暂时屏蔽掉共鸣技能等级预览
        self.TxtSkillLevel.text = CS.XTextManager.GetText("WeaponLevel", level, resonanceLevel)
        self.TxtSkillDesc.text = gradeConfig.Intro
    else
        self.TxtSkillLevel.text = level
        self.TxtSkillDesc.text = config.config.Intro
    end
    self.TxtSkillName.text = config.config.Name
end