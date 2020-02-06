
local XUiFubenCoinSkill = XLuaUiManager.Register(XLuaUi, "UiFubenCoinSkill")

local LOCAL_COUNTDOWN_NAME = "UiFubenCoinSkillCountDown"


function XUiFubenCoinSkill:OnAwake()
    self:InitAutoScript()
end

function XUiFubenCoinSkill:OnStart()
    self.DetailParams = {}
    self.FubenPanelTabList = {}
    self.CsUiList = {}
    self.BtnsGameObject = self.PanelBtns.gameObject
    self.Animation = self.Transform:GetComponent("Animation")
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self:InitTextByCfg()
    self:StartCountDown()
    self:InitXUiPanelFubenTab()
    self:CheckPlayerLevelUp()
    --XUiHelper.PlayAnimation(self, "FubenCoinSkillBegin", nil, function () self.BeginAnim = true end)
end

function XUiFubenCoinSkill:OnEnable()
    self:CheckPlayerLevelUp()
    self:UpdateData()
end

function XUiFubenCoinSkill:OnDestroy()
    XDataCenter.FubenResourceManager.UpdateRewardFromTemp()
    for k, v in pairs(self.CsUiList) do
        v:Close()
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenCoinSkill:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiFubenCoinSkill:AutoInitUi()
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/Top/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/Top/BtnMainUi"):GetComponent("Button")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.PanelLevelUpTip = self.Transform:Find("SafeAreaContentPane/PanelLevelUpTip")
    self.BtnClosePanelLevelUpTip = self.Transform:Find("SafeAreaContentPane/PanelLevelUpTip/BtnClosePanelLevelUpTip"):GetComponent("Button")
    self.TxtChallengeLevel = self.Transform:Find("SafeAreaContentPane/PanelLevelUpTip/TxtChallengeLevel"):GetComponent("Text")
    self.Panel = self.Transform:Find("SafeAreaContentPane/Panel")
    self.PanelResetTime = self.Transform:Find("SafeAreaContentPane/Panel/PanelResetTime")
    self.TxtResetTime = self.Transform:Find("SafeAreaContentPane/Panel/PanelResetTime/TxtResetTime"):GetComponent("Text")
    self.PanelTitle = self.Transform:Find("SafeAreaContentPane/Panel/PanelTitle")
    self.TxtName = self.Transform:Find("SafeAreaContentPane/Panel/PanelTitle/TxtName"):GetComponent("Text")
    self.TxtDetail = self.Transform:Find("SafeAreaContentPane/Panel/PanelTitle/TxtDetail"):GetComponent("Text")
    self.PanelBtns = self.Transform:Find("SafeAreaContentPane/Panel/PanelBtns")
    self.PanelTab1 = self.Transform:Find("SafeAreaContentPane/Panel/PanelBtns/PanelTab1")
    self.PanelTab2 = self.Transform:Find("SafeAreaContentPane/Panel/PanelBtns/PanelTab2")
    self.PanelFubenTab = self.Transform:Find("SafeAreaContentPane/Panel/TargetFlag/PanelFubenTab")
    self.PanelChallengeLevel = self.Transform:Find("SafeAreaContentPane/Panel/PanelChallengeLevel")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/Panel/PanelChallengeLevel/TxtTitle"):GetComponent("Text")
    self.TxtLevelNow = self.Transform:Find("SafeAreaContentPane/Panel/PanelChallengeLevel/TxtLevelNow"):GetComponent("Text")
    self.TxtLevelBefore = self.Transform:Find("SafeAreaContentPane/Panel/PanelChallengeLevel/TxtLevelBefore"):GetComponent("Text")
    self.BtnActDesc = self.Transform:Find("SafeAreaContentPane/Panel/BtnActDesc"):GetComponent("Button")
end

function XUiFubenCoinSkill:GetAutoKey(uiNode,eventName)
    if not uiNode then return end
    return eventName .. uiNode:GetHashCode()
end

function XUiFubenCoinSkill:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then return end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiFubenCoinSkill:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiFubenCoinSkill:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnClosePanelLevelUpTip, self.OnBtnClosePanelLevelUpTipClick)
    self:RegisterClickEvent(self.BtnActDesc, self.OnBtnActDescClick)
end
-- auto
--初始化ui文本
function XUiFubenCoinSkill:InitTextByCfg()
    local chapterTemplate = XDataCenter.FubenResourceManager.GetResourceChapters()
    for _, v in pairs(chapterTemplate) do
        self.TxtName.text = v.Name
        self.TxtDetail.text = v.SimpleDesc
    end
end

function XUiFubenCoinSkill:StartCountDown()
    local remainingTime = XDataCenter.FubenResourceManager.GetRemainingTime()
    XCountDown.CreateTimer(LOCAL_COUNTDOWN_NAME, remainingTime)
    XCountDown.BindTimer(self, LOCAL_COUNTDOWN_NAME, function(v)
        if self.IsHide then
            return 
        end
        if v > 0 then
            self.PanelResetTime.gameObject:SetActive(true)
            self.TxtResetTime.text = XUiHelper.GetTime(v, XUiHelper.TimeFormatType.CHALLENGE)
        else
            self.TxtResetTime.text = ""
            self.PanelResetTime.gameObject:SetActive(false)
        end
    end)
end

--初始化副本按钮
function XUiFubenCoinSkill:InitXUiPanelFubenTab()
    local sectionDatas = XDataCenter.FubenResourceManager.GetSectionDatas()
    local i = 1
    for typeId, data in pairs(sectionDatas) do
        local btn = self.Transform:Find("SafeAreaContentPane/Panel/PanelBtns/PanelTab" .. i)
        if btn then
            local ui = XUiPanelFubenTab.New(self, btn)
            ui:SetData(data)
            self.FubenPanelTabList[typeId] = ui
        end
        i = i + 1
    end
    self.FocusPanelTab = XUiPanelFubenTab.New(self, self.PanelFubenTab)
end

--更新副本按钮表现
function XUiFubenCoinSkill:UpdateData()
    local sectionDatas = XDataCenter.FubenResourceManager.GetSectionDatas()
    for typeId, data in pairs(sectionDatas) do
        self.FubenPanelTabList[typeId]:UpdateData(data)
    end
end

--挑战等级提升提示
function XUiFubenCoinSkill:CheckPlayerLevelUp()
    local nowLevel, lastLevel = XDataCenter.FubenResourceManager.GetPlayerLevelInfo()
    self.TxtLevelNow.text = nowLevel
    if not lastLevel then
        return
    end
    -- XUiHelper.PlayAnimation(self, "CoinSkillLevelUp", function()
    --     self.TxtChallengeLevel.text = nowLevel
    --     self.PanelLevelUpTip.gameObject:SetActive(true)
    -- end, nil)
end

function XUiFubenCoinSkill:OnBtnBackClick(...)
    self:Close()
end

function XUiFubenCoinSkill:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiFubenCoinSkill:OnBtnActDescClick(...)
    local resourceChapterCfg = XDataCenter.FubenResourceManager.GetResourceChapters()
    for _, v in pairs(resourceChapterCfg) do
        XUiManager.UiFubenDialogTip("", v.DetailDesc or "")
        return
    end
end

function XUiFubenCoinSkill:OnBtnClosePanelLevelUpTipClick(...)
    -- XUiHelper.PlayAnimation(self, "CoinSkillLevelUpEnd", nil, function()
    --     if XTool.UObjIsNil(self.PanelLevelUpTip) then
    --         return
    --     end
        
    --     self.PanelLevelUpTip.gameObject:SetActive(false)
    -- end)
end

--副本按钮入口
function XUiFubenCoinSkill:OnFubenSelected(typeId)
    if not self.BeginAnim then
        return 
    end
    self:SetActive(false)

    local fightCb = function(stage)
        XDataCenter.FubenManager.OpenRoomSingle(stage)
        XDataCenter.FubenResourceManager.UpdateRewardFromTemp()
        self:SetActive(true)
    end
    local closeCb = function()
        self:SetActive(true)
    end

    self.DetailParams.typeId = typeId
    self.DetailParams.fightCb = fightCb
    self.DetailParams.closeCb = closeCb

    self:OpenOneChildUi("UiFubenResourceDetail", self.DetailParams)
end

function XUiFubenCoinSkill:SetActive(flag)
    self.PanelResetTime.gameObject:SetActive(flag)
    self.PanelTitle.gameObject:SetActive(flag)
    self.PanelBtns.gameObject:SetActive(flag)
    self.PanelAsset.gameObject:SetActive(flag)
    self.BtnActDesc.gameObject:SetActive(flag)
    self.IsHide = not flag
end

return XUiFubenCoinSkill