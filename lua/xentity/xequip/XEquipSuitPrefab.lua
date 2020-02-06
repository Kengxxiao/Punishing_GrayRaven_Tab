local PresentSuitEquipsCount = 4    -- 已装备的意识中同一套的装备数量代表值

local XEquipSuitPrefab = XClass()

local Default = {
    EquipCount = 0,
    PresentSuitId = nil,
    SiteToEquipIdDic = {},
    EquipIdCheckTable = {},
    --Original Data
    GroupId = 0,
    Name = "",
    ChipIdList = {},
}
--[[
public class XChipGroupData
{
    // 组合id
    public int GroupId;
    // 组合名字
    public string Name;
    // 意识id列表
    public List<int> ChipIdList;
}
]]
function XEquipSuitPrefab:Ctor(equipGroupData)
    for key, v in pairs(Default) do
        self[key] = v
    end

    self:UpdateData(equipGroupData)
end

function XEquipSuitPrefab:UpdateData(equipGroupData)
    self.GroupId = equipGroupData.GroupId or self.GroupId
    self.Name = equipGroupData.Name or self.Name
    self.ChipIdList = equipGroupData.ChipIdList

    self.SiteToEquipIdDic = {}
    self.EquipIdCheckTable = {}
    for _, equipId in pairs(self.ChipIdList) do
        local equipSite = XDataCenter.EquipManager.GetEquipSite(equipId)
        self.SiteToEquipIdDic[equipSite] = equipId
        self.EquipIdCheckTable[equipId] = true
    end

    local count = 0
    for _, _ in pairs(self.SiteToEquipIdDic) do
        count = count + 1
    end
    self.EquipCount = count

    local presentEquipId = nil
    local suitIdCountDic = {}
    for site = XEquipConfig.EquipSite.Awareness.One, XEquipConfig.EquipSite.Awareness.Six do
        local equipId = self.SiteToEquipIdDic[site]
        if equipId then
            presentEquipId = presentEquipId or equipId

            local suitId = XDataCenter.EquipManager.GetSuitId(equipId)
            local count = suitIdCountDic[suitId] or 0
            count = count + 1
            if count == PresentSuitEquipsCount then
                presentEquipId = equipId
                break
            end
            suitIdCountDic[suitId] = count
        end
    end
    self.PresentSuitId = presentEquipId and XDataCenter.EquipManager.GetSuitId(presentEquipId)
end

function XEquipSuitPrefab:GetGroupId()
    return self.GroupId
end

function XEquipSuitPrefab:GetName()
    return self.Name
end

function XEquipSuitPrefab:SetName(newName)
    self.Name = newName
end

function XEquipSuitPrefab:GetEquipCount()
    return self.EquipCount
end

function XEquipSuitPrefab:GetPresentSuitId()
    return self.PresentSuitId
end

function XEquipSuitPrefab:GetEquipId(site)
    return self.SiteToEquipIdDic[site]
end

function XEquipSuitPrefab:GetEquipIds(site)
    return self.ChipIdList
end

function XEquipSuitPrefab:IsEquipIn(equipId)
    return self.EquipIdCheckTable[equipId]
end

return XEquipSuitPrefab