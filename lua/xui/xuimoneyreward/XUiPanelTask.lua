XUiPanelTask = XClass()

function XUiPanelTask:Ctor(ui, parent, index)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self.Index = index
    self.GridList = {}
    XTool.InitUiObject(self)
    self:InitAutoScript()
    self.GridCommon.gameObject:SetActive(false)
end

function XUiPanelTask:SetupContent(taskData)
    self.PanelNone.gameObject:SetActive(false)
    self.PanelDone.gameObject:SetActive(false)
    self.PanelTask.gameObject:SetActive(false)

    self.BountyTask = taskData

    if self.BountyTask ~= nil then
        self:SetupTask()
    else
        self.PanelNone.gameObject:SetActive(true)
    end
end

--设置任务数据
function XUiPanelTask:SetupTask()
    if not self.BountyTask then
        return
    end

    self.BtnGet.gameObject:SetActive(false)
    self.BtnGo.gameObject:SetActive(false)
    self.PanelTask.gameObject:SetActive(true)

    --根据状态显示按钮状态
    if self.BountyTask.Status == XDataCenter.BountyTaskManager.BountyTaskStatus.AcceptReward then
        self.PanelDone.gameObject:SetActive(true)
    elseif self.BountyTask.Status == XDataCenter.BountyTaskManager.BountyTaskStatus.Complete then
        self.BtnGet.gameObject:SetActive(true)
    else
        self.BtnGo.gameObject:SetActive(true)
    end

    local taskConfig = XDataCenter.BountyTaskManager.GetBountyTaskConfig(self.BountyTask.Id)
    if not taskConfig then
        XLog:Error("Error:BountyTask not exist!!! Id : %s", self.BountyTask.Id)
        return
    end

    self.DifficultStageCfg = XDataCenter.BountyTaskManager.GetBountyTaskDifficultStageConfig(self.BountyTask.DifficultStageId)

    self.TxtLevel.text = self.DifficultStageCfg.Name
    --self.Parent:SetUiSprite(self.ImgPic, taskConfig.RoleIcon)
    self.RImgPic:SetRawImage(taskConfig.RoleIcon)
    self.Parent:SetUiSprite(self.ImgQuality, taskConfig.DifficultLevelIcon, function()
        self.ImgQuality:SetNativeSize()
    end)

    self:SetupReward(self.BountyTask.RewardId)
end

--设置奖励
function XUiPanelTask:SetupReward(rewardId)

    local rewards = XRewardManager.GetRewardList(rewardId)

    if not rewards then
        return
    end

    --显示的奖励
    local start = 0
    if rewards then
        for i, item in ipairs(rewards) do
            start = i
            local grid = nil
            if self.GridList[i] then
                grid = self.GridList[i]
            else
                local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon)
                grid = XUiGridCommon.New(self.Parent, ui)
                grid.Transform:SetParent(self.PanelReward, false)
                self.GridList[i] = grid
            end
            grid:Refresh(item)
            grid.GameObject:SetActive(true)
        end
    end

    for j = start + 1, #self.GridList do
        self.GridList[j].GameObject:SetActive(false)
    end
end


-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelTask:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelTask:AutoInitUi()
    -- self.PanelDone = self.Transform:Find("PanelDone")
    -- self.ImgDone = self.Transform:Find("PanelDone/ImgDone"):GetComponent("Image")
    -- self.PanelTask = self.Transform:Find("PanelTask")
    -- self.PanelHead = self.Transform:Find("PanelTask/PanelHead")
    -- self.RImgPic = self.Transform:Find("PanelTask/PanelHead/RImgPic"):GetComponent("RawImage")
    -- self.ImgQuality = self.Transform:Find("PanelTask/PanelHead/ImgQuality"):GetComponent("Image")
    -- self.BtnClick = self.Transform:Find("PanelTask/PanelHead/BtnClick"):GetComponent("Button")
    -- self.PanelReward = self.Transform:Find("PanelTask/PanelReward")
    -- self.GridCommon = self.Transform:Find("PanelTask/PanelReward/GridCommon")
    -- self.BtnGo = self.Transform:Find("PanelTask/BtnGo"):GetComponent("Button")
    -- self.BtnGet = self.Transform:Find("PanelTask/BtnGet"):GetComponent("Button")
    -- self.TxtLevel = self.Transform:Find("PanelTask/TxtLevel"):GetComponent("Text")
    -- self.PanelNone = self.Transform:Find("PanelNone")
    -- self.BtnSelectedTask = self.Transform:Find("PanelNone/BtnSelectedTask"):GetComponent("Button")
end

function XUiPanelTask:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelTask:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelTask:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelTask:AutoAddListener()
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
    self:RegisterClickEvent(self.BtnGo, self.OnBtnGoClick)
    self:RegisterClickEvent(self.BtnGet, self.OnBtnGetClick)
    self:RegisterClickEvent(self.BtnSelectedTask, self.OnBtnSelectedTaskClick)
end
-- auto

function XUiPanelTask:OnBtnClickAClick(eventData)

end
function XUiPanelTask:OnBtnSelectedTaskClick(...)
    XDataCenter.BountyTaskManager.SetSelectIndex(self.Index)
    --CS.XUiManager.ViewManager:Push("UiMoneyRewardTask", false, false)
    XLuaUiManager.Open("UiMoneyRewardTask")
end

function XUiPanelTask:OnBtnClickClick(...)
    --CS.XUiManager.ViewManager:Push("UiMoneyRewardTaskCardTip", true, false, self.BountyTask, self.Parent)
    XLuaUiManager.Open("UiMoneyRewardTaskCardTip", self.BountyTask, self.Parent)
end

--跳转
function XUiPanelTask:OnBtnGoClick(...)
    if not self.DifficultStageCfg then
        return
    end

    local skipId = self.DifficultStageCfg.SkipId
    XFunctionManager.SkipInterface(skipId)
end

function XUiPanelTask:OnBtnGetClick(...)
    if not self.BountyTask or self.BountyTask.Status ~= XDataCenter.BountyTaskManager.BountyTaskStatus.Complete then
        return
    end

    XDataCenter.BountyTaskManager.AcceptBountyTaskReward(self.BountyTask.Id)
end

return XUiPanelTask