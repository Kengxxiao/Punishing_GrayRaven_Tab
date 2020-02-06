XUiGridTask = XClass()

local PANEL_REWARD_COUNT = 1
local SECTION_LEVEL = 5
function XUiGridTask:Ctor(rootUi, ui, data, parentCb)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.ParentCb = parentCb or function() end
    self.RewardPanelList = {}
    self:InitAutoScript()
    self.GridCommon.gameObject:SetActive(false)
    self.ImgComplete.gameObject:SetActive(false)
    self:ResetData(data)
    self.PanelAnimation.gameObject:SetActive(true)
end

function XUiGridTask:ResetData(data)
    if not self.GameObject:Exist() then
        return
    end

    local temp = XDataCenter.TaskManager.GetTaskTemplate(data.Id)
    self.ImgComplete.gameObject:SetActive(temp.Type == XDataCenter.TaskManager.TaskType.Achievement and data.State == XDataCenter.TaskManager.TaskState.Finish)
    self.Data = data
    local config = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id)
    self.tableData = config
    self.TxtTaskName.text = config.Title
    self.TxtTaskDescribe.text = config.Desc
    self.TxtSubTypeTip.text = config.Suffix or ""
    self.RootUi:SetUiSprite(self.ImgTaskType, config.Icon)

    self:UpdateProgress(self.Data)

    local rewards = XRewardManager.GetRewardList(config.RewardId)
    -- reset reward panel
    for i = 1, #self.RewardPanelList do
        self.RewardPanelList[i]:Refresh()
    end

    if not rewards then
        return
    end

    if not rewards then
        return
    end

    for i = 1, #rewards do
        local panel = self.RewardPanelList[i]
        if not panel then
            if #self.RewardPanelList == 0 then
                panel = XUiGridCommon.New(self.RootUi, self.GridCommon)
            else
                local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon)
                ui.transform:SetParent(self.GridCommon.parent, false)
                panel = XUiGridCommon.New(self.RootUi, ui)
            end
            table.insert(self.RewardPanelList, panel)
        end

        panel:Refresh(rewards[i])
    end

end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridTask:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiGridTask:AutoInitUi()
    self.PanelAnimation = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation", nil)
    self.ImgTaskType = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/ImgTaskType", "Image")
    self.ImgProgress = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/ProgressBg/ImgProgress", "Image")
    self.GridCommon = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/TaskGridList/Viewport/Content/GridCommon", nil)
    self.ImgIcon = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/TaskGridList/Viewport/Content/GridCommon/ImgIcon", "Image")
    self.ImgQuality = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/TaskGridList/Viewport/Content/GridCommon/ImgQuality", "Image")
    self.BtnClick = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/TaskGridList/Viewport/Content/GridCommon/BtnClick", "Button")
    self.TxtCount = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/TaskGridList/Viewport/Content/GridCommon/TxtCount", "Text")
    self.BtnFinish = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/BtnFinish", "Button")
    self.BtnSkip = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/BtnSkip", "Button")
    self.TxtTaskName = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/TxtTaskName", "Text")
    self.TxtTaskDescribe = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/TxtTaskDescribe", "Text")
    self.TxtTaskNumQian = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/TxtTaskNumQian", "Text")
    self.TxtSubTypeTip = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/TxtSubTypeTip", "Text")
    self.ImgComplete = XUiHelper.TryGetComponent(self.Transform, "PanelAnimation/ImgComplete", "Image")
end

function XUiGridTask:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiGridTask:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiGridTask:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridTask:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self,self.BtnClick, self.OnBtnClickClick)
    XUiHelper.RegisterClickEvent(self,self.BtnFinish, self.OnBtnFinishClick)
    XUiHelper.RegisterClickEvent(self ,self.BtnSkip, self.OnBtnSkipClick)
end
-- auto
function XUiGridTask:OnBtnClickClick(...)

end


function XUiGridTask:OnBtnFinishClick(...)
    local taskInfo = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id)
    local weaponCount = 0
    local chipCount = 0
    for i = 1, #self.RewardPanelList do
        local rewardsId = self.RewardPanelList[i].TemplateId
        if XDataCenter.EquipManager.IsClassifyEqualByTemplateId(rewardsId, XEquipConfig.Classify.Weapon) then
            weaponCount = weaponCount + 1
        elseif XDataCenter.EquipManager.IsClassifyEqualByTemplateId(rewardsId, XEquipConfig.Classify.Awareness) then
            chipCount = chipCount + 1
        end
    end
    if weaponCount > 0 and XDataCenter.EquipManager.CheckBagCount(weaponCount, XEquipConfig.Classify.Weapon) == false or
    chipCount > 0 and XDataCenter.EquipManager.CheckBagCount(chipCount, XEquipConfig.Classify.Awareness) == false then
        return
    end
    XDataCenter.TaskManager.FinishTask(self.Data.Id, function(rewardGoodsList)
        self.ImgComplete.gameObject:SetActive(true)
        self.BtnFinish.gameObject:SetActive(false)

        XUiManager.OpenUiObtain(rewardGoodsList, nil, function(...)
            self.ParentCb()
            local nextId = XTaskConfig.GetNextTaskId(self.tableData.Id)
            local nextTask = nextId and XDataCenter.TaskManager.GetTaskDataById(nextId)
            if self.tableData.Type == XDataCenter.TaskManager.TaskType.Achievement then
                if nextTask then
                    self.Data.State = XDataCenter.TaskManager.TaskState.Finish
                    local ui = CS.UnityEngine.Object.Instantiate(self.GameObject, self.Transform.parent)
                    local grid = XUiGridTask.New(self.RootUi, ui, self.Data, self.ParentCb)
                    self:ResetData(nextTask)
                else
                    local parent = self.Transform.parent
                    local grandParent = parent.parent
                    self.Transform:SetParent(grandParent)
                    self.Transform:SetParent(parent)
                end
            else
                if nextTask then
                    self:ResetData(nextTask)
                else
                    self.GameObject:SetActive(false)
                end
            end
        end, nil)
    end)
end

function XUiGridTask:OnBtnSkipClick(...)
    if XDataCenter.RoomManager.RoomData ~= nil then
        local title = CS.XTextManager.GetText("TipTitle")
        local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceQuitRoom")
        XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
            XLuaUiManager.RunMain()
            local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id).SkipId
            XFunctionManager.SkipInterface(skipId)
        end)
    else
        local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.Data.Id).SkipId
        XFunctionManager.SkipInterface(skipId)
    end
end

function XUiGridTask:UpdateProgress(data)
    self.Data = data
    local config = XDataCenter.TaskManager.GetTaskTemplate(data.Id)
    if #config.Condition < 2 then--显示进度
        self.ImgProgress.transform.parent.gameObject:SetActive(true)
        self.TxtTaskNumQian.gameObject:SetActive(true)
        local result = config.Result > 0 and config.Result or 1
        XTool.LoopMap(self.Data.Schedule, function(key, pair)
            self.ImgProgress.fillAmount = pair.Value / result
            self.TxtTaskNumQian.text = pair.Value .. "/" .. result
        end)
    else
        self.ImgProgress.transform.parent.gameObject:SetActive(false)
        self.TxtTaskNumQian.gameObject:SetActive(false)
    end

    self.BtnFinish.gameObject:SetActive(false)
    self.BtnSkip.gameObject:SetActive(false)

    if self.Data.State == XDataCenter.TaskManager.TaskState.Achieved then
        self.BtnFinish.gameObject:SetActive(true)
    elseif self.Data.State ~= XDataCenter.TaskManager.TaskState.Achieved and self.Data.State ~= XDataCenter.TaskManager.TaskState.Finish then
        self.BtnSkip.gameObject:SetActive(true)
    end
end

--==============================--
--desc: 播放入场动画
--@cb: 回调
--@second: 延时回调时间，默认为动画长度
--==============================--
function XUiGridTask:PlayEnter(cb, second)
    --XUiHelper.PlayAnimation(self.PanelAnimation, "GTEnter")
    if not second then
        -- local animation = self.Transform:GetComponent("Animation")
        -- animation.clip = animation:GetClip("GTEnter")
        second = 1
    end

    if cb then
        CS.XScheduleManager.Schedule(cb, second * 1000, 1, second * 1000)
    end
end

--==============================--
--desc: 播放出场动画
--@cb: 回调
--@isDelete: 动画结束是否删除对象
--==============================--
function XUiGridTask:PlayExit(cb, isDelete)
    --XLog.Debug("XUiGridTask:PlayExit")
    cb()
    -- if isDelete then
    --     CS.UnityEngine.Object.Destroy(self.GameObject)
    -- end
    -- XUiHelper.PlayAnimation(self.PanelAnimation, "GTExit", nil, function ()
    --     XLog.Debug("Finish")
    --     if cb then
    --         cb ()
    --     end
    --     if isDelete then
    --         CS.UnityEngine.Object.Destroy(self.GameObject)
    --     end
    -- end)
end

function XUiGridTask:RefreshData(task, cb, second)
    --XLog.Debug("XUiGridTask:RefreshData:", task)
    self:ResetData(task)
    -- self:PlayExit(function ()
    --     self:ResetData(task)
    --     self:PlayEnter(cb, second)
    -- end)
end