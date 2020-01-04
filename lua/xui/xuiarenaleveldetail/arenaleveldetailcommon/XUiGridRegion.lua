local XUiGridRegion = XClass()

function XUiGridRegion:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)

    self.GridCommon.gameObject:SetActive(false)

    self.IsShow = true
    self.GameObject:SetActive(true)

    self.DynamicTable = XDynamicTableNormal.New(self.SViewReward.transform)
    self.DynamicTable:SetProxy(XUiGridCommon)
    self.DynamicTable:SetDelegate(self)
end

function XUiGridRegion:Show()
    if self.IsShow then
        return
    end

    self.IsShow = true
    self.GameObject:SetActive(true)
end

function XUiGridRegion:Hide()
    if not self.IsShow then
        return
    end

    self.IsShow = false
    self.GameObject:SetActive(false)
end

--动态列表事件
function XUiGridRegion:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = nil
        if self.DataList then
            data = self.DataList[index]
        end

        grid.RootUi = self.RootUi
        grid:Refresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        grid:OnBtnClickClick()
    end
end

function XUiGridRegion:SetMetaData(region, data)
    self.TxtRankRegion.text = XArenaConfigs.GetRankRegionColorText(region)
    self.SViewReward.gameObject:SetActive(false)

    if (data.ArenaLv == 1 and region == XArenaPlayerRankRegion.DownRegion) or
       (XDataCenter.ArenaManager.IsMaxArenaLevel(data.ArenaLv) and region == XArenaPlayerRankRegion.UpRegion) then
        self.TxtRegionDesc.text = XArenaConfigs.GetRankNotRegionDescText(region)
        return
    end

    self.SViewReward.gameObject:SetActive(true)
    local rewardId = XArenaConfigs.GetRankRegionRewardId(region, data)
    self.TxtRegionDesc.text = XArenaConfigs.GetRankRegionDescText(region, data)
    self:Show()
    
    self.DataList = XRewardManager.GetRewardList(rewardId) or {}
    self.DynamicTable:SetTotalCount(#self.DataList)
    self.DynamicTable:ReloadDataSync()
end

return XUiGridRegion
