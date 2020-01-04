-- 防沉迷系统
XAntiAddictionManagerCreator = function()
    local XAntiAddictionManager = {}

    local NeedToKickOff = false
    local KickMsg = nil

    local IsDrawingCard = false
    local IsPaying = false

    -- 踢下线
    local KickOffAction = function()
        if not NeedToKickOff then
            return
        end

        if KickMsg == nil or KickMsg == "" then
            -- 无消息踢人，直接退出
            XUserManager.Logout(function(result)
                if result then
                    CS.XHeroSdkAgent.NotifyKickResult(result)
                end
            end)
            return
        end

        -- 有消息，弹窗提醒
        XUiManager.SystemDialogTip(CS.XTextManager.GetText("TipTitle"), KickMsg, XUiManager.DialogType.OnlySure, nil, function()
            XUserManager.Logout(function(result)
                if result then
                    CS.XHeroSdkAgent.NotifyKickResult(result)
                end
            end)
        end)
    end

    -- 防沉迷踢人
    function XAntiAddictionManager.Kick(msg)
        NeedToKickOff = true
        KickMsg = msg

        if CS.XFight.Instance ~= nil then
            -- 战斗中
            return
        end

        if IsPaying then
            -- 充值中
            return
        end

        if IsDrawingCard then
            -- 抽卡中
            return
        end

        KickOffAction()
    end

    -- 开始抽卡行为
    function XAntiAddictionManager.BeginDrawCardAction()
        IsDrawingCard = true
    end

    -- 结束抽卡行为
    function XAntiAddictionManager.EndDrawCardAction()
        IsDrawingCard = false
        KickOffAction()
    end

    -- 开始充值行为
    function XAntiAddictionManager.BeginPayAction()
        IsPaying = true
    end

    -- 结束充值行为
    function XAntiAddictionManager.EndPayAction()
        IsPaying = false
        KickOffAction()
    end

    -- 结束战斗行为
    function XAntiAddictionManager.EndFightAction()
        KickOffAction()
    end

    return XAntiAddictionManager
end