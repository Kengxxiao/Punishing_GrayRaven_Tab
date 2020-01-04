
----------------------------------------------------------------
--角色解锁红点检测
local XRedPointConditionCharacterUnlock = {}

function XRedPointConditionCharacterUnlock.Check(characterId)
    if not characterId then
        return false
    end

    local canUnlock = XDataCenter.CharacterManager:CanCharacterUnlock(characterId)
    return canUnlock
end

return XRedPointConditionCharacterUnlock