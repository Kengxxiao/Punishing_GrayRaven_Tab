local XUiOnLineLoading = XLuaUiManager.Register(XLuaUi, "UiOnLineLoading")

function XUiOnLineLoading:OnAwake()
    self:InitAutoScript()
    self.XUiPanelOnLineLoadingDetail = XUiPanelOnLineLoadingDetail.New(self.PanelOnLineLoadingDetail, self)
end

function XUiOnLineLoading:OnStart()
    XEventManager.AddEventListener(XEventId.EVENT_FIGHT_PROGRESS, self.RefreshLoadProcess, self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiOnLineLoading:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiOnLineLoading:AutoInitUi()
    self.PanelOnLineLoadingDetail = self.Transform:Find("SafeAreaContentPane/PanelOnLineLoadingDetail")
    self.TxtTips = self.Transform:Find("SafeAreaContentPane/TxtTips"):GetComponent("Text")
end

function XUiOnLineLoading:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiOnLineLoading:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiOnLineLoading:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiOnLineLoading:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
function XUiOnLineLoading:SetActive(actived)
    if self.GameObject then
        self.GameObject.gameObject:SetActive(actived)
    end
end

function XUiOnLineLoading:Refresh()
    self.XUiPanelOnLineLoadingDetail:Refresh()
    self:SetActive(true)
end

function XUiOnLineLoading:RefreshLoadProcess(playerId, progress)--更新玩家进度
    self.XUiPanelOnLineLoadingDetail:RefreshLoadProcess(playerId, progress)
end

function XUiOnLineLoading:OnDestroy(...)
    XEventManager.RemoveEventListener(XEventId.EVENT_FIGHT_PROGRESS, self.RefreshLoadProcess, self)
end

return XUiOnLineLoading