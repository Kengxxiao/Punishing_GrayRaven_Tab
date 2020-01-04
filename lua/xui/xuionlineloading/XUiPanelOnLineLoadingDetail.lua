XUiPanelOnLineLoadingDetail = XClass()

function XUiPanelOnLineLoadingDetail:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self.ItemsPool = {}
    self.LeftItem = nil
    self.CenterItem = nil
    self.RightItem = nil
    self:Init()
end

function XUiPanelOnLineLoadingDetail:Init()
    self:InitializationView()
    self:InitData()
    self:SetActive(true)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelOnLineLoadingDetail:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelOnLineLoadingDetail:AutoInitUi()
    self.PanelOnLineLoadingDetailItem = self.Transform:Find("PanelOnLineLoadingDetailItem")
end

function XUiPanelOnLineLoadingDetail:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelOnLineLoadingDetail:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelOnLineLoadingDetail:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelOnLineLoadingDetail:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
function XUiPanelOnLineLoadingDetail:InitializationView(...)--初始化界面
    for i = 1, XDataCenter.RoomManager.IndexType.Max do
        local item = nil
        if i <= #self.ItemsPool then
            item = self.ItemsPool[i]
        else
            local go = i == 1 and self.PanelOnLineLoadingDetailItem.gameObject or CS.UnityEngine.GameObject.Instantiate(self.PanelOnLineLoadingDetailItem.gameObject)
            if go then
                go.transform:SetParent(self.PanelOnLineLoadingDetailItem.transform.parent, false)
            end
            item = XUiPanelOnLineLoadingDetailItem.New(go, self.RootUi, self)
            table.insert(self.ItemsPool, item)
        end
        if i == 1 then
            self.LeftItem = item
        elseif i == 2 then
            self.CenterItem = item
        elseif i == 3 then
            self.RightItem = item
        end
        item:Refresh(nil)
    end
end

function XUiPanelOnLineLoadingDetail:InitData(...)
    if XDataCenter.RoomManager.RoomData == nil then
        return
    end
    local left = false
    XTool.LoopCollection(XDataCenter.RoomManager.RoomData.PlayerDataList, function(data)
        if data.Id == XPlayer.Id then--自己
            self.CenterItem:Refresh(data)
        elseif not left then
            self.LeftItem:Refresh(data)
            left = true
        else
            self.RightItem:Refresh(data)
        end
    end)

end

function XUiPanelOnLineLoadingDetail:SetActive(actived)
    if self.GameObject then
        self.GameObject.gameObject:SetActive(actived)
    end
end

function XUiPanelOnLineLoadingDetail:RefreshLoadProcess(playerId, progress)--更新玩家进度
    for k, v in pairs(self.ItemsPool) do
        if v.Data ~= nil and v.Data.Id == playerId then
            v:UpdateProgress(progress)
        end
    end
end

function XUiPanelOnLineLoadingDetail:OnClose(...)
    -- body
end

return XUiPanelOnLineLoadingDetail