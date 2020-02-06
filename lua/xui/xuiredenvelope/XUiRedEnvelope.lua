local tableInsert = table.insert

local XUiGridRedEnvelopeInfo = require("XUi/XUiRedEnvelope/XUiGridRedEnvelopeInfo")

local XUiRedEnvelope = XLuaUiManager.Register(XLuaUi, "UiRedEnvelope")

XUiRedEnvelope.LeaderTemplateId = 0 --指挥官templateId

function XUiRedEnvelope:OnStart(itemId, rewardGoodsList)
    self.ItemId = itemId
    self.ReawrdGoodsList = rewardGoodsList

    self:InitView()
    self:UpdateView()
end

function XUiRedEnvelope:InitView()
    self.BtnTanchuangClose.CallBack = function() self:Close() end

    local itemId = self.ItemId
    self.TxtTitle.text = XDataCenter.ItemManager.GetItemName(itemId)

    self.DynamicTable = XDynamicTableNormal.New(self.PanelDynamicList)
    self.DynamicTable:SetProxy(XUiGridRedEnvelopeInfo)
    self.DynamicTable:SetDelegate(self)
end

function XUiRedEnvelope:UpdateView()
    self.MemberInfos = {}
    local leaderInfo = {
        Id = self.LeaderTemplateId,
        ItemCount = 0,
        IsLuckyBoy = false,
    }

    local maxCount = 0
    for _, v in pairs(self.ReawrdGoodsList) do
        if v.ItemCount > maxCount then
            maxCount = v.ItemCount
        end
    end

    for k, v in pairs(self.ReawrdGoodsList) do
        local count = v.ItemCount
        if v.NpcId == leaderInfo.Id then
            leaderInfo.ItemCount = v.ItemCount
            leaderInfo.ItemId = v.ItemId
            if maxCount and count == maxCount then
                leaderInfo.IsLuckyBoy = true
                maxCount = nil
            end
        else
            local memberInfo = {}
            memberInfo.Id = v.NpcId
            memberInfo.ItemCount = v.ItemCount
            memberInfo.ItemId = v.ItemId
            if maxCount and count == maxCount then
                memberInfo.IsLuckyBoy = true
                maxCount = nil
            end
            tableInsert(self.MemberInfos, memberInfo)
        end
    end

    self.LeaderGrid = self.LeaderGrid or XUiGridRedEnvelopeInfo.New(self.GridLeader, self)
    self.LeaderGrid:Refresh(leaderInfo)

    self.DynamicTable:SetDataSource(self.MemberInfos)
    self.DynamicTable:ReloadDataASync()
end

function XUiRedEnvelope:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:InitParent(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local memberInfo = self.MemberInfos[index]
        grid:Refresh(memberInfo)
    end
end