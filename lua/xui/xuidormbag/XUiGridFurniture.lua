local XUiGridFurniture = XClass()
local attrRed = XFurnitureConfigs.AttrType.AttrA
local attrYellow = XFurnitureConfigs.AttrType.AttrB
local attrBule = XFurnitureConfigs.AttrType.AttrC

function XUiGridFurniture:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self:SetSelected(false)
end

function XUiGridFurniture:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridFurniture:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridFurniture:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridFurniture:AutoAddListener()
    if self.BtnClick then
        self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
    end
end

function XUiGridFurniture:OnBtnClickClick(...)
    local furnitureConfigId = XDataCenter.FurnitureManager.GetFurnitureConfigId(self.FurnitureId)
    XEventManager.DispatchEvent(XEventId.EVENT_CLICKFURNITURE_GRID, self.FurnitureId, furnitureConfigId, self)
end

function XUiGridFurniture:SetSelected(status)
    if self.ImgSelect then 
        self.ImgSelect.gameObject:SetActiveEx(status)
    end
end

function XUiGridFurniture:IsSelected()
    return self.ImgSelect and self.ImgSelect.gameObject.activeSelf
end

function XUiGridFurniture:SetNewActive()
    self.ImgNew.gameObject:SetActiveEx(false)
end

-- 传入家具的唯一Id
function XUiGridFurniture:Refresh(furnitureId)
    self.FurnitureId = furnitureId

    local furnitureConfig = XDataCenter.FurnitureManager.GetFurnitureConfigByUniqueId(furnitureId)
    if not furnitureConfig then
        return
    end

    local quality = XDataCenter.FurnitureManager.GetLevelRewardQuality(furnitureId)

    if self.ImgSelect then 
        self:SetSelected(self.RootUi:GetGridSelected(furnitureId))
    end

    if self.RImgIcon then
        local icon = XDataCenter.FurnitureManager.GetFurnitureIconById(furnitureId, XDormConfig.DormDataType.Self)
        self.RImgIcon:SetRawImage(icon, nil, true)
    end

    if self.ImgQuality then
        self.RootUi:SetUiSprite(self.ImgQuality, XArrangeConfigs.GeQualityBgPath(quality))
    end

    if self.ImgIconQuality then
        XUiHelper.SetQualityIcon(self.RootUi, self.ImgIconQuality, quality)
    end

    if self.TxtFurnitureName then
        self.TxtFurnitureName.text = furnitureConfig.Name
    end

    local furnitureType = XDataCenter.FurnitureManager.GetFurnitureConfigByUniqueId(furnitureId).TypeId
    if self.TxtFurnitureScore then
        local totalScore = XDataCenter.FurnitureManager.GetFurnitureScore(furnitureId)
        self.TxtFurnitureScore.text = XFurnitureConfigs.GetFurnitureTotalAttrLevelDescription(furnitureType, totalScore)
    end

    if self.TxtRedScore then
        local redScore = XDataCenter.FurnitureManager.GetFurnitureRedScore(furnitureId)
        self.TxtRedScore.text = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureType, attrRed, redScore)
    end

    if self.TxtYellowScore then
        local yellowScore = XDataCenter.FurnitureManager.GetFurnitureYellowScore(furnitureId)
        self.TxtYellowScore.text = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureType, attrYellow, yellowScore)
    end

    if self.TxtBlueScore then
        local blueScore = XDataCenter.FurnitureManager.GetFurnitureBlueScore(furnitureId)
        self.TxtBlueScore.text = XFurnitureConfigs.GetFurnitureAttrLevelDescription(furnitureType, attrBule, blueScore)
    end

    if self.ImgNew then
        local showNew = XDataCenter.FurnitureManager.CheckNewHint(furnitureId)
        self.ImgNew.gameObject:SetActiveEx(showNew)

        -- 记入已经查看过 new 标签
        if showNew then
            local ids = {}
            table.insert(ids, self.FurnitureId)
            XDataCenter.FurnitureManager.AddNewHint(ids)
        end
    end

    if self.TxtCount then
        self.TxtCount.gameObject:SetActiveEx(false)
    end

    self:UpdateUsing(furnitureId)
end

function XUiGridFurniture:UpdateUsing(furnitureId)
    if furnitureId ~= self.FurnitureId then
        return
    end

    if self.PanelUsing then 
        self.PanelUsing.gameObject:SetActiveEx(XDataCenter.FurnitureManager.CheckFurnitureUsing(self.FurnitureId))
    end
end

return XUiGridFurniture