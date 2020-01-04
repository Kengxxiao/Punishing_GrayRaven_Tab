local XUiFurnitureRecycleObtain = XLuaUiManager.Register(XLuaUi, "UiFurnitureRecycleObtain")

function XUiFurnitureRecycleObtain:OnAwake()
    self:AddListener()
end

function XUiFurnitureRecycleObtain:OnStart(furnitureIds, comfirmCb)
    self.Items = {}
    self.ComfirmCb = comfirmCb
    self:Refresh(furnitureIds)
end

function XUiFurnitureRecycleObtain:Refresh(furnitureIds)
    local hintText = CS.XTextManager.GetText("DormFurnitureRecycelComfirm")
    for i = 1, #furnitureIds do
        local isUseing = XDataCenter.FurnitureManager.CheckFurnitureUsing(furnitureIds[i])
        if isUseing then
            hintText = CS.XTextManager.GetText("DormFurnitureRecycelUsingComfirm")
            break
        end
    end

    self.TxtTitle.text = hintText
    local rewards = XDataCenter.FurnitureManager.GetRecycleRewards(furnitureIds)
    XUiHelper.CreateTemplates(self, self.Items, rewards, XUiGridCommon.New, self.GridCommon, self.PanelContent, function(grid, data)
        grid:Refresh(data)
    end)
    self.GridCommon.gameObject:SetActive(false)
end

function XUiFurnitureRecycleObtain:AddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnCancel, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnSure, self.OnBtnSureClick)
end

function XUiFurnitureRecycleObtain:OnBtnCloseClick()
    self:Close()
end

function XUiFurnitureRecycleObtain:OnBtnSureClick()
    self:Close()
    if self.ComfirmCb then 
        self.ComfirmCb()
    end
    XEventManager.DispatchEvent(XEventId.EVENT_DORM_CLOSE_DETAIL)
end

return XUiFurnitureRecycleObtain
