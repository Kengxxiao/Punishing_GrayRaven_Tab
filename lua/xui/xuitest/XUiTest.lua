local XUiTest = XUiManager.Register("UiTest")

function XUiTest:OnOpen()
    self:InitAutoScript()
    self:Test()
end

function XUiTest:Test()
    local count = 10
    local baseItem = self.GridItem
    baseItem.gameObject:SetActive(false)
    
    local scrollItems = {}
    for i = 1, count do
        local item = CS.UnityEngine.Object.Instantiate(baseItem)
        table.insert(scrollItems, XScrollFlowGrid.New(item, i))
    end

    XScrollFlow.New(self.PanelScorll, scrollItems, {selectIndex = 1, moveEndCb = function(item) XLog.Debug(item.Index) end, direction = XScrollConfig.VERTICAL, offsetValue = 0.2, animSpeed = 2.0, isLoop = true})
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiTest:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiTest:AutoInitUi()
    self.PanelScorll = self.Transform:Find("PanelScorll")
    self.GridItem = self.Transform:Find("PanelScorll/GridItem")
    self.TxtId = self.Transform:Find("PanelScorll/GridItem/TxtId"):GetComponent("Text")
end

function XUiTest:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiTest:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiTest:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiTest:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
