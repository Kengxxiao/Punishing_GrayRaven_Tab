XUiPanelRewardBox = XClass()

local RewardBoxState = {
    LOCK = 1,
    OPEN = 2,
    UNREWARD = 3
}

function XUiPanelRewardBox:Ctor(ui, parent, pos, canSelect, isMultiplayer)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self.Pos = pos
    self.CanSelect = canSelect
    self.IsMultiplayer = isMultiplayer
    self:InitAutoScript()
    self.Animation = self.GameObject:GetComponent("Animation")
    self.State = RewardBoxState.LOCK
    self.Grid = XUiGridCommon.New(self.Parent, self.GridCommon)

    self.Grid.BtnClick.gameObject:SetActive(false)

    self.FxUiFanpaiBlue = self.Transform:Find("PanelBox/PanelEffect/FanpaiBlue"):GetComponent("Animation")
    self.FxUiFanpaiGreen = self.Transform:Find("PanelBox/PanelEffect/FanpaiGreen"):GetComponent("Animation")
    self.FxUiFanpaiOrange = self.Transform:Find("PanelBox/PanelEffect/FanpaiOrange"):GetComponent("Animation")
    self.FxUiFanpaiPurple = self.Transform:Find("PanelBox/PanelEffect/FanpaiPurple"):GetComponent("Animation")
end

function XUiPanelRewardBox:OnEnable()
    if self.IsPlaying then
        self:PlayAnimationSelect()
    end
end

function XUiPanelRewardBox:OnDisable()
    self.IsPlaying = self.Animation.isPlaying
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelRewardBox:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiPanelRewardBox:AutoInitUi()
    self.PanelBox = self.Transform:Find("PanelBox")
    self.GridCommon = self.Transform:Find("PanelBox/GridCommon")
    self.ImgIcon = self.Transform:Find("PanelBox/GridCommon/ImgIcon")
    self.ImgQuality = self.Transform:Find("PanelBox/GridCommon/ImgQuality")
    self.BtnClick = self.Transform:Find("PanelBox/GridCommon/BtnClick")
    self.TxtNameB = self.Transform:Find("PanelBox/GridCommon/TxtName")
    self.Panel_Lock = self.Transform:Find("PanelBox/Panel_Lock")
    self.ImgDefault = self.Transform:Find("PanelBox/Panel_Lock/ImgDefault"):GetComponent("Image")
    self.BtnOpen = self.Transform:Find("PanelBox/Panel_Lock/BtnOpen"):GetComponent("Button")
    self.PanelRewards = self.Transform:Find("PanelBox/PanelRewards")
    self.TxtName = self.Transform:Find("PanelBox/PanelRewards/TxtName"):GetComponent("Text")
    self.PanelUnRewards = self.Transform:Find("PanelBox/PanelUnRewards")
    self.TxtNameA = self.Transform:Find("PanelBox/PanelUnRewards/TxtName")
    self.PanelEffect = self.Transform:Find("PanelBox/PanelEffect")
end

function XUiPanelRewardBox:GetAutoKey(uiNode, eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiPanelRewardBox:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiPanelRewardBox:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiPanelRewardBox:AutoAddListener()
    self.AutoCreateListeners = {}
    XUiHelper.RegisterClickEvent(self, self.BtnOpen, self.OnBtnOpenClick)
end
-- auto
function XUiPanelRewardBox:Refresh(data)
    if self.State ~= RewardBoxState.LOCK then
        return
    end

    if not data.GoodsList then
        return
    end
    self.Grid:Refresh(data.GoodsList[1], { Disable = true })
    self.State = RewardBoxState.OPEN
    self.Panel_Lock.gameObject:SetActive(false)
    self.Qulity = self.Grid:GetQuality()
    self.GridCommon.gameObject:SetActive(true)

    local name = ""
    if data.PlayerId == XPlayer.Id then
        name = XPlayer.Name
    elseif self.Parent.WinData.PlayerList then
        for _, v in pairs(self.Parent.WinData.PlayerList) do
            if v.Id == data.PlayerId then
                name = v.Name
            end
        end
    end

    self.TxtName.text = name

    if data.PlayerId ~= 0 then
        self.State = RewardBoxState.OPEN
        self:PlayAnimationSelect()
    else
        self.State = RewardBoxState.UNREWARD
        self:PlayAnimationAutoShow()
    end
end

function XUiPanelRewardBox:OnBtnOpenClick(...)
    if not self.CanSelect or self.Parent.Selected then
        return
    end

    if self.IsMultiplayer then
        XDataCenter.RoomManager.SelectReward(self.Pos)
    else
        XEventManager.DispatchEvent(XEventId.EVENT_ONLINEBOSS_DROPREWARD_NOTIFY, {
            PlayerId = XPlayer.Id,
            Pos = self.Pos
        })
    end
end

function XUiPanelRewardBox:SetupRewards(pos, goodsList)
    if self.Pos ~= pos then
        return
    end

end

function XUiPanelRewardBox:PlayAnimationSelect()
    local aniName = 'UiFanpai0'
    self.Animation:Play(aniName)
    local clip = self.Animation:GetClip(aniName)

    CS.XScheduleManager.Schedule(function(...)
        self:PlayQualityAni()
        CS.XScheduleManager.Schedule(function(...)
            self.PanelRewards.gameObject:SetActive(true)
            self.Animation:Play("UiFanpai1")
            self.Grid.BtnClick.gameObject:SetActive(true)
        end, 500, 1, clip.length * 1000)
    end, clip.length * 1000, 1, clip.length * 1000)
end


function XUiPanelRewardBox:PlayAnimationAutoShow()
    local aniName = 'UiFanpai0'
    self.Animation:Play(aniName)
    local clip = self.Animation:GetClip(aniName)

    CS.XScheduleManager.Schedule(function(...)
        self:PlayQualityAni()
        CS.XScheduleManager.Schedule(function(...)
            self.PanelUnRewards.gameObject:SetActive(true)
            self.Animation:Play("UiFanpai2")
            self.Grid.BtnClick.gameObject:SetActive(true)
        end, 500, 1, clip.length * 1000)
    end, clip.length * 1000, 1, clip.length * 1000)
end


function XUiPanelRewardBox:PlayQualityAni()
    if self.Qulity <= 2 then
        self.FxUiFanpaiGreen.gameObject:SetActive(true)
        self.FxUiFanpaiGreen:Play("FanpaiGreen")
    end

    if self.Qulity == 3 then
        self.FxUiFanpaiBlue.gameObject:SetActive(true)
        self.FxUiFanpaiBlue:Play("FanpaiBlue")
    end

    if self.Qulity == 4 then
        self.FxUiFanpaiPurple.gameObject:SetActive(true)
        self.FxUiFanpaiPurple:Play("FanpaiPurple")
    end

    if self.Qulity > 4 then
        self.FxUiFanpaiOrange.gameObject:SetActive(true)
        self.FxUiFanpaiOrange:Play("FanpaiOrange")
    end
end

return XUiPanelRewardBox