XPayConfigs = XPayConfigs or {}

local TABLE_PAY_PATH = "Share/Pay/Pay.tab"
local TABLE_FIRST_PAY_PATH = "Share/Pay/FirstPayReward.tab"

local PayTemplates = {}
local FirstPayTemplates = {}
local PayListDataConfig = nil

function XPayConfigs.Init()
    PayTemplates = XTableManager.ReadByStringKey(TABLE_PAY_PATH, XTable.XTablePay, "Key")
    FirstPayTemplates = XTableManager.ReadByIntKey(TABLE_FIRST_PAY_PATH, XTable.XTableFirstPayReward, "NeedPayMoney")
end

function XPayConfigs.GetPayTemplate(key)
    local template = PayTemplates[key]
    if not template then
        XLog.Error("XPayConfigs.GetPayTemplate error: can not found template, key is " .. key)
        return
    end

    return template
end

function XPayConfigs.GetPayConfig()
    if not PayListDataConfig then
        PayListDataConfig = {}
        for _,v in pairs(PayTemplates)do
            if v then
                table.insert(PayListDataConfig,v)
            end
        end
    end
    return PayListDataConfig
end

function XPayConfigs.CheckFirstPay(totalPayMoney)
    for k, v in pairs(FirstPayTemplates) do
        return totalPayMoney >= v.NeedPayMoney
    end
end

function XPayConfigs.GetSmallRewards()
    for k, v in pairs(FirstPayTemplates) do
        return v.SmallRewardId
    end
end

function XPayConfigs.GetBigRewards()
    for k, v in pairs(FirstPayTemplates) do
        return v.BigRewardId
    end
end