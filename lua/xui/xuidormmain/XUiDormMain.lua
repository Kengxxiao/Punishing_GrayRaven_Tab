local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local Vector2 = CS.UnityEngine.Vector2
local Quaternion = CS.UnityEngine.Quaternion
local V3O = Vector3.one
local Next = _G.next
local XUiDormMain = XLuaUiManager.Register(XLuaUi, "UiDormMain")
local XUiDormMainItem = require("XUi/XUiDormMain/XUiDormMainItem")
local TextManager = CS.XTextManager
local EnterCfgKeys = {
    Name = "Name",
    Skip = "Skip"
}
local DormManager
local DormDrawGroudId
local White = "#ffffff"
local Blue = "#34AFF8"

function XUiDormMain:OnAwake()
    self.DormItems = {}
    self.Roomsputup = {}
    DormDrawGroudId = CS.XGame.ClientConfig:GetInt("DormDrawGroudId")
    DormManager = XDataCenter.DormManager
    self.DisplaySetType = XDormConfig.VisitDisplaySetType
    self.DormActiveState = XDormConfig.DormActiveState
    XTool.InitUiObject(self)
    self:InitFun()
    self:InitEnter()
    self:InitUI()
end

function XUiDormMain:InitFun()
    self.DormActiveRespCB = function() self:SetDormMainItem() end
    self.DormCharEventCB = function(dormid) self:CharEventChange(dormid) end
    self.OnBtnTaskTipsClickCb = function() self:OnBtnTaskTipsClick() end
    self.BtnHelp.CallBack = function() self:OnBtnHelpClick() end
end

function XUiDormMain:InitEnter()
    self:RegisterClickEvent(self.BtnWork,function() self:OpenWork() end)
    self:RegisterClickEvent(self.BtnPerson,function() self:SetPersonList() end)
    -- self:RegisterClickEvent(self.BtnDraw,function() self:OpenDrawUI() end)
    self:RegisterClickEvent(self.BtnTask,self.OnBtnTaskClick)
    self:RegisterClickEvent(self.BtnShop,function() self:OpenShopUI() end)
    self:RegisterClickEvent(self.BtnBuild,function() self:OpenBuildUI() end)
    self:RegisterClickEvent(self.BtnWareHouse,function() self:OpenWareHpuseUI() end)
    self.BtnWork:SetName(TextManager.GetText("DormWorkText"))
    self.BtnPerson:SetName(TextManager.GetText("DormPersonText"))
    -- self.BtnDraw:SetName(TextManager.GetText("DormDrawText"))
    self.BtnTask:SetName(TextManager.GetText("DormTaskText"))
    self.BtnShop:SetName(TextManager.GetText("DormShopText"))
    self.BtnWareHouse:SetName(TextManager.GetText("DormWareHouseText"))
    self.BtnBuild:SetName(TextManager.GetText("DormBuidText"))
end

-- 跳到仓库
function XUiDormMain:OpenWareHpuseUI()
    XLuaUiManager.Open("UiDormBag")
    self.IsStatic = true
end

-- 跳到建造
function XUiDormMain:OpenBuildUI()
    XLuaUiManager.Open("UiFurnitureBuild")
    self.IsStatic = true
end

function XUiDormMain:CharEventChange(dormid)
    if self.DormItems[dormid] then
        self.DormItems[dormid]:SetEvenIconState(true)
    end
end

-- 跳到商店
function XUiDormMain:OpenShopUI()
    XLuaUiManager.Open("UiShop",XShopManager.ShopType.Dorm)
    self.IsStatic = true
end

-- 跳到抽卡
function XUiDormMain:OpenDrawUI()
    -- 没有开启
    local isOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.DrawCard)
    if not isOpen then
        XUiManager.TipText("DormDrawNoOpenTips")
        return
    end

    XDataCenter.DrawManager.GetDrawGroupList(
    function()
        local info = XDataCenter.DrawManager.GetDrawGroupInfoByGroupId(DormDrawGroudId)
        XDataCenter.DrawManager.GetDrawInfoList(DormDrawGroudId, function()
            XLuaUiManager.Open("UiDraw", DormDrawGroudId, function()
                --XHomeSceneManager.ResetToCurrentSceneType()
                XHomeSceneManager.ResetToCurrentGlobalIllumination()
                XHomeSceneManager.ResetToCurrentGlobalPointLight()
            end, info.UiBackGround)
        end)
    end
    )
    self.IsStatic = true
end

-- 跳到任务
function XUiDormMain:OnBtnTaskTipsClick()
    if self.CurTaskData and not self.CurTaskTagState then
        self:OnTaskSkip()
        return
    end

    local tab
    if self.CurTaskTagState then
        if self.TaskType == XDataCenter.TaskManager.TaskType.DormNormal then
            tab = XTaskConfig.PANELINDEX.Story
        else
            tab = XTaskConfig.PANELINDEX.Daily
        end
    end
    self:OnOpenTask(tab)
end

function XUiDormMain:OnBtnHelpClick()
    XUiManager.ShowHelpTip("Dorm")
end

function XUiDormMain:OnOpenTask(tab)
    XLuaUiManager.Open("UiDormTask",tab)
    self.IsStatic = true
end

function XUiDormMain:OnBtnTaskClick()
    self:OnOpenTask()
end

function XUiDormMain:OnTaskSkip()
    if XDataCenter.RoomManager.RoomData ~= nil then
        local title = CS.XTextManager.GetText("TipTitle")
        local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceQuitRoom")
        XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
            XLuaUiManager.RunMain()
            local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.CurTaskData.Id).SkipId
            XFunctionManager.SkipInterface(skipId)
        end)
    else
        local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.CurTaskData.Id).SkipId
        XFunctionManager.SkipInterface(skipId)
    end
end

-- 跳到打工
function XUiDormMain:OpenWork()
    XLuaUiManager.Open("UiDormWork")
    self.IsStatic = true
end

-- 设置人员list
function XUiDormMain:SetPersonList()
    XLuaUiManager.Open("UiDormPerson")
    self.IsStatic = true
end

-- [监听动态列表事件]
function XUiDormMain:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then   
    end
end

function XUiDormMain:SetSelectState(state)
    if not self.PanelSelect then
        return
    end

    self.PanelSelect.gameObject:SetActive(state)
end

function XUiDormMain:OnStart(...)
    XLuaUiManager.Close("UiLoading")
end

function XUiDormMain:CreateDormMainItems()
    local dormDatas = DormManager.GetDormitoryData()--已经拥有的宿舍
    for dormId,v in pairs(dormDatas) do
        if v:WhetherRoomUnlock() then
            if not self.DormItems[dormId] then
                local item = self:GetItem(dormId)
                self.DormItems[dormId] = item
            end
            self.DormItems[dormId].GameObject:SetActive(true)
            self.DormItems[dormId]:OnRefresh(v,self.DormActiveState.Active)
            self.DormItems[dormId]:SetEvenIconState(DormManager.IsHaveDormCharactersEvent(dormId))
        end
    end
end

function XUiDormMain:GetItem(dormid)
    local obj = self:GetDormItemPos(dormid)
    local item = XUiDormMainItem.New(obj,self)
    return item
end

function XUiDormMain:GetDormItemPos(id)
    return self.Roomsputup[id]
end

function XUiDormMain:OnEnable()
    self.BtnPanelTask.CallBack = self.OnBtnTaskTipsClickCb
    self:OnPlayAnimation()
    DormManager.StartDormRedTimer()
    self.BtnWork:ShowReddot(DormManager.DormWorkRedFun())
    self.BtnBuild:ShowReddot(XDataCenter.FurnitureManager.HasCollectableFurniture())
    XRedPointManager.AddRedPointEvent(self.BtnTask.ReddotObj, self.RefreshTaskTabRedDot, self, { XRedPointConditions.Types.CONDITION_DORM_MAIN_TASK_RED}) 
    XRedPointManager.AddRedPointEvent(self.BtnBuild.ReddotObj, self.OnCheckBuildFurniture, self, { XRedPointConditions.Types.CONDITION_FURNITURE_CREATE })
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_DORMMAIN_EVENT_NOTIFY, self.DormCharEventCB)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_ROOM_ACTIVE_SUCCESS, self.DormActiveRespCB, self)
    local data,tasktype,state = XDataCenter.TaskManager.GetDormTaskTips()
    if data and tasktype and state then
        self.CurTaskData = data
        self.TaskType = tasktype
        self.PanelTask.gameObject:SetActive(true)
        local config = XDataCenter.TaskManager.GetTaskTemplate(data.Id)
        self.CurTaskTagState = state == XDataCenter.TaskManager.TaskState.Achieved
        if self.CurTaskTagState then          
            self.BtnPanelTask:SetName(string.format("<color=%s>%s</color>", Blue, config.Desc))
        else
            self.BtnPanelTask:SetName(string.format("<color=%s>%s</color>", White, config.Desc))
        end
        self.BtnPanelTask:ShowTag(not self.CurTaskTagState)
        self.BtnPanelTask:ShowReddot(self.CurTaskTagState)
    else
        self.CurTaskData = nil
        self.PanelTask.gameObject:SetActive(false)
    end
end

function XUiDormMain:RefreshTaskTabRedDot(count)
    self.BtnTask:ShowReddot(count >= 0)
end

function XUiDormMain:OnCheckBuildFurniture(count)
    self.BtnBuild:ShowReddot(count >= 0)
end

function XUiDormMain:OnPlayAnimation()
    local delay = XDormConfig.DormAnimationMoveTime
    if self.IsStatic then
        self.IsStatic = false
        delay = XDormConfig.DormAnimationStaicTime
    end
    if delay > 0 then
        self.IsFirstAnimation = true
        self.SafeAreaContentPane.gameObject:SetActive(false)
        self.DormMainLookTimer = CS.XScheduleManager.ScheduleOnce(function()
            self.SafeAreaContentPane.gameObject:SetActive(true)
            self:PlayAnimation("AnimStartEnable")
            self:SetDormMainItem()
            CS.XScheduleManager.UnSchedule(self.DormMainLookTimer)
        end,delay)
    else
        self:SetDormMainItem()
        self:PlayAnimation("AnimStartEnable")
    end
end

function XUiDormMain:SetDormMainItem()
    self:CreateDormMainItems()
end

function XUiDormMain:OnDisable()
    self.BtnPanelTask.CallBack = nil
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_DORMMAIN_EVENT_NOTIFY, self.DormCharEventCB)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_ROOM_ACTIVE_SUCCESS, self.DormActiveRespCB, self)
    if self.DormMainLookTimer then
        CS.XScheduleManager.UnSchedule(self.DormMainLookTimer)
       self.DormMainLookTimer = nil
    end

    -- 进入房间应该隐藏Hud
    for _,v in pairs(self.DormItems) do
        v.GameObject:SetActive(false)
        v:SetEvenIconState(false)
    end
    DormManager.StopDormRedTimer()
end

function XUiDormMain:OnDestroy()
    XHomeSceneManager.LeaveScene()
    XEventManager.DispatchEvent(XEventId.EVENT_DORM_HIDE_COMPONET)
end

function XUiDormMain:OnGetEvents()
end

function XUiDormMain:OnNotify(evt, ...)
end

function XUiDormMain:InitUI()
    self.AssetPanel = XUiPanelAsset.New(self,self.PanelAsset,XDataCenter.ItemManager.ItemId.DormCoin,XDataCenter.ItemManager.ItemId.FurnitureCoin,XDataCenter.ItemManager.ItemId.DormEnterIcon)
    self:AddListener()
    local cfg = XDormConfig.GetTotalDormitoryCfg()
    local i = 1
    for _,v in pairs(cfg)do
        self.Roomsputup[v.Id] = self["DormlMainItem"..i]
        i  = i + 1
    end
end

function XUiDormMain:AddListener()
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUIClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnReturnClick)
end

function XUiDormMain:OnBtnMainUIClick(eventData)
    XDataCenter.DormManager.RequestDormitoryExit()
    XEventManager.DispatchEvent(XEventId.EVENT_DORM_CLOSE_COMPONET)
    XLuaUiManager.RunMain()
end

function XUiDormMain:OnBtnReturnClick(eventData)
    XDataCenter.DormManager.RequestDormitoryExit()
    XEventManager.DispatchEvent(XEventId.EVENT_DORM_CLOSE_COMPONET)
    self:Close()
end
