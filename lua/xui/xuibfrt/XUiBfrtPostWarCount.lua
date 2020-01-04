local ipairs = ipairs
local XUiGridEchelonExp = require("XUi/XUiBfrt/XUiGridEchelonExp")
local XUiBfrtPostWarCount = XLuaUiManager.Register(XLuaUi, "UiBfrtPostWarCount")
local ANIMATION_OPEN = "AniBfrtPostWarCountBegin"

function XUiBfrtPostWarCount:OnAwake()
    self:InitAutoScript()
end

function XUiBfrtPostWarCount:OnStart(data)
    self:InitComponentState()
    self:ResetDataInfo()
    self:UpdateDataInfo(data)
    self.GameObject:PlayLegacyAnimation(ANIMATION_OPEN)
end

function XUiBfrtPostWarCount:OnNotify(evt, ...)
    
    local args = {...}
    
    if evt == CS.XEventId.EVENT_UI_ALLOWOPERATE and args[1] == self.Ui then
        XDataCenter.FunctionEventManager.UnLockFunctionEvent()
    end
end

function XUiBfrtPostWarCount:OnGetEvents()
    return {CS.XEventId.EVENT_UI_ALLOWOPERATE}
end

function XUiBfrtPostWarCount:InitComponentState()
    self.GridEchelonExp.gameObject:SetActive(false)
end

function XUiBfrtPostWarCount:ResetDataInfo()
    self.RewardGoodsList = {}
    self.GroupId = nil

    self.GridReward.gameObject:SetActive(false)
    self.GridEchelonExp.gameObject:SetActive(false)
end

function XUiBfrtPostWarCount:UpdateDataInfo(data)
    self.RewardGoodsList = data.RewardGoodsList
    self.GroupId = XDataCenter.BfrtManager.GetGroupIdByStageId(data.StageId)

    self:UpdatePanelRewardContent()
    self:UpdatePanelEchelonExpContent()
    self:UpdatePanelPlayer()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiBfrtPostWarCount:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiBfrtPostWarCount:AutoInitUi()
    self.PanelRewardContent = self.Transform:Find("SafeAreaContentPane/PaneReward/RewardList/Viewport/PanelRewardContent")
    self.GridReward = self.Transform:Find("SafeAreaContentPane/PaneReward/RewardList/Viewport/PanelRewardContent/GridReward")
    self.PanelEchelonExpContent = self.Transform:Find("SafeAreaContentPane/PaneEchelonExp/EchelonExpList/Viewport/PanelEchelonExpContent")
    self.GridEchelonExp = self.Transform:Find("SafeAreaContentPane/PaneEchelonExp/EchelonExpList/Viewport/PanelEchelonExpContent/GridEchelonExp")
    self.BtnExit = self.Transform:Find("SafeAreaContentPane/BtnExit"):GetComponent("Button")
    self.BtnClose = self.Transform:Find("SafeAreaContentPane/BtnClose"):GetComponent("Button")
    self.PanelPlayer = self.Transform:Find("SafeAreaContentPane/PanelPlayer")
    self.ImgExp = self.Transform:Find("SafeAreaContentPane/PanelPlayer/ImgExp"):GetComponent("Image")
    self.TxtAddExp = self.Transform:Find("SafeAreaContentPane/PanelPlayer/TxtAddExp"):GetComponent("Text")
    self.TxtLevelA = self.Transform:Find("SafeAreaContentPane/PanelPlayer/TxtLevel"):GetComponent("Text")
end

function XUiBfrtPostWarCount:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiBfrtPostWarCount:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiBfrtPostWarCount:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiBfrtPostWarCount:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnExit, "onClick", self.OnBtnExitClick)
    self:RegisterListener(self.BtnClose, "onClick", self.OnBtnCloseClick)
end
-- auto
function XUiBfrtPostWarCount:OnBtnExitClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end

function XUiBfrtPostWarCount:OnBtnCloseClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end

function XUiBfrtPostWarCount:UpdatePanelRewardContent()
    local rewards = XRewardManager.MergeAndSortRewardGoodsList(self.RewardGoodsList)
    for i, item in ipairs(rewards) do
        local ui = CS.UnityEngine.Object.Instantiate(self.GridReward)
        local grid = XUiGridCommon.New(self, ui)
        grid.Transform:SetParent(self.PanelRewardContent, false)
        grid:Refresh(item, nil, nil, true)
        grid.GameObject:SetActive(true)
    end
end

function XUiBfrtPostWarCount:UpdatePanelEchelonExpContent()
    local data = {
        EchelonId = nil,
        EchelonType = nil,
        EchelonIndex = nil,
        BaseStage = XDataCenter.BfrtManager.GetBaseStage(self.GroupId),
    }

    local fightInfoIdList = XDataCenter.BfrtManager.GetFightInfoIdList(self.GroupId)
    for index, echelonId in ipairs(fightInfoIdList) do
        data.EchelonId = echelonId
        data.EchelonIndex = index
        data.EchelonType = XDataCenter.BfrtManager.EchelonType.Fight

        local ui = CS.UnityEngine.Object.Instantiate(self.GridEchelonExp)
        local grid = XUiGridEchelonExp.New(self, ui, data)
        grid.Transform:SetParent(self.PanelEchelonExpContent, false)
        grid.GameObject:SetActive(true)
    end

    local lgoisticsInfoIdList = XDataCenter.BfrtManager.GetLogisticsInfoIdList(self.GroupId)
    for index, echelonId in ipairs(lgoisticsInfoIdList) do
        data.EchelonId = echelonId
        data.EchelonIndex = index
        data.EchelonType = XDataCenter.BfrtManager.EchelonType.Logistics

        local ui = CS.UnityEngine.Object.Instantiate(self.GridEchelonExp)
        local grid = XUiGridEchelonExp.New(self, ui, data)
        grid.Transform:SetParent(self.PanelEchelonExpContent, false)
        grid.GameObject:SetActive(true)
    end
end

function XUiBfrtPostWarCount:UpdatePanelPlayer()
    local curLevel = XPlayer.Level
    local curExp = XPlayer.Exp
    local maxExp = XPlayerManager.GetMaxExp(curLevel)
    local baseStageId = XDataCenter.BfrtManager.GetBaseStage(self.GroupId)
    local baseStageCfg = XDataCenter.FubenManager.GetStageCfg(baseStageId)

    self.TxtLevelA.text = curLevel
    self.TxtAddExp.text = "+ " .. baseStageCfg.TeamExp
    self.ImgExp.fillAmount = curExp / maxExp
end