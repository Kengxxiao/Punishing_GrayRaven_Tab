XShopConfigs = {}

local ShopGroupTemplate = {}
local ShopTypeNameTemplate = {}

local TABLE_SHOP_GROUP = "Client/Shop/ShopGroup.tab"
local TABLE_SHOP_TYPENAME = "Client/Shop/ShopTypeName.tab"

function XShopConfigs.Init()
    ShopGroupTemplate = XTableManager.ReadByIntKey(TABLE_SHOP_GROUP, XTable.XTableShopGroup, "Id")
    ShopTypeNameTemplate = XTableManager.ReadByIntKey(TABLE_SHOP_TYPENAME, XTable.XTableShopTypeName, "Id")
end


function XShopConfigs.GetShopGroupTemplate()
    return ShopGroupTemplate
end

function XShopConfigs.GetShopTypeNameTemplate()
    return ShopTypeNameTemplate
end
