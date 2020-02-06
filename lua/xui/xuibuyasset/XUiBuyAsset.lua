local XUiBuyAsset = XLuaUiManager.Register(XLuaUi, "UiBuyAsset")

local DefaultIndex = 1

function XUiBuyAsset:OnStart(id, successCallback, challegeCountData, buyAmount)
    self.SuccessCallback = successCallback
    self.BuyAmount = buyAmount
    
    if challegeCountData ~= nil then
        self:RefreshChallegeCount(challegeCountData)
        return
    end
   
    self.Id = id
    self:Refresh(id)
    self:FreshCallBack(id)
    self:AutoAddListener()

end

function XUiBuyAsset:OnDestroy()

end

function XUiBuyAsset:AutoAddListener()
    self.BtnCancel.CallBack = function ()
        self:OnBtnCancelClick()
    end
    self.BtnConfirm.CallBack = function ()
        self:OnBtnConfirmClick()
    end
    self.BtnTanchuangClose.CallBack = function ()
        self:OnBtnCloseClick()
    end
    self.BtnPackageExchange.CallBack = function ()
        self:OnBtnShowTypeClick()
    end
end
-- auto

function XUiBuyAsset:OnBtnShowTypeClick(...)
    self:Close()
    XLuaUiManager.Open("UiUsePackage", self.Id,self.SuccessCallback,self.ChallegeCountData,self.BuyAmount)
end

function XUiBuyAsset:OnBtnCloseClick(...)
    self:Close()
end

function XUiBuyAsset:FreshCallBack(id)
    XDataCenter.ItemManager.AddBuyTimesUpdateListener(id, function(targetId)
        if self.Data.LeftTimes == 0 then
            return
        end
        if targetId ~= self.Data.TargetId then
            return
        end
        self:Refresh(targetId)
    end, self.PanelInfo, self.gameObject)
end

function XUiBuyAsset:OnBtnCancelClick(...)
    self:Close()
end

function XUiBuyAsset:OnBtnConfirmClick(...) 
    if self.ChallegeCountData ~= nil then
        self:OnBtnChallegeCountClick()
        return
    end

    if not XDataCenter.ItemManager.CheckItemCountById(self.Data.ConsumeId, self.Data.ConsumeCount) then
        local itemName = XDataCenter.ItemManager.GetItemName(self.Data.ConsumeId)
        local text = CS.XTextManager.GetText('AssetsBuyConsumeNotEnough', itemName)
        XUiManager.TipMsg(text, XUiManager.UiTipType.Tip)
        return
    end

    if self.Data.LeftTimes == 0 then
        local itemName = XDataCenter.ItemManager.GetItemName(self.Data.ConsumeId)
        local text = CS.XTextManager.GetText('BuyCountIsNotEnough', itemName)
        XUiManager.TipMsg(text, XUiManager.UiTipType.Tip)
        return
    end

    local callback = function(targetId, targetCount)
        local name = XDataCenter.ItemManager.GetItemName(targetId)
        if (self.Data.ConsumeId == XDataCenter.ItemManager.ItemId.FreeGem or
                self.Data.ConsumeId == XDataCenter.ItemManager.ItemId.PaidGem) then
        end
        XUiManager.TipMsg(CS.XTextManager.GetText("Buy") .. CS.XTextManager.GetText("Success") .. "," .. CS.XTextManager.GetText("Acquire") .. targetCount .. name, XUiManager.UiTipType.Tip)
        self:Refresh(targetId)
        if self.BuyAmount then
            self:Close()
        end 
        if self.SuccessCallback then
            self.SuccessCallback()
        end     
    end
    XDataCenter.ItemManager.BuyAsset(self.Data.TargetId, callback,nil,self.BuyAmount)
end

function XUiBuyAsset:Refresh(targetId)
    self.Data = XDataCenter.ItemManager.GetBuyAssetInfo(targetId)
    
    local active = self.Data ~= nil
    self.PanelInfo.gameObject:SetActiveEx(active)
    self.PanelMax.gameObject:SetActiveEx(not active)
    self.BtnCancel.gameObject:SetActiveEx(true)
    self.BtnConfirm.gameObject:SetActiveEx(true)
    self.BtnPackageExchange.gameObject:SetActiveEx(self.Data.TargetId == XDataCenter.ItemManager.ItemId.ActionPoint)
    -- 当前状态
    local num = "?"
    if self.Data.ConsumeId == XDataCenter.ItemManager.ItemId.Coin then
        num = XDataCenter.ItemManager.GetCoinsNum()
    end
    if self.Data.ConsumeId == XDataCenter.ItemManager.ItemId.FreeGem or targetId == XDataCenter.ItemManager.ItemId.PaidGem then
        num = XDataCenter.ItemManager.GetTotalGemsNum()
    end
    if self.Data.ConsumeId == XDataCenter.ItemManager.ItemId.ActionPoint then
        num = XDataCenter.ItemManager.GetActionPointsNum() .. "/" .. XDataCenter.ItemManager.GetMaxActionPoints()
    end
    if self.Data.ConsumeId == XDataCenter.ItemManager.ItemId.SkillPoint then
        num = XDataCenter.ItemManager.GetSkillPointNum()
    end
    if num == "?" then
        local item = XDataCenter.ItemManager.GetItem(self.Data.ConsumeId)
        num = item.Count
        if item.Template.MaxCount > 0 then
            num = num .. "/" .. item.Template.MaxCount
        end
    end
    
    local curStateIcon = XDataCenter.ItemManager.GetItemIcon(self.Data.ConsumeId)
    local curStateName = CS.XTextManager.GetText("AtPresent")
    local curStateCount = num

    -- 消耗道具信息
    local consumeIcon = XDataCenter.ItemManager.GetItemIcon(self.Data.ConsumeId)
    local consumeName = XDataCenter.ItemManager.GetItemName(self.Data.ConsumeId)
    local consumeCount = self.Data.ConsumeCount * (self.BuyAmount or 1)

    -- 获取道具信息
    local targetIcon = XDataCenter.ItemManager.GetItemIcon(self.Data.TargetId)
    local targetName = XDataCenter.ItemManager.GetItemName(self.Data.TargetId)
    local targetCount = self.Data.TargetCount* (self.BuyAmount or 1)

    -- 修改Ui
    self.TxtCurStateName.text = curStateName
    self.TxtCurStateCount.text = curStateCount
    if curStateIcon ~= nil then
        self.RawImageCurState:SetRawImage(curStateIcon)
    end
    
    self.Time.gameObject:SetActiveEx(self.Data.LeftTimes ~= nil)
    self.TxtTimes.text = self.Data.LeftTimes == nil and "∞" or self.Data.LeftTimes
    
    self.TxtConsumeCount.text = consumeCount
    self.TxtConsumeName.text = consumeName
    if consumeIcon ~= nil then
        self.RawImageConsume:SetRawImage(consumeIcon)
    end
    
    self.TxtTargetCount.text = targetCount
    self.TxtTargetName.text = targetName
    if targetIcon ~= nil then
        self.RawImageTarget:SetRawImage(targetIcon)
    end
    
end

function XUiBuyAsset:RefreshChallegeCount(challegeCountData)
    self.ChallegeCountData = challegeCountData

    local active = self.ChallegeCountData.BuyCount < self.ChallegeCountData.BuyChallengeCount
    self.PanelInfo.gameObject:SetActiveEx(active)
    self.PanelMax.gameObject:SetActiveEx(not active)
    self.BtnCancel.gameObject:SetActiveEx(active)
    self.BtnConfirm.gameObject:SetActiveEx(active)

    local num = (self.ChallegeCountData.MaxChallengeNums - self.ChallegeCountData.PassTimesToday) .. " / " .. self.ChallegeCountData.MaxChallengeNums

    local curStateName = CS.XTextManager.GetText("CanChallegeCount")
    local curStateCount = "<color=#FA774FFF>" .. num .. "</color>"

    local consumeName = XDataCenter.ItemManager.GetItemName(XDataCenter.ItemManager.ItemId.FreeGem)
    local consumeCount = self.ChallegeCountData.BuyChallengeCost

    local targetCount = 1
    local targetName = CS.XTextManager.GetText("BuyChallegeDesc")

    self.TxtCurStateName.text = curStateName
    self.TxtCurStateCount.text = curStateCount
    self.TxtTimes.text = self.ChallegeCountData.BuyChallengeCount - self.ChallegeCountData.BuyCount
    self.TxtConsumeCount.text = consumeCount
    self.TxtConsumeName.text = consumeName
    self.TxtTargetCount.text = targetCount
    self.TxtTargetName.text = targetName
end

function XUiBuyAsset:OnBtnChallegeCountClick()
    if not XDataCenter.ItemManager.CheckItemCountById(XDataCenter.ItemManager.ItemId.FreeGem, self.ChallegeCountData.BuyChallengeCost) then
        local itemName = XDataCenter.ItemManager.GetItemName(XDataCenter.ItemManager.ItemId.FreeGem)
        local text = CS.XTextManager.GetText('AssetsBuyConsumeNotEnough', itemName)
        XUiManager.TipMsg(text, XUiManager.UiTipType.Tip)
        return
    end

    local callback = function()
        local name = CS.XTextManager.GetText("BuyChallegeDesc")
        XUiManager.TipMsg(CS.XTextManager.GetText("Buy") .. CS.XTextManager.GetText("Success") .. "," .. CS.XTextManager.GetText("Acquire") .. 1 .. name, XUiManager.UiTipType.Tip)
        if self.SuccessCallback then
            self.SuccessCallback()
        end
        local challegeCountData = XDataCenter.FubenMainLineManager.GetStageBuyChallegeData(self.ChallegeCountData.StageId)
        self:RefreshChallegeCount(challegeCountData)
    end
    XDataCenter.FubenMainLineManager.BuyMainLineChallengeCount(callback, self.ChallegeCountData.StageId)
end

