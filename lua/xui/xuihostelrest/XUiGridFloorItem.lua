XUiGridFloorItem = XClass()

function XUiGridFloorItem:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.Floor = 0
    self.Select = false
    self.CallBack = nil
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridFloorItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridFloorItem:AutoInitUi()
    self.BtnFloor = self.Transform:Find("BtnFloor"):GetComponent("Button")
    self.TxtFloor = self.Transform:Find("BtnFloor/TxtFloor"):GetComponent("Text")
    self.PanelLock = self.Transform:Find("PanelLock")
    self.BtnLock = self.Transform:Find("PanelLock/BtnLock"):GetComponent("Button")
end

function XUiGridFloorItem:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridFloorItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridFloorItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridFloorItem:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnFloor, "onClick", self.OnBtnFloorClick)
    self:RegisterListener(self.BtnLock, "onClick", self.OnBtnLockClick)
end
-- auto

function XUiGridFloorItem:SetData(data)
    self.GameObject:SetActive(true)
    self.Floor = data.Floor
    self.CallBack = data.CallBack
    self:RefreshItem()
end

function XUiGridFloorItem:RefreshItem()
    if not XDataCenter.HostelManager.IsHostelFloorOpen(self.Floor) then
        self.PanelLock.gameObject:SetActive(true)
        return
    end
    self.PanelLock.gameObject:SetActive(false)
    local config  = XDataCenter.HostelManager.GetHostelRestTemplate(self.Floor)
    if not config then return end
    self.TxtFloor.text = config.Name
end

function XUiGridFloorItem:SetSelect(value)
    self.Select = value
    if self.Select then
        self.BtnFloor.interactable = false
    else
        self.BtnFloor.interactable = true
    end
end

function XUiGridFloorItem:OnBtnLockClick(...)
    XUiManager.TipText("HostelFloorLock")
end

function XUiGridFloorItem:OnBtnFloorClick(...)
    if not XDataCenter.HostelManager.IsHostelFloorOpen(self.Floor) then
        return
    end
    self.CallBack(self.Floor)
end
