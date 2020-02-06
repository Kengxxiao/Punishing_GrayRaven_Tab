local XUiDrawMain = XLuaUiManager.Register(XLuaUi, "UiDrawMain")
local XUiGridBanner = require("XUi/XUiDraw/XUiGridDrawGroupBanner")

function XUiDrawMain:OnAwake()
    self:InitAutoScript()
end

function XUiDrawMain:OnStart(defaultIdx)
    self.DefaultTab = defaultIdx
    self.TxtTabName.text = ""
    self.InfoList = {}
    self.GridTab = {}
    self.CurTabInfo = nil
    self.TogTabIDs = {}
    --自己管理加载的Asset
    self.BannerRes = {}
    self.NeedUpdate = false
    XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiDrawMain:OnEnable()
    self:InitDrawCardsData()

    if self.NeedUpdate then
        self.NeedUpdate = false
    end
    self.GameObject:PlayLegacyAnimation("UiDrawMainBegin")
end

function XUiDrawMain:OnDisable()
    self.CurTabInfo = nil
    self.NeedUpdate = true
end

function XUiDrawMain:OnDestroy()
    --清除已加载的Asset
    for k, v in pairs(self.BannerRes) do
        v:Release()
    end
    self.BannerRes = {}
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiDrawMain:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiDrawMain:AutoInitUi()
    -- self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    -- self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnBack"):GetComponent("Button")
    -- self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnMainUi"):GetComponent("Button")
    -- self.PanelContentTabBtns = self.Transform:Find("SafeAreaContentPane/PanelTab/PanelSview/SViewCards/Viewport/PanelContentTabBtns")
    -- self.TxtTabName = self.Transform:Find("SafeAreaContentPane/PanelTab/Bt/TxtTabName"):GetComponent("Text")
end

function XUiDrawMain:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.SViewCards, self.OnSViewCardsClick)
end
-- auto
function XUiDrawMain:OnBtnBackClick(eventData)
    self:Close()
end

function XUiDrawMain:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

--获取所有卡片数据
function XUiDrawMain:InitDrawCardsData()
    self.InfoList = {}
    self.InfoListFull = {}
    XDataCenter.DrawManager.GetDrawGroupList(function()
        self.InfoList = XDataCenter.DrawManager.GetDrawGroupInfos()
        self.InfoListFull = self.InfoList
        --XDataCenter.DrawManager.UpdateActivityDrawListByTag(self.InfoList)
        self:InitDrawTabs()
    end)
end

function XUiDrawMain:InitDrawTabs()
    --去重
    self.TogTabIDs = {}
    for k, drawGroupInfo in pairs(self.InfoList) do
        self.TogTabIDs[drawGroupInfo.Tag] = drawGroupInfo
    end

    self.InfoList = {}
    local count = 1
    for k, v in pairs(self.TogTabIDs) do
        self.InfoList[count] = v
        count = count + 1
    end

    self.TabGroup = self.TabGroup or {}
    for i = 1, #self.InfoList do
        local uiButton = self.TabGroup[i]

        if not uiButton then
            if i == 1 then
                uiButton = self.BtnTab
            else
                local itemGo = CS.UnityEngine.Object.Instantiate(self.BtnTab.gameObject)
                itemGo.transform:SetParent(self.PanelTogBtnsRT, false)
                uiButton = itemGo.transform:GetComponent("XUiButton")
            end
        end

        local tabInfo = XDataCenter.DrawManager.GetDrawTab(self.InfoList[i].Tag)
        if tabInfo then
            uiButton:SetNameByGroup(0, tabInfo.TxtName1)
            uiButton:SetNameByGroup(1, tabInfo.TxtName2)
            uiButton:SetNameByGroup(2, tabInfo.TxtName3)
            if tabInfo.TxtTagName then
                local tagText = uiButton.transform:Find("Tag/TxtTag"):GetComponent("Text")
                if not XTool.UObjIsNil(tagText) then
                    tagText.text = tabInfo.TxtTagName
                end
                uiButton:ShowTag(true)
            else
                uiButton:ShowTag(false)
            end
        end

        self.TabGroup[i] = uiButton
    end
    self.PanelTogBtns:Init(self.TabGroup, function(tabIndex) self:OnSelectedTog(tabIndex) end)

    XEventManager.DispatchEvent(XEventId.EVENT_GUIDE_STEP_OPEN_EVENT)

    self:DefaultSelect()
end

function XUiDrawMain:UpdateCards(tabInfo)
    --忽略重复点击
    if tabInfo == self.CurTabInfo and not self.NeedUpdate then
        return nil
    else
        self.CurTabInfo = tabInfo
    end
    self:PlayAnimation("SviewQiehuan")
    
    --clean
    for _, v in pairs(self.GridTab) do
        v:RemoveCountDown()
        CS.UnityEngine.Object.Destroy(v.GameObject)
    end
    self.GridTab = {}

    --parent
    local childCount = self.PanelSview.childCount
    for i = 0, childCount - 1 do
        self.PanelSview:GetChild(i).gameObject:SetActive(false)
    end
    local drawTabData = XDataCenter.DrawManager.GetDrawTab(tabInfo.Tag)
    self[drawTabData.ParentName].parent.parent.gameObject:SetActive(true)

    XDataCenter.DrawManager.SetCurSelectTabInfo(tabInfo)
    self.TxtTabName.text = XDataCenter.DrawManager.GetDrawTab(tabInfo.Tag).TxtName

    table.sort(self.InfoListFull, function(a, b)
        return a.Priority > b.Priority
    end)

    for i = 1, #self.InfoListFull do
        if self.InfoListFull[i].Tag == tabInfo.Tag and self.InfoListFull[i].Priority > 1 then
            local prefabName = string.format(self.InfoListFull[i].Banner)
            local resource = CS.XResourceManager.Load(prefabName);
            table.insert(self.BannerRes, resource)
            local banner = CS.UnityEngine.Object.Instantiate(resource.Asset)
            local newBanner = XUiGridBanner.New(banner, self.InfoListFull[i], self)
            newBanner.Transform:SetParent(self[drawTabData.ParentName], false)
            newBanner.GameObject.name = self.InfoListFull[i].Id
            table.insert(self.GridTab, newBanner)
        end
    end
    XEventManager.DispatchEvent(XEventId.EVENT_GUIDE_STEP_OPEN_EVENT)
end

function XUiDrawMain:DefaultSelect()
    
    if self.DefaultTab then
        self.PanelTogBtns:SelectIndex(self.DefaultTab)
        self.DefaultTab = nil
        return
    end

    local maxKey = 1
    local maxPriority = 0
    local maxValue = nil
    if XDataCenter.DrawManager.GetCurSelectTabInfo() == nil then
        for k, v in pairs(self.InfoList) do
            local drawTabInfo = XDataCenter.DrawManager.GetDrawTab(v.Tag)
            if drawTabInfo.Priority > maxPriority then
                maxPriority = drawTabInfo.Priority
                maxValue = v
                maxKey = k
            end
        end
        XDataCenter.DrawManager.SetCurSelectTabInfo(maxValue)
    end
    for k, v in pairs(self.InfoList) do
        if v.Tag == XDataCenter.DrawManager.GetCurSelectTabInfo().Tag then
            self.PanelTogBtns:SelectIndex(k)
            return
        end
    end
    --如果到这里说明没有结果满足选择条件，默认选中第一个
    self.PanelTogBtns:SelectIndex(1)
end

--研发红点
function XUiDrawMain:OnCheckTabNews(count)
    self.BtnReward:ShowReddot(count >= 0)
end

function XUiDrawMain:OnSelectedTog(index)
    self:UpdateCards(self.InfoList[index])
end