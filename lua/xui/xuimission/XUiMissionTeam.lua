--local XUiMissionTeam = XUiManager.Register("UiMissionTeam")
local XUiMissionTeam = XLuaUiManager.Register(XLuaUi, "UiMissionTeam")

local MissionQuality = 
{
    [1] = CS.XGame.ClientConfig:GetString("MissionQuality1"),
    [2] = CS.XGame.ClientConfig:GetString("MissionQuality2"),
    [3] = CS.XGame.ClientConfig:GetString("MissionQuality3"),
    [4] = CS.XGame.ClientConfig:GetString("MissionQuality4"),
    [5] = CS.XGame.ClientConfig:GetString("MissionQuality5"),
}

function XUiMissionTeam:OnAwake()
    self:InitAutoScript()
end

function XUiMissionTeam:OnStart(task)

    self.Task = task
    self:Init()
    self.CharacterIds = {}
    self:SetupContent()
    XUiHelper.PlayAnimation(self, "UiMissionTeamBegin")

end

function XUiMissionTeam:Init()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)

    local characterGrid = {}
    characterGrid[1] = XUiPanelMissionCharacter.New(self.PanelMissionCharacter, self, 1)
    characterGrid[2] = XUiPanelMissionCharacter.New(self.PanelMissionCharacter1, self, 2)
    characterGrid[3] = XUiPanelMissionCharacter.New(self.PanelMissionCharacter2, self, 3)
    self.CharacterGrid = characterGrid

    self.GridConditions = {}
    local XUiGridConditionTxt = require("XUi/XUiMission/XUiGridConditionTxt")
    table.insert(self.GridConditions, XUiGridConditionTxt.New(self.GridConditionTxt))
    for i = 1, 2, 1 do
        local ui = CS.UnityEngine.Object.Instantiate(self.GridConditionTxt)
        local gridCondition = XUiGridConditionTxt.New(ui)
        gridCondition.Transform:SetParent(self.PanelLayoutAct, false)
        table.insert(self.GridConditions, gridCondition)
    end
end

--设置内容
function XUiMissionTeam:SetupContent()
    if not self.Task then
        return
    end

    local taskCfg = self.Task.TaskCfg
    if not taskCfg then
        return
    end

    self.TaskCfg = taskCfg

    self:SetupBaseInfo()
    self:SetupExtraCondition()
    self:SetupTeamCondition()
    self:SetupTeamCharacter()
end

function XUiMissionTeam:SetupBaseInfo()
    local taskCfg = self.TaskCfg
    self.TxtName.text = taskCfg.Name
    self.TxtTime.text = CS.XDate.GetTimeString(taskCfg.Duration)
    self:SetUiSprite(self.ImgQuality, MissionQuality[taskCfg.Quality])

    local curSectionId = XDataCenter.TaskForceManager.GetCurTaskForceSectionId()
    local data = XDataCenter.TaskForceManager.GetTaskForceSectionConfigById(curSectionId)
    self:SetUiSprite(self.ImgZhangjie, data.SectionChapterIcon)
end

function XUiMissionTeam:Refresh(ids)
    self.CharacterIds = ids
    self:SetupContent()
end

function XUiMissionTeam:SetupTeamCharacter()
    local taskCfg = self.TaskCfg
    local memberCount = taskCfg.MemberCount
    for i, v in ipairs(self.CharacterGrid) do
        if not self.CharacterIds[i] then
            if memberCount >= i then
                v:SetEmpty()
            else
                v:SetLock()
            end
        else
            v:SetCharacter(self.CharacterIds[i])
        end

        v:SetSelectData(memberCount, self.CharacterIds)
    end
end


--设置额外条件
function XUiMissionTeam:SetupExtraCondition()
    local extraRewardConditionId = self.TaskCfg.ExtraRewardConditionId
    self.PanelOtherReward.gameObject:SetActive(extraRewardConditionId ~= 0)

    if extraRewardConditionId and extraRewardConditionId > 0 then

        local template = XConditionManager.GetConditionTemplate(extraRewardConditionId)
        if template then
            self.TxtDesc.text = template.Desc
            self.TxtDescA.text = template.Desc
        end

        local enough = XConditionManager.CheckTeamCondition(extraRewardConditionId, self.CharacterIds)
        self.PanelOn.gameObject:SetActive(enough)
        self.PanelOff.gameObject:SetActive(not enough)

        local rewards = XRewardManager.GetRewardList(self.TaskCfg.ExtraRewardId)
        local item = XDataCenter.ItemManager.GetItem(rewards[1].TemplateId)

        self.GoodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(rewards[1].TemplateId)

        self.TxtCount.text = "x" .. tostring(rewards[1].Count)
        self.TxtCountA.text = "x" .. tostring(rewards[1].Count)

        self:SetUiSprite(self.ImgRes, item.Template.Icon)
        self:SetUiSprite(self.ImgResA, item.Template.Icon)

    end
end


--设置条件
function XUiMissionTeam:SetupTeamCondition()
    local conditionList = self.TaskCfg.ConditionList

    local ids = {}

    for k, v in pairs(self.CharacterIds) do
        table.insert(ids, v)
    end

    if conditionList then
        for i = 1, 3, 1 do
            if i == 1 then
                self.GridConditions[i]:SetupExtraContent(self.TaskCfg.MemberCount, ids)
            elseif conditionList[i - 1] then
                self.GridConditions[i].GameObject:SetActive(true)
                self.GridConditions[i]:SetupContent(conditionList[i - 1], ids)
            else
                self.GridConditions[i].GameObject:SetActive(false)
            end
        end
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiMissionTeam:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiMissionTeam:AutoInitUi()
    self.PanelInfo = self.Transform:Find("SafeAreaContentPane/PanelInfo")
    self.TxtTime = self.Transform:Find("SafeAreaContentPane/PanelInfo/TxtTime"):GetComponent("Text")
    self.PanelImg = self.Transform:Find("SafeAreaContentPane/PanelInfo/PanelImg")
    self.ImgZhangjie = self.Transform:Find("SafeAreaContentPane/PanelInfo/PanelImg/ImgZhangjie"):GetComponent("Image")
    self.ImgQuality = self.Transform:Find("SafeAreaContentPane/PanelInfo/PanelImg/ImgQuality"):GetComponent("Image")
    self.TxtName = self.Transform:Find("SafeAreaContentPane/PanelInfo/PanelImg/TxtName"):GetComponent("Text")
    self.PanelRequire = self.Transform:Find("SafeAreaContentPane/PanelInfo/PanelRequire")
    self.PanelLayoutAct = self.Transform:Find("SafeAreaContentPane/PanelInfo/PanelRequire/PanelLayoutAct")
    self.GridConditionTxt = self.Transform:Find("SafeAreaContentPane/PanelInfo/PanelRequire/PanelLayoutAct/GridConditionTxt")
    self.BtnSend = self.Transform:Find("SafeAreaContentPane/PanelInfo/BtnSend"):GetComponent("Button")
    self.BtnAutoTeam = self.Transform:Find("SafeAreaContentPane/PanelInfo/BtnAutoTeam"):GetComponent("Button")
    self.PanelTeam = self.Transform:Find("SafeAreaContentPane/PanelTeam")
    self.PanelMissionCharacter2 = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelMissionCharacter2")
    self.PanelMissionCharacter1 = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelMissionCharacter1")
    self.PanelMissionCharacter = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelMissionCharacter")
    self.PanelOtherReward = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward")
    self.PanelOn = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward/PanelOn")
    self.TxtDescA = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward/PanelOn/TxtDesc"):GetComponent("Text")
    self.ImgResA = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward/PanelOn/ImgRes"):GetComponent("Image")
    self.BtnResOn = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward/PanelOn/ImgRes/BtnResOn"):GetComponent("Button")
    self.TxtCountA = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward/PanelOn/TxtCount"):GetComponent("Text")
    self.PanelOff = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward/PanelOff")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward/PanelOff/TxtDesc"):GetComponent("Text")
    self.ImgRes = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward/PanelOff/ImgRes"):GetComponent("Image")
    self.BtnResOff = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward/PanelOff/ImgRes/BtnResOff"):GetComponent("Button")
    self.TxtCount = self.Transform:Find("SafeAreaContentPane/PanelTeam/PanelOtherReward/PanelOff/TxtCount"):GetComponent("Text")
    self.PanelTopBtn = self.Transform:Find("SafeAreaContentPane/PanelTopBtn")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelTopBtn/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelTopBtn/BtnMainUi"):GetComponent("Button")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
end

function XUiMissionTeam:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiMissionTeam:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiMissionTeam:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiMissionTeam:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnSend, "onClick", self.OnBtnSendClick)
    self:RegisterListener(self.BtnAutoTeam, "onClick", self.OnBtnAutoTeamClick)
    self:RegisterListener(self.BtnResOn, "onClick", self.OnBtnResOnClick)
    self:RegisterListener(self.BtnResOff, "onClick", self.OnBtnResOffClick)
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnMainUi, "onClick", self.OnBtnMainUiClick)
end
-- auto

function XUiMissionTeam:OnBtnResOnClick(...)
    self:OnBtnResOffClick()
end

function XUiMissionTeam:OnBtnResOffClick(...)
    local rewards = XRewardManager.GetRewardList(self.TaskCfg.ExtraRewardId)
    local rewardData = rewards[1]

    if not rewardData then
        return
    end

    if self.GoodsShowParams.RewardType == XRewardManager.XRewardType.Character then
        --CS.XUiManager.ViewManager:Push("UiCharacterDetail", false, false, rewardData.TemplateId)
        XLuaUiManager.Open("UiCharacterDetail", rewardData.TemplateId)
    elseif self.GoodsShowParams.RewardType == XRewardManager.XRewardType.Equip then
        --CS.XUiManager.ViewManager:Push("UiEquip", false, false, rewardData, XGlobalVar.EquipTabIndex.Detail, true)
        -- XLuaUiManager.Open("UiEquip", rewardData, XGlobalVar.EquipTabIndex.Detail, true)
    else
        --CS.XUiManager.ViewManager:Push("UiTip", true, false, rewardData and rewardData or rewardData.TemplateId)
        XLuaUiManager.Open("UiTip", rewardData and rewardData or rewardData.TemplateId)
    end
end

function XUiMissionTeam:OnBtnSendClick(...)
    local enough, error = XDataCenter.TaskForceManager.CheckTeamCondition(self.TaskCfg.Id, self.CharacterIds)
    if not enough then
        XUiManager.TipMsg(error)
        return
    end

    XDataCenter.TaskForceManager.AcceptTaskForceTaskRequest(self.TaskCfg.Id, self.CharacterIds, function()
        --CS.XUiManager.ViewManager:Pop()
        self:Close()
    end)
end

--一键选择
function XUiMissionTeam:OnBtnAutoTeamClick(...)
    if not self.TaskCfg then
        return
    end

    local characterIds = XDataCenter.TaskForceManager.AutoChoiceCharacter(self.TaskCfg.Id)
    if #characterIds <= 0 then
        XUiManager.TipMsg(CS.XTextManager.GetText("MissionAutoSelectFail"))
        return
    end

    self.CharacterIds = characterIds

    XUiHelper.PlayAnimation(self, "UiMissionTeamSlect")

    self:SetupContent()
end

function XUiMissionTeam:OnBtnBackClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end

function XUiMissionTeam:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end