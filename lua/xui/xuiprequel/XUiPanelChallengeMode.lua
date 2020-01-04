XUiPanelChallengeMode = XClass()
local ANICHALLENGEMODEBEGIN = "AniChallengeModeBegin"

local ChallengeChapterTimer = nil
local ChallengeChapterInterval = 1000

function XUiPanelChallengeMode:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self.ChallengeTab = XUiPanelChallengeTab.New(self.PanelChallengeTab, self.RootUi)
    self.ChallengeList = {}
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelChallengeMode:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelChallengeMode:AutoInitUi()
    self.PanelMode = self.Transform:Find("PanelMode")
    self.BtnDetailMask = self.Transform:Find("PanelMode/BtnDetailMask"):GetComponent("Button")
    self.PanelPrequelStages = self.Transform:Find("PanelMode/PanelPrequelStages")
    self.TxtMode = self.Transform:Find("PanelMode/ImageLine/TxtMode"):GetComponent("Text")
    self.PanelLeft = self.Transform:Find("PanelMode/PanelLeft")
    self.PanelChallengeTab = self.Transform:Find("PanelMode/PanelLeft/PanelChallengeTab")
    self.BtnSwitch2Regional = self.Transform:Find("PanelMode/PanelLeft/BtnSwitch2Regional"):GetComponent("Button")
    self.PanelShop = self.Transform:Find("PanelMode/PanelShop")
    self.BtnShop = self.Transform:Find("PanelMode/PanelShop/BtnShop"):GetComponent("Button")
    self.PanelReset = self.Transform:Find("PanelMode/PanelReset")
    self.PanelCenter = self.Transform:Find("PanelMode/PanelReset/PanelCenter")
    self.TxtResetTime = self.Transform:Find("PanelMode/PanelReset/PanelCenter/TxtResetTime"):GetComponent("Text")
    self.PanelOpenItem = self.Transform:Find("PanelMode/PanelOpenItem")
    self.TxtTotalNum = self.Transform:Find("PanelMode/PanelOpenItem/TxtTotalNum"):GetComponent("Text")
    self.RImgCostIcon = self.Transform:Find("PanelMode/PanelOpenItem/RImgCostIcon"):GetComponent("RawImage")
    self.BtnActDesc = self.Transform:Find("PanelMode/BtnActDesc"):GetComponent("Button")
end

function XUiPanelChallengeMode:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelChallengeMode:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelChallengeMode:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelChallengeMode:AutoAddListener()
    self:RegisterClickEvent(self.BtnDetailMask, self.OnBtnDetailMaskClick)
    self:RegisterClickEvent(self.BtnSwitch2Regional, self.OnBtnSwitch2RegionalClick)
    self:RegisterClickEvent(self.BtnShop, self.OnBtnShopClick)
    self:RegisterClickEvent(self.BtnActDesc, self.OnBtnActDescClick)
end
-- auto

function XUiPanelChallengeMode:OnBtnDetailMaskClick(eventData)
    self:OnClosePrequelDetail()
end

function XUiPanelChallengeMode:OnClosePrequelDetail()
    self.RootUi:OnClosePrequelDetail()
end

function XUiPanelChallengeMode:OnBtnSwitch2RegionalClick(eventData)
    self:OnClosePrequelDetail()
    self.RootUi:Switch2Regional(self.CurrentCover)
    self:RemoveTimer()
    self:RemoveChallengeTimer()
end

function XUiPanelChallengeMode:OnBtnShopClick(eventData)
    if self.CurrentCover then
        if XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.ShopCommon) then
            XLuaUiManager.Open("UiShop", XShopManager.ShopType.Activity)
        end
    end
end

function XUiPanelChallengeMode:OnBtnActDescClick(eventData)
    if self.CurrentCover then
        self:OnClosePrequelDetail()
        local coverInfo = XPrequelConfigs.GetPrequelCoverInfoById(self.CurrentCover.CoverId)
        local description = string.gsub(coverInfo.CoverDescription, "\\n", "\n")
        XUiManager.UiFubenDialogTip("", description)
    end
end

function XUiPanelChallengeMode:InitChallengeTab()
    self.ChallengeTab:UpdateTabs(self.CurrentCover)
end

function XUiPanelChallengeMode:UpdateChallengeStages()
    if not self.CurrentCover then return end
    for _, v in pairs(self.ChallengeList) do
        v:Hide()
    end

    local prefabName = self.CurrentCover.CoverVal.ChallengePrefabName
    if not prefabName or prefabName == "" then
        XLog.Error("XUiPanelChallengeMode:UpdateChallengeStages error : prefabName not found " .. tostring(prefabName))
        return 
    end

    self.ChallengeStageDatas = {}
    for i=1, #self.CurrentCover.CoverVal.ChallengeStage do
        table.insert(self.ChallengeStageDatas, {
            CoverId = self.CurrentCover.CoverId,
            ChallengeStage = self.CurrentCover.CoverVal.ChallengeStage[i],
            ChallengeConsumeItem = self.CurrentCover.CoverVal.ChallengeConsumeItem[i],
            ChallengeConsumeCount = self.CurrentCover.CoverVal.ChallengeConsumeCount[i],
            ChallengeIndex = i,
        })
    end

    local asset = self.PanelPrequelStages:LoadPrefab(prefabName)
    if asset == nil or (not asset:Exist()) then
        XLog.Error("当前prefab不存在：" .. tostring(prefabName))
        return 
    end
    local grid = XUiPanelChallengeChapter.New(asset, self.RootUi)
    grid.Transform:SetParent(self.PanelPrequelStages, false)
    grid:UpdateChallengeGrid(self.ChallengeStageDatas)
    grid:Show()
    self.CurrentChallengeGrid = grid
end

function XUiPanelChallengeMode:OnDetailClosed()
    if self.CurrentChallengeGrid then
        self.CurrentChallengeGrid:OnPrequelDetailClosed()
    end
end

-- [刷新挑战消耗]
function XUiPanelChallengeMode:UpdateCostItem()
    local itemId = self.CurrentCover.CoverVal.ChallengeConsumeItem[1]
    local itemNum = XDataCenter.ItemManager.GetCount(itemId)
    self.TxtTotalNum.text = itemNum
    self.RImgCostIcon:SetRawImage(XDataCenter.ItemManager.GetItemIcon(itemId))
end

function XUiPanelChallengeMode:OnRefresh(coverData)
    self.CurrentCover = coverData

    XUiHelper.PlayAnimation(self.RootUi, ANICHALLENGEMODEBEGIN, function()
        self.RootUi:SetChallengeAnimBegin(true)
        self:InitChallengeTab()
        self:UpdateChallengeStages()
        self:UpdateCostItem()
        self:AddTimer()
        self:AddChallengeTimer()
    end, function()
        self.RootUi:SetChallengeAnimBegin(false)
    end)
    
end

function XUiPanelChallengeMode:UpdateTimer()
    self:AddTimer()
end

function XUiPanelChallengeMode:AddTimer()
    local checkpointTime = XDataCenter.PrequelManager.GetNextCheckPointTime()
    local remainTime = checkpointTime - XTime.Now()
    if remainTime > 0 then
    
        XCountDown.CreateTimer(self.GameObject.name, remainTime)
        XCountDown.BindTimer(self.GameObject, self.GameObject.name, function(v, oldV)
            self.TxtResetTime.text = XUiHelper.GetTime(v, XUiHelper.TimeFormatType.SHOP)
            if v == 0 then self:RemoveTimer() end
        end)
    end
end

function XUiPanelChallengeMode:RemoveTimer()
    XCountDown.RemoveTimer(self.GameObject.name)
end

function XUiPanelChallengeMode:AddChallengeTimer()
    self:RemoveChallengeTimer()
    ChallengeChapterTimer = CS.XScheduleManager.Schedule(function()
        self:UpdateChapterItems()
    end, ChallengeChapterInterval, 0)
end

function XUiPanelChallengeMode:RemoveChallengeTimer()
    if ChallengeChapterTimer then
        CS.XScheduleManager.UnSchedule(ChallengeChapterTimer)
        ChallengeChapterTimer = nil
    end
end

function XUiPanelChallengeMode:UpdateChapterItems()
    if self.CurrentChallengeGrid then
        self.CurrentChallengeGrid:UpdateItems()
    end
end

return XUiPanelChallengeMode
