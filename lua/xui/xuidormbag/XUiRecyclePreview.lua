local XUiRecyclePreview = XClass()

function XUiRecyclePreview:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.SelectFurnitureIds = {}
    self.Rewards = {}
    XTool.InitUiObject(self)

    self:AutoAddListener()
    self:InitDynamicTable()

    self.GridCommonPopUp.gameObject:SetActive(false)
end

function XUiRecyclePreview:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiRecyclePreview:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiRecyclePreview:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiRecyclePreview:AutoAddListener()
    self:RegisterClickEvent(self.BtnRecycleConfirm, self.OnBtnRecycleConfirmClick)
    self:RegisterClickEvent(self.BtnRecycleCancel, self.OnBtnRecycleCancelClick)
end

-- 确认回收
function XUiRecyclePreview:OnBtnRecycleConfirmClick(...)
    if not self.SelectFurnitureIds or #self.SelectFurnitureIds <= 0 then
        XUiManager.TipMsg(CS.XTextManager.GetText("DormFurnitureRecycelNull"), XUiManager.UiTipType.Tip)
        return
    end

    local hintText = CS.XTextManager.GetText("DormFurnitureRecycelComfirm")
    for i = 1, #self.SelectFurnitureIds do
        local isUseing = XDataCenter.FurnitureManager.CheckFurnitureUsing(self.SelectFurnitureIds[i])
        if isUseing then
            hintText = CS.XTextManager.GetText("DormFurnitureRecycelUsingComfirm")
            break
        end
    end

    XUiManager.DialogTip("", hintText, XUiManager.DialogType.Normal, nil, function()
        self:Hide()
        self.RootUi:OnRecycleConfirm()
    end)
end

-- 取消回收
function XUiRecyclePreview:OnBtnRecycleCancelClick(...)
    self.RootUi:PlayAnimation("RecyclePreviewDisable",function ()
        self:Hide()
        self.RootUi:OnRecycleCancel()
    end)
end

function XUiRecyclePreview:Refresh(selectFurnitureIds)
    self.SelectFurnitureIds = selectFurnitureIds

    self.Rewards = XDataCenter.FurnitureManager.GetRecycleRewards(selectFurnitureIds)
    self:UpdateDynamicTable()
end

function XUiRecyclePreview:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelDynamicTablePopUp)
    self.DynamicTable:SetProxy(XUiGridCommon)
    self.DynamicTable:SetDelegate(self)
end

function XUiRecyclePreview:UpdateDynamicTable(bReload)
    self.TxtSelectNum.text = #self.SelectFurnitureIds

    self.DynamicTable:SetDataSource(self.Rewards)
    self.DynamicTable:ReloadDataASync(bReload and 1 or -1)
end

function XUiRecyclePreview:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.RootUi)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:Refresh(self.Rewards[index])
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        XLuaUiManager.Open("UiTip", self.Rewards[index])
    end
end

function XUiRecyclePreview:Hide()
    self.GameObject:SetActive(false)
end

function XUiRecyclePreview:Show()
    self.SelectFurnitureIds = {}
    self.Rewards = {}
    self:UpdateDynamicTable()

    self.GameObject:SetActive(true)
end

function XUiRecyclePreview:IsShow()
    return self.GameObject.activeSelf
end

return XUiRecyclePreview