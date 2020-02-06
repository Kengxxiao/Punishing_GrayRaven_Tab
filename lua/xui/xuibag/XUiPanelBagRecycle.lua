local XUiPanelBagRecycle = XClass()

function XUiPanelBagRecycle:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RecycleItems = {}
    self.RewardItems = {}

    XTool.InitUiObject(self)
    self:AutoAddListener()

    self.GridBagItemRecycle.gameObject:SetActive(false)
end

function XUiPanelBagRecycle:Refresh(recycleItems, rewardItems)
    local recycleGridDatas = {}
    for index, item in pairs(recycleItems) do
        table.insert(recycleGridDatas, { Data = XRewardManager.CreateRewardGoods(item.Id, item.Count), GridIndex = index })
    end

    local rewardGridDatas = {}
    local sortedRewardItems = XRewardManager.MergeAndSortRewardGoodsList(rewardItems)
    for index, data in pairs(sortedRewardItems) do
        table.insert(rewardGridDatas, { Data = data, GridIndex = index })
    end

    local onCreate = function(item, data)
        item:Refresh(data, false, true, true)
    end
    XUiHelper.CreateTemplates(self.RootUi, self.RecycleItems, recycleGridDatas, XUiBagItem.New, self.GridBagItemRecycle.gameObject, self.PanelRecycle, onCreate)
    XUiHelper.CreateTemplates(self.RootUi, self.RewardItems, rewardGridDatas, XUiBagItem.New, self.GridBagItemRecycle.gameObject, self.PanelReward, onCreate)
    self.GameObject:SetActive(true)
    self.RootUi:PlayAnimation("AnimTanChuangEnable")
end

function XUiPanelBagRecycle:AutoAddListener()
    self.BtnClose.CallBack = function() self:OnBtnCloseClick() end
end

function XUiPanelBagRecycle:OnBtnCloseClick()
    self.RootUi:PlayAnimation("AnimTanChuangDisable")
    self.GameObject:SetActive(false)
end

return XUiPanelBagRecycle