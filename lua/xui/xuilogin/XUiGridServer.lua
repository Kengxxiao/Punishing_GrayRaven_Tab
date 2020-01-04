XUiGridServer = XClass()

function XUiGridServer:Ctor(ui, server, cb)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.SelectCb = cb
    self:InitAutoScript()
    self:InitServerName(server.Name)
    self:UpdateServer(server)
end

function XUiGridServer:InitServerName(name)
    self.PanelMaintain:Find("TxtName"):GetComponent("Text").text = name
    self.PanelLow:Find("TxtName"):GetComponent("Text").text = name
    self.PanelHigh:Find("TxtName"):GetComponent("Text").text = name
end

function XUiGridServer:UpdateServer(server)
    self.Server = server
    self.PanelMaintain.gameObject:SetActive(false)
    self.PanelLow.gameObject:SetActive(false)
    self.PanelHigh.gameObject:SetActive(false)
    self:UpdateServerSelect()   

    if server.State == XServerManager.SERVER_STATE.MAINTAIN then
        self.PanelMaintain.gameObject:SetActive(true)
    elseif server.State == XServerManager.SERVER_STATE.LOW then
        self.PanelLow.gameObject:SetActive(true)
    elseif server.State == XServerManager.SERVER_STATE.GIGH then
        self.PanelHigh.gameObject:SetActive(true)
    else
        XLog.Error("XUiGridServer:UpdateServerState error: unknown state ui, server id is " .. server.Id .. ", state is " .. server.State)
    end

    -- self.PanelLow.gameObject:SetActive(true)
end

function XUiGridServer:UpdateServerSelect()
    self.ImgSelect.gameObject:SetActive(self.Server.Id == XServerManager.Id)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridServer:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridServer:AutoInitUi()
    self.BtnServer = self.Transform:Find("BtnServer"):GetComponent("Button")
    self.ImgSelect = self.Transform:Find("BtnServer/ImgSelect"):GetComponent("Image")
    self.PanelMaintain = self.Transform:Find("BtnServer/PanelMaintain")
    self.PanelLow = self.Transform:Find("BtnServer/PanelLow")
    self.PanelHigh = self.Transform:Find("BtnServer/PanelHigh")
end

function XUiGridServer:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridServer:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridServer:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridServer:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnServer, "onClick", self.OnBtnServerClick)
end
-- auto

function XUiGridServer:OnBtnServerClick(...)
    if self.SelectCb then
        self.SelectCb(self.Server.Id)
    end
end
