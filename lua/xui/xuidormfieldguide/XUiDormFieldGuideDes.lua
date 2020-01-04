local XUiDormFieldGuideDesListItem = require("XUi/XUiDormFieldGuide/XUiDormFieldGuideDesListItem")
local XUiDormFieldGuideDes = XClass()

function XUiDormFieldGuideDes:Ctor(ui, uiroot)
    self.DormManager = XDataCenter.DormManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    self.OnBtnClickCb = function() self:OnBtnClick() end
    XTool.InitUiObject(self)
    self.BtnTanchuangClose.CallBack = self.OnBtnClickCb
    self:InitList()
end

function XUiDormFieldGuideDes:OnBtnClick()
    self.UiRoot:PlayAnimation("PanelDesDisable")
    self.GameObject:SetActive(false)
end

-- 更新数据
function XUiDormFieldGuideDes:OnRefresh(itemData)
    if not itemData then
        return
    end

    self.ItemData = itemData
    self.TxtName.text = itemData.Name or ""
    self.TxtSuit.text = XFurnitureConfigs.GetFurnitureSuitName(itemData.SuitId) or ""
    self.TxtDes.text = itemData.Desc or ""
    local iconpath = itemData.Icon
    if iconpath then
        self.UiRoot:SetUiSprite(self.ImgIcon, iconpath)
    end

    local randomGroupId = itemData.RandomGroupId
    if self.PrerandomGroupId ~= randomGroupId then
        self.PrerandomGroupId = randomGroupId
        local d = XFurnitureConfigs.GetGroupRandomIntroduce(randomGroupId, true) or {}

        local listdata = {}

        if itemData.SuitId > 0 then
            local suitBgmInfo = XDormConfig.GetDormSuitBgmInfo(itemData.SuitId)
            if suitBgmInfo then
                table.insert(listdata, CS.XGame.ClientConfig:GetString("DormSuitBgmTitleDesc"))
                local suitDesc = string.format(CS.XGame.ClientConfig:GetString("DormSuitBgmDesc"), suitBgmInfo.SuitNum, ",", suitBgmInfo.Name)
                table.insert(listdata, suitDesc)
            end
        end

        for k1, v1 in pairs(d) do
            table.insert(listdata, k1)
            for k2, v2 in pairs(v1) do
                table.insert(listdata, v2.Introduce)
            end
        end

        self.ListData = listdata
        self.DynamicTable:SetDataSource(listdata)
        self.DynamicTable:ReloadDataASync(1)
    end
end

function XUiDormFieldGuideDes:InitList()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelDesList)
    self.DynamicTable:SetProxy(XUiDormFieldGuideDesListItem)
    self.DynamicTable:SetDelegate(self)
end

-- [监听动态列表事件]
function XUiDormFieldGuideDes:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
    end
end

return XUiDormFieldGuideDes