local XUiTrial = XLuaUiManager.Register(XLuaUi, "UiTrial")
local XUiPanelTrialMain = require("XUi/XUiTrial/XUiPanelTrialMain")
local XUiPanelTrialSelect = require("XUi/XUiTrial/XUiPanelTrialSelect")
local XUiPanelTrialTips = require("XUi/XUiTrial/XUiPanelTrialTips")
local XUiPanelTrialGet = require("XUi/XUiTrial/XUiPanelTrialGet")

local ViewTypeCfg = {
    TrialMain = 1,
    TrialSelect = 2
}

local ViewTipsTypeCfg = {
    TrialFor = 1,
    TrialBackEnd = 2,
    TrialTypeReward = 3
}

function XUiTrial:OnAwake()
    XTool.InitUiObject(self)
    self:AddListener()
    self:InitUiAfterAuto()
end

function XUiTrial:InitUiAfterAuto()
    self.AssetPanel = XUiPanelAsset.New(
        self,
        self.PanelAsset,
        XDataCenter.ItemManager.ItemId.FreeGem,
        XDataCenter.ItemManager.ItemId.ActionPoint,
        XDataCenter.ItemManager.ItemId.Coin
    )
    self.TrialMain = XUiPanelTrialMain.New(self.PanelTrialMain, self)
    self.TrialSelect = XUiPanelTrialSelect.New(self.PanelTrialSelect, self)
    self.TrialTips = XUiPanelTrialTips.New(self.PanelTrialTips, self)
    self.TrialGet = XUiPanelTrialGet.New(self.PanelTrialGet, self)
end

function XUiTrial:OnStart(...)

end

-- 刚好通关前段
function XUiTrial:OnSettleTrial()
    self.TrialTips.GameObject:SetActive(true)
    self:HandleForFinishTips()
end

-- 处理前段终结
function XUiTrial:HandleForFinishTips()
    self.TrialTips:SetTrialType(ViewTipsTypeCfg.TrialFor)
    self.GameObject:PlayLegacyAnimation("AniTrialTips", function()
        self:HandleBackStartTips()
    end)
end

-- 处理后段开启
function XUiTrial:HandleBackStartTips()
    self.GameObject:PlayLegacyAnimation("AniTrialTips2", function()
        if self.TrialTips and not XTool.UObjIsNil(self.TrialTips.GameObject) then
            self.TrialTips.GameObject:SetActive(false)
        end
    end)
    local trialtype = XDataCenter.TrialManager.TrialTypeCfg.TrialBackEnd
    self.TrialMain:SetForTrialFinsih(trialtype)
    self.TrialMain:SetTypeTrialPro()
    self.TrialTips:SetTrialType(ViewTipsTypeCfg.TrialBackEnd)
end

-- 处理后段终结
function XUiTrial:HandleBackFinishTips()
    self:PlayAnimation("AniTrialGet")
    --XUiHelper.PlayAnimation(self, "AniTrialGet")
    local cfg = XTrialConfigs.GetTrialTypeCfg(XDataCenter.TrialManager.TrialTypeCfg.TrialBackEnd)
    if cfg then
        self.TrialGet:SetBg(cfg.BigIcon)
        local rewardIdcfg = XRewardManager.GetRewardList(cfg.RewardId)[1]
        if rewardIdcfg then
            local name = XGoodsCommonManager.GetGoodsName(rewardIdcfg.TemplateId)
            self.TrialGet:SetName(name)
        end
    end
    self.TrialGet.GameObject:SetActive(true)
    self.TrialGet:SetAnimationFx()
    local btncb = function()
        self.TrialGet.GameObject:SetActive(false)
        XDataCenter.TrialManager.OnTrialTypeRewardRequest(
        XDataCenter.TrialManager.TrialTypeCfg.TrialBackEnd,
        function(rewardGoodsList)
            XUiManager.OpenUiObtain(rewardGoodsList, nil, function()
                local trialtype = XDataCenter.TrialManager.TrialTypeCfg.TrialTypeReward
                self.TrialTips.GameObject:SetActive(true)
                self.TrialTips:SetTrialType(trialtype)
                self.GameObject:PlayLegacyAnimation("AniTrialTips3", function()
                    XLuaUiManager.Close("UiTrial")
                    XLuaUiManager.Open("UiMain")
                end)
            end)
        end
        )
    end
    self.TrialGet:SetBtnCB(btncb)
end

-- 处理前段完成的Tips弹出
function XUiTrial:HandleForTrialFinish()
    self:PlayAnimation("AniTrialGet")
    local cfg = XTrialConfigs.GetTrialTypeCfg(XDataCenter.TrialManager.TrialTypeCfg.TrialFor)
    if cfg then
        self.TrialGet:SetBg(cfg.BigIcon)
        local rewardIdcfg = XRewardManager.GetRewardList(cfg.RewardId)[1]
        if rewardIdcfg then
            local name = XGoodsCommonManager.GetGoodsName(rewardIdcfg.TemplateId)
            self.TrialGet:SetName(name)
        end
    end
    self.TrialGet.GameObject:SetActive(true)
    self.TrialGet:SetAnimationFx()

    local btncb = function()
        self.TrialGet.GameObject:SetActive(false)
        XDataCenter.TrialManager.OnTrialTypeRewardRequest(
        XDataCenter.TrialManager.TrialTypeCfg.TrialFor,
        function(rewardGoodsList)
            XUiManager.OpenUiObtain(rewardGoodsList, nil, function()
                self:OnSettleTrial()
            end)
        end
        )
    end
    self.TrialGet:SetBtnCB(btncb)
end

-- 关闭list的item的特效，防止特效透ui。
function XUiTrial:SetListItemFx()
    self.TrialMain:SetListItemFx()
end

-- 重新设置list的item的状态，让特效出现。
function XUiTrial:ClostMainListItemFx()
    self.TrialMain:ClostListItemFx()
end

function XUiTrial:OnEnable()
    self:OpenMainView()
end

function XUiTrial:OnDisable()
    self.TrialMain:CloseView()
end

function XUiTrial:OnDestroy()
end

function XUiTrial:OnGetEvents()
    return { XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL, XEventId.EVENT_FUBEN_ENTERFIGHT }
end

-- 打开主界面
function XUiTrial:OpenMainView()
    if self.CurTrialView == ViewTypeCfg.TrialSelect then
        return
    end
    self.CurTrialView = ViewTypeCfg.TrialMain
    self.TrialMain.GameObject:SetActive(true)
    self.TrialMain:OpenView()
end

-- 奖励界面还在打开中不？
function XUiTrial:OpenRewardViewNow(flage)
    self.RewardUIOpen = flage
end


-- 关闭主界面
function XUiTrial:CloseMainView()
    self.TrialMain:CloseView()
    self.TrialMain.GameObject:SetActive(false)
end

-- 关闭二级界面
function XUiTrial:CloseSelectView()
    self.CurTrialView = ViewTypeCfg.TrialMain
    self.TrialSelect:CloseView()
end

-- 打开二级界面
function XUiTrial:OpenSelectView(data)
    self.CurSeleData = data
    self.CurTrialView = ViewTypeCfg.TrialSelect
    self.TrialSelect:OpenView(data)
end

function XUiTrial:OnNotify(evt, ...)
    self.TrialSelect:OnNotify(evt, ...)
end

-- 设置背景
function XUiTrial:SetTrialBg(trialtype)
    if trialtype == XDataCenter.TrialManager.TrialTypeCfg.TrialFor then
        self.RImgForePartBg.gameObject:SetActive(true)
        self.RImgBackEndBg.gameObject:SetActive(false)
    else
        self.RImgForePartBg.gameObject:SetActive(false)
        self.RImgBackEndBg.gameObject:SetActive(true)
    end
    self.PreTrialBg = trialtype
end

-- 设置背景(二级界面关闭后设置回原来界面)
function XUiTrial:ReturnPreTrialBg()
    if self.PreTrialBg then
        self:SetTrialBg(self.PreTrialBg)
    end
end

function XUiTrial:AddListener()
    self.BtnMainUI.CallBack = function()self:OnBtnMainUIClick()end
    self.BtnReturn.CallBack = function()self:OnBtnReturnClick()end
    self.BtnHelp.CallBack = function()self:OnBtnHelpClick()end
end
-- auto
function XUiTrial:OnBtnMainUIClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiTrial:OnBtnReturnClick(eventData)
    if self.CurTrialView == ViewTypeCfg.TrialMain then
        XLuaUiManager.Close("UiTrial")
    else
        self.Dark.gameObject:SetActiveEx(true)
        self:PlayAnimation("AnimStartEnable")
        self:CloseSelectView()
    end
end

function XUiTrial:OnBtnHelpClick(eventData)
    XUiManager.ShowHelpTip("Trial")
end
