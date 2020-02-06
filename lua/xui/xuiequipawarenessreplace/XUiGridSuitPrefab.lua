local CSXTextManagerGetText = CS.XTextManager.GetText

local CurSuitName = CSXTextManagerGetText("EquipSuitPrefabCurName")

local XUiGridSuitPrefab = XClass()

function XUiGridSuitPrefab:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self.PanelSelect.gameObject:SetActiveEx(false)
end

function XUiGridSuitPrefab:Refresh(suitPrefabInfo, suitPrefabIndex, isPreafabSaved)
    self.SuitPrefabIndex = suitPrefabIndex

    -- 套装预设序号
    if isPreafabSaved then
        self.TxtOrder.text = "0" .. suitPrefabIndex
        self.TxtOrder.gameObject:SetActiveEx(true)
    else
        self.TxtOrder.gameObject:SetActiveEx(false)
    end

    -- 套装预设图标
    local presentSuitId = suitPrefabInfo:GetPresentSuitId()
    if presentSuitId then
        self.RImgIcon:SetRawImage(XDataCenter.EquipManager.GetSuitBigIconBagPath(presentSuitId))
        self.ImgDefaultIcon.gameObject:SetActiveEx(false)
        self.RImgIcon.gameObject:SetActiveEx(true)
    else
        self.ImgDefaultIcon.gameObject:SetActiveEx(true)
        self.RImgIcon.gameObject:SetActiveEx(false)
    end

    -- 套装预设名字
    self.TxtName.text = isPreafabSaved and suitPrefabInfo:GetName() or CurSuitName

    -- 套装预设数量
    local equipCount = suitPrefabInfo:GetEquipCount()
    local maxCount = XEquipConfig.MAX_SUIT_COUNT
    if equipCount == maxCount then
        self.TxtNum.text = CSXTextManagerGetText("EquipSuitPrefabCountMax", equipCount, maxCount)
    else
        self.TxtNum.text = CSXTextManagerGetText("EquipSuitPrefabCount", equipCount, maxCount)
    end
end

function XUiGridSuitPrefab:SetSelected(selected)
    self.PanelSelect.gameObject:SetActiveEx(selected)
end

return XUiGridSuitPrefab