local tableInsert = table.insert
local tableSort = table.sort

XItemConfigs = XItemConfigs or {}

local XItemTemplate = require("XEntity/XItem/XItemTemplate")
local XCharacterExpTemplate = require("XEntity/XItem/XCharacterExpTemplate")
local XEquipExpTempalte = require("XEntity/XItem/XEquipExpTemplate")
local XGiftTemplate = require("XEntity/XItem/XGiftTemplate")

local TABLE_ITEM_PATH = "Share/Item/Item.tab"
local TABLE_BUY_ASSET_PATH = "Share/Item/BuyAsset.tab"
local TABLE_BUY_ASSET_CONFIG_PATH = "Share/Item/BuyAssetConfig.tab"

local BuyAssetTemplates = {}                    -- 购买资源配置表
local BuyAssetDailyLimit = {}                   -- 购买资源每日限制
local ItemTemplates = {}

XItemConfigs.ItemType = {
    Assert = 1 << 0, -- 资源
    Money = 1 << 1 | 1 << 0, -- 货币，包括金币和钻石
    Material = 1 << 2, -- 材料
    Fragment = 1 << 3, -- 碎片
    Gift = 1 << 4, -- 礼包

    CardExp = 1 << 11 | 1 << 2, -- 卡牌exp
    EquipExp = 1 << 12 | 1 << 2, -- 装备exp
    EquipReform = 1 << 13 | 1 << 2, -- 装备改造道具
    FurnitureItem = 1 << 14 | 1 << 2, -- 家具图纸
}

function XItemConfigs.Init()
    local itemTable = XTableManager.ReadByIntKey(TABLE_ITEM_PATH, XTable.XTableItem, "Id")
    for k, item in pairs(itemTable) do
        local template = XItemTemplate.New(item)

        if item.ItemType == XItemConfigs.ItemType.CardExp then
            template = XCharacterExpTemplate.New(template)
        elseif item.ItemType == XItemConfigs.ItemType.EquipExp then
            template = XEquipExpTempalte.New(template)
        elseif item.ItemType == XItemConfigs.ItemType.Gift then
            template = XGiftTemplate.New(template)
        end

        ItemTemplates[k] = template
    end

    local bATemplates = XTableManager.ReadByIntKey(TABLE_BUY_ASSET_PATH, XTable.XTableBuyAsset, "Id")
    local bACTemplates = XTableManager.ReadByIntKey(TABLE_BUY_ASSET_CONFIG_PATH, XTable.XTableBuyAssetConfig, "Id")

    for id, tab in pairs(bATemplates) do
        BuyAssetDailyLimit[id] = tab.DailyLimit

        local configs = {}
        for _, config in pairs(tab.Config) do
            local buyConfig = bACTemplates[config]
            if not buyConfig then
                XLog.Error("XItemManager.Init Error: can not found buy asset config! table path is " .. TABLE_BUY_ASSET_PATH .. " Id is " .. id .. " Config is " .. config)
                return
            end

            if not ItemTemplates[buyConfig.ConsumeId] then
                XLog.Error("XItemManager.Init Error: can not found consume item! table path is " .. TABLE_BUY_ASSET_CONFIG_PATH .. " Id is " .. id .. " ConsumeId is " .. buyConfig.ConsumeId)
                return
            end

            tableInsert(configs, bACTemplates[config])
        end

        tableSort(configs, function(a, b)
            return a.Times < b.Times
        end)

        BuyAssetTemplates[id] = configs
    end
end

function XItemConfigs.GetItemTemplates()
    return ItemTemplates
end

function XItemConfigs.GetBuyAssetDailyLimit()
    return BuyAssetDailyLimit
end

function XItemConfigs.GetBuyAssetTemplates()
    return BuyAssetTemplates
end