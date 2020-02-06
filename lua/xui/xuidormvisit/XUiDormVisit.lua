local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local V3O = Vector3.one
local XUiDormVisit = XLuaUiManager.Register(XLuaUi, "UiDormVisit")
local XUiDormVisitTypeListItem = require("XUi/XUiDormVisit/XUiDormVisitTypeListItem")
local XUiDormVisitGridItem = require("XUi/XUiDormVisit/XUiDormVisitGridItem")
local TextManager = CS.XTextManager
local Next = _G.next
local DormManager
local timelimit = 10
local TabTypeCfg
local DisplaySetType

function XUiDormVisit:OnAwake()
    DormManager = XDataCenter.DormManager
    TabTypeCfg = XDormConfig.VisitTabTypeCfg
    DisplaySetType = XDormConfig.VisitDisplaySetType
    XTool.InitUiObject(self)
    self.TabObjs = {}
    self.TabObjs[1] = self.BtnTab1
    self.TabObjs[2] = self.BtnTab2
    self.DormVisitFriendEmptyTips = TextManager.GetText("DormVisitFriendEmptyTips")
    self.DormVisitStrangeEmptyTips = TextManager.GetText("DormVisitStrangeEmptyTips")
    self.DormVistorFriend = TextManager.GetText("DormVistorFriend")
    self.DormVistorStranger = TextManager.GetText("DormVistorStranger")
    self:InitUI()
    self:InitTypeCfg()
    self.PreVistorReqTime = XTime.GetServerNowTimestamp()
end

function XUiDormVisit:InitTypeCfg()
    self.TabObs = {}
    self.TypeListDataCfg = {}
    self.TypeListDataCfg[TabTypeCfg.MyFriend] = {["Name"] = TextManager.GetText("DormMyFriend"),["Skip"] = function() self:OnReqFriendData() end}
    self.TypeListDataCfg[TabTypeCfg.Visitor] = {["Name"] = TextManager.GetText("DormStranger"),["Skip"] = function() self:OnReqVisitorData() end}
    self:CreateTypeItems()
end

function XUiDormVisit:CreateTypeItems()
    if self.PanelTab then
        for k,v in pairs(self.TypeListDataCfg) do
            local obj = self.TabObjs[k]
            obj.gameObject:SetActive(true)
            obj.transform:SetParent(self.PanelTab.transform,false)
            obj.transform.localScale = V3O
            self.TabObs[k] = obj
            local cs = obj:GetComponent("XUiButton")
            cs:SetName(v.Name)
        end
        self.Tabgroup = self.PanelTab:GetComponent("XUiButtonGroup")
        self.Tabgroup:Init(self.TabObs, function(tab) self:TabSkip(tab) end)
    end
end

function XUiDormVisit:TabSkip(tab)
    self.CuTabType = tab
    local cfg = self.TypeListDataCfg[tab]
    local skip = cfg.Skip
    if skip then
        skip()
    end
end

function XUiDormVisit:InitList()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelItemCommon.gameObject)
    self.DynamicTable:SetProxy(XUiDormVisitGridItem)
    self.DynamicTable:SetDelegate(self)
end

-- 未知访客
function XUiDormVisit:SetVisitorListData(data)
    local data = data.Details or {}
    self:SetVisitorData(data)
end

function XUiDormVisit:SetVisitorData(data)
    self.ListData = data or {}
    if Next(self.ListData) ~= nil then
        self.VisitTips.gameObject:SetActive(false)
        self.BtnRandomVisit.gameObject:SetActive(true)
    else
        self.VisitTips.gameObject:SetActive(true)
        self.TxtEmptyTips.text = self.DormVisitStrangeEmptyTips
        self.BtnRandomVisit.gameObject:SetActive(false)
    end

    self.TxtType.text = self.DormVistorStranger
    self.DynamicTable:SetDataSource(self.ListData)
    self.DynamicTable:ReloadDataASync(1)
end

--好友 
function XUiDormVisit:SetFriendListData(data)
    if data and Next(data) ~= nil then
        self.VisitTips.gameObject:SetActive(false)
    else
        self.VisitTips.gameObject:SetActive(true)
        self.TxtEmptyTips.text = self.DormVisitFriendEmptyTips
    end
    self.TxtType.text = self.DormVistorFriend
    self.ListData = data or {}
    self.DynamicTable:SetDataSource(self.ListData)
    self.DynamicTable:ReloadDataASync(1)
    self.BtnRandomVisit.gameObject:SetActive(false)
end

function XUiDormVisit:UpdataFriendList()
    local data = DormManager.GetVisFriendData()
    self.ListData = {}
    if Next(data) ~= nil then
        for _,v in pairs(data) do
            table.insert(self.ListData, v)
        end
    end
    self:SetFriendListData(self.ListData)
end

-- [监听动态列表事件]
function XUiDormVisit:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then   
    end
end

function XUiDormVisit:OnStart(ui,tab)
    self.HostelSecond = ui
    local t = tab or TabTypeCfg.MyFriend
    self.Tabgroup:SelectIndex(t)
    if t == TabTypeCfg.MyFriend then
        self:OnReqFriendData()
    else
        self:OnReqVisitorData()
    end
end

-- 请求好友宿舍数据
function XUiDormVisit:OnReqFriendData()
    self.ListData = {}
    local ids = XDataCenter.SocialManager.GetFriendIds()
    if not Next(ids) then 
        self:SetFriendListData()
        return
    end

    local sendids = {}
    local data = DormManager.GetVisFriendData()
    if Next(data) ~= nil then
        local curtime = XTime.GetServerNowTimestamp()
        for _,id in pairs(ids)do
            local v = data[id]
            if v then
                if curtime - v.DataTime < timelimit then
                    table.insert(self.ListData, v)
                else
                    table.insert(sendids, id)
                end
            else
                table.insert(sendids, id)
            end
        end
        
        if Next(sendids) then
            if Next(self.ListData) then
                self:SetFriendListData(self.ListData)
                DormManager.RequestDormitoryDetails(sendids)
            else
                DormManager.RequestDormitoryDetails(sendids,self.UpdataFriendCb)
            end
        else
            self:SetFriendListData(self.ListData)
        end
    else
        DormManager.RequestDormitoryDetails(ids,self.UpdataFriendCb)
    end
end

-- 请求访客宿舍数据
function XUiDormVisit:OnReqVisitorData()
    local data = DormManager.GetDormitoryRecommendTotalData()
    self.ListData = {}
    if Next(data) ~= nil then
        local curtime = XTime.GetServerNowTimestamp()
        if curtime - self.PreVistorReqTime < timelimit then
            for _,v in pairs(data)do
                table.insert(self.ListData,v)
            end
            self:SetVisitorData(self.ListData)
            return     
        end
    end
    
    self.PreVistorReqTime = XTime.GetServerNowTimestamp()
    DormManager.RequestDormitoryRecommend(self.SetVisitorCb)
end

function XUiDormVisit:OnEnable()
    XEventManager.AddEventListener(XEventId.EVENT_DORM_VISTOR_SKIP, self.OnVisit, self)
end

function XUiDormVisit:OnDisable()
end

function XUiDormVisit:OnVisit(playid,dormid)
    local charId = DormManager.GetVisitorDormitoryCharacterId()
    XLuaUiManager.CloseWithCallback("UiDormVisit",function()
        DormManager.RequestDormitoryVisit(playid,dormid,charId,function ()
            self:DoDormVisitor(playid,dormid)
        end)
    end)
end

function XUiDormVisit:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_VISTOR_SKIP, self.OnVisit, self)
end

function XUiDormVisit:OnGetEvents()
    
end

function XUiDormVisit:OnNotify(evt, ...)
end

function XUiDormVisit:InitUI()
    self.TxtScoreDes.text = TextManager.GetText("DormTotalScore")
    self.BtnRandomVisit:SetName(TextManager.GetText("DormVisitBtn"))
    self.AssetPanel = XUiPanelAsset.New(self,self.PanelAsset,XDataCenter.ItemManager.ItemId.DormCoin,XDataCenter.ItemManager.ItemId.FurnitureCoin)
    self.UpdataFriendCb = function() self:UpdataFriendList() end
    self.SetVisitorCb = function(data) self:SetVisitorListData(data) end
    self.OnClickEmptyVisitorCb = function() self:OnClickEmptyVisitor() end
    self:AddListener()
    self:InitList()
end

function XUiDormVisit:OnClickEmptyVisitor()
    XLuaUiManager.Open("UiSocial")
end

function XUiDormVisit:AddListener()
    self.OnBtnRandomVisitCb = function() self:OnBtnRandomVisit() end
    self.OnBtnMainUIClickCb = function() self:OnBtnMainUIClick() end
    self.OnBtnReturnClickCb = function() self:OnBtnReturnClick() end
    self.OnEnterDormcb = function() self:EnterDormVisitor() end
    self:RegisterClickEvent(self.BtnRandomVisit, self.OnBtnRandomVisitCb)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUIClickCb)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnReturnClickCb)
    self:RegisterClickEvent(self.VisitTips, self.OnClickEmptyVisitorCb)
end

function XUiDormVisit:OnBtnMainUIClick()
    XLuaUiManager.RunMain()
end

function XUiDormVisit:OnBtnReturnClick()
    XLuaUiManager.Close("UiDormVisit")    
end

function XUiDormVisit:OnBtnRandomVisit()
    local d = self.ListData or {}
    local len = #d
    if len == 0 then
        return
    end

    local index = math.random(1,len)
    self.DormData = d[index]

    if self.DormData then
        local dormid = self.DormData.DormitoryId
        local charId = DormManager.GetVisitorDormitoryCharacterId()
        XLuaUiManager.CloseWithCallback("UiDormVisit",function()
            DormManager.RequestDormitoryVisit(self.DormData.PlayerId,dormid,charId,self.OnEnterDormcb)
        end)
    end
end

function XUiDormVisit:EnterDormVisitor()
    if self.DormData and self.DormData.PlayerId and self.DormData.DormitoryId then
        self:DoDormVisitor(self.DormData.PlayerId,self.DormData.DormitoryId)
    end
end

function XUiDormVisit:DoDormVisitor(playerId,dormitoryId)
    local t = DisplaySetType.Stranger
    if self.CuTabType == TabTypeCfg.MyFriend then
        t = DisplaySetType.MyFriend
    end
    if self.HostelSecond and (not XTool.UObjIsNil(self.HostelSecond.GameObject)) then
        self.HostelSecond.GameObject:SetActive(true)
        self.HostelSecond:OnRecordSelfDormId()
        DormManager.VisitDormitory(t,dormitoryId)
        self.HostelSecond:UpdateData(t,dormitoryId,playerId)
    else
        XLuaUiManager.Open("UiDormSecond", t, dormitoryId,playerId)
        DormManager.VisitDormitory(t,dormitoryId)
    end
end
