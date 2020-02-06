-- 家具摆放界面
local XUiFurnitureReform = XLuaUiManager.Register(XLuaUi, "UiFurnitureReform")

local XUiPanelMenu = require("XUi/XUiDorm/XUiFurnitureReform/XUiPanelMenu")
local XUiFurnitureAttrGrid = require("XUi/XUiDorm/XUiFurnitureReform/XUiFurnitureAttrGrid")

local FurnitureCache = {}
local delayRefreshTimer = nil
local delayUpdateScoresTimer = nil

function XUiFurnitureReform:OnAwake()
    self.SuitCFG = XFurnitureConfigs.GetFurnitureSuitTemplates()
    self.RefreshFurnitureList = function() self:RefreshFurntiureReform() end
    XEventManager.AddEventListener(XEventId.EVENT_FURNITURE_ON_MODIFY, self.RefreshFurnitureList, self)

    self.BtnFilter.CallBack = function() self:OnBtnFilterClick() end
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnRecover.CallBack = function() self:OnBtnRecoverClick() end
    self.BtnUndo.CallBack = function() self:OnBtnUndoClick() end
    self.BtnSaveAndQuit.CallBack = function() self:OnBtnSaveClick() end
    self.BtnExplain.CallBack = function() self:OnBtnExplainClick() end
    self.BtnFilterBack.CallBack = function() self:OnBtnFilterBackClick() end
    self:RegisterClickEvent(self.BtnDrdSort, self.OnBtnShowDormAttr)


end

function XUiFurnitureReform:OnStart(roomId)
    self.PanelMenu.gameObject:SetActive(false)

    self.MenuPanel = XUiPanelMenu.New(self, self.PanelMenu)
    self.MainPanelGo = self.Transform:Find("SafeAreaContentPane").gameObject

    XHomeDormManager.SetClickFurnitureCallback(function(furniture) self:ShowFurnitureMenu(furniture, false, false) end)
    XHomeCharManager.HideAllCharacter()
    self.CameraController = XHomeSceneManager.GetSceneCameraController()
    if not XTool.UObjIsNil(self.CameraController) then
        self.OldCameraDistance = self.CameraController.Distance
        self.OldCameraTarget = self.CameraController.TargetObj
        self.TargetAngleX = self.CameraController.TargetAngleX
        self.TargetAngleY = self.CameraController.TargetAngleY
        XCameraHelper.SetCameraTarget(self.CameraController, self.OldCameraTarget, 13)
    end

    self.RoomId = roomId
    self.GridSuitPool = {}
    self.GridBaseTypePool = {}
    self.GridSubTypePool = {}
    self.BtnTabGoList = {}
    self.PanelFilterGameObject = self.PanelFilter.gameObject
    self.CurrentBaseTypeId = nil
    self.CurrentSubTypeId = nil
    self.CurrentSuitId = 1--by default
    self.DefaultBaseType = CS.XGame.ClientConfig:GetInt("UiFurnitureReformDefaultBaseType")
    self:Init()
end


function XUiFurnitureReform:OnDisable()
    XHomeDormManager.SetClickFurnitureCallback(nil)

    XHomeDormManager.AttachSurfaceToRoom()
end

function XUiFurnitureReform:OnHideBlockGrids()
    if self.CurFurniture then
        XHomeDormManager.OnHideBlockGrids(self.CurFurniture.HomePlatType, self.CurFurniture.RotateAngle)
    end
end
function XUiFurnitureReform:OnBtnCancelClick()
    if self.RoomId then
        XHomeDormManager.RevertRoom(self.RoomId)
        self:CloseFurnitureReform()
    end
end

function XUiFurnitureReform:OnBtnBackClick(...)
    if self.RoomId and XHomeDormManager.IsNeedSave(self.RoomId) then

        XUiManager.DialogTip(CS.XTextManager.GetText("FurnitureTips"), CS.XTextManager.GetText("FurnitureIsSave"), XUiManager.DialogType.Normal, function()
            XHomeDormManager.RevertRoom(self.RoomId)
            self:CloseFurnitureReform()
        end, function()
            XHomeDormManager.SaveRoomModification(self.RoomId, function()
                self:CloseFurnitureReform()
            end)
        end)
    else
        self:CloseFurnitureReform()
    end
end

function XUiFurnitureReform:CloseFurnitureReform()
    self:RestoreViewAngles()
    self:Close()
end

function XUiFurnitureReform:OnBtnShowDormAttr()

    if self.FurnitureTagTypeShow then
        self.Template.gameObject:SetActiveEx(false)
        self.FurnitureTagTypeShow = false
        return
    end

    self.FurnitureTagTypeShow = true
    self.Template.gameObject:SetActiveEx(true)
    self.DynamicTable:SetTotalCount(#self.FurnitureTagType)
    self.DynamicTable:ReloadDataSync()
end

function XUiFurnitureReform:OnBtnFilterClick(...)
    self:ShowPanelFilter()
end

function XUiFurnitureReform:OnBtnFilterBackClick(...)
    self:HidePanelFilter()
end

-- 全部收起
function XUiFurnitureReform:OnBtnRecoverClick(...)
    XUiManager.DialogTip(CS.XTextManager.GetText("FurnitureTips"), CS.XTextManager.GetText("FurnitureCleanRoom"), XUiManager.DialogType.Normal, nil, function()
        XHomeDormManager.CleanRoom(self.RoomId)
    end)
end

-- 重置房间
function XUiFurnitureReform:OnBtnUndoClick(...)
    XUiManager.DialogTip(CS.XTextManager.GetText("FurnitureTips"), CS.XTextManager.GetText("FurnitureRevertRoom"), XUiManager.DialogType.Normal, nil, function()
        XHomeDormManager.RevertRoom(self.RoomId)
        CsXGameEventManager.Instance:Notify(XEventId.EVENT_DORM_FURNITURE_ATTR_TAG, self.FurnitureTagType[self.SelectIndex].AttrIndex)
    end)
end

-- 保存房间
function XUiFurnitureReform:OnBtnSaveClick(...)
    XHomeDormManager.SaveRoomModification(self.RoomId)
end

function XUiFurnitureReform:OnBtnExplainClick(...)
    XUiManager.UiFubenDialogTip(CS.XTextManager.GetText("DormDes"), CS.XTextManager.GetText("FurnitureDescription") or "")
end

-- 显示家具菜单
function XUiFurnitureReform:ShowFurnitureMenu(furniture, isFollowMouse, isNew)
    self.MainPanelGo:SetActive(not furniture)
    local isOutOfLimit = false
    if furniture and (not XDataCenter.FurnitureManager.CheckFurnitureUsing(furniture.Data.Id)) then
        local minorType = XFurnitureConfigs.GetFurnitureTypeCfgByConfigId(furniture.Data.CfgId).MinorType
        local curLength = XHomeDormManager.GetFurnitureNumsByRoomAndMinor(self.RoomId, minorType)
        local curCapacity = XHomeDormManager.GetFurnitureCapacityByRoomANdMinor(self.RoomId, minorType)
        isOutOfLimit = (curCapacity > 0) and (curLength >= curCapacity) or false
    end
    self.MenuPanel:SetFurniture(furniture, isFollowMouse, isNew, isOutOfLimit)

    self.CurFurniture = furniture
    self:OnShowBlockGrids()
end

function XUiFurnitureReform:OnShowBlockGrids()
    if self.CurFurniture then
        XHomeDormManager.OnShowBlockGrids(self.CurFurniture.HomePlatType, self.CurFurniture.GridOffset, self.CurFurniture.RotateAngle)
    end
end

--初始化begin
function XUiFurnitureReform:Init()
    self:RestoreCache()

    self.SViewFurniture = XUiPanelSViewFurniture.New(self.PanelSViewFurniture, self)
    --初始化家具类型
    self.TypeList = XFurnitureConfigs.GetFurnitureTypeGroupList()
    self.FurnitureGroupList = self:GenerateFurnitureGroupList(self.TypeList)
    self:InitFurnitureTabGroup()

    self.GridOption.gameObject:SetActive(false)
    if not self.SuitCFG then
        XLog.Warning("XUiFurnitureReform:Init error: self.SuitCFG is nil")
    end

    self:InitFurnitureAttrTag()

    if not self.DynamicTableSuit then
        self.DynamicTableSuit = XDynamicTableNormal.New(self.SViewFilter.gameObject)
        self.DynamicTableSuit:SetProxy(XUiGridOption)
        self.DynamicTableSuit:SetDelegate(self)
    end
    self:UpdateScores()
    self:SwitchSuitFilter(self.CurrentSuitId or 1)
end

function XUiFurnitureReform:InitFurnitureAttrTag()

    self.FurnitureTagType = XFurnitureConfigs.GetFurnitureTagTypeTemplates()
    self.FurnitureTagTypeShow = false


    --local key = tostring(XPlayer.Id) .. "FurnitureAttr"
    self.SelectIndex = 1
    XHomeDormManager.FurnitureShowAttrType = -1
    -- local index = CS.UnityEngine.PlayerPrefs.GetInt(key, 1)
    -- for k, v in ipairs(self.FurnitureTagType) do
    --     if v.AttrIndex == index then
    --         self.SelectIndex = k
    --     end
    -- end

    self.BtnDrdSortLabel.text = self.FurnitureTagType[self.SelectIndex].TagName

    --家具属性tips
    self.DynamicTable = XDynamicTableNormal.New(self.Template)
    self.DynamicTable:SetProxy(XUiFurnitureAttrGrid)
    self.DynamicTable:SetDelegate(self)
    self.DynamicTable:SetDynamicEventDelegate(function(...)
        self:OnFurnitureAttrDynamicTableEvent(...)
    end)


    self.SelectGrid = nil

    CsXGameEventManager.Instance:Notify(XEventId.EVENT_DORM_FURNITURE_ATTR_TAG, self.FurnitureTagType[self.SelectIndex].AttrIndex)

end

function XUiFurnitureReform:GenerateFurnitureGroupList(typeList)
    local groupList = {}

    for i = 1, #self.TypeList do
        local typeList = self.TypeList[i]
        table.insert(groupList, {
            MinorType = typeList.MinorType,
            MinorName = typeList.MinorName,
            isBaseType = true
        })
        local subIndex = #groupList
        for i = 1, #typeList.CategoryList do
            local categoryData = typeList.CategoryList[i]
            table.insert(groupList, {
                MinorType = typeList.MinorType,
                MinorName = typeList.MinorName,
                SubIndex = subIndex,
                CategoryType = categoryData.Category,
                CategoryName = categoryData.CategoryName,
            })
        end
    end
    return groupList
end

function XUiFurnitureReform:InitFurnitureTabGroup()
    for i = 1, #self.FurnitureGroupList do
        local tempGroup = self.FurnitureGroupList[i]
        if not self.BtnTabGoList[i] then
            local tempBtnTab
            if tempGroup.SubIndex and tempGroup.SubIndex > 0 then
                tempBtnTab = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("BtnTabFurnitureSubType"))
            else
                tempBtnTab = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("BtnTabFurnitureBaseType"))
            end
            tempBtnTab.transform:SetParent(self.TabGroupContent.transform, false)
            local uiButton = tempBtnTab:GetComponent("XUiButton")
            uiButton.SubGroupIndex = tempGroup.SubIndex
            table.insert(self.BtnTabGoList, uiButton)
        end
        self.BtnTabGoList[i].gameObject:SetActive(true)
    end

    for i = #self.FurnitureGroupList + 1, #self.BtnTabGoList do
        self.BtnTabGoList[i].gameObject:SetActive(false)
    end
    self.TabFurnitureGroup:Init(self.BtnTabGoList, function(index) self:OnSelectFurnitureType(index) end)

    for i = 0, #self.FurnitureGroupList - 1 do
        local furnitureGroup = self.FurnitureGroupList[i + 1]
        if furnitureGroup then
            if furnitureGroup.SubIndex and furnitureGroup.SubIndex > 0 then
                self.TabFurnitureGroup.TabBtnList[i]:SetNameByGroup(0, furnitureGroup.CategoryName)

                local count = 0
                local categoryList = self:GetCategoryListByMinorType(furnitureGroup.MinorType)
                if #categoryList <= 0 then
                    count = self:GetBaseTypeCount(furnitureGroup.MinorType)
                else
                    if furnitureGroup.CategoryType == 0 then
                        count = self:GetBaseTypeCount(furnitureGroup.MinorType)
                    else
                        count = self:GetSubTypeCount(furnitureGroup.MinorType, furnitureGroup.CategoryType)
                    end
                end
                self.TabFurnitureGroup.TabBtnList[i]:SetNameByGroup(1, count)
            else
                self.TabFurnitureGroup.TabBtnList[i]:SetNameByGroup(0, furnitureGroup.MinorName)
            end
        end
    end

    self.TabFurnitureGroup:SelectIndex(1)

end

function XUiFurnitureReform:OnSelectFurnitureType(index)
    local furnitureGroup = self.FurnitureGroupList[index]
    self.LastSelectGroupIndex = index
    if furnitureGroup then
        self.LastBaseTypeId = self.CurrentBaseTypeId
        self.CurrentBaseTypeId = furnitureGroup.MinorType

        --选中二级菜单
        local categoryList = self:GetCategoryListByMinorType(self.CurrentBaseTypeId)
        if #categoryList <= 0 then
            self:SwitchSubType(0)
        else
            self:SwitchSubType(furnitureGroup.CategoryType)
        end
    end
end

function XUiFurnitureReform:SelectTypeByFurniture(furnitureId)
    if not furnitureId or furnitureId <= 0 then return end

    local furntiureDatas = XDataCenter.FurnitureManager.GetFurnitureById(furnitureId)
    if not furntiureDatas then return end

    local furnitureTemplates = XFurnitureConfigs.GetFurnitureTemplateById(furntiureDatas.ConfigId)
    if not furnitureTemplates then return end

    local furnitureTypeTemplates = XFurnitureConfigs.GetFurnitureTypeById(furnitureTemplates.TypeId)
    if not furnitureTypeTemplates then return end

    local index = 0
    local subIndex = 0
    for tabKey, tabValue in ipairs(self.FurnitureGroupList) do
        if furnitureTypeTemplates.MinorType == tabValue.MinorType and tabValue.CategoryType and tabValue.CategoryType == furnitureTypeTemplates.Category then
            index = tabKey
        end
        if furnitureTypeTemplates.MinorType == tabValue.MinorType and tabValue.CategoryType == nil then
            subIndex = tabKey
        end
    end

    if index == 0 or (self.LastSelectGroupIndex and self.LastSelectGroupIndex == index) then return end

    local furnitureGroup = self.FurnitureGroupList[self.LastSelectGroupIndex]
    if subIndex > 0 and furnitureGroup and furnitureGroup.MinorType ~= furnitureTypeTemplates.MinorType then
        self.TabFurnitureGroup:SelectIndex(subIndex)
    end
    self.TabFurnitureGroup:SelectIndex(index)
end

function XUiFurnitureReform:GetCategoryListByMinorType(minor)
    local typeList = XFurnitureConfigs.GetFurnitureTypeList()
    for k, v in pairs(typeList) do
        if v.MinorType == minor then
            return v.CategoryList
        end
    end
    return {}
end

function XUiFurnitureReform:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        self:OnRefreshSuit(index, grid)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        self:OnRefreshSuit(index, grid)
    end
end

function XUiFurnitureReform:OnRefreshSuit(index, grid)
    local data = self.SuitCFG[index]
    if not data then return end
    grid:Init(data, self)
end

--切换选择家具基础类型
function XUiFurnitureReform:SwitchBaseType(baseTypeId)
    if not baseTypeId then return end
    self.CurrentBaseTypeId = baseTypeId
    self.CurrentSubTypeId = nil

    self:UpdateItemsByFilter()
    self:UpdatePanelLimit()
    self:SwitchViewAngle(baseTypeId)
end

function XUiFurnitureReform:SwitchViewAngle(minor)
    local viewAngles = XFurnitureConfigs.GetFurnitureViewAngleByMinor(minor)
    if not viewAngles then return end
    if self.LastBaseTypeId then
        local lastViewAngles = XFurnitureConfigs.GetFurnitureViewAngleByMinor(self.LastBaseTypeId)
        if lastViewAngles and lastViewAngles.GroupId == viewAngles.GroupId then return end
    end

    XHomeSceneManager.ChangeAngleYAndYAxis(viewAngles.TargetAngleY, viewAngles.AllowYAxis == 1)
end

function XUiFurnitureReform:RestoreViewAngles()
    local defaultTargetAngle = CS.XGame.ClientConfig:GetInt("DefaultDormTargetAngle")
    local defaultAllowYAxis = CS.XGame.ClientConfig:GetInt("DefaultAllowYAxis")
    XHomeSceneManager.ChangeAngleYAndYAxis(defaultTargetAngle, defaultAllowYAxis == 1)
end

--切换选择家具二级类型
function XUiFurnitureReform:SwitchSubType(subTypeId)
    if not subTypeId then return end
    if subTypeId == 0 then
        self:SwitchBaseType(self.CurrentBaseTypeId)
        return
    end
    self.CurrentSubTypeId = subTypeId
    self:UpdateItemsByFilter()
    self:UpdatePanelLimit()
end

--隐藏二级类型
function XUiFurnitureReform:HideSubTypePanel()
    if self.PanelSubType.gameObject.activeSelf then
        self.PanelSubType.gameObject:SetActive(false)
    end
end

--显示套装过滤面板
function XUiFurnitureReform:ShowPanelFilter()
    self.PanelFilterGameObject:SetActive(true)

    if not self.DynamicTableSuit then return end
    self.DynamicTableSuit:SetDataSource(self.SuitCFG)
    self.DynamicTableSuit:ReloadDataASync(1)

    self.FilterEnable:PlayTimelineAnimation()
end

--隐藏套装过滤面板
function XUiFurnitureReform:HidePanelFilter()
    self.FilterDisable:PlayTimelineAnimation(function()
        self.PanelFilterGameObject:SetActive(false)
    end)
end

--选择套装过滤
function XUiFurnitureReform:SwitchSuitFilter(suitId)
    self:HidePanelFilter()
    self.CurrentSuitId = suitId
    self.BtnFilter:SetNameByGroup(0, self.SuitCFG[suitId].SuitName)

    self:UpdateItemsByFilter()
    self:UpdateCountOnChanged()
    self:UpdatePanelLimit()
end

function XUiFurnitureReform:UpdateCountOnChanged()
    -- 切换了套装，数量要重新结算
    self:UpdateSubTypeCount()
    -- 获得套装数量
    if self.CurrentSuitId then
        self.BtnFilter:SetNameByGroup(1, self:CalcFurnitureNumsBySuitId(self.CurrentSuitId))
    end
end

function XUiFurnitureReform:CalcFurnitureNumsBySuitId(suitId)
    if not self.RoomId then return 0 end
    return XDataCenter.FurnitureManager.GetFurnitureCountBySuitId(self.RoomId, FurnitureCache, suitId)
end

--根据条件过滤家具
function XUiFurnitureReform:UpdateItemsByFilter()
    if delayRefreshTimer then
        CS.XScheduleManager.UnSchedule(delayRefreshTimer)
        delayRefreshTimer = nil
    end

    delayRefreshTimer = CS.XScheduleManager.ScheduleOnce(function()
        local cacheKey = self:GetCacheKey(self.CurrentBaseTypeId, self.CurrentSubTypeId)
        self:SortFurnitureCache(FurnitureCache[cacheKey])

        local filterSuitCache = self:FilterCacheBySuitId(FurnitureCache[cacheKey] or {})
        if self.SViewFurniture then
            self.SViewFurniture:UpdateItems(filterSuitCache)
            self.AnimFurnitureList:PlayTimelineAnimation()
        end
    end, 100)

end

function XUiFurnitureReform:FilterCacheBySuitId(cache)
    local suitCache = {}
    if (not self.CurrentSuitId) or (not cache) or self.CurrentSuitId == 1 then return cache end

    for k, v in ipairs(cache) do
        local furntiureTemplate = XFurnitureConfigs.GetFurnitureTemplateById(v.ConfigId)
        if furntiureTemplate.SuitId == self.CurrentSuitId then
            table.insert(suitCache, v)
        end
    end
    return suitCache
end

function XUiFurnitureReform:SortFurnitureCache(cache)

    if not cache then return end

    local j = 0

    for i = 2, #cache do
        local temp = cache[i]
        j = i - 1
        while (j > 0) do
            local totalJScores = XDataCenter.FurnitureManager.GetFurnitureScore(cache[j].Id)
            local totalIScores = XDataCenter.FurnitureManager.GetFurnitureScore(temp.Id)
            if totalIScores <= totalJScores then
                break
            end
            cache[j + 1] = cache[j]
            j = j - 1
        end
        cache[j + 1] = temp
    end

end

-- 更新家具的数量
function XUiFurnitureReform:UpdateSubTypeCount()
    if not self.FurnitureGroupList then return end
    for i = 0, #self.FurnitureGroupList - 1 do
        local furnitureGroup = self.FurnitureGroupList[i + 1]
        if furnitureGroup then
            local categoryList = self:GetCategoryListByMinorType(furnitureGroup.MinorType)

            local count = 0
            if #categoryList <= 0 then
                count = self:GetBaseTypeCount(furnitureGroup.MinorType)
            else
                if furnitureGroup.CategoryType == nil or furnitureGroup.CategoryType == 0 then
                    count = self:GetBaseTypeCount(furnitureGroup.MinorType)
                else
                    count = self:GetSubTypeCount(furnitureGroup.MinorType, furnitureGroup.CategoryType)
                end
            end

            self.TabFurnitureGroup.TabBtnList[i]:SetNameByGroup(1, count)
        end
    end
end

function XUiFurnitureReform:GetBaseTypeCount(minor)
    local cacheKey = self:GetCacheKey(minor, nil)
    return XDataCenter.FurnitureManager.GetFurnitureCountByMinorTypeAndSuitId(self.RoomId, FurnitureCache[cacheKey], self.CurrentSuitId, minor)
end

function XUiFurnitureReform:GetSubTypeCount(minor, category)
    local cacheKey = self:GetCacheKey(minor, category)
    return XDataCenter.FurnitureManager.GetFurnitureCountByMinorAndCategoryAndSuitId(self.RoomId, FurnitureCache[cacheKey], self.CurrentSuitId, minor, category)
end

function XUiFurnitureReform:GetCurrentSuitId()
    return self.CurrentSuitId or 1
end

--更新放置限制面板
function XUiFurnitureReform:UpdatePanelLimit()
    if not self.CurrentBaseTypeId then return end
    local typeList = XFurnitureConfigs.GetFurnitureTypeList()
    for k, v in pairs(typeList) do
        if self.CurrentBaseTypeId == v.MinorType then
            self.TxtLimit.text = v.MinorName
            if self.CurrentSubTypeId ~= nil and #v.CategoryList > 0 then
                for _, category in pairs(v.CategoryList) do
                    if self.CurrentSubTypeId == category.Category then
                        self.TxtLimit.text = string.format("%s-%s", v.MinorName, category.CategoryName)
                        break
                    end
                end
            end
            break
        end
    end
end


function XUiFurnitureReform:UpdateScores()
    if delayUpdateScoresTimer then
        CS.XScheduleManager.UnSchedule(delayUpdateScoresTimer)
        delayUpdateScoresTimer = nil
    end
    delayUpdateScoresTimer = CS.XScheduleManager.ScheduleOnce(function()
        if self.RoomId then
            local newFurnitureAttrs = XHomeDormManager.GetFurnitureScoresByRoomId(self.RoomId)
            local oldFurnitureAttrs = XHomeDormManager.GetFurnitureScoresByUnsaveRoom(self.RoomId)

            -- 总评分
            local oldScores = oldFurnitureAttrs.TotalScore
            local newScores = newFurnitureAttrs.TotalScore
            self.TxtTotalScore.text = XFurnitureConfigs.GetFurnitureTotalAttrLevelNewColorDescription(1, newScores)
            self.ImgTotalScoreDown.gameObject:SetActive(newScores < oldScores)
            self.ImgTotalScoreUp.gameObject:SetActive(newScores > oldScores)

            -- 三个属性分
            for i = 1, #newFurnitureAttrs.AttrList do
                local attrOldVal = oldFurnitureAttrs.AttrList[i]
                local attrNewVal = newFurnitureAttrs.AttrList[i]
                local typeDatas = XFurnitureConfigs.GetDormFurnitureType(i)
                self:SetUiSprite(self[string.format("ImgTool%d", i)], typeDatas.TypeIcon)
                self[string.format("TxtAttrTool%d", i)].text = XFurnitureConfigs.GetFurnitureAttrLevelNewDescription(1, i, attrNewVal)
                self[string.format("ImgScoreUp%d", i)].gameObject:SetActive(attrOldVal < attrNewVal)
                self[string.format("ImgScoreDown%d", i)].gameObject:SetActive(attrOldVal > attrNewVal)
            end
        end
    end, 50)
end

function XUiFurnitureReform:GetCacheKey(baseType, subType)
    return XDataCenter.FurnitureManager.GenerateCacheKey(baseType, subType)
end

function XUiFurnitureReform:ResetCache()
    FurnitureCache = {}
end

function XUiFurnitureReform:RestoreCache()
    local typeList = XFurnitureConfigs.GetFurnitureTypeList()
    for id, typeDatas in pairs(typeList) do
        local baseType = typeDatas.MinorType
        local cacheBaseKey = self:GetCacheKey(baseType, nil)
        FurnitureCache[cacheBaseKey] = XDataCenter.FurnitureManager.FilterDisplayFurnitures(self.RoomId, 1, baseType, nil)

        for _, categoryList in pairs(typeDatas.CategoryList) do
            local subType = categoryList.Category
            if subType ~= 0 then
                local cacheSubKey = self:GetCacheKey(baseType, subType)
                FurnitureCache[cacheSubKey] = XDataCenter.FurnitureManager.FilterDisplayFurnitures(self.RoomId, 1, baseType, subType)
            end
        end
    end
end

function XUiFurnitureReform:UpdateCacheFurniture(isRemove, furntiureId)

    local furnitureDatas = XDataCenter.FurnitureManager.GetFurnitureById(furntiureId)
    if not furnitureDatas then return end
    local furnitureTemplates = XFurnitureConfigs.GetFurnitureTemplateById(furnitureDatas.ConfigId)
    local furntiureTypeTemplates = XFurnitureConfigs.GetFurnitureTypeById(furnitureTemplates.TypeId)

    local baseCacheKey = self:GetCacheKey(furntiureTypeTemplates.MinorType, nil)
    local baseSubCacheKey = self:GetCacheKey(furntiureTypeTemplates.MinorType, furntiureTypeTemplates.Category)
    if isRemove then--收纳家具
        self:AddCacheToList(FurnitureCache[baseCacheKey], furnitureDatas)
        if FurnitureCache[baseSubCacheKey] then
            self:AddCacheToList(FurnitureCache[baseSubCacheKey], furnitureDatas)
        end
    else--摆放家具
        self:RemoveCacheFromList(FurnitureCache[baseCacheKey], furntiureId)
        if FurnitureCache[baseSubCacheKey] then
            self:RemoveCacheFromList(FurnitureCache[baseSubCacheKey], furntiureId)
        end
    end

    self:UpdateItemsByFilter()

end

function XUiFurnitureReform:AddCacheToList(cache, furnitureDatas)
    for k, v in pairs(cache) do
        if v.Id == furnitureDatas.Id then
            return
        end
    end

    table.insert(cache, furnitureDatas)
end

function XUiFurnitureReform:RemoveCacheFromList(cache, furnitureId)
    local index = 0
    local length = #cache
    for k, v in pairs(cache) do
        if v.Id == furnitureId then
            index = k
            break
        end
    end
    if index == 0 then return end
    cache[index] = nil
    for i = index, length - 1 do
        cache[i] = cache[i + 1]
    end
    cache[length] = nil

end

function XUiFurnitureReform:OnGetEvents()
    return { XEventId.EVENT_FURNITURE_ONDRAGITEM_CHANGED, XEventId.EVENT_FURNITURE_REFRESH, XEventId.EVENT_FURNITURE_CLEANROOM, XEventId.EVENT_CLICKFURNITURE_ONROOM }
end

function XUiFurnitureReform:OnNotify(evt, ...)
    if evt == XEventId.EVENT_FURNITURE_ONDRAGITEM_CHANGED then
        local args = { ... }
        if not args then return end
        self:UpdateCacheFurniture(args[1], args[2])
        self:UpdateCountOnChanged()
        self:UpdatePanelLimit()
        self:UpdateScores()

    elseif evt == XEventId.EVENT_FURNITURE_REFRESH then
        self:RefreshFurntiureReform()
    elseif evt == XEventId.EVENT_FURNITURE_CLEANROOM then

        self:UpdatePanelLimit()
        self:UpdateScores()

    elseif evt == XEventId.EVENT_CLICKFURNITURE_ONROOM then

        local args = { ... }
        if not args then return end
        self:SelectTypeByFurniture(args[1])
    end
end

function XUiFurnitureReform:RefreshFurntiureReform()
    self:RestoreCache()
    self:UpdateItemsByFilter()

    self:UpdateCountOnChanged()
    self:UpdatePanelLimit()
    self:UpdateScores()
end

function XUiFurnitureReform:OnDestroy()
    if delayRefreshTimer then
        CS.XScheduleManager.UnSchedule(delayRefreshTimer)
        delayRefreshTimer = nil
    end

    if delayUpdateScoresTimer then
        CS.XScheduleManager.UnSchedule(delayUpdateScoresTimer)
        delayUpdateScoresTimer = nil
    end
    XEventManager.RemoveEventListener(XEventId.EVENT_FURNITURE_ON_MODIFY, self.RefreshFurnitureList, self)
    local isResetPosition = true
    XHomeCharManager.ShowAllCharacter(isResetPosition)

    if not XTool.UObjIsNil(self.CameraController) then
        self.CameraController:SetTartAngle(CS.UnityEngine.Vector2(self.TargetAngleX, self.TargetAngleY))
        XCameraHelper.SetCameraTarget(self.CameraController, self.OldCameraTarget, self.OldCameraDistance)
    end
    self.CameraController = nil
    self.OldCameraTarget = nil
    self.OldCameraDistance = nil
    self.TargetAngleX = nil
    self.TargetAngleY = nil

    CsXGameEventManager.Instance:Notify(XEventId.EVENT_DORM_FURNITURE_HIDE_ALL_ATTR_TAG_DETAIL)
end


function XUiFurnitureReform:OnFurnitureAttrDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        --    grid:Init(self.RootUI)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then

        local isSelect = false
        if self.SelectIndex == index then
            self.SelectGrid = grid
            isSelect = true
        end
        grid:SetSelect(isSelect)
        grid:SetContent(self.FurnitureTagType[index])

    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then

        if self.SelectIndex == index then
            return
        end

        if self.SelectGrid then
            self.SelectGrid:SetSelect(false)
        end

        self.SelectGrid = grid
        self.SelectIndex = index
        grid:SetSelect(true)

        local cfg = self.FurnitureTagType[index]
        self.BtnDrdSortLabel.text = cfg.TagName

        XHomeDormManager.FurnitureShowAttrType = cfg.AttrIndex
        --CS.UnityEngine.PlayerPrefs.SetInt(tostring(XPlayer.Id) .. "FurnitureAttr", cfg.AttrIndex)
        --CS.UnityEngine.PlayerPrefs.Save()
        CsXGameEventManager.Instance:Notify(XEventId.EVENT_DORM_FURNITURE_ATTR_TAG, cfg.AttrIndex)
    end
end