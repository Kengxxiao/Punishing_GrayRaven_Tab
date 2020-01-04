XTypeManager = XTypeManager or {}

local GetIconFuncs = {}
local GetNameFuncs = {}
local GetQualityFuncs = {}

----Initialize----
function XTypeManager.Init()
    GetNameFuncs[XArrangeConfigs.Types.Character] = XCharacterConfigs.GetCharacterName
    GetNameFuncs[XArrangeConfigs.Types.Weapon] = XDataCenter.EquipManager.GetEquipName
    GetNameFuncs[XArrangeConfigs.Types.Wafer] = XDataCenter.EquipManager.GetEquipName
    GetNameFuncs[XArrangeConfigs.Types.Item] = XDataCenter.ItemManager.GetItemName
    GetNameFuncs[XArrangeConfigs.Types.Fashion] = XDataCenter.FashionManager.GetFashionName
    GetNameFuncs[XArrangeConfigs.Types.Furniture] = XFurnitureConfigs.GetFurnitureNameById
    GetNameFuncs[XArrangeConfigs.Types.HeadPortrait] = XPlayerManager.GetHeadPortraitNameById

    GetQualityFuncs[XArrangeConfigs.Types.Character] = XCharacterConfigs.GetCharMinQuality
    GetQualityFuncs[XArrangeConfigs.Types.Weapon] = XDataCenter.EquipManager.GetEquipQuality
    GetQualityFuncs[XArrangeConfigs.Types.Wafer] = XDataCenter.EquipManager.GetEquipQuality
    GetQualityFuncs[XArrangeConfigs.Types.Item] = XDataCenter.ItemManager.GetItemQuality
    GetQualityFuncs[XArrangeConfigs.Types.Fashion] = XDataCenter.FashionManager.GetFashionQuality
    GetQualityFuncs[XArrangeConfigs.Types.Furniture] = XDataCenter.FurnitureManager.GetRewardFurnitureQuality
    GetQualityFuncs[XArrangeConfigs.Types.HeadPortrait] = XPlayerManager.GetHeadPortraitQuality
end

----Public Methods----
local GetTypeById = function(id)
    return XArrangeConfigs.GetType(id)
end

local GetNameById = function(id)
    local type = GetTypeById(id)
    return GetNameFuncs[type](id)
end

local GetQualityById = function(id)
    local type = GetTypeById(id)
    return GetQualityFuncs[type](id)
end

XTypeManager.GetTypeById = GetTypeById --(id)
XTypeManager.GetQualityById = GetQualityById --(id)
XTypeManager.GetNameById = GetNameById --(id)