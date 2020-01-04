local XUiPanelSelectGift = XClass()

function XUiPanelSelectGift:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self.RewardItems = {}
end

function XUiPanelSelectGift:Refresh(id)
    self.ItemId = id
    self.RewardId = XDataCenter.ItemManager.GetSelectGiftRewardId(id)

    local gridDatas = {}
    local rewardItems = XRewardManager.GetRewardList(self.RewardId)
    for index, data in pairs(rewardItems) do
        table.insert(gridDatas, { Data = data, GridIndex = index })
    end

    local onCreate = function(item, data)
        item:Refresh(data, false, true, true)
    end
    XUiHelper.CreateTemplates(self.RootUi, self.RewardItems, gridDatas, XUiBagItem.New, self.GridRewardItem.gameObject, self.PanelRewardA, onCreate)

    for _, grid in pairs(self.RewardItems) do
        grid:SetClickCallback(function(gridData, grid)
            self:SelectRewardGrid(gridData, grid)
        end)
    end

    self.SelectGridIndexs = {}
    self.SelectCount = 0
    self.LastSelectGrid = nil
    local template = XDataCenter.ItemManager.GetItem(id).Template
    self.SupposedCount = template.SelectCount

    self.TxtGiftName.text = template.Name
    self.TxtCanSelectNum.text = CS.XTextManager.GetText("SelectGiftCount", template.SelectCount)
    self.TxtGfitCount.text = 0

    self.GameObject:SetActive(true)
    self.ImgCantConfirm.gameObject:SetActive(self.SelectCount ~= self.SupposedCount)
    self.BtnConfirm.gameObject:SetActive(self.SelectCount == self.SupposedCount)
    self.RootUi:PlayAnimation("AnimShengDanEnable")
end

function XUiPanelSelectGift:SelectRewardGrid(gridData, grid)
    local id = gridData.Data.TemplateId
    if not self.SelectGridIndexs[id] then
        if self.SupposedCount == 1 then
            if self.LastSelectGrid then
                self.SelectGridIndexs = {}
                self.LastSelectGrid:SetSelectState(false)
                self.SelectCount = 0
            end
            self.LastSelectGrid = grid
        else
            if self.SelectCount >= self.SupposedCount then
                XUiManager.TipText("SelectGiftMaxCount")
                return
            end
        end
        self.SelectCount = self.SelectCount + 1
        self.SelectGridIndexs[id] = gridData.GridIndex
        grid:SetSelectState(true)
    else
        self.SelectCount = self.SelectCount - 1
        self.SelectGridIndexs[id] = nil
        grid:SetSelectState(false)
    end

    self.TxtGfitCount.text = self.SelectCount
    self.BtnConfirm.gameObject:SetActive(self.SelectCount == self.SupposedCount)
    self.ImgCantConfirm.gameObject:SetActive(self.SelectCount ~= self.SupposedCount)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSelectGift:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelSelectGift:AutoInitUi()
    self.TxtGiftName = self.Transform:Find("TxtGiftName"):GetComponent("Text")
    self.TxtCanSelectNum = self.Transform:Find("PaneSelectGiftNum/TxtCanSelectNum"):GetComponent("Text")
    self.TxtGfitCount = self.Transform:Find("PaneSelectGiftNum/TxtGfitCount"):GetComponent("Text")
    self.GridRewardItem = self.Transform:Find("GridRewardItem")
    self.RImgIconE = self.Transform:Find("GridRewardItem/RImgIcon"):GetComponent("RawImage")
    self.PanelRewardA = self.Transform:Find("ViewReward/Viewport/PanelReward")
    self.BtnCloseA = self.Transform:Find("BtnClose"):GetComponent("Button")
    self.BtnConfirm = self.Transform:Find("BtnConfirm"):GetComponent("Button")
    self.ImgCantConfirm = self.Transform:Find("ImgCantConfirm"):GetComponent("Image")
end

function XUiPanelSelectGift:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelSelectGift:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelSelectGift:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelSelectGift:AutoAddListener()
    self:RegisterClickEvent(self.BtnCloseA, self.OnBtnCloseAClick)
    self:RegisterClickEvent(self.BtnConfirm, self.OnBtnConfirmClick)
end
-- auto
function XUiPanelSelectGift:OnBtnCloseAClick(eventData)
    self.GameObject:SetActive(false)
end

function XUiPanelSelectGift:OnBtnConfirmClick(eventData)
    if self.SelectCount ~= self.SupposedCount then return end

    local rewardIds = {}
    for _, index in pairs(self.SelectGridIndexs) do
        table.insert(rewardIds, XRewardManager.GetRewardSubId(self.RewardId, index))
    end

    local callback = function(rewardGoodsList)
        XUiManager.OpenUiObtain(rewardGoodsList, CS.XTextManager.GetText("CongratulationsToObtain"))
    end
    XDataCenter.ItemManager.Use(self.ItemId, nil, 1, callback, rewardIds)

    self.GameObject:SetActive(false)
end

return XUiPanelSelectGift