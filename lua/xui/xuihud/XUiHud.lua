local XUiGridCoolTime = require("XUi/XUiHud/XUiGridCoolTime")
local XUiGridDeviceState = require("XUi/XUiHud/XUiGridDeviceState")
local XUiGridWorkSlotState = require("XUi/XUiHud/XUiGridWorkSlotState")
local XUiGridRoomUpgrade = require("XUi/XUiHud/XUiGridRoomUpgrade")

local HudInstId = 1

local XUiHud = XLuaUiManager.Register(XLuaUi, "UiHud")

function XUiHud:OnAwake()
    
end

function XUiHud:OnStart()
    self:InitAutoScript()

    self:InitHudPool()
    XHudManager.AddHudFunc(function(hudType)
        return self:GetHudFromPool(hudType)
    end,
            function(hud)
                self:ReturnHudToPool(hud)
            end)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiHud:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHud:AutoInitUi()
    self.PanelCoolTime = self.Transform:Find("FullScreenBackground/PanelCoolTime")
    self.GridCoolTime = self.Transform:Find("FullScreenBackground/PanelCoolTime/GridCoolTime")
    self.PanelDeviceState = self.Transform:Find("FullScreenBackground/PanelDeviceState")
    self.GridDeviceState = self.Transform:Find("FullScreenBackground/PanelDeviceState/GridDeviceState")
    self.PanelWorkSlotState = self.Transform:Find("FullScreenBackground/PanelWorkSlotState")
    self.GridWorkSlotState = self.Transform:Find("FullScreenBackground/PanelWorkSlotState/GridWorkSlotState")
    self.PanelRoomUpgrade = self.Transform:Find("FullScreenBackground/PanelRoomUpgrade")
    self.GridRoomUpgrade = self.Transform:Find("FullScreenBackground/PanelRoomUpgrade/GridRoomUpgrade")
end

function XUiHud:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiHud:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiHud:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHud:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto

function XUiHud:HideTemplateGrids()
    for _, config in pairs(self.HudConfig) do
        config.go.gameObject:SetActive(false)
    end
end

-- Init Hud Pool
function XUiHud:InitHudPool()
    -- generate config
    self.HudConfig = {
        [UiHudType.CoolTime] = { root = self.PanelCoolTime, go = self.GridCoolTime, luaCtor = XUiGridCoolTime.New },
        [UiHudType.DeviceState] = { root = self.PanelDeviceState, go = self.GridDeviceState, luaCtor = XUiGridDeviceState.New },
        [UiHudType.WorkSlotState] = { root = self.PanelWorkSlotState, go = self.GridWorkSlotState, luaCtor = XUiGridWorkSlotState.New },
        [UiHudType.RoomUpgrade] = { root = self.PanelRoomUpgrade, go = self.GridRoomUpgrade, luaCtor = XUiGridRoomUpgrade.New },
    }

    self:HideTemplateGrids()

    HudInstId = 1

    -- init pool
    self.Pool = {}
    for i, v in pairs(self.HudConfig) do
        self.Pool[i] = {}
    end
end

-- Get the type of HUD from the pool
function XUiHud:GetHudFromPool(hudType)
    local hud = nil
    local pool = self.Pool[hudType]

    if pool then
        for _, v in pairs(pool) do
            hud = v
            break
        end
        if hud then
            pool[hud] = nil
        end
    end

    if not hud then
        local config = self.HudConfig[hudType]

        local go = CS.UnityEngine.Object.Instantiate(config.go)
        go.transform:SetParent(config.root, false)

        hud = config.luaCtor(self, go, hudType)
    end

    hud.InstId = HudInstId
    HudInstId = HudInstId + 1

    XHudManager.AddDisplayHud(hud.InstId, hud)

    return hud
end

-- Return the HUD to the pool
function XUiHud:ReturnHudToPool(hud)
    if hud and hud.HudType then
        XHudManager.RemoveDisplayHud(hud.InstId)
        hud.InstId = 0
        local pool = self.Pool[hud.HudType]
        if pool then
            pool[hud] = hud
        end
    end
end