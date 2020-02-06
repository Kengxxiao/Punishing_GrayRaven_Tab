local XUiFubenChallengeMapEmex = XLuaUiManager.Register(XLuaUi, "UiFubenChallengeMapEmex")

function XUiFubenChallengeMapEmex:RefreshReward()
    self.Panelreceived.gameObject:SetActive(false)
    self.PanelEffect.gameObject:SetActive(false)
    local curFightNum = 0
    local isGetChallengeReward = false
    local sectionData = XDataCenter.FubenDailyManager.GetDailySectionData(self.SectionCfg.Id)
    if sectionData then
        curFightNum = sectionData.PassTimesToday
        isGetChallengeReward = sectionData.ReceiveReward
    end

    self.curFightNum = curFightNum
    self.BtnReward.interactable = true
    self.PanelBottom.gameObject:SetActive(true)
    self:RefreshText(isGetChallengeReward)
end

function XUiFubenChallengeMapEmex:RefreshText(isGetChallengeReward)
    if not self.SectionCfg then
        return
    end

    local rewardNeedFinishCount = self.SectionCfg.RewardNeedFinishCount or 0
    if self.curFightNum > rewardNeedFinishCount then
        self.curFightNum = rewardNeedFinishCount
    end

    self.TxtProgress.text = (rewardNeedFinishCount - self.curFightNum) .. "/" .. rewardNeedFinishCount
    self.TxtBt.text = self.SectionCfg.Name or ""
    self.ImgSlide.fillAmount = self.curFightNum / rewardNeedFinishCount
    self.isGetChallengeReward = isGetChallengeReward
    if isGetChallengeReward then
        self.Panelreceived.gameObject:SetActive(true)
        self.PanelEffect.gameObject:SetActive(false)
    else
        if self.curFightNum >= rewardNeedFinishCount then
            self.PanelEffect.gameObject:SetActive(true)
        end
    end

end

function XUiFubenChallengeMapEmex:OnBtnRewardClick()
    if self.isGetChallengeReward then
        XUiManager.TipText("ChallengeRewardIsGetted")
    else
        if self.curFightNum >= self.SectionCfg.RewardNeedFinishCount then
            XDataCenter.FubenDailyManager.ReceiveDailyReward(function(reward)
                self.isGetChallengeReward = true
                XUiManager.OpenUiObtain(reward, CS.XTextManager.GetText("Award"))
                self:RefreshText(self.isGetChallengeReward)
            end, self.SectionCfg.Id)
        else
            local data = XRewardManager.GetRewardList(self.SectionCfg.RewardId)
            XUiManager.OpenUiTipReward(data)
        end
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenChallengeMapEmex:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiFubenChallengeMapEmex:AutoInitUi()
    self.BtnActDesc = self.Transform:Find("SafeAreaContentPane/LayerWrap/BtnActDesc"):GetComponent("Button")
    self.TxtPipei = self.Transform:Find("SafeAreaContentPane/LayerWrap/BtnActDesc/TxtPipei"):GetComponent("Text")
    self.PanelEvent = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelEvent")
    self.TxtEventDesc = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelEvent/head/TxtEventDesc"):GetComponent("Text")
    self.PanelTip = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTip")
    self.BtnCancelMatch = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTip/BtnCancelMatch"):GetComponent("Button")
    self.TxtPipeiA = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTip/TxtPipei"):GetComponent("Text")
    self.PanelBottom = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom")
    self.TxtProgress = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom/GameObject/TxtProgress"):GetComponent("Text")
    self.ImgSlide = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom/GameObject/ImgSlide"):GetComponent("Image")
    self.BtnReward = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom/GameObject/BtnReward"):GetComponent("Button")
    self.Panelreceived = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom/GameObject/Panelreceived")
    self.PanelEffect = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelBottom/GameObject/PanelEffect")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelAsset")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/LayerWrap/Top/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/LayerWrap/Top/BtnMainUi"):GetComponent("Button")
    self.PanelTitle = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTitle")
    self.TxtShuaxin = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTitle/TxtShuaxin"):GetComponent("Text")
    self.TxtCurTime = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTitle/TxtCurTime"):GetComponent("Text")
    self.TxtBt = self.Transform:Find("SafeAreaContentPane/LayerWrap/PanelTitle/TxtBt"):GetComponent("Text")
    self.ImgBg = self.Transform:Find("FullScreenBackground/ImgBg"):GetComponent("Image")
    self.PanelContent = self.Transform:Find("FullScreenBackground/PanelContent")
end

function XUiFubenChallengeMapEmex:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiFubenChallengeMapEmex:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiFubenChallengeMapEmex:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiFubenChallengeMapEmex:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnActDesc, self.OnBtnActDescClick)
    self:RegisterClickEvent(self.BtnCancelMatch, self.OnBtnCancelMatchClick)
    self:RegisterClickEvent(self.BtnReward, self.OnBtnRewardClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end
-- auto