-- 家具建造主界面
local XUiPracticeSkillDetail = XLuaUiManager.Register(XLuaUi, "UiPracticeSkillDetail")

function XUiPracticeSkillDetail:OnAwake()
    self:AddBtnsListeners()
end

function XUiPracticeSkillDetail:AddBtnsListeners()
    self:RegisterClickEvent(self.BtnDarkBg, self.OnBtnDarkBgClick)
end


function XUiPracticeSkillDetail:OnStart(stageId)
    local skillDetail = XPracticeConfigs.GetPracticeSkillDetailById(stageId)
    self.TxtSkillName.text = skillDetail.Title
    self.RImgSkill:SetRawImage(skillDetail.Icon)
    self.TxtSkillDesc.text = skillDetail.Description
end

function XUiPracticeSkillDetail:OnEnable()
    if CS.XFight.IsRunning then
        CS.XFight.Instance:Pause()
    end
end

function XUiPracticeSkillDetail:OnDisable()
    if CS.XFight.Instance then
        CS.XFight.Instance:Resume()
    end
end

function XUiPracticeSkillDetail:OnBtnDarkBgClick(...)
    self:Close()
end

function XUiPracticeSkillDetail:OnDestroy()
end


