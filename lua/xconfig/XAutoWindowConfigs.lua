XAutoWindowConfigs = XAutoWindowConfigs or {}

XAutoWindowConfigs.AutoType = {
    EachTime  = 1,     -- 每次登陆弹出
    EachDay   = 2,     -- 每天登陆弹出
    EachWeek  = 3,     -- 每周登陆弹出
    EachMonth = 4,     -- 每月登陆弹出
    Period    = 5,     -- 周期内弹出
}

XAutoWindowConfigs.AutoFuncitonType = {
    AutoWindowView  = 1,     -- 自动弹出公告
    Sign            = 2,     -- 签到
    FirstRecharge   = 3,     -- 首充
    Card            = 4,     -- 月卡
}

local TABLE_AUTO_WINDOW_VIEW       = "Client/AutoWindow/AutoWindowView.tab"
local TABLE_AUTO_WINDOW_CONTROLLER = "Client/AutoWindow/AutoWindowController.tab"

local AutoWindowViewConfig = {}         -- 自动弹窗公告配置表
local AutoWindowControllerConfig = {}   -- 自动弹窗控制配置表

function XAutoWindowConfigs.Init()
    AutoWindowViewConfig = XTableManager.ReadByIntKey(TABLE_AUTO_WINDOW_VIEW, XTable.XTableAutoWindowView, "Id")
    AutoWindowControllerConfig = XTableManager.ReadByIntKey(TABLE_AUTO_WINDOW_CONTROLLER, XTable.XTableAutoWindowController, "Id")
end

function XAutoWindowConfigs.GetAutoWindowConfig(id)
    local t = AutoWindowViewConfig[id]
    if not t then
        XLog.Error("XAutoWindowConfigs.GetAutoWindowConfig Error Config is nil, is " .. tostring(id))
        return nil
    end

    return t
end

function XAutoWindowConfigs.GetAutoWindowControllerConfig()
    return AutoWindowControllerConfig
end