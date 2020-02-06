local Next = _G.next
local DormManager
local TextManager
local Object = CS.UnityEngine.Object
local XUiDormFoundryDetail = XLuaUiManager.Register(XLuaUi, "UiDormFoundryDetail")
local XUiDormFoundryDetailItem = require("XUi/XUiDormWork/XUiDormFoundryDetailItem")
local XUiDormFoundryDetailRewardItem = require("XUi/XUiDormWork/XUiDormFoundryDetailRewardItem")

function XUiDormFoundryDetail:OnAwake()
    DormManager = XDataCenter.DormManager
    TextManager = CS.XTextManager
    self.RewardGoPool = {}
    XTool.InitUiObject(self)
    self:Initfun()
    self:InitList()
end

function XUiDormFoundryDetail:InitList()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelExpendContent.gameObject)
    self.DynamicTable:SetProxy(XUiDormFoundryDetailItem)
    self.DynamicTable:SetDelegate(self)
end

-- [监听动态列表事件]
function XUiDormFoundryDetail:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self,self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then      
    end
end

function XUiDormFoundryDetail:OnStart(uiroot,datalist)
    self.UiRoot = uiroot
    self.ListData = datalist
    self:OnRefresh()
end

function XUiDormFoundryDetail:OnEnable()
    self:OnRefresh()
end

function XUiDormFoundryDetail:OnDisable()
    for _,v in pairs(self.RewardGoPool)do
        if v then
            v.GameObject:SetActiveEx(false)
        end
    end
    self.UiRoot.PanelWork.gameObject:SetActiveEx(true)
end

function XUiDormFoundryDetail:OnDestroy()
end

function XUiDormFoundryDetail:OnRefreshData(datalist)
    self.ListData = datalist
    self:OnRefresh()
end

function XUiDormFoundryDetail:OnRefresh()
    self.DynamicTable:SetDataSource(self.ListData)
    self.DynamicTable:ReloadDataSync(1)
    self.WorkposList = {}
    self.WorkRewardCount = {}
    self.TotalWorkRewCount = 0
    for _, v in pairs(self.ListData) do
        table.insert(self.WorkposList, v.WorkPos)
        local c = DormManager.GetDormWorkRewCounrByPos(v.WorkPos)
        self.TotalWorkRewCount = self.TotalWorkRewCount + c
    end

    local count = #self.ListData
    local dormcount= DormManager.GetDormitoryCount()
    local daiGongData = XDormConfig.GetDormCharacterWorkById(dormcount)
    local index = 1
    if daiGongData then
        local cfg = XDataCenter.ItemManager.GetItemTemplate(daiGongData.ItemId)
        local item = self:GetGride(index)
        item:OnRefresh(cfg,self.TotalWorkRewCount,false)
        local extracount = 0
        local rewardList = XRewardManager.GetRewardList(daiGongData.ExtraReward)
        if rewardList then
            for _,v in pairs(rewardList)do
                -- if v.TemplateId == cfg.Id then
                --     extracount = extracount + v.Count
                -- else
                    index = index + 1
                    local item = self:GetGride(index)
                    item:OnRefresh(v,count * v.Count,true)
                -- end
            end
        end
        -- item:RefreshExCount(extracount)
    end
end

function XUiDormFoundryDetail:GetGride(index)
    if self.RewardGoPool[index] then
        self.RewardGoPool[index].GameObject:SetActiveEx(true)
        return self.RewardGoPool[index]
    end

    local obj = Object.Instantiate(self.RewardGrid,self.Rewards)
    obj.gameObject:SetActive(true)
    local item = XUiDormFoundryDetailRewardItem.New(obj)
    item:Init(self.UiRoot)
    table.insert(self.RewardGoPool, item)
    return item
end

function XUiDormFoundryDetail:Initfun()
    self.BtnCloseFun = function() self:Close() end
    self.OnCompleteFun = function() self:OnComplete() end
    self.BtnComplete.CallBack = self.OnCompleteFun
    self.BtncCancel.CallBack = self.BtnCloseFun
    self.BtnClose.CallBack = self.BtnCloseFun
    self.BtnBg.CallBack = self.BtnCloseFun
end

function XUiDormFoundryDetail:OnComplete()
    DormManager.DormWordDoneReq(self.WorkposList)
end

