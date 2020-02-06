local XUiBabelTowerMainUi = XLuaUiManager.Register(XLuaUi, "UiBabelTowerMainUi")
local XUiGridBabelStageBanner = require("XUi/XUiFubenBabelTower/XUiGridBabelStageBanner")

local Mathf = CS.UnityEngine.Mathf
local Smooting = 10
local Sensitive = 8

function XUiBabelTowerMainUi:OnAwake()
    self:Init()

    XEventManager.AddEventListener(XEventId.EVENT_BABEL_STAGE_INFO_ASYNC, self.RefreshMainUi, self)
    XEventManager.AddEventListener(XEventId.EVENT_BABEL_ACTIVITY_STATUS_CHANGED, self.OnActivityStatusChanged, self)
end

function XUiBabelTowerMainUi:OnDestroy()
    if self.StageContentWidget then
        self.StageContentWidget:RemoveAllListeners()
    end

    XEventManager.RemoveEventListener(XEventId.EVENT_BABEL_STAGE_INFO_ASYNC, self.RefreshMainUi, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_BABEL_ACTIVITY_STATUS_CHANGED, self.OnActivityStatusChanged, self)
end

function XUiBabelTowerMainUi:Init()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.BtnBack.CallBack = function() self:OnBtnBackClick() end
    self.BtnMainUi.CallBack = function() self:OnBtnMainUiClick() end
    self.BtnAchievement.CallBack = function() self:OnBtnAchievementClick() end

    self.StageContentWidget:AddBeginDragListener(function(eventData) self:OnBeginDrag(eventData) end)
    self.StageContentWidget:AddEndDragListener(function(eventData) self:OnEndDrag(eventData) end)
    self.StageContentWidget:AddDragListener(function(eventData) self:OnDrag(eventData) end)

    local behaviour = self.GameObject:GetComponent(typeof(CS.XLuaBehaviour))
    if not behaviour then
        behaviour = self.GameObject:AddComponent(typeof(CS.XLuaBehaviour))
    end
    if self.Update then
        behaviour.LuaUpdate = function() self:Update() end
    end
end

function XUiBabelTowerMainUi:InitScrollPages()
    self.ScrollPages = {}
    local temp = #self.CurrentActivityTemplate.StageId
    for i=1, temp do
        local progress = 0
        if temp ~= 1 then
            progress = (i- 1) / (temp - 1)
        end
        table.insert(self.ScrollPages, progress)
    end
end

function XUiBabelTowerMainUi:Update()
    if not self.IsDraging and self.ScrollPages and #self.ScrollPages > 0  and self.ScrollPages[self.CurrentIndex] then
        local t = CS.UnityEngine.Time.deltaTime * Smooting
        self.PanelTaskList.verticalNormalizedPosition = Mathf.Lerp(self.PanelTaskList.verticalNormalizedPosition, 1 - self.ScrollPages[self.CurrentIndex], t)
    end
end

function XUiBabelTowerMainUi:OnBeginDrag(eventData)
    self.PanelTaskList:OnBeginDrag(eventData)
    self.IsDraging = true
    self.PreY = self.PanelTaskList.verticalNormalizedPosition
end

function XUiBabelTowerMainUi:OnDrag(eventData)
    self.PanelTaskList:OnDrag(eventData)
end

function XUiBabelTowerMainUi:OnEndDrag(eventData)
    self.PanelTaskList:OnEndDrag(eventData)

    local curY = self.PanelTaskList.verticalNormalizedPosition
    
    local sensitive = 1 / (#self.ScrollPages * Sensitive)
    local index = self.CurrentIndex or 1
    if self.PreY and curY - self.PreY >= sensitive then
        index = index - 1
        if index <= 0 then
            index = 1
        end
        -- self.CurrentIndex = index
        self.PanelNoticeTitleBtnGroup:SelectIndex(index)
    end
    
    if self.PreY and self.PreY - curY >= sensitive then
        index = index + 1
        if index >= #self.ScrollPages then
            index = #self.ScrollPages
        end
        -- self.CurrentIndex = index
        self.PanelNoticeTitleBtnGroup:SelectIndex(index)
    end

    self.IsDraging = false
end

function XUiBabelTowerMainUi:OnBtnBackClick()
    self:Close()
end

function XUiBabelTowerMainUi:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiBabelTowerMainUi:OnBtnAchievementClick()
    -- 时间限制，不在活动期间不给打开
    if not self.CurrentActivityNo or not XDataCenter.FubenBabelTowerManager.IsInActivityTime(self.CurrentActivityNo) then
        XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerNoneOpen"))
        return
    end

    XLuaUiManager.Open("UiBabelTowerTask")
end

function XUiBabelTowerMainUi:OnActivityStatusChanged()
    if not XLuaUiManager.IsUiShow("UiBabelTowerMainUi") then return end
    local curActivityNo = XDataCenter.FubenBabelTowerManager.GetCurrentActivityNo()
    if not curActivityNo or not XDataCenter.FubenBabelTowerManager.IsInActivityTime(curActivityNo) then
        XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerNoneOpen"))
        XLuaUiManager.RunMain()
    end
end

function XUiBabelTowerMainUi:OnEnable()
    self:OnActivityStatusChanged()
end

function XUiBabelTowerMainUi:OnStart()
    self.CurrentActivityNo = XDataCenter.FubenBabelTowerManager.GetCurrentActivityNo()
    self.CurrentActivityMaxScore = XDataCenter.FubenBabelTowerManager.GetCurrentActivityMaxScore()
    self.CurrentActivityTemplate = XFubenBabelTowerConfigs.GetBabelTowerActivityTemplateById(self.CurrentActivityNo)
    if not self.CurrentActivityTemplate then 
        return 
    end

    self:InitScrollPages()
    self:UpdateStageDetails()
    self:SetStageDetails()
    self:UpdateStageScores()
end

function XUiBabelTowerMainUi:RefreshMainUi()
    if self.CurrentActivityTemplate then
        for i=1, #self.CurrentActivityTemplate.StageId do
            local curStageId = self.CurrentActivityTemplate.StageId[i]
            if self.StageGridChapter[i] then
                self.StageGridChapter[i]:UpdateStageInfo(curStageId)
            end
        end
    end
    self:UpdateStageScores()
end

function XUiBabelTowerMainUi:UpdateStageScores()
    local curScore, maxScore = XDataCenter.FubenBabelTowerManager.GetCurrentActivityScores()
    self.TxtTotalLevel.text = curScore
    self.TxtName.text = XFubenBabelTowerConfigs.GetActivityName(self.CurrentActivityNo)
    self.TxtHighest.text = CS.XTextManager.GetText("BabelTowerCurMaxScore", maxScore)
end

function XUiBabelTowerMainUi:UpdateStageDetails()
    self.StageTabList = {}
    self.StageGridChapter = {}

    for i=1, #self.CurrentActivityTemplate.StageId do
        local curStageId = self.CurrentActivityTemplate.StageId[i]
        if not self.StageGridChapter[i] then
            local gridGo = CS.UnityEngine.Object.Instantiate(self.GrideStageChapter)
            gridGo.transform:SetParent(self.PanelStageContent, false)
            gridGo.gameObject:SetActiveEx(true)
            gridGo.name = string.format("%s%d", self.GrideStageChapter.name, i)
            table.insert(self.StageGridChapter, XUiGridBabelStageBanner.New(gridGo, self, curStageId))
        end
        self.StageGridChapter[i]:UpdateStageInfo(curStageId)

        if not self.StageTabList[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.BtnStageTab)
            go.transform:SetParent(self.PanelNoticeTitleBtnGroup.transform, false)
            go.gameObject:SetActiveEx(true)
            go.name = string.format("%s%d", self.BtnStageTab.name, i)
            table.insert(self.StageTabList, go.transform:GetComponent("XUiButton"))
        end
    end
    for i = #self.CurrentActivityTemplate.StageId + 1, #self.StageTabList do
        self.StageTabList[i].gameObject:SetActiveEx(false)
        self.StageGridChapter[i].GameObject:SetActiveEx(false)
    end

    self.PanelNoticeTitleBtnGroup:Init(self.StageTabList, function(i) self:OnStageTabClick(i) end)

    -- 默认选中
    local defaultSelect = XDataCenter.FubenBabelTowerManager.GetBabelTowerPrefs(XFubenBabelTowerConfigs.LAST_SELECT_KEY, #self.ScrollPages)
    self.PanelNoticeTitleBtnGroup:SelectIndex(defaultSelect)
    self.PanelTaskList.verticalNormalizedPosition = 1 - self.ScrollPages[defaultSelect]
end

-- 设置关卡详情
function XUiBabelTowerMainUi:SetStageDetails()
    for i=1, #self.CurrentActivityTemplate.StageId do
        local curStageId = self.CurrentActivityTemplate.StageId[i]
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(curStageId)
        self.StageTabList[i]:SetNameByGroup(0, stageCfg.Name)
    end
end

-- 关卡点击
function XUiBabelTowerMainUi:OnStageTabClick(index)
    self.CurrentStageId = self.CurrentActivityTemplate.StageId[index]
    if not self.CurrentStageId then
        XLog.Error("OnStageTabClick error:" .. tostring(index))
        return
    end
    
    XDataCenter.FubenBabelTowerManager.SaveBabelTowerPrefs(XFubenBabelTowerConfigs.LAST_SELECT_KEY, index)
    
    -- 切换背景
    local stageConfigs = XFubenBabelTowerConfigs.GetBabelStageConfigs(self.CurrentStageId)
    self:SwitchMainBg(stageConfigs.MainUiBg)
    if self.CurrentIndex and self.CurrentIndex ~= index then
        self:PlayAnimation("QieHuan")
    end
    
    if self.CurrentActivityTemplate then
        local curStageId = self.CurrentActivityTemplate.StageId[self.CurrentIndex]
        if curStageId and self.StageGridChapter[self.CurrentIndex] then
            self.StageGridChapter[self.CurrentIndex]:RefreshStageBanner()
            self.StageGridChapter[self.CurrentIndex]:RefreshBtns()
        end
    end
    self.CurrentIndex = index
end

-- 加上自选战略等级
function XUiBabelTowerMainUi:GetGuideList(guidIds)
    local guideList = {}
    for i=1, #guidIds do
        table.insert(guideList, guidIds[i])
    end
    return guideList
end

-- 更改背景
function XUiBabelTowerMainUi:SwitchMainBg(bg)
    self.RImgBg:SetRawImage(bg)
end