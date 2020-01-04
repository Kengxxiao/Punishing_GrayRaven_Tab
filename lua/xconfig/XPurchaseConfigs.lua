XPurchaseConfigs = XPurchaseConfigs or {}
-- local TABLE_PURCHASE_GIFT = "Share/Purchase/PurchasePackage.tab"
-- local TABLE_PURCHASE_ITEM = "Share/Purchase/PurchaseItem.tab"
local TABLE_PAY = "Share/Pay/Pay.tab"
local TABLE_PURCHASE_ICON_ASSETPATH = "Client/Purchase/PurchaseIconAssetPath.tab"
local TABLE_PURCHASE_TAB_CONTROL = "Client/Purchase/PurchaseTabControl.tab"
local TABLE_PURCHASE_UITYPE = "Client/Purchase/PurchaseUiType.tab"
local TABLE_PURCHASE_TAGTYPE = "Client/Purchase/PurchaseTagType.tab"
local TABLE_ACCUMULATED_PAY = "Share/Pay/AccumulatedPay.tab"
local TABLE_ACCUMULATED_PAY_REWARD = "Share/Pay/AccumulatedPayReward.tab"
local TABLE_LB_BY_PASS = "Client/Purchase/PurchaseLBByPass.tab"

local PurchaseGiftConfig = {}
local PurchaseItemConfig = {}
local PayConfig = {}
local PurchaseIconAssetPathConfig = {}
local PurchaseTabControlConfig = {}
local PurchaseUiTypeConfig = {}
local PurchaseTagTypeConfig = {}

local AccumulatedPayConfig = {}
local AccumulatedPayRewardConfig = {}
local PurchaseLBByPassConfig = {}

local PurchaseUiTypeGroupConfig = nil

local PurchaseTabGroudConfig = nil
local PurchaseTabByUiTypeConfig = nil
local PurchasePayUiTypeConfig = nil
local PurchaseLBUiTypeListConfig = nil
local PurchaseLBUiTypeDicConfig = nil
local PurchaseYKUiTypeConfig = nil
local PurchaseHKUiTypeConfig = nil
local PurchaseLBByPassIDDic = nil

XPurchaseConfigs.PurchaseDataConfig = {
    Pay = 1,--充值
    LB = 2,--礼包
    YK = 3,--月卡
    HKDH = 4,--黑卡兑换
    HKShop = 5,--黑卡商店
}

XPurchaseConfigs.TabsConfig = {
    Pay = 1,--充值
    LB = 2,--礼包
    YK = 3,--月卡
    HK = 4--黑卡
}

XPurchaseConfigs.ConsumeTypeConfig = {
    RMB = 1,--人名币
    ITEM = 2,--道具
    FREE = 3,--免费
}

XPurchaseConfigs.RestTypeConfig = {
    Day = 0,--每日
    Week = 1,--每周
    Moonth = 2,--每月
    Interval = 3,--间隔
    RemainDay = 4,
}

XPurchaseConfigs.LBGetTypeConfig = {
    Direct = 1,--直接
    Day = 2,--每日
}

XPurchaseConfigs.PanelNameConfig = {
    PanelRecharge = "PanelRecharge",
    PanelLb = "PanelLb",
    PanelYk = "PanelYk",
    PanelHksd = "PanelHksd",
    PanelDh = "PanelDh"
}

XPurchaseConfigs.PanelExNameConfig = {
    PanelRecharge = "PanelRechargeEx",
    PanelLb = "PanelLbEx",
    PanelYk = "PanelYkEx",
    PanelHksd = "PanelHksdEx",
    PanelDh = "PanelDhEx"
}

XPurchaseConfigs.TabExConfig = {
    Sample = 1,--没有页签
    EXTable = 2,--左边有页签
}

XPurchaseConfigs.PurchaseRewardAddState = {
    CanGet = 1,--能领，没有领。
    Geted = 2,--已经领
    CanotGet = 3,--不能领，钱不够。
}

function XPurchaseConfigs.Init()
    XPurchaseConfigs.PurChaseGiftTips = CS.XGame.ClientConfig:GetInt("PurChaseGiftTips") or 1
    XPurchaseConfigs.PurChaseCardId = CS.XGame.ClientConfig:GetInt("PurchaseCardId")

    PayConfig = XTableManager.ReadByStringKey(TABLE_PAY, XTable.XTablePay, "Key")
    PurchaseIconAssetPathConfig = XTableManager.ReadByStringKey(TABLE_PURCHASE_ICON_ASSETPATH, XTable.XTablePurchaseIconAssetPath, "Icon")
    PurchaseTabControlConfig = XTableManager.ReadByStringKey(TABLE_PURCHASE_TAB_CONTROL, XTable.XTablePurchaseTabControl, "Id")
    PurchaseUiTypeConfig = XTableManager.ReadByIntKey(TABLE_PURCHASE_UITYPE, XTable.XTablePurchaseUiType, "UiType")
    PurchaseTagTypeConfig = XTableManager.ReadByIntKey(TABLE_PURCHASE_TAGTYPE, XTable.XTablePurchaseTagType, "Tag")

    AccumulatedPayConfig = XTableManager.ReadByIntKey(TABLE_ACCUMULATED_PAY, XTable.XTableAccumulatedPay, "Id")
    AccumulatedPayRewardConfig = XTableManager.ReadByIntKey(TABLE_ACCUMULATED_PAY_REWARD, XTable.XTableAccumulatedPayReward, "Id")

    -- PurchaseLBByPassConfig = XTableManager.ReadByIntKey(TABLE_LB_BY_PASS, XTable.XTablePurchaseLBByPass, "Id")
end

function XPurchaseConfigs.GetIconPathByIconName(iconname)
    return PurchaseIconAssetPathConfig[iconname]
end

function XPurchaseConfigs.GetPurchaseLBByPassIDDic()
    if PurchaseLBByPassIDDic then
        return PurchaseLBByPassIDDic
    end

    PurchaseLBByPassIDDic = {}
    PurchaseLBByPassConfig = XTableManager.ReadByIntKey(TABLE_LB_BY_PASS, XTable.XTablePurchaseLBByPass, "Id") or {}
    for _,v in pairs(PurchaseLBByPassConfig)do
        if v then
            PurchaseLBByPassIDDic[v.LBId] = v.LBId
        end
    end
    return PurchaseLBByPassIDDic
end

function XPurchaseConfigs.IsLBByPassID(id)
    if not id then
        return false
    end

    local config = XPurchaseConfigs.GetPurchaseLBByPassIDDic()
    if config then
        return config[id] ~= nil
    end

    return false
end

function XPurchaseConfigs.GetGroupConfigType()
    if not PurchaseTabGroudConfig then
        PurchaseTabGroudConfig = {}
        for _,v in pairs(PurchaseTabControlConfig)do
            if v.IsOpen == 1 then
                if not PurchaseTabGroudConfig[v.GroupId] then
                    local d = {}
                    d.GroupOrder = v.GroupOrder
                    d.GroupName = v.GroupName
                    d.GroupId = v.GroupId
                    d.GroupIcon = v.GroupIcon
                    d.Childs = {}
                    PurchaseTabGroudConfig[v.GroupId] = d
                else
                    local groupOrder = PurchaseTabGroudConfig[v.GroupId].GroupOrder
                    if groupOrder > v.GroupOrder then
                        PurchaseTabGroudConfig[v.GroupId].GroupOrder = v.GroupOrder
                    end
                end
                table.insert(PurchaseTabGroudConfig[v.GroupId].Childs,v)
            end
            table.sort(PurchaseTabGroudConfig[v.GroupId].Childs, function(a,b)
                return a.GroupOrder < b.GroupOrder
            end)
        end
        table.sort(PurchaseTabGroudConfig, function(a,b)
            return a.GroupOrder < b.GroupOrder
        end)
    end
    return PurchaseTabGroudConfig
end

function XPurchaseConfigs.GetUiTypeGroupConfig()
    if not PurchaseUiTypeGroupConfig then
        PurchaseUiTypeGroupConfig = {}
        XPurchaseConfigs.GetGroupConfigType()
        for _,v in pairs(PurchaseUiTypeConfig) do
            if not PurchaseUiTypeGroupConfig[v.GroupType] then
                PurchaseUiTypeGroupConfig[v.GroupType]  = {}
            end

            table.insert(PurchaseUiTypeGroupConfig[v.GroupType], v)
        end
    end
end

-- 参数XPurchaseConfigs.TabsConfig,所有的uiype
function XPurchaseConfigs.GetUiTypesByTab(t)
    XPurchaseConfigs.GetUiTypeGroupConfig()
    return PurchaseUiTypeGroupConfig[t]
end

-- 充值的uitype
function XPurchaseConfigs.GetPayUiTypes()
    if not PurchasePayUiTypeConfig then
        PurchasePayUiTypeConfig = {}
        local cfg = XPurchaseConfigs.GetUiTypesByTab(XPurchaseConfigs.TabsConfig.Pay)
        for _,v in pairs(cfg)do
            PurchasePayUiTypeConfig[v.UiType] = v.UiType
        end
    end

    return PurchasePayUiTypeConfig
end

-- 礼包的uitype的list
function XPurchaseConfigs.GetLBUiTypesList()
    if not PurchaseLBUiTypeListConfig then
        PurchaseLBUiTypeListConfig = {}
        local cfg = XPurchaseConfigs.GetUiTypesByTab(XPurchaseConfigs.TabsConfig.LB)
        for _,v in pairs(cfg)do
            table.insert(PurchaseLBUiTypeListConfig,v.UiType)
        end
    end

    return PurchaseLBUiTypeListConfig
end

-- 礼包的uitype的Dic
function XPurchaseConfigs.GetLBUiTypesDic()
    if not PurchaseLBUiTypeDicConfig then
        PurchaseLBUiTypeDicConfig = {}
        local cfg = XPurchaseConfigs.GetUiTypesByTab(XPurchaseConfigs.TabsConfig.LB)
        for _,v in pairs(cfg)do
            table.insert(PurchaseLBUiTypeDicConfig,v.UiType)
        end
    end

    return PurchaseLBUiTypeDicConfig
end

-- 月卡的uitype
function XPurchaseConfigs.GetYKUiTypes()
    if not PurchaseYKUiTypeConfig then
        PurchaseYKUiTypeConfig = {}
        local cfg = XPurchaseConfigs.GetUiTypesByTab(XPurchaseConfigs.TabsConfig.YK)
        for _,v in pairs(cfg)do
            table.insert(PurchaseYKUiTypeConfig,v.UiType)
        end
    end

    return PurchaseYKUiTypeConfig
end

-- 黑卡的uitype
function XPurchaseConfigs.GetHKUiTypes()
    if not PurchaseHKUiTypeConfig then
        PurchaseHKUiTypeConfig = {}
        local cfg = XPurchaseConfigs.GetUiTypesByTab(XPurchaseConfigs.TabsConfig.HK)
        for _,v in pairs(cfg)do
            table.insert(PurchaseHKUiTypeConfig,v.UiType)
        end
    end

    return PurchaseHKUiTypeConfig
end

function XPurchaseConfigs.GetTabControlUiTypeConfig()
    if not PurchaseTabByUiTypeConfig then
        PurchaseTabByUiTypeConfig = {}
        for _,v in pairs(PurchaseTabControlConfig)do
            PurchaseTabByUiTypeConfig[v.UiType] = v
        end
    end

    return PurchaseTabByUiTypeConfig
end

function XPurchaseConfigs.GetUiTypeConfigByType(uitype)
    return PurchaseUiTypeConfig[uitype]
end

function XPurchaseConfigs.GetTagDes(tag)
    if not PurchaseTagTypeConfig[tag] then
        return ""
    end
    return PurchaseTagTypeConfig[tag].Des
end

function XPurchaseConfigs.GetTagBgPath(tag)
    if not PurchaseTagTypeConfig[tag] then
        return nil
    end
    return PurchaseTagTypeConfig[tag].Style
end

function XPurchaseConfigs.GetTagEffectPath(tag)
    if not PurchaseTagTypeConfig[tag] then
        return nil
    end
    return PurchaseTagTypeConfig[tag].Effect
end

function XPurchaseConfigs.GetAccumlatePayConfigById(id)
    if not id or not AccumulatedPayConfig[id] then
        return
    end

    return AccumulatedPayConfig[id]
end

function XPurchaseConfigs.GetAccumlateRewardCofigById(id)
    if not id or not AccumulatedPayRewardConfig[id] then
        return
    end

    return AccumulatedPayRewardConfig[id]
end