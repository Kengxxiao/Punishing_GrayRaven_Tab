--local XUiObtain = XUiManager.Register("UiObtain")
local XUiObtain = XLuaUiManager.Register(XLuaUi, "UiObtain")

-- auto
-- Automatic generation of code, forbid to edit
function XUiObtain:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiObtain:AutoInitUi()
    self.ScrView = self.Transform:Find("SafeAreaContentPane/ScrView"):GetComponent("Scrollbar")
    self.PanelContent = self.Transform:Find("SafeAreaContentPane/ScrView/Viewport/PanelContent")
    self.GridCommon = self.Transform:Find("SafeAreaContentPane/ScrView/Viewport/PanelContent/GridCommon")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/BtnBack"):GetComponent("Button")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/TxtTitle"):GetComponent("Text")
    self.BtnCancel = self.Transform:Find("SafeAreaContentPane/BtnCancel"):GetComponent("Button")
    self.BtnSure = self.Transform:Find("SafeAreaContentPane/BtnSure"):GetComponent("Button")
end

function XUiObtain:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiObtain:RegisterListener(uiNode, eventName, func)
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
            XLog.Error("XUiObtain:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiObtain:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnCancel, self.OnBtnCancelClick)
    self:RegisterClickEvent(self.BtnSure, self.OnBtnSureClick)
end
-- auto
--初始化音效
function XUiObtain:InitBtnSound()
    self.SpecialSoundMap[self:GetAutoKey(self.BtnBack, "onClick")] = XSoundManager.UiBasicsMusic.Return
    self.SpecialSoundMap[self:GetAutoKey(self.BtnCancel, "onClick")] = XSoundManager.UiBasicsMusic.Return
    self.SpecialSoundMap[self:GetAutoKey(self.BtnSure, "onClick")] = XSoundManager.UiBasicsMusic.Confirm
end

function XUiObtain:OnBtnCancelClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
    if self.CancelCallback then
        self.CancelCallback()
    end
    self:CheakItemOverLimit()
end

function XUiObtain:OnBtnSureClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
    if self.OkCallback then
        self.OkCallback()
    end
    self:CheakItemOverLimit()
end

function XUiObtain:OnBtnBackClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
    if self.CancelCallback then
        self.CancelCallback()
    end
    self:CheakItemOverLimit()
end

function XUiObtain:CheakItemOverLimit()
    --XUiManager.TipMsg(CS.XTextManager.GetText("ItemOverLimit"))
end

function XUiObtain:OnAwake()
    self:InitAutoScript()
    self:InitBtnSound()
end

function XUiObtain:OnStart(rewardGoodsList, title, closecallback, surecallback)

    self.Items = {}
    self.GridCommon.gameObject:SetActive(false)
    self.CancelBtnPosX = self.BtnCancel.transform.localPosition.x
    self.SureBtnPosX = self.BtnSure.transform.localPosition.x
    if title then
        self.TxtTitle.text = title
    end
    self.OkCallback = surecallback
    self.CancelCallback = closecallback
    self:Refresh(rewardGoodsList)
    self:Layout()

    self:PlayAnimation("AniObtain")
    --XUiHelper.PlayAnimation(self, "AniObtain")

end

function XUiObtain:OnEnable()
    CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.Common_UiObtain)
end

function XUiObtain:Layout()
    self.BtnSure.gameObject:SetActive(false)
    self.BtnCancel.gameObject:SetActive(false)
    local CancelBtnPosY = self.BtnCancel.transform.localPosition.y
    local SureBtnPosY = self.BtnSure.transform.localPosition.y

    if self.OkCallback and self.CancelCallback then
        self.BtnSure.gameObject:SetActive(true)
        self.BtnCancel.gameObject:SetActive(true)
        self.BtnCancel.transform.localPosition = CS.UnityEngine.Vector3(self.CancelBtnPosX, CancelBtnPosY, 0)
        self.BtnSure.transform.localPosition = CS.UnityEngine.Vector3(self.SureBtnPosX, SureBtnPosY, 0)
    elseif self.OkCallback then
        self.BtnSure.gameObject:SetActive(true)
        self.BtnSure.transform.localPosition = CS.UnityEngine.Vector3(0, SureBtnPosY, 0)
    elseif self.CancelCallback then
        self.BtnCancel.gameObject:SetActive(true)
        self.BtnCancel.transform.localPosition = CS.UnityEngine.Vector3(0, CancelBtnPosY, 0)
    end
end

function XUiObtain:Refresh(rewardGoodsList)
    rewardGoodsList = XRewardManager.MergeAndSortRewardGoodsList(rewardGoodsList)
    XUiHelper.CreateTemplates(self, self.Items, rewardGoodsList, XUiGridCommon.New, self.GridCommon, self.PanelContent, function(grid, data)
        grid:Refresh(data, nil, nil, false)
    end)
end