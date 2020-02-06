local XUiHostelMissionComplete = XLuaUiManager.Register(XLuaUi, "UiHostelMissionComplete")

function XUiHostelMissionComplete:OnAwake()
    self:InitAutoScript()
end

function XUiHostelMissionComplete:OnStart(charId, rewards)

    self.CharId = charId
    self.Rewards = rewards
    self:Refresh()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiHostelMissionComplete:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHostelMissionComplete:AutoInitUi()
    self.BtnOk = self.Transform:Find("FullScreenBackground/BtnOk"):GetComponent("Button")
    self.ImgHeadIcon = self.Transform:Find("SafeAreaContentPane/ImgHeadIcon"):GetComponent("Image")
    self.TxtName = self.Transform:Find("SafeAreaContentPane/TxtName"):GetComponent("Text")
    self.TxtDesc = self.Transform:Find("SafeAreaContentPane/TxtDesc"):GetComponent("Text")
    self.ImgRewardIcon = self.Transform:Find("SafeAreaContentPane/ImgRewardIcon"):GetComponent("Image")
    self.TxtRewardCount = self.Transform:Find("SafeAreaContentPane/TxtRewardCount"):GetComponent("Text")
    self.TxtMsg = self.Transform:Find("SafeAreaContentPane/TxtMsg"):GetComponent("Text")
end

function XUiHostelMissionComplete:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiHostelMissionComplete:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiHostelMissionComplete:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHostelMissionComplete:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnOk, self.OnBtnOkClick)
end
-- auto

function XUiHostelMissionComplete:OnBtnOkClick(...)
    --CS.XUiManager.DialogManager:Pop()
    self:Close()
end

function XUiHostelMissionComplete:Refresh()
    local data = {}
    local collectData = function(key, value)
        data = value
    end
    XTool.LoopMap(self.Rewards.Items, collectData)

    local char = XDataCenter.CharacterManager.GetCharacter(self.CharId)
    self:SetUiSprite(self.ImgHeadIcon, XDataCenter.CharacterManager.GetCharBigHeadIcon(self.CharId))
    self.TxtName.text = XCharacterConfigs.GetCharacterName(self.CharId)

    self.TxtDesc.text = CS.XTextManager.GetText("HostelWorkReward")
    self:SetUiSprite(self.ImgRewardIcon, XDataCenter.ItemManager.GetItemIcon(data.Id))
    self.TxtRewardCount.text = data.Count
end