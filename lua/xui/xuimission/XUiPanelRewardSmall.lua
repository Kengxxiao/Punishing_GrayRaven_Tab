local XUiPanelRewardSmall = XClass()

function XUiPanelRewardSmall:Ctor(ui,parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self:InitAutoScript()
    self.GridList = {}
    self.GridMissionCommonA.gameObject:SetActive(false)
end

--设置奖励
function XUiPanelRewardSmall:SetupReward(result)
    if not result then
        return
    end
    local rewardExtra = result.ExtraRewardList
    local rewards = result.Rewards

    local XUiGridMissionCommon = require("XUi/XUiMission/XUiGridMissionCommon")

    local start = 0
    if rewardExtra then
        for i, item in ipairs(rewardExtra) do
            start = start + 1
            local grid = nil
            if self.GridList[start] then
                grid = self.GridList[start]
            else
                local ui = CS.UnityEngine.Object.Instantiate(self.GridMissionCommonA)
                grid = XUiGridMissionCommon.New(self.Parent, ui)
                grid.Transform:SetParent(self.PanelReward, false)
                grid.ImgAdditional.gameObject:SetActive(true)
                grid.ImgBig.gameObject:SetActive(false)
                table.insert(self.GridList, grid)
            end
            grid:Refresh(item)
            grid.GameObject:SetActive(true)
        end
    end

    --显示的奖励
    if rewards then
        for i, item in ipairs(rewards) do
            start = start + 1
            local grid = nil
            if self.GridList[start] then
                grid = self.GridList[start]
            else
                local ui = CS.UnityEngine.Object.Instantiate(self.GridMissionCommonA)
                grid = XUiGridMissionCommon.New(self.Parent, ui)
                grid.Transform:SetParent(self.PanelReward, false)
                grid.ImgAdditional.gameObject:SetActive(false)
                grid.ImgBig.gameObject:SetActive(false)
                table.insert(self.GridList, grid)
            end
            grid:Refresh(item)
            grid.GameObject:SetActive(true)
        end
    end

    for j = start + 1, #self.GridList do
        self.GridList[j].GameObject:SetActive(false)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelRewardSmall:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelRewardSmall:AutoInitUi()
    self.PanelRewardSmallA = self.Transform:Find("PanelRewardSmall")
    self.ScrollViewA = self.Transform:Find("PanelRewardSmall/ScrollView"):GetComponent("Scrollbar")
    self.PanelReward = self.Transform:Find("PanelRewardSmall/ScrollView/Viewport/PanelReward")
    self.GridMissionCommonA = self.Transform:Find("PanelRewardSmall/ScrollView/Viewport/PanelReward/GridMissionCommon")
end

function XUiPanelRewardSmall:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelRewardSmall:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelRewardSmall:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelRewardSmall:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto



return XUiPanelRewardSmall
