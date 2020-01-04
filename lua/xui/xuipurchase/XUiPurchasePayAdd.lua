local XUiPurchasePayAdd = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local Next = _G.next
local XUiPurchasePayAddListItem = require("XUi/XUiPurchase/XUiPurchasePayAddListItem")

function XUiPurchasePayAdd:Ctor(ui,uiroot)
    PurchaseManager = XDataCenter.PurchaseManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    self.PurcahaseCanGet = {}
    self.PurcahaseGeted = {}
    self.PurcahaseCanotGet = {}
    self.ListData = {}
    self.CurLookState = true
    XTool.InitUiObject(self)
    self:Init()
end

-- 更新数据
function XUiPurchasePayAdd:OnRefresh()
    local data = PurchaseManager.GetAccumlatePayConfig()
    if not data then
        return
    end

    if data.BeginTimeStr and data.EndTimeStr then
        self.TxtLjczTime.text = data.BeginTimeStr .."--"..data.EndTimeStr
    else
        self.TxtLjczTime.text = ""
    end

    self.TxtPaynumber.text = PurchaseManager.GetAccumlatedPayCount()
    
    self.CurPayIds = data.PayRewardId or {}
    self:SetListData()
    self:SetLookState(self.CurLookState)
end

function XUiPurchasePayAdd:SetListData()
    self.ListData = {}
    self.PurcahaseCanGet = {}
    self.PurcahaseGeted = {}
    self.PurcahaseCanotGet = {}
    for _,id in pairs(self.CurPayIds)do
        local state = PurchaseManager.PurchaseAddRewardState(id)
        if state == XPurchaseConfigs.PurchaseRewardAddState.CanGet then
            table.insert(self.PurcahaseCanGet, id)   
        elseif state == XPurchaseConfigs.PurchaseRewardAddState.Geted then
            table.insert(self.PurcahaseGeted, id)    
        elseif state == XPurchaseConfigs.PurchaseRewardAddState.CanotGet then
            table.insert(self.PurcahaseCanotGet, id)              
        end
    end

    for _,id in pairs(self.PurcahaseCanGet) do
        table.insert(self.ListData, id)
    end

    for _,id in pairs(self.PurcahaseCanotGet) do
        table.insert(self.ListData, id)
    end

    for _,id in pairs(self.PurcahaseGeted) do
        table.insert(self.ListData, id)
    end
    self.DynamicTable:SetDataSource(self.ListData)
    self.DynamicTable:ReloadDataASync(1)
end

function XUiPurchasePayAdd:Init()
    self:InitList()
    local closefun = function() self.GameObject:SetActive(false) end
    self.BtnClose.CallBack = closefun
    self.BtnLjczHelp.CallBack = function() self:OnBtnHelp() end
    self.BtnLjczLook.CallBack = function() self:OnBtnLook() end
    self.BtnCloseBg.CallBack = closefun
end

function XUiPurchasePayAdd:OnBtnLook()
    self.CurLookState = not self.CurLookState
    self:SetLookState(self.CurLookState)
end

function XUiPurchasePayAdd:SetLookState(state)
    self.ImgLook.gameObject:SetActive(state)
    self.ImgUnlook.gameObject:SetActive(not state)
    local num = PurchaseManager.GetAccumlatedPayCount()
    if state then
        self.TxtPaynumber.text = num
    else
        self.TxtPaynumber.text = TextManager.GetText("PurchaseAddHide")
    end
end


function XUiPurchasePayAdd:OnBtnHelp()
    XUiManager.UiFubenDialogTip("", TextManager.GetText("PurchaseAddPayDes") or "")
end

function XUiPurchasePayAdd:InitList()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelRewardGroup)
    self.DynamicTable:SetProxy(XUiPurchasePayAddListItem)
    self.DynamicTable:SetDelegate(self)
end

-- [监听动态列表事件]
function XUiPurchasePayAdd:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.Uiroot,self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
    end
end
return XUiPurchasePayAdd