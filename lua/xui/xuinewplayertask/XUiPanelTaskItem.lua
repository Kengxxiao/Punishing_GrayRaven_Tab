XUiPanelTaskItem = XClass()

function XUiPanelTaskItem:Ctor(ui, index, funcCallback)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.TaskId = 0
    self.Index = index
    self.Selected = false
    self.FunctionCallBack = funcCallback
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelTaskItem:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelTaskItem:AutoInitUi()
    self.BtnClick = self.Transform:Find("BtnClick"):GetComponent("Button")
    self.ImgNormal = self.Transform:Find("ImgNormal").gameObject
    self.ImgCompleted = self.Transform:Find("ImgCompleted").gameObject
    self.ImgSelected = self.Transform:Find("ImgSelected").gameObject
    self.TxtTitle = self.Transform:Find("TxtTitle"):GetComponent("Text")
    self.ImgRedPoint = self.Transform:Find("ImgRedPoint").gameObject
end

function XUiPanelTaskItem:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelTaskItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelTaskItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelTaskItem:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnClick, "onClick", self.OnBtnClickClick)
end
-- auto
function XUiPanelTaskItem:OnBtnClickClick(...)
    self.FunctionCallBack(self.Index)
end

function XUiPanelTaskItem:SetSelect(bValue)
    self.Selected = bValue
    self:UpdateTitle()
    self:UpdateView()
end

function XUiPanelTaskItem:UpdateTaskState()
    self.State = XDataCenter.TaskManager.GetTaskDataById(self.TaskId).State
end

function XUiPanelTaskItem:SetData(taskId, funcCallback)
    self.TaskId = taskId
    self.GameObject.name = "XUiPanelTaskItem" .. taskId

    self:UpdateTitle()
    self:UpdateTaskState()
    self:UpdateView()
end

function XUiPanelTaskItem:UpdateTitle()
    local title = XDataCenter.TaskManager.GetTaskTemplate(self.TaskId).Title
    if self.Selected then
        self.TxtTitle.text = "<color=#ffffffff>" .. title .. "</color>"
    else
        self.TxtTitle.text = "<color=#000000ff>" .. title .. "</color>"
    end
end

function XUiPanelTaskItem:UpdateView()
    self.ImgSelected:SetActive(self.Selected)
    self.ImgNormal:SetActive(not self.Selected and self.State < XDataCenter.TaskManager.TaskState.Finish)
    self.ImgCompleted:SetActive(not self.Selected and self.State == XDataCenter.TaskManager.TaskState.Finish)
    self.ImgRedPoint:SetActive(self.State == XDataCenter.TaskManager.TaskState.Achieved)
end

function XUiPanelTaskItem:SetActive(bValue)
    self.GameObject:SetActive(bValue)
end