local SECOND_CHECK_EQUIP_STAR = 4 --超过（包含）这个星星的装备分解时需要二次确认
local SECOND_CHECK_ITEM_QUALITY = 5 --超过（包含）这个品质的物品出售时需要二次确认

local XUiPanelSidePopUp = XClass()

function XUiPanelSidePopUp:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self.SelectCount = 0

    self:InitAutoScript()
    self:InitDynamicTable()

    self.GridCommonPopUp.gameObject:SetActive(false)
end

function XUiPanelSidePopUp:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelDynamicTablePopUp)
    self.DynamicTable:SetProxy(XUiGridCommon)
    self.DynamicTable:SetDelegate(self)
end

function XUiPanelSidePopUp:UpdateDynamicTable(bReload)
    self.DynamicTable:SetDataSource(self.Rewards)
    self.DynamicTable:ReloadDataASync(bReload and 1 or -1)
end

function XUiPanelSidePopUp:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.Parent)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:Refresh(self.Rewards[index])
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        XLuaUiManager.Open("UiTip", self.Rewards[index])
    end
end

function XUiPanelSidePopUp:Refresh()
    if self.Parent.Operation == self.Parent.OperationType.Common then
        self.Parent:PlayAnimation("AnimChuShouDisable",function()
            self.CurState = false
            self.GameObject:SetActive(false)
        end)
        
    else
        if self.Parent.Operation == self.Parent.OperationType.Decomposion then
            self.PanelNumBtn.gameObject:SetActive(false)
            self.PanelSellPopUp.gameObject:SetActive(false)
            self.PanelConvertPopUp.gameObject:SetActive(false)
            self.TxtTitle.text = CS.XTextManager.GetText("DecomposeTitle")
            self.PanelDecomposionPopUp.gameObject:SetActive(true)
            self.PanelFilterPopUp.gameObject:SetActive(true)
            self.PanelSelectNum.gameObject:SetActive(true)

            --再次打开侧边栏时toggle清空选中状态
            for i = 1,4 do
                self["TogStar" .. i .. "PopUp"].isOn = false
            end

            self:RefreshDecomposionPreView()
        else
            if self.Parent.Operation == self.Parent.OperationType.Sell then
                self.PanelConvertPopUp.gameObject:SetActive(false)
                self.TxtTitle.text = CS.XTextManager.GetText("SellTitle")
                self.PanelSellPopUp.gameObject:SetActive(true)
            elseif self.Parent.Operation == self.Parent.OperationType.Convert then
                self.PanelSellPopUp.gameObject:SetActive(false)
                self.TxtTitle.text = CS.XTextManager.GetText("ConverseTitle")
                self.PanelConvertPopUp.gameObject:SetActive(true)
            end
            self.PanelDecomposionPopUp.gameObject:SetActive(false)
            self.PanelFilterPopUp.gameObject:SetActive(false)
            self.PanelSelectNum.gameObject:SetActive(false)
            self.PanelNumBtn.gameObject:SetActive(true)
            self:RefreshSellPreView()
        end
        self.GameObject:SetActive(true)
        self.CurState = true
        self.Parent:PlayAnimation("AnimChuShouEnable")
    end
end

function XUiPanelSidePopUp:RefreshDecomposionPreView(selectEquipIds, cancelStar)
    self.SelectEquipIds = {}
    if selectEquipIds then
        for _, equipId in pairs(selectEquipIds) do
            table.insert(self.SelectEquipIds, equipId)
        end
    end

    self.TxtSelectNum.text = #self.SelectEquipIds

    local cantDecompose = not next(self.SelectEquipIds)
    self.ImgCantDecomposionPopUp.gameObject:SetActive(cantDecompose)
    self.BtnDecomposionPopUp.gameObject:SetActive(not cantDecompose)

    self.Rewards = XDataCenter.EquipManager.GetDecomposeRewards(self.SelectEquipIds)
    if #self.Rewards == 1 then
        if not self.SingleItemGrid then
            self.SingleItemGrid = XUiGridCommon.New(self.Parent, self.GridCommonPopUp)
        end

        self.SingleItemGrid:Refresh(self.Rewards[1])
        self.SingleItemGrid.GameObject:SetActive(true)
        self.PanelDynamicTablePopUp.gameObject:SetActive(false)
    else
        self:UpdateDynamicTable()

        if self.SingleItemGrid then
            self.SingleItemGrid.GameObject:SetActive(false)
        end
        self.PanelDynamicTablePopUp.gameObject:SetActive(true)
    end

    --取消选中时星星筛选tog状态置false
    if cancelStar and self["TogStar" .. cancelStar .. "PopUp"] then
        self["TogStar" .. cancelStar .. "PopUp"].isOn = false
    end
end

function XUiPanelSidePopUp:RefreshSellPreView(selectItemId, count, selectGrid)
    self.SelectItemId = selectItemId
    self.SelectCount = count or 0
    self.SelectGrid = selectGrid or self.SelectGrid
    self.GridMaxCount = self.SelectGrid and self.SelectGrid:GetGridCount() or self.GridMaxCount

    local cantSell = not self.SelectItemId or not self.SelectCount or self.SelectCount == 0
    if self.Parent.Operation == self.Parent.OperationType.Sell then
        self.BtnSellPopUp.gameObject:SetActive(not cantSell)
        self.ImgCantSellPopUp.gameObject:SetActive(cantSell)
    elseif self.Parent.Operation == self.Parent.OperationType.Convert then
        self.BtnConvertPopUp.gameObject:SetActive(not cantSell)
        self.ImgCantConvertPopUp.gameObject:SetActive(cantSell)
    end
    self.TxtNumA.text = self.SelectCount

    local showSub = self.SelectCount ~= 0
    self.BtnSub.gameObject:SetActive(showSub)
    self.ImgCantSub.gameObject:SetActive(not showSub)

    local showAdd = self.SelectItemId and (not self.GridMaxCount or self.SelectCount ~= self.GridMaxCount) 
    self.BtnAdd.gameObject:SetActive(showAdd)
    self.ImgCantAdd.gameObject:SetActive(not showAdd)

    local reward = XDataCenter.ItemManager.GetSellReward(self.SelectItemId, count)
    if not next(reward) then
        if self.SingleItemGrid then
            self.SingleItemGrid.GameObject:SetActive(false)
        end
    else
        if not self.SingleItemGrid then
            self.SingleItemGrid = XUiGridCommon.New(self.Parent, self.GridCommonPopUp)
        end
        self.SingleItemGrid:Refresh(reward)
        self.SingleItemGrid.GameObject:SetActive(true)
    end
    self.PanelDynamicTablePopUp.gameObject:SetActive(false)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSidePopUp:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelSidePopUp:AutoInitUi()
    self.GridCommonPopUp = self.Transform:Find("GridCommonPopUp")
    self.RImgIconC = self.Transform:Find("GridCommonPopUp/RImgIcon"):GetComponent("RawImage")
    self.PanelDynamicTablePopUp = self.Transform:Find("PanelDynamicTablePopUp")
    self.PanelFilterPopUp = self.Transform:Find("PanelFilterPopUp")
    self.TogStar1PopUp = self.Transform:Find("PanelFilterPopUp/TogStar1PopUp"):GetComponent("Toggle")
    self.TogStar2PopUp = self.Transform:Find("PanelFilterPopUp/TogStar2PopUp"):GetComponent("Toggle")
    self.TogStar3PopUp = self.Transform:Find("PanelFilterPopUp/TogStar3PopUp"):GetComponent("Toggle")
    self.TogStar4PopUp = self.Transform:Find("PanelFilterPopUp/TogStar4PopUp"):GetComponent("Toggle")
    self.PanelNumBtn = self.Transform:Find("PanelNumBtn")
    self.BtnSub = self.Transform:Find("PanelNumBtn/BtnSub"):GetComponent("Button")
    self.TxtNumA = self.Transform:Find("PanelNumBtn/TxtNum"):GetComponent("Text")
    self.BtnAdd = self.Transform:Find("PanelNumBtn/BtnAdd"):GetComponent("Button")
    self.BtnMax = self.Transform:Find("PanelNumBtn/BtnMax"):GetComponent("Button")
    self.ImgCantSub = self.Transform:Find("PanelNumBtn/ImgCantSub"):GetComponent("Image")
    self.ImgCantAdd = self.Transform:Find("PanelNumBtn/ImgCantAdd"):GetComponent("Image")
    self.PanelSelectNum = self.Transform:Find("PanelSelectNum")
    self.TxtDes = self.Transform:Find("PanelSelectNum/TxtDes"):GetComponent("Text")
    self.TxtSelectNum = self.Transform:Find("PanelSelectNum/TxtSelectNum"):GetComponent("Text")
    self.PanelSellPopUp = self.Transform:Find("BottomBtns/PanelSellPopUp")
    self.BtnSellPopUp = self.Transform:Find("BottomBtns/PanelSellPopUp/BtnSellPopUp"):GetComponent("Button")
    self.ImgCantSellPopUp = self.Transform:Find("BottomBtns/PanelSellPopUp/ImgCantSellPopUp"):GetComponent("Image")
    self.TxtTitle = self.Transform:Find("TxtTitle"):GetComponent("Text")
    self.PanelDecomposionPopUp = self.Transform:Find("BottomBtns/PanelDecomposionPopUp")
    self.BtnDecomposionPopUp = self.Transform:Find("BottomBtns/PanelDecomposionPopUp/BtnDecomposionPopUp"):GetComponent("Button")
    self.ImgCantDecomposionPopUp = self.Transform:Find("BottomBtns/PanelDecomposionPopUp/ImgCantDecomposionPopUp"):GetComponent("Image")
    self.PanelConvertPopUp = self.Transform:Find("BottomBtns/PanelConvertPopUp")
    self.ImgCantConvertPopUp = self.Transform:Find("BottomBtns/PanelConvertPopUp/ImgCantConvertPopUp"):GetComponent("Image")
    self.BtnConvertPopUp = self.Transform:Find("BottomBtns/PanelConvertPopUp/BtnConvertPopUp"):GetComponent("Button")
    self.BtnCha = self.Transform:Find("BottomBtns/BtnCha"):GetComponent("Button")
end

function XUiPanelSidePopUp:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelSidePopUp:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelSidePopUp:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelSidePopUp:AutoAddListener()
    self:RegisterClickEvent(self.TogStar1PopUp, self.OnTogStar1PopUpClick)
    self:RegisterClickEvent(self.TogStar2PopUp, self.OnTogStar2PopUpClick)
    self:RegisterClickEvent(self.TogStar3PopUp, self.OnTogStar3PopUpClick)
    self:RegisterClickEvent(self.TogStar4PopUp, self.OnTogStar4PopUpClick)
    self:RegisterClickEvent(self.BtnSub, self.OnBtnSubClick)
    self:RegisterClickEvent(self.BtnAdd, self.OnBtnAddClick)
    self:RegisterClickEvent(self.BtnMax, self.OnBtnMaxClick)
    self:RegisterClickEvent(self.BtnSellPopUp, self.OnBtnSellPopUpClick)
    self:RegisterClickEvent(self.BtnDecomposionPopUp, self.OnBtnDecomposionPopUpClick)
    self:RegisterClickEvent(self.BtnConvertPopUp, self.OnBtnConvertPopUpClick)
    self:RegisterClickEvent(self.BtnCha, self.OnBtnChaClick)
end
-- auto
function XUiPanelSidePopUp:OnBtnSubClick(eventData)
    self:RefreshSellPreView(self.SelectItemId, self.SelectCount - 1)
end

function XUiPanelSidePopUp:OnBtnAddClick(eventData)
    self:RefreshSellPreView(self.SelectItemId, self.SelectCount + 1)
end

function XUiPanelSidePopUp:OnBtnMaxClick(eventData)
    if not self.SelectItemId then return end
    self:RefreshSellPreView(self.SelectItemId, self.SelectGrid:GetGridCount())
end

function XUiPanelSidePopUp:OnTogStar1PopUpClick(eventData)
    self.Parent:SelectByStar(1, self.TogStar1PopUp.isOn)
end

function XUiPanelSidePopUp:OnTogStar2PopUpClick(eventData)
    self.Parent:SelectByStar(2, self.TogStar2PopUp.isOn)
end

function XUiPanelSidePopUp:OnTogStar3PopUpClick(eventData)
    self.Parent:SelectByStar(3, self.TogStar3PopUp.isOn)
end

function XUiPanelSidePopUp:OnTogStar4PopUpClick(eventData)
    self.Parent:SelectByStar(4, self.TogStar4PopUp.isOn)
end

function XUiPanelSidePopUp:OnBtnSellPopUpClick(eventData)
    if not self.SelectItemId or not self.SelectCount or self.SelectCount == 0 then return end

    local sellFunc = function()
        local datas = {[self.SelectItemId] = self.SelectCount }
        XDataCenter.ItemManager.Sell(datas, function(rewardGoodDic)
            self.Parent:OperationTurn(self.Parent.OperationType.Sell)

            local rewards = {}
            for key, value in pairs(rewardGoodDic) do
                table.insert(rewards, { TemplateId = key, Count = value })
            end
            XUiManager.OpenUiObtain(rewards)
        end)
    end

    local quality = XDataCenter.ItemManager.GetItemQuality(self.SelectItemId)
    if quality >= SECOND_CHECK_ITEM_QUALITY then
        local title = CS.XTextManager.GetText("SellConfirmTitle")
        local content = CS.XTextManager.GetText("SellConfirmTip")

        XUiManager.DialogTip(title, content, XUiManager.DialogType.Normal, nil, function()
            sellFunc()
        end)

        return
    end

    sellFunc()
end

function XUiPanelSidePopUp:OnBtnDecomposionPopUpClick(eventData)
    local decomposeFunc = function()
        XDataCenter.EquipManager.EquipDecompose(self.SelectEquipIds, function(rewardGoodsList)
            self.Parent:OperationTurn(self.Parent.OperationType.Decomposion)
            if (#rewardGoodsList > 0) then
                XUiManager.OpenUiObtain(rewardGoodsList)
            end
        end)
    end

    for _, equipId in pairs(self.SelectEquipIds) do
        local equip = XDataCenter.EquipManager.GetEquip(equipId)
        local star = XDataCenter.EquipManager.GetEquipStar(equip.TemplateId)

        if star >= SECOND_CHECK_EQUIP_STAR then
            local title = CS.XTextManager.GetText("DecomposeConfirmTitle")
            local content = CS.XTextManager.GetText("DecomposeConfirmTip")

            XUiManager.DialogTip(title, content, XUiManager.DialogType.Normal, nil, function()
                decomposeFunc()
            end)

            return
        end
    end

    decomposeFunc()
end

function XUiPanelSidePopUp:OnBtnConvertPopUpClick(eventData)
    if not self.SelectItemId or not self.SelectCount or self.SelectCount == 0 then return end

    local datas = {[self.SelectItemId] = self.SelectCount }
    XDataCenter.ItemManager.Sell(datas, function(rewardGoodDic)
        self.Parent:OperationTurn(self.Parent.OperationType.Convert)

        local rewards = {}
        for key, value in pairs(rewardGoodDic) do
            table.insert(rewards, { TemplateId = key, Count = value })
        end
        XUiManager.OpenUiObtain(rewards)
    end)
end

function XUiPanelSidePopUp:OnBtnChaClick(eventData)
    self.Parent:OperationTurn(self.Parent.OperationType.Common)
end

return XUiPanelSidePopUp