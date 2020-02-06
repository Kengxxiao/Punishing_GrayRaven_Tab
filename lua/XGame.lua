XGame = XGame or {}

local UI_LOGIN = "UiLogin"

XGame.Profiler = CS.XGame.Profiler:CreateChild("XGame")

XGame.Start1 = function()
    XGame.Profiler:Start()

    XConfigCenter.Init()
    --打点
    CS.XRecord.Record("23009", "LuaXGameStart")
    CS.XApplication.SetProgress(0.86)
end

XGame.Start2 = function()
    XLoginManager.Init()
    XDataCenter.Init()
    CS.XApplication.SetProgress(0.88)
end

XGame.Start3 = function()
    local playerProfiler = XGame.Profiler:CreateChild("XPlayerManager")
    playerProfiler:Start()
    XPlayerManager.Init()
    playerProfiler:Stop()

    local userProfiler = XGame.Profiler:CreateChild("XUserManager")
    userProfiler:Start()
    XUserManager.Init()
    userProfiler:Stop()

    local functionProfiler = XGame.Profiler:CreateChild("XFunctionManager")
    functionProfiler:Start()
    XFunctionManager.Init()
    functionProfiler:Stop()

    local resetProfiler = XGame.Profiler:CreateChild("XResetManager")
    resetProfiler:Start()
    XResetManager.Init()
    resetProfiler:Stop()
    CS.XApplication.SetProgress(0.89)
end

XGame.Start4 = function()
    XAttribManager.Init()
    CS.XApplication.SetProgress(0.95)
end

XGame.Start5 = function()
    local magicProfiler = XGame.Profiler:CreateChild("XMagicSkillManager")
    magicProfiler:Start()
    XMagicSkillManager.Init()
    magicProfiler:Stop()

    local fightCharacterProfiler = XGame.Profiler:CreateChild("XFightCharacterManager")
    fightCharacterProfiler:Start()
    XFightCharacterManager.Init()
    fightCharacterProfiler:Stop()

    local fightEquipProfiler = XGame.Profiler:CreateChild("XFightEquipManager")
    fightEquipProfiler:Start()
    XFightEquipManager.Init()
    fightEquipProfiler:Stop()

    local modelProfiler = XGame.Profiler:CreateChild("XModelManager")
    modelProfiler:Start()
    XModelManager.Init()
    modelProfiler:Stop()

    local conditionProfiler = XGame.Profiler:CreateChild("XConditionManager")
    conditionProfiler:Start()
    XConditionManager.Init()
    conditionProfiler:Stop()

    local newRoleShowProfiler = XGame.Profiler:CreateChild("XNewRoleShowManager")
    newRoleShowProfiler:Start()
    XNewRoleShowManager.Init()
    newRoleShowProfiler:Stop()

    local rewardProfiler = XGame.Profiler:CreateChild("XRewardManager")
    rewardProfiler:Start()
    XRewardManager.Init()
    rewardProfiler:Stop()

    local roomSingleProfiler = XGame.Profiler:CreateChild("XRoomSingleManager")
    roomSingleProfiler:Start()
    XRoomSingleManager.Init()
    roomSingleProfiler:Stop()

    local robotProfiler = XGame.Profiler:CreateChild("XRobotManager")
    robotProfiler:Start()
    XRobotManager.Init()
    robotProfiler:Stop()

    local tipProfiler = XGame.Profiler:CreateChild("XTipManager")
    tipProfiler:Start()
    XTipManager.Init()
    tipProfiler:Stop()

    local redPointProfiler = XGame.Profiler:CreateChild("XRedPointManager")
    redPointProfiler:Start()
    XRedPointManager.Init()
    redPointProfiler:Stop()

    local hudProfiler = XGame.Profiler:CreateChild("XHudManager")
    hudProfiler:Start()
    XHudManager.Init()
    hudProfiler:Stop()

    CS.XApplication.SetProgress(1, true)
end

XGame.Start6 = function()
    local serverProfiler = XGame.Profiler:CreateChild("XServerManager")
    serverProfiler:Start()
    XServerManager.Init(function()
        CsXUiManager.Instance:PopAllThenOpen(UI_LOGIN)
    end)
    serverProfiler:Stop()
    XGame.Profiler:Stop()
    --打点
    CS.XRecord.Record("23014", "LuaXGameStartFinish")
end

XGame.OnGMInit = function()
    XGmTestManager.Init()
end

if CS.UnityEngine.Application.platform == CS.UnityEngine.RuntimePlatform.WindowsEditor then
    local timer
    local breakSocketHandle, debugXpCall = require("XDebug/LuaDebug")("localhost", 7003)
    timer = CS.XScheduleManager.ScheduleForever(function(...)
        breakSocketHandle()
    end, 0)
end