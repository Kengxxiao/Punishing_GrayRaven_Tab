local DormBagItem = require("XUi/XUiDormBag/XUiPanelDormBagItem")
local XUiRecyclePreview = require("XUi/XUiDormBag/XUiRecyclePreview")
local XUiDormBag = XLuaUiManager.Register(XLuaUi, "UiDormBag")

local SELECT_OFFSET_MIN = CS.UnityEngine.Vector2(32, 155)
local SELECT_OFFSET_MAX = CS.UnityEngine.Vector2(-59, -216)

function XUiDormBag:OnAwake()
    self:AddListener()
end

function XUiDormBag:OnStart(pageRecord, furnitureState, selectCb, filter)
    self.SelectIds = {} -- 记录筛选的ConfigId
    self.SelectSuitIds = {} -- 记录套装筛选的ConfigId
    self.PriorSortType = XFurnitureConfigs.PriorSortType.All

    self:InitFurniturePart()
    self:InitRecyclePreview()
    self:InitPrivateVariable(pageRecord, furnitureState, selectCb, filter)
    self:InitDynamicTable()
    self:InitTabGroup()
    self:SetAscendBtn()

    self.AssetPanel = XUiPanelAsset.New(self, self.PanelHostelAsset, XDataCenter.ItemManager.ItemId.DormCoin, XDataCenter.ItemManager.ItemId.FurnitureCoin)
end

function XUiDormBag:OnDestroy()
    self.SelectIds = nil
    self.SelectSuitIds = nil
    self.PageRecord = 0
    self.FurnitureState = 0
    self.AscendSort = false
end

function XUiDormBag:OnEnable()
    self:RefreshSelectedPanel(self.PageRecord, true)
    XEventManager.AddEventListener(XEventId.EVENT_CLICKFURNITURE_GRID, self.OnFurnitureGridClick, self)
    XEventManager.AddEventListener(XEventId.EVENT_CLICKDRAFT_GRID, self.OnDraftGridClick, self)
end

function XUiDormBag:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_CLICKFURNITURE_GRID, self.OnFurnitureGridClick, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CLICKDRAFT_GRID, self.OnDraftGridClick, self)
end

function XUiDormBag:InitRecyclePreview()
    self.RecyclePreview = XUiRecyclePreview.New(self.PanelRecyclePreview, self)
    self.RecyclePreview:Hide()
end

function XUiDormBag:InitPrivateVariable(pageRecord, furnitureState, selectCb, filter)
    self.SelectCb = selectCb

    if pageRecord then
        self.PageRecord = pageRecord
    else
        self.PageRecord = XDormConfig.DORM_BAG_PANEL_INDEX.FURNITURE
    end

    if furnitureState then
        self.FurnitureState = furnitureState
    else
        self.FurnitureState = XFurnitureConfigs.FURNITURE_STATE.DETAILS
    end

    -- 过滤家具或者图纸
    self.Filter = filter
end

function XUiDormBag:InitTabGroup()
    self.BtnList = {}
    table.insert(self.BtnList, self.BtnTogFurniture)
    table.insert(self.BtnList, self.BtnTogCharacter)
    table.insert(self.BtnList, self.BtnTogDraft)

    self.PanelTogs:Init(self.BtnList, function(index)
        self:RefreshSelectedPanel(index, true)
    end)

    -- 选择家具状态处理
    if self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.SELECT then
        if self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.FURNITURE then
            self.BtnTogFurniture.gameObject:SetActiveEx(true)
            self.BtnTogCharacter.gameObject:SetActiveEx(false)
            self.BtnTogDraft.gameObject:SetActiveEx(false)
        elseif self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.DRAFT then
            self.BtnTogFurniture.gameObject:SetActiveEx(false)
            self.BtnTogCharacter.gameObject:SetActiveEx(false)
            self.BtnTogDraft.gameObject:SetActiveEx(true)
        end

        self.PanelSelect.gameObject:SetActiveEx(true)
        self.BtnRecycle.gameObject:SetActiveEx(false)
        self.PanelNormlBt.gameObject:SetActiveEx(false)
        self.BtnBuild.gameObject:SetActiveEx(false)
        self.PanelTogs.gameObject:SetActiveEx(false)
        self.BtnShop.gameObject:SetActiveEx(false)
        self.TxtPartDesc.gameObject:SetActiveEx(false)
        self.TxtSelectCount.gameObject:SetActiveEx(false)
        self.DrdSort.gameObject:SetActiveEx(false)
        self.BtnOrder.gameObject:SetActiveEx(false)

        self.PanelDynamicTableRct.offsetMin = SELECT_OFFSET_MIN
        self.PanelDynamicTableRct.offsetMax = SELECT_OFFSET_MAX

        self.AscendSort = true
    else
        self.PanelSelect.gameObject:SetActiveEx(false)
        self.BtnRecycle.gameObject:SetActiveEx(true)
        self.PanelNormlBt.gameObject:SetActiveEx(true)
        self.BtnBuild.gameObject:SetActiveEx(true)
        self.PanelTogs.gameObject:SetActiveEx(true)
        self.BtnShop.gameObject:SetActiveEx(true)
        self.TxtPartDesc.gameObject:SetActiveEx(true)
        self.TxtSelectCount.gameObject:SetActiveEx(false)
        self.DrdSort.gameObject:SetActiveEx(true)
        self.BtnOrder.gameObject:SetActiveEx(true)

        self.AscendSort = false
    end

    -- 设置默认开启
    self.PanelTogs:SelectIndex(self.PageRecord)
end

function XUiDormBag:InitDynamicTable()
    self.PanelDormBagItem.gameObject:SetActiveEx(false)
    self.DynamicTable = XDynamicTableNormal.New(self.PanelDynamicTable)
    self.DynamicTable:SetProxy(DormBagItem)
    self.DynamicTable:SetDelegate(self)
end

function XUiDormBag:InitFurniturePart()
    local allTypeId = XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID
    local allSuitTypeId = XFurnitureConfigs.FURNITURE_SUIT_CATEGORY_ALL_ID
    table.insert(self.SelectIds, allTypeId)
    table.insert(self.SelectSuitIds, allSuitTypeId)
end

function XUiDormBag:SetAscendBtn()
    self.ImgAscend.gameObject:SetActiveEx(self.AscendSort)
    self.ImgDescend.gameObject:SetActiveEx(not self.AscendSort)
end

--动态列表事件
function XUiDormBag:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.PageDatas[index]
        if self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.FURNITURE then
            local isSelect = self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.SELECT
            grid:SetupFurniture(data, isSelect)
        elseif self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.CHARACTER then
            grid:SetupCharacter(data)
        elseif self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.DRAFT then
            grid:SetupDraft(data)
        end
    end
end

function XUiDormBag:AddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnBuild, self.OnBtnBuildClick)
    self:RegisterClickEvent(self.BtnRecycle, self.OnBtnRecycleClick)
    self:RegisterClickEvent(self.BtnPart, self.OnBtnPartClick)
    self:RegisterClickEvent(self.BtnShop, self.OnBtnShopClick)
    self:RegisterClickEvent(self.BtnSelect, self.OnBtnSelectClick)
    self:RegisterClickEvent(self.BtnOrder, self.OnBtnOrderClick)
    self.DrdSort.onValueChanged:AddListener(function()
        self.PriorSortType = self.DrdSort.value
        self:RefreshSelectedPanel(self.PageRecord, true)
    end)
end

function XUiDormBag:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiDormBag:OnBtnBackClick(...)
    if self.RecyclePreview:IsShow() then
        self:PlayAnimation("RecyclePreviewDisable",function()
            self:OnRecycleCancel()
            self.RecyclePreview:Hide()
        end)
        return
    end

    self:Close()
end

function XUiDormBag:OnBtnBuildClick(...)
    XLuaUiManager.Open("UiFurnitureBuild")
end

-- 点击筛选
function XUiDormBag:OnBtnPartClick(...)
    XLuaUiManager.Open("UiFurnitureTypeSelect", self.SelectIds, self.SelectSuitIds, function(selectIds, selectSuitIds)
        if #selectIds <= 0 and #selectSuitIds <= 0 then
            return
        end

        -- 如果再单选情况下 重新选择家具
        if self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.SELECT then
            if self.FurnitureSelectGrid then
                self.FurnitureSelectGrid:SetSelected(false)
                self.FurnitureSelectGrid = nil
            end
            self.FurnitureSelectId = nil
        end

        self.SelectIds = selectIds
        self.SelectSuitIds = selectSuitIds
        self:RefreshSelectedPanel(self.PageRecord, true)
    end)
end

function XUiDormBag:SetPartCount(count)
    local allTypeId = XFurnitureConfigs.FURNITURE_CATEGORY_ALL_ID
    local allSuitTypeId = XFurnitureConfigs.FURNITURE_SUIT_CATEGORY_ALL_ID

    if #self.SelectIds == 1 and self.SelectIds[1] == allTypeId and
    self.PriorSortType == XFurnitureConfigs.PriorSortType.All and
    #self.SelectSuitIds == 1 and self.SelectSuitIds[1] == allSuitTypeId then
        self.TxtPartDesc.text = CS.XTextManager.GetText("DormSelectAllCount", count)
    else
        self.TxtPartDesc.text = CS.XTextManager.GetText("DormSelectCount", count)
    end
end

function XUiDormBag:OnBtnShopClick(...)
    local shopId = XDormConfig.GetDraftShopId()
    XLuaUiManager.Open("UiShop", XShopManager.ShopType.Dorm)
end

-- 排序按钮
function XUiDormBag:OnBtnOrderClick(...)
    self.AscendSort = not self.AscendSort
    self:SetAscendBtn()
    self:RefreshSelectedPanel(self.PageRecord, true)
end

-- 家具回收
function XUiDormBag:OnBtnRecycleClick(...)
    self.AscendSort = true
    self:SetAscendBtn()
    self.DrdSort.gameObject:SetActiveEx(false)

    self.PanelFurnitureBtn.gameObject:SetActiveEx(false)
    self.RecyclePreview:Show()
    self:PlayAnimation("RecyclePreviewEnable")
    self.FurnitureRecycleList = {}
    self.FurnitureState = XFurnitureConfigs.FURNITURE_STATE.RECYCLE
    self:RefreshSelectedPanel(self.PageRecord, true)
end

-- 确认回收
function XUiDormBag:OnRecycleConfirm()
    XDataCenter.FurnitureManager.DecomposeFurniture(self.FurnitureRecycleList, function(rewardItems, successIds)
        -- 先打开回收界面
        XLuaUiManager.Open("UiDormBagRecycle", self.FurnitureRecycleList, rewardItems)

        local configIds = {}
        -- 将分解成功的家具从缓存中移除
        for _, id in ipairs(successIds) do
            local configId = XDataCenter.FurnitureManager.GetFurnitureConfigId(id)
            table.insert(configIds, configId)
            XDataCenter.FurnitureManager.RemoveFurniture(id)
        end

        -- 删除红点
        XDataCenter.FurnitureManager.DeleteNewHint(successIds)

        -- 清理数据
        self:OnRecycleCancel()
    end)
end

-- 取消回收
function XUiDormBag:OnRecycleCancel()
    -- 设置排序
    self.AscendSort = false
    self:SetAscendBtn()
    self.DrdSort.gameObject:SetActiveEx(true)


    self.FurnitureRecycleList = {}
    self.FurnitureState = XFurnitureConfigs.FURNITURE_STATE.DETAILS
    self:RefreshSelectedPanel(self.PageRecord, true)
    self.PanelFurnitureBtn.gameObject:SetActiveEx(true)
end

-- 确认选择
function XUiDormBag:OnBtnSelectClick(...)
    if not self.FurnitureSelectId or self.FurnitureSelectId == nil then
        XUiManager.TipMsg(CS.XTextManager.GetText("DormFurnitureSelectNull"), XUiManager.UiTipType.Tip)
        return
    end

    if self.SelectCb then
        self.SelectCb(self.FurnitureSelectId)
    end

    self:Close()
end

function XUiDormBag:RefreshSelectedPanel(index, startIndex)
    self.PageRecord = index
    self:UpdateDynamicTable(startIndex)
end

function XUiDormBag:OnFurnitureGridClick(furnitureId, furnitureConfigId, grid)
    if self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.DETAILS then
        grid:SetNewActive()
        XLuaUiManager.Open("UiFurnitureDetail", furnitureId, furnitureConfigId, nil, function()
            self:RefreshSelectedPanel(self.PageRecord, true)
        end)

    elseif self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.RECYCLE then
        grid:SetSelected(not grid:IsSelected())
        for i = 1, #self.FurnitureRecycleList do
            if self.FurnitureRecycleList[i] == furnitureId then
                table.remove(self.FurnitureRecycleList, i)
                self.RecyclePreview:Refresh(self.FurnitureRecycleList)
                return
            end
        end

        table.insert(self.FurnitureRecycleList, furnitureId)
        self.RecyclePreview:Refresh(self.FurnitureRecycleList)
    elseif self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.SELECT then
        grid:SetSelected(not grid:IsSelected())
        if furnitureId == self.FurnitureSelectId then
            self.FurnitureSelectId = nil
            self.FurnitureSelectGrid = nil
        else
            self.FurnitureSelectId = furnitureId

            --记录选择得Grid
            if self.FurnitureSelectGrid then
                self.FurnitureSelectGrid:SetSelected(false)
            end
            self.FurnitureSelectGrid = grid
        end
    end
end

function XUiDormBag:OnDraftGridClick(templateId, count, grid)
    if self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.DETAILS then
        XLuaUiManager.Open("UiTip", { TemplateId = templateId, Count = count })
    elseif self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.SELECT then
        grid:SetSelected(not grid:IsSelected())
        if templateId == self.FurnitureSelectId then
            self.FurnitureSelectId = nil
            self.FurnitureSelectGrid = nil
        else
            self.FurnitureSelectId = templateId

            if self.FurnitureSelectGrid then
                self.FurnitureSelectGrid:SetSelected(false)
            end

            --记录选择得Grid
            self.FurnitureSelectGrid = grid
        end
    end
end

function XUiDormBag:GetGridSelected(id)
    -- 选择家具状态下
    if self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.SELECT then
        if not self.FurnitureSelectId then
            return false
        end

        return id == self.FurnitureSelectId

        -- 回收家具状态下
    elseif self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.RECYCLE then
        if not self.FurnitureRecycleList then
            return false
        end

        for i = 1, #self.FurnitureRecycleList do
            if self.FurnitureRecycleList[i] == id then
                return true
            end
        end

        return false
    end

    return false
end

function XUiDormBag:UpdateDynamicTable(startIndex)
    self.PageDatas = self:GetDataByPage()

    self.DynamicTable:SetDataSource(self.PageDatas)
    self.DynamicTable:ReloadDataASync(startIndex and 1 or -1)

    -- 判断是否为空
    local isEmpty = #self.PageDatas <= 0
    self.PanelEmpty.gameObject:SetActiveEx(isEmpty)

    -- 刷新Btn的显示
    if self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.FURNITURE then
        self.PanelFurnitureBtn.gameObject:SetActiveEx(true)
        self.PanelDraftBtn.gameObject:SetActiveEx(false)
        if isEmpty then
            self.TxtNull.text = CS.XTextManager.GetText("DormNullFurniture")
        end
    elseif self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.CHARACTER then
        self.PanelFurnitureBtn.gameObject:SetActiveEx(false)
        self.PanelDraftBtn.gameObject:SetActiveEx(false)
        if isEmpty then
            self.TxtNull.text = CS.XTextManager.GetText("DormNullCharacter")
        end
    elseif self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.DRAFT then
        self.PanelFurnitureBtn.gameObject:SetActiveEx(false)
        self.PanelDraftBtn.gameObject:SetActiveEx(true)
        if isEmpty then
            self.TxtNull.text = CS.XTextManager.GetText("DormNullDraft")
        end
    end
end

--获取数据
function XUiDormBag:GetDataByPage()
    -- 家具
    if self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.FURNITURE then
        local furnitureIds = {}
        -- 是否过滤已经使用的家具
        local isRemoveUsed = self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.SELECT
        or self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.RECYCLE
        or self.PriorSortType == XFurnitureConfigs.PriorSortType.Unuse

        -- 是否过滤还未使用的家具
        local isRemoveUnuse = self.PriorSortType == XFurnitureConfigs.PriorSortType.Use and self.FurnitureState ~= XFurnitureConfigs.FURNITURE_STATE.RECYCLE

        furnitureIds = XDataCenter.FurnitureManager.GetFurnitureCategoryIds(self.SelectIds, self.SelectSuitIds, isRemoveUsed, self.AscendSort, isRemoveUnuse)
        local allCount = XDataCenter.FurnitureManager.GetAllFurnitureCount()
        self.TxtCount.text = CS.XTextManager.GetText("DormBagFurnitureCount", allCount)
        self.TxtSelectCount.text = CS.XTextManager.GetText("DormBagFurnitureCount", allCount)
        self:SetPartCount(#furnitureIds)

        return furnitureIds
    end

    -- 构造体
    if self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.CHARACTER then
        local characterIds = {}
        characterIds = XDataCenter.DormManager.GetCharacterIds()

        local allCount = XCharacterConfigs.GetCharacterTemplatesCount()
        self.TxtCount.text = CS.XTextManager.GetText("DormBagCharacterCount", #characterIds, allCount)
        self.TxtSelectCount.text = CS.XTextManager.GetText("DormBagCharacterCount", #characterIds, allCount)
        return characterIds
    end

    -- 图纸
    if self.PageRecord == XDormConfig.DORM_BAG_PANEL_INDEX.DRAFT then
        local itemDatas = {}
        itemDatas = XDataCenter.ItemManager.GetItemsByType(XItemConfigs.ItemType.FurnitureItem)

        -- 需要过滤
        local isSelectMode = self.FurnitureState == XFurnitureConfigs.FURNITURE_STATE.SELECT
        if isSelectMode and self.Filter then
            local filterDatas = {}
            for k, v in pairs(itemDatas) do
                if self.Filter(v.Id) then
                    table.insert(filterDatas, v)
                end
            end

            local count = self:GetDraftItemsCount(filterDatas)
            self.TxtCount.text = CS.XTextManager.GetText("DormBagDraftCount", count)
            self.TxtSelectCount.text = CS.XTextManager.GetText("DormBagDraftCount", count)
            return filterDatas
        end

        local count = self:GetDraftItemsCount(itemDatas)
        self.TxtCount.text = CS.XTextManager.GetText("DormBagDraftCount", count)
        self.TxtSelectCount.text = CS.XTextManager.GetText("DormBagDraftCount", count)
        return itemDatas
    end
end

function XUiDormBag:GuideGetDynamicTableIndex(id)
    for i, v in ipairs(self.PageDatas) do
        local furnitureConfig = XDataCenter.FurnitureManager.GetFurnitureConfigByUniqueId(v)
        if not furnitureConfig then
            return -1
        end

        if tostring(furnitureConfig.Id) == tostring(id) then
            return i
        end
    end

    return -1
end

function XUiDormBag:GetDraftItemsCount(list)
    local count = 0
    if not list or #list <= 0 then
        return count
    end

    for _, v in pairs(list) do
        count = count + v.Count
    end

    return count
end