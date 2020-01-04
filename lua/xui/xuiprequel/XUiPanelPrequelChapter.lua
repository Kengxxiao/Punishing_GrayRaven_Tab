local stringFormat = string.format

local XUiGridStage = require("XUi/XUiFubenMainLineChapter/XUiGridStage")

XUiPanelPrequelChapter = XClass()

function XUiPanelPrequelChapter:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self.GridChapterStageList = {}
    self.GridLineList = {}
    self.BoundSizeFitter = self.PanelStageContent:GetComponent("XBoundSizeFitter")
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelPrequelChapter:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelPrequelChapter:AutoInitUi()
    self.GridPrequelStage = self.Transform:Find("GridPrequelStage")
    self.SViewlStageList = self.Transform:Find("SViewlStageList"):GetComponent("ScrollRect")
    self.PanelStageContent = self.Transform:Find("SViewlStageList/ViewPort/PanelStageContent")
end

function XUiPanelPrequelChapter:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelPrequelChapter:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelPrequelChapter:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelPrequelChapter:AutoAddListener()
end
-- auto

function XUiPanelPrequelChapter:Show()
    if self.GameObject.activeSelf == true then return end
    self.GameObject:SetActive(true)
end

function XUiPanelPrequelChapter:Hide()
    if self.GameObject.activeSelf == false then return end
    self.GameObject:SetActive(false)
end

-- 如果没有彩蛋，生成假彩蛋
function XUiPanelPrequelChapter:GenerateEggDatas(datas)
    local eggDatas = {}
    if not datas then return eggDatas end
    for k, v in pairs(datas) do
        eggDatas[k] = v
    end
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(eggDatas[1])
    if not self:IsHideStage(stageCfg) then
        table.insert(eggDatas, 1, eggDatas[1])
    end
    return eggDatas
end

function XUiPanelPrequelChapter:UpdatePrequelGrid(data)
    if not data then return end
    self.PrequelChapterStageList = self:GenerateEggDatas(data)

    -- 设置剧情数据
    for i=1, #self.PrequelChapterStageList do
        local grid = self.GridChapterStageList[i]
        if not grid then
            local parent = self.PanelStageContent.transform:Find(string.format("GridPrequelStage%d", i))
            if not parent then
                XLog.Error("XUiPanelPrequelChapter:UpdatePrequelGrid error: prefab not found a child name " .. string.format("GridPrequelStage%d", i))
                return 
            end
            local prefab = parent:LoadPrefab(CS.XGame.ClientConfig:GetString("GridPrequelStage"))
            grid = XUiGridStage.New(self.RootUi, prefab , nil, XFubenConfigs.FUBENTYPE_PREQUEL)
            self.GridChapterStageList[i] = grid
        end

        local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.PrequelChapterStageList[i])
        grid:UpdateStageMapGrid(stageCfg)
    end

    -- 隐藏多余的剧情
    local index = #self.PrequelChapterStageList + 1
    local extraStage = self.PanelStageContent.transform:Find(string.format("GridPrequelStage%d", index))
    while extraStage do
        extraStage.gameObject:SetActive(false)
        index = index + 1
        extraStage = self.PanelStageContent.transform:Find(string.format("GridPrequelStage%d", index))
    end

    -- 获得所有黑色线条
    for i = 1, #self.PrequelChapterStageList - 1 do
        if not self.GridLineList[i] then
            local line = self.PanelStageContent.transform:Find(string.format("Line%d", i))
            if not XTool.UObjIsNil(line) then
                line.gameObject:SetActive(false)
                self.GridLineList[i] = line
            end
        end
    end

    -- 隐藏多余的黑色线条，如果有
    local index = #self.PrequelChapterStageList - 1
    local hideGrid = self.PanelStageContent.transform:Find(string.format("Line%d", index))
    while hideGrid do
        hideGrid.gameObject:SetActive(false)
        index = index + 1
        hideGrid = self.PanelStageContent.transform:Find(string.format("Line%d", index))
    end

    -- 第一个是彩蛋
    -- 设置剧情显隐,从2开始第一个默认开启
    for i=3, #self.PrequelChapterStageList do
        local currentStageId = self.PrequelChapterStageList[i]
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(currentStageId)
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(currentStageId)
        local isHideStage = self:IsHideStage(stageCfg)
        self.GridChapterStageList[i].GameObject:SetActive(stageInfo.Unlock)
        self.GridChapterStageList[i].Transform.parent.gameObject:SetActive(stageInfo.Unlock)
        if self.GridLineList[i-2] then
            self.GridLineList[i-2].gameObject:SetActive(stageInfo.Unlock)
        end
    end

    -- 挂彩蛋
    local hideStageGridIndex = 1
    local hideStageGrid = self.GridChapterStageList[hideStageGridIndex]
    local hideStageId = self.PrequelChapterStageList[hideStageGridIndex]
    self:HangUpHideStage(hideStageGridIndex, hideStageGrid, hideStageId)


    -- 移动至ListView正确的位置
    if self.BoundSizeFitter then
        self.BoundSizeFitter:SetLayoutHorizontal()
    end

    if self.SViewlStageList then
        self.SViewlStageList.horizontalNormalizedPosition = 1
    end
    
end

function XUiPanelPrequelChapter:HangUpHideStage(hideStageGridIndex, hideStageGrid, hideStageId)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(hideStageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(hideStageId)
    local isHideStage = self:IsHideStage(stageCfg)
    local isHideStageOpen = XDataCenter.PrequelManager.CheckPrequelStageOpen(hideStageId)

    local isShowHideStage = isHideStage and isHideStageOpen
    hideStageGrid.GameObject:SetActive(isShowHideStage)
    hideStageGrid.Transform.parent.gameObject:SetActive(isShowHideStage)

    if isShowHideStage then
        if stageCfg.PreStageId and stageCfg.PreStageId[1] then
            for i=1, #self.PrequelChapterStageList do
                local hangUpPointStage = self.PrequelChapterStageList[i]
                if hangUpPointStage == stageCfg.PreStageId[1] then
                    hideStageGrid.Transform.parent.transform.localPosition = self.GridChapterStageList[i].Transform.parent.transform.localPosition
                    break
                end
            end
        end
    end
end

function XUiPanelPrequelChapter:IsHideStage(stageCfg)
    return stageCfg.StageType == XFubenConfigs.STAGETYPE_STORYEGG or stageCfg.StageType == XFubenConfigs.STAGETYPE_FIGHTEGG
end

return XUiPanelPrequelChapter
