XUiPanelShopItem = XClass()

local MAX_COUNT = CS.XGame.Config:GetInt("ShopBuyGoodsCountLimit")
function XUiPanelShopItem:Ctor(ui, parent, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self.RootUi = rootUi or parent
    self:InitAutoScript()
    self:SetSelectTextData()
    self.Grid = XUiGridCommon.New(self.RootUi, self.GridBuyCommon)
    self.Price = {}
    table.insert(self.Price, self.PanelCostItem1)
    table.insert(self.Price, self.PanelCostItem2)
    table.insert(self.Price, self.PanelCostItem3)
    
    self.WgtBtnAddSelect = self.BtnAddSelect.gameObject:GetComponent("XUiPointer")
    self.WgtBtnMinusSelect = self.BtnMinusSelect.gameObject:GetComponent("XUiPointer")
    
    XUiButtonLongClick.New(self.WgtBtnAddSelect, 100, self, nil, self.BtnAddSelectLongClickCallback, nil, true)
    XUiButtonLongClick.New(self.WgtBtnMinusSelect, 100, self, nil, self.BtnMinusSelectLongClickCallback, nil, true)
    
    self.MinCount = 1
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelShopItem:InitAutoScript()
    XTool.InitUiObject(self)
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelShopItem:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelShopItem:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelShopItem:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelShopItem:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnBlock, self.OnBtnBlockClick)
    XUiHelper.RegisterClickEvent(self, self.BtnMax, self.OnBtnMaxClick)

    if self.BtnUse then
        self.BtnUse.CallBack =  function ()
            self:OnBtnUseClick()
        end
    end

    if self.BtnAddSelect then
        self.BtnAddSelect.CallBack =  function ()
            self:OnBtnAddSelectClick()
        end
    end

    if self.BtnMinusSelect then
        self.BtnMinusSelect.CallBack =  function ()
            self:OnBtnMinusSelectClick()
        end
    end

    self.TxtSelect.onValueChanged:AddListener(function()
            self:OnSelectTextChange()
        end)

    self.TxtSelect.onEndEdit:AddListener(function()
            self:OnSelectTextInputEnd()
    end)

    if self.BtnTanchuangClose then
        self.BtnTanchuangClose.CallBack =  function ()
            self:OnBtnBlockClick()
        end
    end
end

function XUiPanelShopItem:SetSelectTextData()
    self.TxtSelect.characterLimit = 4
    self.TxtSelect.contentType = CS.UnityEngine.UI.InputField.ContentType.IntegerNumber
end

-- auto
function XUiPanelShopItem:OnBtnBlockClick(...)
    self.GameObject:SetActiveEx(false)
end

function XUiPanelShopItem:OnBtnAddSelectClick(...)
    if self.Count + 1 > self.MaxCount then
        XDataCenter.EquipManager.ShowBoxOverLimitText()
        return
    end
    self.Count = self.Count + 1
    self:RefreshConsumes()
    self:JudgeBuy()
    self.TxtSelect.text = self.Count
    self:SetCanAddOrMinusBtn()
end

function XUiPanelShopItem:OnBtnMinusSelectClick(...)
    if self.Count - 1 < self.MinCount then
        return
    end
    self.Count = self.Count - 1
    self:RefreshConsumes()
    self:JudgeBuy()
    self.TxtSelect.text = self.Count
    self:SetCanAddOrMinusBtn()
end

function XUiPanelShopItem:BtnAddSelectLongClickCallback(time)
    if self.Count + 1 > self.MaxCount then
        XDataCenter.EquipManager.ShowBoxOverLimitText()
        return
    end
    
    local delta = math.max(0, math.floor(time / 150))
    self.Count = self.Count + delta
    if self.MaxCount and self.Count >= self.MaxCount then
        self.Count = self.MaxCount
    end
    
    self:RefreshConsumes()
    self:JudgeBuy()
    self.TxtSelect.text = self.Count
    self:SetCanAddOrMinusBtn()
end

function XUiPanelShopItem:BtnMinusSelectLongClickCallback(time)
    if self.Count - 1 < self.MinCount then
        return
    end
    local delta = math.max(0, math.floor(time / 150))
    self.Count = self.Count - delta
    if self.Count <= 0 then
        self.Count = 0
    end
    self:RefreshConsumes()
    self:JudgeBuy()
    self.TxtSelect.text = self.Count
    self:SetCanAddOrMinusBtn()
end



function XUiPanelShopItem:OnBtnMaxClick(...)
    if self.Count == self.MaxCount then
        return
    end
    self.Count = math.min(self.MaxCount, self.CanBuyCount)
    self:RefreshConsumes()
    self:JudgeBuy()
    self.TxtSelect.text = self.Count
    self:SetCanAddOrMinusBtn()
end

function XUiPanelShopItem:OnSelectTextChange()
    if self.TxtSelect.text == nil or self.TxtSelect.text == "" then
        return
    end
    if self.TxtSelect.text == "0" then
        self.TxtSelect.text = 1
    end
    local tmp = tonumber(self.TxtSelect.text)
    local tmpMax = math.max(math.min(MAX_COUNT, self.MaxCount), 1)
    if tmp > tmpMax then
        tmp = tmpMax
        self.TxtSelect.text = tmp
    end
    self.Count = tmp
    self:RefreshConsumes()
    self:JudgeBuy()
end

function XUiPanelShopItem:OnSelectTextInputEnd()
    if self.TxtSelect.text == nil or self.TxtSelect.text == "" then
        self.TxtSelect.text = 1
        local tmp = tonumber(self.TxtSelect.text)
        self.Count = tmp
        self:RefreshConsumes()
        self:JudgeBuy()
    end
end

function XUiPanelShopItem:SetCanAddOrMinusBtn()
    self.BtnMinusSelect.interactable = self.Count > self.MinCount
    self.BtnAddSelect.interactable = self.MaxCount > self.Count
    self.BtnMax.interactable = self.MaxCount > 1
    self.BtnMax.gameObject:GetComponent("Image").color = self.MaxCount > 1 and CS.UnityEngine.Color(1, 1, 1, 1) or CS.UnityEngine.Color(1, 1, 1, 0.8)
    self.TxtCanBuy.gameObject:SetActiveEx(self.MaxCount < MAX_COUNT)
    self.TxtCanBuy.text = self.MaxCount
end

function XUiPanelShopItem:OnBtnUseClick(...)
    if self.HaveNotBuyCount then
        if not XDataCenter.EquipManager.ShowBoxOverLimitText() then
            XUiManager.TipText("ShopHaveNotBuyCount")
        end
        return
    end

    for k,v in pairs(self.NotEnough or {}) do
        if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(v.ItemId,
                v.UseItemCount,
                1,
                function()
                    self:OnBtnUseClick()
                    end,
                "BuyNeedItemInsufficient") then
            return
        end
        self.NotEnough[k] = nil
    end

    local func = function()
        self.Cb(self.Count)
        XUiManager.TipText("BuySuccess")
        self.Parent:RefreshBuy(true)
        self.GameObject:SetActiveEx(false)
    end
    XShopManager.BuyShop(self.Parent:GetCurShopId(), self.Data.Id, self.Count, func)
end

function XUiPanelShopItem:ShowPanel(data, cb)
    if data then
        self.Data = data
    else
        return
    end

    if cb then
        self.Cb = cb
    end

    self.Count = 1
    self.Consumes = {}
    self.BuyConsumes = {}

    XTool.LoopMap(self.Data.ConsumeList, function(k, consume)
        local buyitem = {}
        buyitem.Id = consume.Id
        buyitem.Count = consume.Count
        table.insert(self.Consumes, buyitem)
        local consumes = {}
        consumes.Id = consume.Id
        consumes.Count = 0
        table.insert(self.BuyConsumes, consumes)
    end)

    self:RefreshCommon()
    self:RefreshPrice()
    self:GetSalesInfo()
    self:GetMaxCount()
    self:RefreshConsumes()
    self:SetCanBuyCount()
    self:JudgeBuy()
    self:HaveItem()
    self:SetCanAddOrMinusBtn()
    self.GameObject:SetActiveEx(true)
    self.TxtSelect.text = self.Count
end

function XUiPanelShopItem:HaveItem()
    if XArrangeConfigs.GetType(self.Data.RewardGoods.TemplateId) == XArrangeConfigs.Types.Furniture then
        self.TxtOwnCount.gameObject:SetActiveEx(false)
    else
        local count = XGoodsCommonManager.GetGoodsCurrentCount(self.Data.RewardGoods.TemplateId)
        self.TxtOwnCount.text = CS.XTextManager.GetText("CurrentlyHas", count)
        self.TxtOwnCount.gameObject:SetActiveEx(true)
    end
end

function XUiPanelShopItem:RefreshCommon()
    self.RImgType.gameObject:SetActiveEx(false)

    local rewardGoods = self.Data.RewardGoods
    self.Grid:Refresh(rewardGoods, nil, true)
    self.Grid:ShowCount(true)
end

function XUiPanelShopItem:RefreshPrice()
    if #self.Consumes ~= 0 then
        self.PanelPrice.gameObject:SetActiveEx(true)
        for i = 1, #self.Price do
            if i <= #self.Consumes then
                self.Price[i].gameObject:SetActiveEx(true)
            else
                self.Price[i].gameObject:SetActiveEx(false)
            end
        end
    else
        self.PanelPrice.gameObject:SetActiveEx(false)
    end
end

function XUiPanelShopItem:RefreshOnSales(buyCount)
    self.OnSales = {}
    XTool.LoopMap(self.Data.OnSales, function(k, sales)
        self.OnSales[k] = sales
    end)
    local sumbuy = buyCount + self.Data.TotalBuyTimes
    if #self.OnSales ~= 0 then
        local curLevel = 0
        for k, v in pairs(self.OnSales) do
            if sumbuy >= k and k > curLevel then
                self.Sales = v
                curLevel = k
            end
        end
    else
        self.Sales = 100
    end
end

function XUiPanelShopItem:RefreshConsumes()
    for i = 1, #self.BuyConsumes do
        self.BuyConsumes[i].Count = 0
    end
    for k, v in pairs(self.Consumes) do
        self.BuyConsumes[k].Id = v.Id
        self.BuyConsumes[k].Count = math.floor(v.Count * self.Sales / 100) * self.Count
    end
    for i = 1, #self.Consumes do
        self["RImgCostIcon" .. i]:SetRawImage(XDataCenter.ItemManager.GetItemBigIcon(self.BuyConsumes[i].Id))
        self["TxtCostCount" .. i].text = math.floor(self.BuyConsumes[i].Count)
    end
end

function XUiPanelShopItem:HidePanel()
    if not XTool.UObjIsNil(self.GameObject) then
        self.GameObject:SetActiveEx(false)
    end
end


function XUiPanelShopItem:GetSalesInfo()
    self.OnSales = {}
    XTool.LoopMap(self.Data.OnSales, function(k, sales)
        self.OnSales[k] = sales
    end)
end

function XUiPanelShopItem:GetMaxCount()
    self.Sales = 100
    local sortedKeys = {}
    for k, _ in pairs(self.OnSales) do
        table.insert(sortedKeys, k)
    end
    table.sort(sortedKeys)

    local leftSalesGoods = MAX_COUNT

    for i = 1, #sortedKeys do
        if self.Data.TotalBuyTimes >= sortedKeys[i] - 1 then
            self.Sales = self.OnSales[sortedKeys[i]]
        else
            leftSalesGoods = sortedKeys[i] - self.Data.TotalBuyTimes - 1
            break
        end
    end

    local leftShopTimes = XShopManager.GetShopLeftBuyTimes(self.Parent:GetCurShopId())
    if not leftShopTimes then
        leftShopTimes = MAX_COUNT
    end

    local leftGoodsTimes = MAX_COUNT
    if self.Data.BuyTimesLimit and self.Data.BuyTimesLimit > 0 then
        local buyCount = self.Data.TotalBuyTimes and self.Data.TotalBuyTimes or 0
        leftGoodsTimes = self.Data.BuyTimesLimit - buyCount
    end
    local tmpMaxCount = math.min(leftGoodsTimes, math.min(leftShopTimes, leftSalesGoods))
    self.MaxCount = tmpMaxCount
    self.MaxCount = XDataCenter.EquipManager.GetMaxCountOfBoxOverLimit(self.Data.RewardGoods.TemplateId,self.MaxCount,self.Data.RewardGoods.Count)
    
    if self.MaxCount < tmpMaxCount then
        self.BuyHintText.text = CS.XTextManager.GetText("MaxCanBuyText")
    else
        self.BuyHintText.text = CS.XTextManager.GetText("CanBuyText")
    end
end

function XUiPanelShopItem:SetCanBuyCount()
    local canBuyCount = self.MaxCount
    for k, v in pairs(self.BuyConsumes) do
        local buyCount = math.floor(XDataCenter.ItemManager.GetItem(v.Id).Count / v.Count)
        canBuyCount = math.min(buyCount, canBuyCount)
    end
    canBuyCount = math.max(self.MinCount, canBuyCount)
    self.CanBuyCount = canBuyCount
end

function XUiPanelShopItem:JudgeBuy()
    self.HaveNotBuyCount = self.Count > self.MaxCount or self.Count == 0
    if self.HaveNotBuyCount then
        return
    end

    local index = 1
    local enoughIndex = {}
    self.NotEnough = {}

    for k, v in pairs(self.BuyConsumes) do
        if v.Count > XDataCenter.ItemManager.GetItem(v.Id).Count then
            self:ChangeCostColor(false, index)
            if not self.NotEnough[index] then self.NotEnough[index] = {} end
            self.NotEnough[index].ItemId = v.Id
            self.NotEnough[index].UseItemCount = v.Count
        else
            table.insert(enoughIndex, index)
        end
        index = index + 1
    end

    for _, v in pairs(enoughIndex) do
        self:ChangeCostColor(true, v)
    end
end


function XUiPanelShopItem:ChangeCostColor(bool, index)
    if bool then
        self["TxtCostCount" .. index].color = CS.UnityEngine.Color(0, 0, 0)
    else
        self["TxtCostCount" .. index].color = CS.UnityEngine.Color(1, 0, 0)
    end
end