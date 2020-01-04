local XUiPanelBagRecycle = XClass()

function XUiPanelBagRecycle:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.RecycleItems = {}
    self.RewardItems = {}
    self.PanelBagItemRecycle.gameObject:SetActive(false)
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
    XUiHelper.CreateTemplates(self.RootUi, self.RecycleItems, recycleGridDatas, XUiBagItem.New, self.PanelBagItemRecycle.gameObject, self.PanelRecycleA, onCreate)
    XUiHelper.CreateTemplates(self.RootUi, self.RewardItems, rewardGridDatas, XUiBagItem.New, self.PanelBagItemRecycle.gameObject, self.PanelReward, onCreate)
    self.GameObject:SetActive(true)
    self.RootUi:PlayAnimation("AnimTanChuangEnable")
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelBagRecycle:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelBagRecycle:AutoInitUi()
    self.PanelReward = self.Transform:Find("ViewReward/Viewport/PanelReward")
    self.PanelRecycleA = self.Transform:Find("ViewRecycle/Viewport/PanelRecycle")
    self.PanelBagItemRecycle = self.Transform:Find("PanelBagItemRecycle")
    self.RImgStateA = self.Transform:Find("PanelBagItemRecycle/RImgState"):GetComponent("RawImage")
    self.RImgIconD = self.Transform:Find("PanelBagItemRecycle/RImgIcon"):GetComponent("RawImage")
    self.BtnItemTip = self.Transform:Find("PanelBagItemRecycle/BtnItemTip"):GetComponent("Button")
    self.BtnClose = self.Transform:Find("BtnClose"):GetComponent("Button")
end

function XUiPanelBagRecycle:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelBagRecycle:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelBagRecycle:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelBagRecycle:AutoAddListener()
    self:RegisterClickEvent(self.BtnItemTip, self.OnBtnItemTipClick)
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end
-- auto

function XUiPanelBagRecycle:OnBtnItemTipClick(eventData)

end
function XUiPanelBagRecycle:OnBtnCloseClick()
    self.RootUi:PlayAnimation("AnimTanChuangDisable")
    self.GameObject:SetActive(false)
end

return XUiPanelBagRecycle