local XUiPanelSelectGift = XClass()

function XUiPanelSelectGift:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.RewardItems = {}

    XTool.InitUiObject(self)
    self:AutoAddListener()
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
    XUiHelper.CreateTemplates(self.RootUi, self.RewardItems, gridDatas, XUiBagItem.New, self.GridRewardItem.gameObject, self.PanelReward, onCreate)

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

    self.GameObject:SetActiveEx(true)
    self.ImgCantConfirm.gameObject:SetActiveEx(self.SelectCount ~= self.SupposedCount)
    self.BtnConfirm.gameObject:SetActiveEx(self.SelectCount == self.SupposedCount)
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
    self.BtnConfirm.gameObject:SetActiveEx(self.SelectCount == self.SupposedCount)
    self.ImgCantConfirm.gameObject:SetActiveEx(self.SelectCount ~= self.SupposedCount)
end

function XUiPanelSelectGift:AutoAddListener()
    self.BtnClose.CallBack = function() self:Close() end
    self.BtnCloseAllScreen.CallBack = function() self:Close() end
    self.BtnConfirm.CallBack = function() self:OnBtnConfirmClick() end
end

function XUiPanelSelectGift:OnBtnConfirmClick()
    if self.SelectCount ~= self.SupposedCount then return end

    local rewardIds = {}
    for _, index in pairs(self.SelectGridIndexs) do
        table.insert(rewardIds, XRewardManager.GetRewardSubId(self.RewardId, index))
    end

    local callback = function(rewardGoodsList)
        XUiManager.OpenUiObtain(rewardGoodsList, CS.XTextManager.GetText("CongratulationsToObtain"))
    end
    XDataCenter.ItemManager.Use(self.ItemId, nil, 1, callback, rewardIds)

    self:Close()
end

function XUiPanelSelectGift:Close()
    self.GameObject:SetActiveEx(false)
end

return XUiPanelSelectGift