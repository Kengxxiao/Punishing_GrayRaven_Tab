local XUiUsePackage = XLuaUiManager.Register(XLuaUi, "UiUsePackage")

local DefaultIndex = 1

function XUiUsePackage:OnStart(id, successCallback, challegeCountData, buyAmount)
    self.SuccessCallback = successCallback
    self.BuyAmount = buyAmount
    self.ChallegeCountData = challegeCountData
    self:InitDynamicTable()
    self.Id = id
    self:Refresh(id)
    self:AddBtnCallBack()
    if self.Data.TargetId == XDataCenter.ItemManager.ItemId.ActionPoint then
        self.Timers = CS.XScheduleManager.ScheduleForever(function() self:SetRecTime() end, CS.XScheduleManager.SECOND)
    end
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_UIDIALOG_VIEW_ENABLE)
end

function XUiUsePackage:OnDestroy()
    if self.Timers then
        CS.XScheduleManager.UnSchedule(self.Timers)
        self.Timers = nil
    end
end

function XUiUsePackage:AddBtnCallBack()
    self.BtnCancel.CallBack = function()
        self:OnBtnCancelClick()
    end
    self.BtnConfirm.CallBack = function()
        self:OnBtnConfirmClick()
    end
    self.BtnTanchuangClose.CallBack = function()
        self:OnBtnCloseClick()
    end
    self.BtnElectricExchange.CallBack = function()
        self:OnBtnShowTypeClick()
    end
end
-- auto
function XUiUsePackage:OnBtnShowTypeClick(...)
    self:Close()
    XLuaUiManager.Open("UiBuyAsset", self.Id, self.SuccessCallback, self.ChallegeCountData, self.BuyAmount)
end

function XUiUsePackage:OnBtnCloseClick(...)
    self:Close()
end

function XUiUsePackage:OnBtnCancelClick(...)
    self:Close()
end

function XUiUsePackage:SetPanelType(targetId)
    self.Data = XDataCenter.ItemManager.GetBuyAssetInfo(targetId)
    self.TxtElectricDesc.gameObject:SetActiveEx(false)
    self.TxtElectricNumPackage.gameObject:SetActiveEx(true)

    if self.Data.TargetId == XDataCenter.ItemManager.ItemId.ActionPoint then
        if not XDataCenter.ItemManager.CheakBatteryIsHave() then
            self.ImgEmpty.gameObject:SetActiveEx(true)
            self.SelectItem = nil
        else
            self.ImgEmpty.gameObject:SetActiveEx(false)
        end

        if self.SelectItem and not XDataCenter.ItemManager.CheakBatteryIsHaveById(self.SelectItem.Data.Id) then
            self.SelectItem = nil
        end

        if not self.SelectItem then
            self.TxtElectricNumPackage.text = 0
        end

        self:SetupDynamicTable()
    end
end

function XUiUsePackage:SetRecTime()

    local time = XDataCenter.ItemManager.GetActionPointsRefreshResidueSecond()
    self.TxtRecoverTime.text = CS.XTextManager.GetText("RecActPoint", XUiHelper.GetTime(time, XUiHelper.TimeFormatType.ONLINE_BOSS))
    self.TxtCurrentElectric.text = XDataCenter.ItemManager.GetActionPointsNum() .. "/" .. XDataCenter.ItemManager.GetMaxActionPoints()
    if time == 0 then
        self.TxtRecoverTime.text = ""
    end

end

function XUiUsePackage:OnBtnConfirmClick(...)
    if self.SelectItem then
        local callback = function(rewardGoodsList)
            self:SetPanelType(self.Id)
            if self.BuyAmount then
                self:Close()
            end
            if self.SuccessCallback then
                self.SuccessCallback()
            end
            XUiManager.OpenUiObtain(rewardGoodsList, CS.XTextManager.GetText("CongratulationsToObtain"))

        end
        if not self:CheakActionPointOverLimit() then
            XDataCenter.ItemManager.Use(self.SelectItem.Data.Id, self.SelectItem.RecycleBatch and self.SelectItem.RecycleBatch.RecycleTime, 1, callback)
        else
            XUiManager.TipError(CS.XTextManager.GetText("OverLimitCanNotUse"))
        end
    else
        XUiManager.TipError(CS.XTextManager.GetText("UseBattery"))
    end
end

function XUiUsePackage:Refresh(targetId)
    self:SetPanelType(targetId)
    local active = self.Data ~= nil
    self.PanelInfo.gameObject:SetActiveEx(active)
    self.TxtCurrentElectric.text = XDataCenter.ItemManager.GetActionPointsNum() .. "/" .. XDataCenter.ItemManager.GetMaxActionPoints()
end

function XUiUsePackage:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.ElectricPackageScroll)
    self.DynamicTable:SetProxy(XUiBattery)
    self.DynamicTable:SetDelegate(self)
    self.GridCommonPopUp.gameObject:SetActiveEx(false)
end

function XUiUsePackage:SetupDynamicTable()
    self.BatteryDatas = XDataCenter.ItemManager.GetCurBatterys()
    if self.SelectItem == nil and self.BatteryDatas[DefaultIndex] then
        self.SelectItem = self.BatteryDatas[DefaultIndex]
    end
    self.DynamicTable:SetDataSource(self.BatteryDatas)
    self.DynamicTable:ReloadDataSync(1)
end

function XUiUsePackage:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then

    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:UpdateGrid(self.BatteryDatas[index], self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then

    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RECYCLE then
        grid:OnRecycle()
    end
end

function XUiUsePackage:CheakActionPointOverLimit()
    local GoodsNum = 1
    local RewardIndex = 2
    local ActionPoint = XDataCenter.ItemManager.GetItem(XDataCenter.ItemManager.ItemId.ActionPoint)
    local goodsList = XRewardManager.GetRewardList(self.SelectItem.Data.Template.SubTypeParams[RewardIndex])
    if goodsList[GoodsNum].Count + ActionPoint:GetCount() > ActionPoint.Template.MaxCount then
        return true
    end
    return false
end