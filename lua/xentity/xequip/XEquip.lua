local XEquip = XClass()

local Default = {
    Id = 0,
    TemplateId = 0,
    CharacterId = 0,
    Level = 1,
    Exp = 0,
    Breakthrough = 0,
    CreateTime = 0,
    IsLock = false,
}

--[[装备共鸣表结构
ResonanceInfo = {
    Slot = slot,
    Type = XEquipConfig.EquipResonanceType.Attrib,
    CharacterId = 0,
    TemplateId = 0,
} 
]]
function XEquip:Ctor(protoData)
    for key, v in pairs(Default) do
        self[key] = v
    end
    self:SyncData(protoData)
end

function XEquip:SyncData(protoData)
    self.Id = protoData.Id
    self.TemplateId = protoData.TemplateId
    self.CharacterId = protoData.CharacterId
    self.Level = protoData.Level
    self.Exp = protoData.Exp
    self.Breakthrough = protoData.Breakthrough
    self.CreateTime = protoData.CreateTime
    self.IsLock = protoData.IsLock

    if protoData.ResonanceInfo and next(protoData.ResonanceInfo) then
        self.ResonanceInfo = {}
        for _, info in pairs(protoData.ResonanceInfo) do
            self.ResonanceInfo[info.Slot] = info
        end
    else
        self.ResonanceInfo = nil
    end


    if protoData.UnconfirmedResonanceInfo and next(protoData.UnconfirmedResonanceInfo) then
        self.UnconfirmedResonanceInfo = {}
        for _, info in pairs(protoData.UnconfirmedResonanceInfo) do
            self.UnconfirmedResonanceInfo[info.Slot] = info
        end
    else
        self.UnconfirmedResonanceInfo = nil
    end
end

return XEquip