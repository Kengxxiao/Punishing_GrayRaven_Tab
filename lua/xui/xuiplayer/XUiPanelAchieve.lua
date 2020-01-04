local XUiPanelAchieve = XLuaUiManager.Register(XLuaUi, "UiPanelAchieve")

function XUiPanelAchieve:OnAwake()
    self:InitAutoScript()
end

function XUiPanelAchieve:OnStart(parent, selectIdx)
    self.Base = parent
    self.AchieveType = selectIdx or XDataCenter.TaskManager.AchvType.Fight
    self:SetTogFightActive(self.AchieveType == XDataCenter.TaskManager.AchvType.Fight)
    self:SetTogCollectActive(self.AchieveType == XDataCenter.TaskManager.AchvType.Collect)
    self:SetTogSocialActive(self.AchieveType == XDataCenter.TaskManager.AchvType.Social)
    self:SetTogOtherActive(self.AchieveType == XDataCenter.TaskManager.AchvType.Other)

    self.AchieveTasks = {}
    self.DynamicTable = XDynamicTableNormal.New(self.PanelAchvList)
    self.DynamicTable:SetProxy(XDynamicGridTask)
    self.DynamicTable:SetDelegate(self)
    self:AddRedPointEvent()
    self:InitAchvPanel()
    XEventManager.AddEventListener(XEventId.EVENT_TASK_SYNC, self.OnTaskChangeSync, self)
end

function XUiPanelAchieve:AddRedPointEvent()
    XRedPointManager.AddRedPointEvent(self.ImgRedFight,self.OnCheckTabRedPoint,self,{XRedPointConditions.Types.CONDITION_PLAYER_ACHIEVE_TYPE},XDataCenter.TaskManager.AchvType.Fight)
    XRedPointManager.AddRedPointEvent(self.ImgRedCollect,self.OnCheckTabRedPoint,self,{XRedPointConditions.Types.CONDITION_PLAYER_ACHIEVE_TYPE},XDataCenter.TaskManager.AchvType.Collect)
    XRedPointManager.AddRedPointEvent(self.ImgRedSocial,self.OnCheckTabRedPoint,self,{XRedPointConditions.Types.CONDITION_PLAYER_ACHIEVE_TYPE},XDataCenter.TaskManager.AchvType.Social)
    XRedPointManager.AddRedPointEvent(self.ImgRedOther,self.OnCheckTabRedPoint,self,{XRedPointConditions.Types.CONDITION_PLAYER_ACHIEVE_TYPE},XDataCenter.TaskManager.AchvType.Other)
end

function XUiPanelAchieve:OnCheckTabRedPoint(show,achievetype)
    if XDataCenter.TaskManager.AchvType.Fight == achievetype then
        self.ImgRedFight.gameObject:SetActive(show >= 0)
    elseif XDataCenter.TaskManager.AchvType.Collect == achievetype then
        self.ImgRedCollect.gameObject:SetActive(show >= 0)
    elseif XDataCenter.TaskManager.AchvType.Social == achievetype then
        self.ImgRedSocial.gameObject:SetActive(show >= 0)
    elseif XDataCenter.TaskManager.AchvType.Other == achievetype then
        self.ImgRedOther.gameObject:SetActive(show >= 0)
    end
end

function XUiPanelAchieve:OnShow()
    self:SetupTaskList(false)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelAchieve:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelAchieve:AutoInitUi()
    self.TogFight = self.Transform:Find("GroupTop/TogFight"):GetComponent("Toggle")
    self.ImgAchvUnactive = self.Transform:Find("GroupTop/TogFight/ImgAchvUnactive"):GetComponent("Image")
    self.ImgAchvActive = self.Transform:Find("GroupTop/TogFight/ImgAchvActive"):GetComponent("Image")
    self.ImgRedFight = self.Transform:Find("GroupTop/TogFight/ImgRedFight"):GetComponent("Image")
    self.TogCollect = self.Transform:Find("GroupTop/TogCollect"):GetComponent("Toggle")
    self.ImgCollvUnActive = self.Transform:Find("GroupTop/TogCollect/ImgCollvUnActive"):GetComponent("Image")
    self.ImgCollvActive = self.Transform:Find("GroupTop/TogCollect/ImgCollvActive"):GetComponent("Image")
    self.ImgRedCollect = self.Transform:Find("GroupTop/TogCollect/ImgRedCollect"):GetComponent("Image")
    self.TogSocial = self.Transform:Find("GroupTop/TogSocial"):GetComponent("Toggle")
    self.ImgSocUnactive = self.Transform:Find("GroupTop/TogSocial/ImgSocUnactive"):GetComponent("Image")
    self.ImgSocActive = self.Transform:Find("GroupTop/TogSocial/ImgSocActive"):GetComponent("Image")
    self.ImgRedSocial = self.Transform:Find("GroupTop/TogSocial/ImgRedSocial"):GetComponent("Image")
    self.TogOther = self.Transform:Find("GroupTop/TogOther"):GetComponent("Toggle")
    self.ImgOthUnactive = self.Transform:Find("GroupTop/TogOther/ImgOthUnactive"):GetComponent("Image")
    self.ImgOthActive = self.Transform:Find("GroupTop/TogOther/ImgOthActive"):GetComponent("Image")
    self.ImgRedOther = self.Transform:Find("GroupTop/TogOther/ImgRedOther"):GetComponent("Image")
    self.PanelAchvList = self.Transform:Find("PanelAchvList")
    self.PanelAchvContainer = self.Transform:Find("PanelAchvList/Viewport/PanelAchvContainer")
    self.PanelAchvReach = self.Transform:Find("PanelAchvReach")
    self.TxtAchvGetCount = self.Transform:Find("PanelAchvReach/TxtAchvGetCount"):GetComponent("Text")
end

function XUiPanelAchieve:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelAchieve:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelAchieve:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelAchieve:AutoAddListener()
    self:RegisterClickEvent(self.TogFight, self.OnTogFightClick)
    self:RegisterClickEvent(self.TogCollect, self.OnTogCollectClick)
    self:RegisterClickEvent(self.TogSocial, self.OnTogSocialClick)
    self:RegisterClickEvent(self.TogOther, self.OnTogOtherClick)
end
-- auto

function XUiPanelAchieve:OnTogFightClick(eventData)
    self:SetTogOtherActive(false)
    self:SetTogCollectActive(false)
    self:SetTogSocialActive(false)
    self:SetTogFightActive(true)

    self.AchieveType = XDataCenter.TaskManager.AchvType.Fight
    self:SetupTaskList(true)
end

function XUiPanelAchieve:OnTogCollectClick(eventData)
    self:SetTogOtherActive(false)
    self:SetTogCollectActive(true)
    self:SetTogSocialActive(false)
    self:SetTogFightActive(false)

    self.AchieveType = XDataCenter.TaskManager.AchvType.Collect
    self:SetupTaskList(true)
end

function XUiPanelAchieve:OnTogSocialClick(eventData)
    self:SetTogOtherActive(false)
    self:SetTogCollectActive(false)
    self:SetTogSocialActive(true)
    self:SetTogFightActive(false)
    self.AchieveType = XDataCenter.TaskManager.AchvType.Social
    self:SetupTaskList(true)
end

function XUiPanelAchieve:OnTogOtherClick(eventData)
    self:SetTogOtherActive(true)
    self:SetTogCollectActive(false)
    self:SetTogSocialActive(false)
    self:SetTogFightActive(false)

    self.AchieveType = XDataCenter.TaskManager.AchvType.Other
    self:SetupTaskList(true)
end

--动态列表事件
function XUiPanelAchieve:OnDynamicTableEvent(event,index,grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.AchieveTasks[index]
        grid.RootUi = self.Base
        grid:ResetData(data)
    end
end

function XUiPanelAchieve:SetTogFightActive(flag) 
    self.ImgAchvActive.gameObject:SetActive(flag)
    self.ImgAchvUnactive.gameObject:SetActive(not flag)
end

function XUiPanelAchieve:SetupTaskList(isReload)
    local achieveTask,achieveCount, total = XDataCenter.TaskManager.GetAchievedTasksByType(self.AchieveType)
    self.TxtAchvGetCount.text = tostring(achieveCount) .. "/" .. tostring(total)
    self.AchieveTasks = achieveTask

    self.DynamicTable:SetDataSource(self.AchieveTasks)
    self.DynamicTable:ReloadDataSync(1)
end

function XUiPanelAchieve:SetTogCollectActive(flag)
    self.ImgCollvActive.gameObject:SetActive(flag)
    self.ImgCollvUnActive.gameObject:SetActive(not flag)
end

function XUiPanelAchieve:SetTogSocialActive(flag)
    self.ImgSocActive.gameObject:SetActive(flag)
    self.ImgSocUnactive.gameObject:SetActive(not flag)
end

function XUiPanelAchieve:SetTogOtherActive(flag)
    self.ImgOthActive.gameObject:SetActive(flag)
    self.ImgOthUnactive.gameObject:SetActive(not flag)
end

function XUiPanelAchieve:InitAchvPanel()
    self.PanelAchvContainer.gameObject:SetActive(true)
    self:SetupTaskList(true)
end

function XUiPanelAchieve:ShowPanelPlayer()
    self.PanelPlayerObj:SetActive(true)
    self.PanelPlayerInst:UpdatePlayerInfo()
    self.PanelPlayerExpInst:UpdatePlayerLevelInfo()
end

function XUiPanelAchieve:OnTaskChangeSync()
    self:SetupTaskList(false)
end

function XUiPanelAchieve:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_TASK_SYNC, self.OnTaskChangeSync, self)
end

return XUiPanelAchieve
