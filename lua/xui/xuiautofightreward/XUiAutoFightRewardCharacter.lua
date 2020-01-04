local XUiAutoFightRewardCharacter = XClass()

function XUiAutoFightRewardCharacter:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

function XUiAutoFightRewardCharacter:SetData(id, addExp)
    self.Id = id

    local character = XDataCenter.CharacterManager.GetCharacter(id)
    local level = character and character.Level or 1
    self.TxtLv.text = level

    self.TxtExp.text = "+" .. addExp

    local icon = XDataCenter.CharacterManager.GetCharSmallHeadIcon(id)
    self.RImgIcon:SetRawImage(icon)

    local exp = character and character.Exp or 0
    local maxExp = XCharacterConfigs.GetCharMaxLevel(id)
    local expBefore = exp - addExp
    self.ImgExpBar.fillAmount = expBefore > 0 and expBefore / maxExp or 0
    self.ImgExpBarReward.fillAmount = exp / maxExp
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiAutoFightRewardCharacter:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiAutoFightRewardCharacter:AutoInitUi()
    self.RImgIcon = XUiHelper.TryGetComponent(self.Transform, "RImgIcon", "RawImage")
    self.TxtLv = XUiHelper.TryGetComponent(self.Transform, "TxtLv", "Text")
    self.TxtExp = XUiHelper.TryGetComponent(self.Transform, "TxtExp", "Text")
    self.ImgExpBarReward = XUiHelper.TryGetComponent(self.Transform, "ExpBar/ImgExpBarReward", "Image")
    self.ImgExpBar = XUiHelper.TryGetComponent(self.Transform, "ExpBar/ImgExpBar", "Image")
end

function XUiAutoFightRewardCharacter:AutoAddListener()
end
-- auto
return XUiAutoFightRewardCharacter