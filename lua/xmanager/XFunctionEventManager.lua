XFunctionEventManagerCreator = function()


    local FunctionEvenState =    {
        IDLE = 1,
        PLAYING = 2,
        LOCK = 3
    }

    local XFunctionEventManager = {}
    local FunctionState = FunctionEvenState.IDLE

    function XFunctionEventManager.Init()

        XEventManager.AddEventListener(XEventId.EVENT_LOGIN_SUCCESS, function()
            XEventManager.AddEventListener(XEventId.EVENT_PLAYER_LEVEL_CHANGE, XFunctionEventManager.HandlerPlayerLevelChange)
            XEventManager.AddEventListener(XEventId.EVENT_FIGHT_RESULT_WIN, XFunctionEventManager.HandlerFightResult)
            XEventManager.AddEventListener(XEventId.EVENT_FUNCTION_EVENT_START, XFunctionEventManager.OnFunctionEventStart)
            XEventManager.AddEventListener(XEventId.EVENT_MEDAL_TIPSOVER, XFunctionEventManager.OnMedalTipsCompleteted)
            XEventManager.AddEventListener(XEventId.EVENT_FUNCTION_EVENT_COMPLETE, XFunctionEventManager.OnFunctionEventCompleteted)
            XEventManager.AddEventListener(XEventId.EVENT_PLAYER_LEVEL_UP_ANIMATION_END, XFunctionEventManager.OnLevelUpAnimationEnd)
            XEventManager.AddEventListener(XEventId.EVENT_TASKFORCE_TIP_MISSION_END, XFunctionEventManager.OnTipMissionEnd)
            XEventManager.AddEventListener(XEventId.EVENT_AUTO_WINDOW_STOP, XFunctionEventManager.OnFunctionEventBreak)
            XEventManager.AddEventListener(XEventId.EVENT_MAINUI_ENABLE, XFunctionEventManager.OnFunctionEventValueChange)
            XEventManager.AddEventListener(XEventId.EVENT_ARENA_RESULT_CLOSE, XFunctionEventManager.UnLockFunctionEvent)

            local FunctionState = FunctionEvenState.IDLE
        end)
    end

    --处理战斗结算
    function XFunctionEventManager.HandlerFightResult(evt)
        XFunctionEventManager.OnFunctionEventValueChange()
    end

    --处理等级提升
    function XFunctionEventManager.HandlerPlayerLevelChange()
        XFunctionEventManager.OnFunctionEventValueChange()
    end

    function XFunctionEventManager.OnFunctionEventValueChange()
        --第一次进入主界面并播放完成首次进入动画后在响应对应的方法
        if not XLoginManager.IsStartGuide() then
            return
        end

        XDataCenter.CommunicationManager.SetCommunication()
        XFunctionManager.CheckOpen()

        if FunctionState ~= FunctionEvenState.IDLE then
            return
        end
        if XPlayer.HandlerPlayLevelUpAnimation() then --玩家等级提升
            FunctionState = FunctionEvenState.PLAYING
        elseif XDataCenter.FubenManager.CheakHasNewHideStage() then --隐藏关卡开启
            FunctionState = FunctionEvenState.PLAYING
        elseif XDataCenter.TaskForceManager.HandlerPlayTipMission() then --任务提示
            FunctionState = FunctionEvenState.PLAYING
        elseif XDataCenter.ArenaManager.CheckOpenArenaActivityResult() then -- 竞技结算
            FunctionState = FunctionEvenState.PLAYING
        elseif XDataCenter.MedalManager.ShowUnlockTips() then --勋章飘窗
            FunctionState = FunctionEvenState.PLAYING
        elseif XDataCenter.CommunicationManager.ShowNextCommunication(XDataCenter.CommunicationManager.Type.Medal) then --勋章通讯
            FunctionState = FunctionEvenState.PLAYING
        elseif XDataCenter.CommunicationManager.ShowNextCommunication(XDataCenter.CommunicationManager.Type.Normal) then --通常通讯
            FunctionState = FunctionEvenState.PLAYING
        elseif XFunctionManager.ShowOpenHint() then --系统开放
            FunctionState = FunctionEvenState.PLAYING
        elseif XDataCenter.GuideManager.CheckGuideOpen() then -- 引导
            FunctionState = FunctionEvenState.PLAYING
        elseif XDataCenter.AutoWindowManager.CheckAutoWindow() then -- 打脸
            FunctionState = FunctionEvenState.PLAYING
        end 

        if FunctionState ~= FunctionEvenState.PLAYING then
            XEventManager.DispatchEvent(XEventId.EVENT_FUNCTION_EVENT_END)
        end
    end

    --开始
    function XFunctionEventManager.OnFunctionEventStart()
        FunctionState = FunctionEvenState.PLAYING
    end

    --完成
    function XFunctionEventManager.OnFunctionEventCompleteted()
        FunctionState = FunctionEvenState.IDLE
        XFunctionEventManager.OnFunctionEventValueChange()
    end
    
    --飘窗结束
    function XFunctionEventManager.OnMedalTipsCompleteted()
        FunctionState = FunctionEvenState.IDLE
        XFunctionEventManager.OnFunctionEventValueChange()
    end

    -- 打脸中断
    function XFunctionEventManager.OnFunctionEventBreak()
        FunctionState = FunctionEvenState.IDLE
    end

    --完成
    function XFunctionEventManager.OnLevelUpAnimationEnd()
        FunctionState = FunctionEvenState.IDLE
        XFunctionEventManager.OnFunctionEventValueChange()
    end

    -- 派遣队伍提升
    function XFunctionEventManager.OnTipMissionEnd()
        FunctionState = FunctionEvenState.IDLE
        XFunctionEventManager.OnFunctionEventValueChange()
    end

    --锁
    function XFunctionEventManager.LockFunctionEvent()
        FunctionState = FunctionEvenState.LOCK
    end

    --解锁
    function XFunctionEventManager.UnLockFunctionEvent()
        FunctionState = FunctionEvenState.IDLE
        XFunctionEventManager.OnFunctionEventValueChange()
    end

    function XFunctionEventManager.IsPlaying()
        return FunctionState == FunctionEvenState.PLAYING
    end

    XFunctionEventManager.Init()
    return XFunctionEventManager
end