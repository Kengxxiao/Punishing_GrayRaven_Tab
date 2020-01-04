XHudManager = XHudManager or {}

UiHudType = {
    CoolTime = 1,
    DeviceState = 2,
    WorkSlotState = 3,
    RoomUpgrade = 4,
}

local GetHudFunc = nil
local ReturnHudFunc = nil

local DisplayHudMap = {}

function XHudManager.Init()
    --local ret = CS.XUiManager.HudManager:Push("UiHud", false, false)

    local ret = XLuaUiManager.Open("UiHud")

    -- Test
    --CS.XTool.WaitCoroutine(ret, function()
    --    local hud = XHudManager.GetHud(UiHudType.CoolTime)
    --    hud:SetMetaData()
    --    hud:Hide()
    --end)
end

---------------------------------------------HUD Pool start-------------------------------------------
function XHudManager.AddHudFunc(getFunc, returnFunc)
    GetHudFunc = getFunc
    ReturnHudFunc = returnFunc
end

function XHudManager.RemoveHudFunc()
    GetHudFunc = nil
    ReturnHudFunc = nil
end

function XHudManager.GetHud(hudType)
    return GetHudFunc(hudType)
end

function XHudManager.ReturnHud(hud)
    ReturnHudFunc(hud)
end
---------------------------------------------HUD Pool end-------------------------------------------

---------------------------------------------显示中的HUD start-------------------------------------------
function XHudManager.AddDisplayHud(hudId, hud)
    DisplayHudMap[hudId] = hud
end

function XHudManager.RemoveDisplayHud(hudId)
    DisplayHudMap[hudId] = nil
end

function XHudManager.ClearDisplayHud()
    for _, hud in pairs(DisplayHudMap) do
        hud:Hide()
    end
    DisplayHudMap = {}
end

function XHudManager.GetDisplayHudMap()
    return DisplayHudMap
end

function XHudManager.GetDisplayHudByInstId(hudId)
    return DisplayHudMap[hudId]
end
---------------------------------------------显示中的HUD end-------------------------------------------