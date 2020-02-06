local XUiPanelJieduan = XClass()

XUiPanelJieduan.StatusType = {
    OFF = 1,
    ON = 2,
    REWARD = 3
}

function XUiPanelJieduan:Ctor(ui, isLast, sectionId, status)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.SectionId = sectionId
    self.IsLast = isLast
    self:InitAutoScript()
    self:SetStatus(status)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelJieduan:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelJieduan:AutoInitUi()
    self.ImgJieduanOn = self.Transform:Find("ImgJieduanOn"):GetComponent("Image")
    self.ImgJieduanOff = self.Transform:Find("ImgJieduanOff"):GetComponent("Image")
    self.BtnJieduanGift = self.Transform:Find("BtnJieduanGift"):GetComponent("Button")
end

function XUiPanelJieduan:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelJieduan:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelJieduan:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key],eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelJieduan:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnJieduanGift, self.OnBtnJieduanGiftClick)
end
-- auto

function XUiPanelJieduan:OnBtnJieduanGiftClick(...)
    if self.Status == XUiPanelJieduan.StatusType.REWARD then
        XDataCenter.FubenDailyManager.ReceiveDailyReward(function(reward)
            self.Status = XUiPanelJieduan.StatusType.ON
            self:RefreshUI()
            XUiManager.OpenUiObtain(reward, CS.XTextManager.GetText("Award"))
        end, self.SectionId)
    elseif self.Status == XUiPanelJieduan.StatusType.OFF then
        local cfg = XDataCenter.FubenDailyManager.GetDailySection(self.SectionId)
        local data = XRewardManager.GetRewardList(cfg.RewardId)
        XUiManager.OpenUiObtain(data, CS.XTextManager.GetText("ChallengeRewardIsTips"))
    else
        XUiManager.TipMsg(CS.XTextManager.GetText("ChallengeRewardIsGetted"))
    end
end

function XUiPanelJieduan:RefreshUI()
    self.BtnJieduanGift.gameObject:SetActive(self.IsLast)
    self.BtnJieduanGift.interactable = self.Status == XUiPanelJieduan.StatusType.REWARD or self.Status == XUiPanelJieduan.StatusType.OFF
    self.ImgJieduanOn.gameObject:SetActive(not self.IsLast and self.Status == XUiPanelJieduan.StatusType.ON)
    self.ImgJieduanOff.gameObject:SetActive(not self.IsLast and self.Status == XUiPanelJieduan.StatusType.OFF)
end

function XUiPanelJieduan:SetStatus(status)
    self.Status = status
    self:RefreshUI()
end

return XUiPanelJieduan