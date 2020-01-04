local XUiDormBagRecycle = XLuaUiManager.Register(XLuaUi, "UiDormBagRecycle")
local XUiGridFurniture = require("XUi/XUiDormBag/XUiGridFurniture")


function XUiDormBagRecycle:OnAwake()
    self:AddListener()
end

function XUiDormBagRecycle:OnStart(recycleFurnitures, rewardItems)
    self.RecycleItems = {}
    self.RewardItems = {}
    self:Refresh(recycleFurnitures, rewardItems)
end

function XUiDormBagRecycle:Refresh(recycleFurnitures, rewardItems)
    local rewardGridDatas = {}
    local sortedRewardItems = XRewardManager.MergeAndSortRewardGoodsList(rewardItems)
  
    for index, data in pairs(sortedRewardItems) do
        table.insert(rewardGridDatas, { Data = data, GridIndex = index })
    end

    local onCreate = function(item, data)
        item:Refresh(data, false, true, true)
    end

    local onFurnitureCreate = function(item, id)
        item:Refresh(id)
    end

    XUiHelper.CreateTemplates(self, self.RecycleItems, recycleFurnitures, XUiGridFurniture.New, self.GridFurnitureRecycle.gameObject, self.PanelRecycle, onFurnitureCreate)
    XUiHelper.CreateTemplates(self, self.RewardItems, rewardGridDatas, XUiBagItem.New, self.GridFurnitureRecycle.gameObject, self.PanelReward, onCreate)
    self.GridFurnitureRecycle.gameObject:SetActive(false)
end

function XUiDormBagRecycle:AddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end

function XUiDormBagRecycle:OnBtnCloseClick()
    self:Close()
end

return XUiDormBagRecycle