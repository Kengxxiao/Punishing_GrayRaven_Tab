XCharacter = XClass()

local Default = {
    Id = 0,
    Level = 1,
    Exp = 0,
    Quality = 1,
    Star = 0,
    Grade = 1,
    SkillState = 0,
    SkillLevel = {},
    PartGrades = {},
    CreateTime = 0,
    Ability = 0,
    TrustLv = 0,
    TrustExp = 0,
    Type = 0,
    NpcId = 0,
    Attribs = {},
}

function XCharacter:Ctor(character)
    for key in pairs(Default) do
        self[key] = Default[key]
    end

    for k, v in pairs(character) do
        self[k] = v
    end

    self.CharacterTemplate = XCharacterConfigs.GetCharacterTemplate(self.Id)

    self:ChangeNpcId()

    -- 登录数据加载成功后计算
    XEventManager.AddEventListener(XEventId.EVENT_LOGIN_DATA_LOAD_COMPLETE, function(equip)
        self:RefreshAttribs()
    end)

    XEventManager.AddEventListener(XEventId.EVENT_EQUIP_DATA_CHANGE_NOTIFY, function(equip)
        self:RefreshAttribs()
    end)

    XEventManager.AddEventListener(XEventId.EVENT_BASE_EQUIP_DATA_CHANGE_NOTIFY, function(equip)
        self:RefreshAttribs()
    end)
end

function XCharacter:RefreshSkillLevel()
    self.SkillTotalLevel = 0
    self.SkillLevel = {}

    XTool.LoopCollection(self.SkillList, function(skill) 
        self.SkillLevel[skill.Id] = skill.Level
        self.SkillTotalLevel = self.SkillTotalLevel + skill.Level
    end)
end

function XCharacter:RefreshAttribs()
    local attribs = XDataCenter.CharacterManager.GetCharacterAttribs(self)
    if attribs then
        self.Attribs = attribs
    end

    self:RefreshSkillLevel()
    self:RefreshAbility()
end

-- 刷新战力
function XCharacter:RefreshAbility()
    self.Ability = XDataCenter.CharacterManager.GetCharacterAbility(self)
end

function XCharacter:ChangeNpcId()
    local npcId = XCharacterConfigs.GetCharNpcId(self.Id, self.Quality)
    if npcId == nil then
        return
    end
    
    if self.NpcId and self.NpcId ~= npcId then
        self.NpcId = npcId
        self:ChangeType()
    end
end

function XCharacter:ChangeType()
    local npcTemplate = CS.XNpcManager.GetNpcTemplate(self.NpcId)
    if not npcTemplate then
        XLog.Error("XCharacter:ChangeType error: can not found npc template, npcId is " .. self.NpcId)
        return
    end

    self.Type = npcTemplate.Type
end

function XCharacter:Sync(data)
    for k, v in pairs(data) do
        self[k] = v
    end

    self:ChangeNpcId()
    self:RefreshAttribs()
end

function XCharacter:IsContains(container, item)
    for k, v in pairs(container or {}) do
        if v == item then
            return true
        end
    end
    return false
end