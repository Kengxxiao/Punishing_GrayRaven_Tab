local RESONANCED_GRID_TEXT_COLOR = {
    [true] = XUiHelper.Hexcolor2Color("fee82aff"),
    [false] = XUiHelper.Hexcolor2Color("ffffffff"),
}

XUiGridSubSkill = XClass()

function XUiGridSubSkill:Ctor(ui, index, callback)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Index = index
    self.ClickCallback = callback
    self:InitAutoScript()
    self:SetSelect(false)
    self.PanelIconTip.gameObject:SetActive(true)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridSubSkill:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridSubSkill:AutoInitUi()
    self.TxtSubSkillLevel = XUiHelper.TryGetComponent(self.Transform, "ImgLevelBg/TxtSubSkillLevel", "Text")
    self.PanelIconTip = XUiHelper.TryGetComponent(self.Transform, "PanelIconTip", nil)
    self.ImgUpgrade = XUiHelper.TryGetComponent(self.Transform, "PanelIconTip/ImgUpgrade", "Image")
    self.ImgLock = XUiHelper.TryGetComponent(self.Transform, "PanelIconTip/ImgLock")
    self.ImgBgSelected = XUiHelper.TryGetComponent(self.Transform, "ImgBgSelected", "Image")
    self.RImgSubSkillIconSelected = XUiHelper.TryGetComponent(self.Transform, "ImgBgSelected/RImgSubSkillIconSelected", "RawImage")
    self.RImgSubSkillIconNormal = XUiHelper.TryGetComponent(self.Transform, "RImgSubSkillIconNormal", "RawImage")
    self.BtnSubSkillIconBg = XUiHelper.TryGetComponent(self.Transform, "BtnSubSkillIconBg", "Button")
end

function XUiGridSubSkill:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridSubSkill:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridSubSkill:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridSubSkill:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnSubSkillIconBg, self.OnBtnSubSkillIconBgClick)
end
-- auto
function XUiGridSubSkill:OnBtnSubSkillIconBgClick(...)
    if (self.ClickCallback) then
        self.ClickCallback(self.SubSkillInfo, self.Index)
    end
end

function XUiGridSubSkill:UpdateGrid(characterId, subSkillInfo)
    self.SubSkillInfo = subSkillInfo

    if (subSkillInfo.config.Icon and subSkillInfo.config.Icon ~= "") then
        self.RImgSubSkillIconNormal:SetRawImage(subSkillInfo.config.Icon)
        self.RImgSubSkillIconSelected:SetRawImage(subSkillInfo.config.Icon)
    else
        XLog.Warning("sub skill config icon is null. id = " .. subSkillInfo.SubSkillId)
    end

    local resonanceLevel = XDataCenter.CharacterManager.GetResonanceSkillLevel(characterId, subSkillInfo.SubSkillId)
    local totalLevel = subSkillInfo.config.Level + resonanceLevel
    local curLevel = totalLevel == 0 and '' or CS.XTextManager.GetText("HostelDeviceLevel") .. ':' .. totalLevel
    self.TxtSubSkillLevel.color = RESONANCED_GRID_TEXT_COLOR[resonanceLevel > 0]
    self.TxtSubSkillLevel.text = curLevel

    local min_max = XCharacterConfigs.GetSubSkillMinMaxLevel(subSkillInfo.SubSkillId)
    if (subSkillInfo.Level >= min_max.Max) then
        self.ImgLock.gameObject:SetActive(false)
        self.ImgUpgrade.gameObject:SetActive(false)
    else
        self.ImgLock.gameObject:SetActive(subSkillInfo.Level <= 0)
        self.ImgUpgrade.gameObject:SetActive(XDataCenter.CharacterManager.CheckCanUpdateSkill(characterId, subSkillInfo.SubSkillId, subSkillInfo.Level))
    end

    self.GameObject:SetActive(true)
end

function XUiGridSubSkill:SetSelect(isSelect)
    if (self.ImgBgSelected) then
        self.ImgBgSelected.gameObject:SetActive(isSelect)
    end
end

function XUiGridSubSkill:Reset()
    self.SubSkillInfo = nil
    self.GameObject:SetActive(false)
    self:SetSelect(false)
end

function XUiGridSubSkill:ResetSelect(subSkillId)
    self:SetSelect(self.SubSkillInfo and self.SubSkillInfo.SubSkillId == subSkillId)
end