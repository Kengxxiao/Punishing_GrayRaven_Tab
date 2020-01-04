XTaskContainer = XClass()

function XTaskContainer:Ctor(rootUi, container, grid, taskType, cb)
    self.RootUi = rootUi
    self.PanelContainer = container
    self.GridTask = grid
    self.TaskType = taskType
    self.GridContainer = {}
    self.Girds = {}
    if self.TaskType == XDataCenter.TaskManager.TaskType.Daily then
        self.Cb = cb
    end
    self.GridTask.gameObject:SetActive(false)
end

function XTaskContainer:GetTaskList()
    if self.TaskType == XDataCenter.TaskManager.TaskType.Story then
        return XDataCenter.TaskManager.GetStoryTaskList()
    elseif self.TaskType == XDataCenter.TaskManager.TaskType.Daily then
        return XDataCenter.TaskManager.GetDailyTaskList()
    elseif self.TaskType == XDataCenter.TaskManager.TaskType.Activity then
        return XDataCenter.TaskManager.GetActivityTaskList()
    elseif self.TaskType == XDataCenter.TaskManager.TaskType.Achievement then
        return XDataCenter.TaskManager.GetAchvTaskList()
    else
        XLog.Error("XTaskContainer:GetTaskList error: unknown task type, task type is " .. self.TaskType)
    end
end

function XTaskContainer:Refresh()
    local list = self:GetTaskList()
    if not list or #list <= 0 then 
        return 
    end

    self.GridContainer = {}

    for i,var in ipairs(self.Girds) do
        var.GameObject.name = "-1"
        var.GameObject:SetActive(false)
    end

    for i,var in ipairs(list) do
        local grid = self.Girds[i]
        if grid then
            self.GridContainer[var.Id] = grid
            grid:ResetData(var)
            grid.GameObject.name = var.Id
            grid.GameObject:SetActive(true)
        else
            self:AddItem(var)
        end
    end


end

function XTaskContainer:AddItem(data)
    local ui = CS.UnityEngine.Object.Instantiate(self.GridTask)
    ui.transform:SetParent(self.PanelContainer, false)
    ui.gameObject:SetActive(true)
    ui.gameObject.name = data.Id

    local grid = XUiGridTask.New(self.RootUi, ui, data, function()
        if self.Cb then
            self.Cb()
        end
    end)
    table.insert(self.Girds,grid) 

    grid:PlayEnter()
    self.GridContainer[data.Id] = grid
end

function XTaskContainer:RemoveItem(id)
    if self.TaskType ~= XDataCenter.TaskManager.TaskType.Achievement then
        self.GridContainer[id].GameObject:SetActive(false)
       -- CS.UnityEngine.Object.Destroy(self.GridContainer[id].GameObject)
    end
    self.GridContainer[id] = nil
end

--成就列表分类显示
function XTaskContainer:MatchType(achvtype)
    
    for i,var in ipairs(self.Girds) do
        var.GameObject:SetActive(false)
    end

    for k, v in pairs(self.GridContainer) do
        if v.tableData.AchvType == achvtype then
            v.GameObject.gameObject:SetActive(true)
        end
    end
end

function XTaskContainer:UpdateTaskProgress(id, value)
    self.GridContainer[data.Id]:UpdateProgress(value)
end