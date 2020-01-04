XUiPanelUnlockChallenge = XClass()

function XUiPanelUnlockChallenge:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self:InitAutoScript()
    self.RewardList = {}
    self.GridCommon.gameObject:SetActive(false)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelUnlockChallenge:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelUnlockChallenge:AutoInitUi()
    self.ImgMask = self.Transform:Find("ImgMask"):GetComponent("Image")
    self.PanelMain = self.Transform:Find("PanelMain")
    self.TxtUnlockTitle = self.Transform:Find("PanelMain/TxtUnlockTitle"):GetComponent("Text")
    self.PanelInfo = self.Transform:Find("PanelMain/PanelInfo")
    self.TxtTitle = self.Transform:Find("PanelMain/PanelInfo/TxtTitle"):GetComponent("Text")
    self.TxtCheckPoint = self.Transform:Find("PanelMain/PanelInfo/TxtCheckPoint"):GetComponent("Text")
    self.RImgCheckPoint = self.Transform:Find("PanelMain/PanelInfo/RImgCheckPoint"):GetComponent("RawImage")
    self.GridCommon = self.Transform:Find("PanelMain/RewardListList/Viewport/Content/GridCommon")
    self.RImgIcon = self.Transform:Find("PanelMain/RewardListList/Viewport/Content/GridCommon/RImgIcon"):GetComponent("RawImage")
    self.PanelChallengeTimes = self.Transform:Find("PanelMain/PanelChallengeTimes")
    self.TxtChallengeTimes = self.Transform:Find("PanelMain/PanelChallengeTimes/TxtChallengeTimes"):GetComponent("Text")
    self.PanelCost = self.Transform:Find("PanelMain/PanelCost")
    self.PanelMoney = self.Transform:Find("PanelMain/PanelCost/PanelMoney")
    self.RImgCost = self.Transform:Find("PanelMain/PanelCost/PanelMoney/RImgCost"):GetComponent("RawImage")
    self.TxtCostNum = self.Transform:Find("PanelMain/PanelCost/PanelMoney/TxtCostNum"):GetComponent("Text")
    self.BtnUnlock = self.Transform:Find("PanelMain/PanelCost/BtnUnlock"):GetComponent("Button")
    self.BtnMask = self.Transform:Find("BtnMask"):GetComponent("Button")
    self.PanelBgA = self.Transform:Find("PanelBg")
end

function XUiPanelUnlockChallenge:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelUnlockChallenge:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelUnlockChallenge:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelUnlockChallenge:AutoAddListener()
    self:RegisterClickEvent(self.BtnUnlock, self.OnBtnUnlockClick)
    self:RegisterClickEvent(self.BtnMask, self.OnBtnMaskClick)
end
-- auto

function XUiPanelUnlockChallenge:OnBtnMaskClick(eventData)
    XUiHelper.PlayAnimation(self.RootUi, "AniUnlockChallengeEnd", nil, function()
        self.GameObject:SetActive(false)
    end)
end

function XUiPanelUnlockChallenge:OnBtnUnlockClick(eventData)
    if not self.CurrentChallengeStage then return end

    XDataCenter.PrequelManager.UnlockPrequelChallengeRequest(self.CurrentChallengeStage.CoverId, self.CurrentChallengeStage.ChallengeIndex, self.CurrentChallengeStage.ChallengeStage, function()
        self.GameObject:SetActive(false)
        self.RootUi:RefreshChallenge()
    end)
end

function XUiPanelUnlockChallenge:RefreshWithAnim(challengeStage)
    XUiHelper.PlayAnimation(self.RootUi, "AniUnlockChallengeBegin", function()
        self:RefreshDatas(challengeStage)
    end, nil)
end

function XUiPanelUnlockChallenge:RefreshDatas(challengeStage)
    self.CurrentChallengeStage = challengeStage
    local stageId = challengeStage.ChallengeStage
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    self.TxtCheckPoint.text = stageCfg.Name
    self.RImgCheckPoint:SetRawImage(stageCfg.Icon)
    self.TxtChallengeTimes.text = stageCfg.MaxChallengeNums or 0

    self.RImgCost:SetRawImage(XDataCenter.ItemManager.GetItemIcon(self.CurrentChallengeStage.ChallengeConsumeItem))
    local ownNum = XDataCenter.ItemManager.GetCount(self.CurrentChallengeStage.ChallengeConsumeItem)
    local needNum = self.CurrentChallengeStage.ChallengeConsumeCount
    local currentNum = (ownNum >= needNum) and needNum or XPrequelConfigs.GetNotEnoughCost(needNum)
    self.TxtCostNum.text = currentNum
    self:UpdateRewards()
end 

function XUiPanelUnlockChallenge:UpdateRewards()
    local stageId = self.CurrentChallengeStage.ChallengeStage
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
    local rewardId = stageCfg.FirstRewardShow
    local rewards = XRewardManager.GetRewardList(rewardId)

    if not rewards then return end
    local rewardCount = #rewards
    for i=1, rewardCount do
        local xcommon = self.RewardList[i]
        if not xcommon then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridCommon.gameObject)
            ui.transform:SetParent(self.GridCommon.parent, false)
            ui.gameObject:SetActive(true)
            xcommon = XUiGridCommon.New(self.RootUi, ui)
            table.insert(self.RewardList, i, xcommon)
        end
    end

    for i=1, #self.RewardList do
        self.RewardList[i].GameObject:SetActive(i <= rewardCount)
        if i <= rewardCount then
            self.RewardList[i]:Refresh(rewards[i])
        end
    end
end

return XUiPanelUnlockChallenge
