local XUiMissionAddSpeedTip = XLuaUiManager.Register(XLuaUi, "UiMissionAddSpeedTip")

function XUiMissionAddSpeedTip:OnAwake()
    self:InitAutoScript()
end

function XUiMissionAddSpeedTip:OnStart(taskData)
    self.TaskData = taskData
    self:SetupContent()
end

function XUiMissionAddSpeedTip:SetupContent()
    local costItemId = CS.XGame.Config:GetInt("TaskForceItemId")
    local elapseMinutes = CS.XGame.Config:GetInt("TaskForceElapseMinutes")

    local curTime = XTime.GetServerNowTimestamp()
    local completeTime = self.TaskData.Task.UtcFinishTime
    local min = math.ceil((completeTime - curTime) / 60)

    local costCount = math.ceil(min / elapseMinutes)
    local itemCount = XDataCenter.ItemManager.GetCount(costItemId)
    local icon = XDataCenter.ItemManager.GetItemIcon(costItemId)

    self.TxtCostCount.text = costCount
    self.TxtCount.text = itemCount
    self:SetUiSprite(self.ImgIcon, icon)

    self.ItemCount = itemCount
    self.CostCount = costCount
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiMissionAddSpeedTip:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiMissionAddSpeedTip:AutoInitUi()
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/PanelContent")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/PanelContent/TxtTitle"):GetComponent("Text")
    self.TxtCount = self.Transform:Find("SafeAreaContentPane/PanelContent/TxtCount"):GetComponent("Text")
    self.BtnSure = self.Transform:Find("SafeAreaContentPane/PanelContent/BtnSure"):GetComponent("Button")
    self.PanelCost = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelCost")
    self.ImgIcon = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelCost/ImgIcon"):GetComponent("Image")
    self.Txt = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelCost/Txt"):GetComponent("Text")
    self.TxtCostCount = self.Transform:Find("SafeAreaContentPane/PanelContent/PanelCost/TxtCostCount"):GetComponent("Text")
    self.BtnCancel = self.Transform:Find("SafeAreaContentPane/PanelContent/BtnCancel"):GetComponent("Button")
    self.BtnBg = self.Transform:Find("FullScreenBackground/BtnBg"):GetComponent("Button")
end

function XUiMissionAddSpeedTip:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiMissionAddSpeedTip:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiMissionAddSpeedTip:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiMissionAddSpeedTip:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnSure, self.OnBtnSureClick)
    self:RegisterClickEvent(self.BtnCancel, self.OnBtnCancelClick)
    self:RegisterClickEvent(self.BtnBg, self.OnBtnBgClick)
end
-- auto

function XUiMissionAddSpeedTip:OnBtnCancelClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end

function XUiMissionAddSpeedTip:OnBtnBgClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end

function XUiMissionAddSpeedTip:OnBtnSureClick(...)
    if self.ItemCount < self.CostCount then
        XUiManager.TipText("EquipLevelUpItemNotEnough")
        return
    end

    XDataCenter.TaskForceManager.TaskForceTaskFinishRequest(self.TaskData.Task.TaskId)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end
