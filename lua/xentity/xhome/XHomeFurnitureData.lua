XHomeFurnitureData = XClass()

function XHomeFurnitureData:Ctor(data)
    self.Id = data.Id or 0
    self.PlayerId = 0
    self.ConfigId = data.ConfigId or 0
    self.X = data.X
    self.Y = data.Y
    self.Angle = data.Angle
    self.DormitoryId = data.DormitoryId
    self.Addition = data.Addition
    self.AttrList = data.AttrList
end

function XHomeFurnitureData:GetInstanceID()
    return self.Id
end

function XHomeFurnitureData:SetConfigId(cfgId)
    self.ConfigId = cfgId
end

function XHomeFurnitureData:GetConfigId()
    return self.ConfigId
end

function XHomeFurnitureData:SetUsedDormitoryId(dormitoryId)
    self.DormitoryId = dormitoryId
end

function XHomeFurnitureData:CheckIsUsed()
    return self.DormitoryId > 0
end

function XHomeFurnitureData:GetScore()
    local score = 0
    if self.Addition > 0 then
        score = score + XFurnitureConfigs.GetAdditionalAddScore(self.Addition)
    end

    for _, attr in ipairs(self.AttrList) do
        score = score + attr
    end
    return score
end

function XHomeFurnitureData:GeAttrtScore(attrType, attrScore)
    local score = attrScore or 0
    if self.Addition <= 0 then
        return score
    end
    
    local additionConfig = XFurnitureConfigs.GetAdditonAttrConfigById(self.Addition)
    if additionConfig == nil then 
        return score
    end

    if additionConfig.AddType == XFurnitureConfigs.FurnitureAdditionType.AttrTotal then
        score = additionConfig.AddValue[attrType] + score
    elseif additionConfig.AddType == XFurnitureConfigs.FurnitureAdditionType.AttrTotalPercent then
        score = math.floor(additionConfig.AddValue[attrType] * score / 100) + score
    end

    return score
end

function XHomeFurnitureData:GetRedScore()
    return self:GeAttrtScore(XFurnitureConfigs.AttrType.AttrA, self.AttrList[XFurnitureConfigs.AttrType.AttrA])
end

function XHomeFurnitureData:GetYellowScore()
    return self:GeAttrtScore(XFurnitureConfigs.AttrType.AttrB, self.AttrList[XFurnitureConfigs.AttrType.AttrB])
end

function XHomeFurnitureData:GetBlueScore()
    return self:GeAttrtScore(XFurnitureConfigs.AttrType.AttrC, self.AttrList[XFurnitureConfigs.AttrType.AttrC])
end
