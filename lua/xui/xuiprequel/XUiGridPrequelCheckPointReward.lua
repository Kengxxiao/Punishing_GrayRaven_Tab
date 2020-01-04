XUiGridPrequelCheckPointReward = XClass()

function XUiGridPrequelCheckPointReward:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.RewardList = {}
    self.GridCommon.gameObject:SetActive(false)
end

function XUiGridPrequelCheckPointReward:Init(rootUi, parent)
    self.RootUi = rootUi
    self.Parent = parent
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridPrequelCheckPointReward:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridPrequelCheckPointReward:AutoInitUi()
    self.TxtOrder = self.Transform:Find("TxtOrder"):GetComponent("Text")
    self.TxtTaskName = self.Transform:Find("TxtTaskName"):GetComponent("Text")
    self.PanelRewardContent = self.Transform:Find("PanelRewardContent")
    self.GridCommon = self.Transform:Find("PanelRewardContent/GridCommon")
    self.RImgIcon = self.Transform:Find("PanelRewardContent/GridCommon/RImgIcon"):GetComponent("RawImage")
    self.ImgQuality = self.Transform:Find("PanelRewardContent/GridCommon/ImgQuality"):GetComponent("Image")
    self.BtnClick = self.Transform:Find("PanelRewardContent/GridCommon/BtnClick"):GetComponent("Button")
    self.TxtCount = self.Transform:Find("PanelRewardContent/GridCommon/TxtCount"):GetComponent("Text")
    self.BtnFinish = self.Transform:Find("BtnFinish"):GetComponent("Button")
    self.ImgAlreadyFinish = self.Transform:Find("ImgAlreadyFinish"):GetComponent("Image")
    self.ImgUnFinish = self.Transform:Find("ImgUnFinish"):GetComponent("Image")
end

function XUiGridPrequelCheckPointReward:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridPrequelCheckPointReward:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridPrequelCheckPointReward:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridPrequelCheckPointReward:AutoAddListener()
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
    self:RegisterClickEvent(self.BtnFinish, self.OnBtnFinishClick)
end
-- auto

function XUiGridPrequelCheckPointReward:OnBtnClickClick(eventData)

end

function XUiGridPrequelCheckPointReward:OnBtnFinishClick(eventData)
    if self.StageId then
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.StageId)
        local rewardedStages = XDataCenter.PrequelManager.GetRewardedStages()
        if stageInfo.Passed and rewardedStages and (not rewardedStages[self.StageId]) then
            XDataCenter.PrequelManager.ReceivePrequelRewardRequest(self.StageId, function()
                self.Parent:RefreshReward()
                self.RootUi:RefreshRegionalReward()
            end)
        end
    end
end

function XUiGridPrequelCheckPointReward:OnRefreshDatas(data, chapterId)
    self.StageId = data
    self.ChapterId = chapterId
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.StageId)
    local chapterInfo = XPrequelConfigs.GetPrequelChapterById(chapterId)
    self.TxtOrder.text = chapterInfo.ChapterName
    self.TxtTaskName.text = stageCfg.Name

    local rewardId = stageCfg.FirstRewardShow
    local rewards = XRewardManager.GetRewardList(rewardId)

    if not rewards then return end
    local rewardCount = #rewards
    for i=1, rewardCount do
        local xcommon = self.RewardList[i]
        if not xcommon then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon.gameObject)
            ui.transform:SetParent(self.PanelRewardContent, false)
            ui.gameObject:SetActive(true)
            xcommon = XUiGridCommon.New(self.RootUi, ui)
            table.insert(self.RewardList, i, xcommon )
        end
    end
    for i=1, #self.RewardList do
        self.RewardList[i].GameObject:SetActive(i <= rewardCount)
        if i <= rewardCount then
            self.RewardList[i]:Refresh(rewards[i])
        end
    end

    local rewardedStages = XDataCenter.PrequelManager.GetRewardedStages()
    if stageInfo.Passed then
        if rewardedStages and rewardedStages[self.StageId] then--领过了
            self:ChangeCollectStatus(false, true, false)
        else--没有领取
            self:ChangeCollectStatus(true, false, false)
        end
    else
        self:ChangeCollectStatus(false, false, true)
    end
end

function XUiGridPrequelCheckPointReward:ChangeCollectStatus(finish, alreadyFinish, unfinish)
    self.BtnFinish.gameObject:SetActive(finish)
    self.ImgAlreadyFinish.gameObject:SetActive(alreadyFinish)
    self.ImgUnFinish.gameObject:SetActive(unfinish)
end

return XUiGridPrequelCheckPointReward
