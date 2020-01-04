local XUiPanelRewardBig = XClass()

function XUiPanelRewardBig:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self.GridList = {}
    self:InitAutoScript()
    self.GridMissionCommon.gameObject:SetActive(false)
end

function XUiPanelRewardBig:SetupCharacter(id)
    local character = XCharacterConfigs.GetCharacterTemplate(id)
    self.TxtDesc.text = character.MissionInfo
    --self.Parent:SetUiSprite(self.RImgRole, XDataCenter.CharacterManager.GetCharHalfBodyImage(id))
    self.RImgRole:SetRawImage(XDataCenter.CharacterManager.GetCharHalfBodyImage(id))
end


--设置奖励
function XUiPanelRewardBig:SetupReward(result)
    if not result then
        return
    end
    local rewardBig = result.DropList
    local rewardExtra = result.ExtraRewardList
    local rewards = result.Rewards

    local XUiGridMissionCommon = require("XUi/XUiMission/XUiGridMissionCommon")

    local start = 0
    if rewardBig then
        for i, item in ipairs(rewardBig) do
            start = start + 1
            local grid = nil
            if self.GridList[start] then
                grid = self.GridList[start]
            else
                local ui = CS.UnityEngine.Object.Instantiate(self.GridMissionCommon)
                grid = XUiGridMissionCommon.New(self.Parent, ui)
                grid.Transform:SetParent(self.PanelRewardBigA, false)
                grid.ImgAdditional.gameObject:SetActive(false)
                grid.ImgBig.gameObject:SetActive(true)
                table.insert(self.GridList, grid)
            end
            grid:Refresh(item)
            grid.GameObject:SetActive(true)
        end
    end


    if rewardExtra then
        for i, item in ipairs(rewardExtra) do
            start = start + 1
            local grid = nil
            if self.GridList[start] then
                grid = self.GridList[start]
            else
                local ui = CS.UnityEngine.Object.Instantiate(self.GridMissionCommon)
                grid = XUiGridMissionCommon.New(self.Parent, ui)
                grid.Transform:SetParent(self.PanelRewardBigA, false)
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
                local ui = CS.UnityEngine.Object.Instantiate(self.GridMissionCommon)
                grid = XUiGridMissionCommon.New(self.Parent, ui)
                grid.Transform:SetParent(self.PanelRewardBigA, false)
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
function XUiPanelRewardBig:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelRewardBig:AutoInitUi()
    self.PanelRewardInfo = self.Transform:Find("GameObject/PanelRewardInfo")
    self.ScrollView = self.Transform:Find("GameObject/PanelRewardInfo/ScrollView"):GetComponent("Scrollbar")
    self.PanelRewardBigA = self.Transform:Find("GameObject/PanelRewardInfo/ScrollView/Viewport/PanelRewardBig")
    self.GridMissionCommon = self.Transform:Find("GameObject/PanelRewardInfo/ScrollView/Viewport/PanelRewardBig/GridMissionCommon")
    self.PanelRole = self.Transform:Find("GameObject/PanelRewardInfo/PanelRole")
    self.RImgRole = self.Transform:Find("GameObject/PanelRewardInfo/PanelRole/RImgRole"):GetComponent("RawImage")
    self.TxtDesc = self.Transform:Find("GameObject/PanelRewardInfo/Image/TxtDesc"):GetComponent("Text")
end

function XUiPanelRewardBig:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelRewardBig:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelRewardBig:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelRewardBig:AutoAddListener()
    self.AutoCreateListeners = {}
end
-- auto
function XUiPanelRewardBig:OnScrollViewValueChanged(...)

end
function XUiPanelRewardBig:OnScrollViewAValueChanged(...)

end


return XUiPanelRewardBig