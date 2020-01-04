local list

local Record = function()
    local charList = XDataCenter.CharacterManager.GetOwnCharacterList()
    list = {}
    for i = 1, #charList do
        table.insert(list, charList[i].Id)
    end
end

local IsOwnCharacter = function(id)
    if not list then
        XLog.Warning("Haven't record character list yet.")
        return
    end

    if XArrangeConfigs.GetType(id) ~= XArrangeConfigs.Types.Character then
        return false
    end

    for i = 1, #list do
        if list[i] == id then
            return true
        end
    end

    table.insert(list, id)

    return false
end

local GetDecomposeData = function(goods)
    local template = XCharacterConfigs.GetCharacterTemplate(goods.TemplateId)
    local decomposeCount = XCharacterConfigs.GetDecomposeCount(goods.Quality)
    return {TemplateId = template.ItemId, Count = decomposeCount}
end

local CharacterRecord = {}

CharacterRecord.Record = Record
CharacterRecord.IsOwnCharacter = IsOwnCharacter
CharacterRecord.GetDecomposeData = GetDecomposeData

return CharacterRecord