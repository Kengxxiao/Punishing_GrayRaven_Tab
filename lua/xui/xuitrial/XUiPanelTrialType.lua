local XUiPanelTrialType = XClass()
local XUiGridTrialTypeItem = require("XUi/XUiTrial/XUiGridTrialTypeItem")
local TrialTypeCfg = {
    TrialFor = 1,
    TrialBackEnd = 2
}

function XUiPanelTrialType:Ctor(ui, uiRoot, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    self.Parent = parent
    self:InitAutoScript()
    self:InitUiAfterAuto()
end

function XUiPanelTrialType:InitUiAfterAuto()
    self.DynamicTable = XDynamicTableNormal.New(self.SViewTrialTypeList.gameObject)
    self.DynamicTable:SetProxy(XUiGridTrialTypeItem)
    self.DynamicTable:SetDelegate(self)
    self.SViewTrialTypeList.gameObject:SetActive(true)
end

function XUiPanelTrialType:UpdateTrialTypeList()
    self.InitEd = true
    self.TrialtypeListData = XTrialConfigs.GetTotalTrialTypeCfg()
    self.DynamicTable:SetDataSource(self.TrialtypeListData)
    self.DynamicTable:ReloadDataSync()
end

-- [监听动态列表事件]
function XUiPanelTrialType:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.TrialtypeListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self:SetTrialTypeNameByType(index)
        self.CurScrollState = false
        self.SViewTrialTypeList.gameObject:SetActive(self.CurScrollState)
        self.ImgArrowUp.gameObject:SetActive(self.CurScrollState)
        self.ImgArrowDown.gameObject:SetActive(not self.CurScrollState)
        self.Parent:SeleTrialType(index)
        self.Parent:SetTrialBg(index)
        self.Parent:SetTypeTrialPro()
        XUiHelper.PlayAnimation(self.UiRoot, "AniTrialOpen")
    end
end

-- 通过类型设置名字
function XUiPanelTrialType:SetTrialTypeNameByType(trialtype)
    local cfg = XTrialConfigs.GetTrialTypeCfg(trialtype)
    self.TxtTitle.text = cfg.Name

    if trialtype == TrialTypeCfg.TrialBackEnd then
        self.ImgAfter.gameObject:SetActive(true)
        self.ImgFront.gameObject:SetActive(false)
    else
        self.ImgAfter.gameObject:SetActive(false)
        self.ImgFront.gameObject:SetActive(true)
    end
end

-- 初始化状态
function XUiPanelTrialType:InitScrollState()
    self.CurScrollState = false
    self.SViewTrialTypeList.gameObject:SetActive(self.CurScrollState)
    if XDataCenter.TrialManager.FinishTrialType() == TrialTypeCfg.TrialBackEnd and XDataCenter.TrialManager.TrialRewardGetedFinish() then
        self.ImgArrowUp.gameObject:SetActive(self.CurScrollState)
        self.ImgArrowDown.gameObject:SetActive(not self.CurScrollState)
    else
        self.ImgArrowUp.gameObject:SetActive(false)
        self.ImgArrowDown.gameObject:SetActive(false)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelTrialType:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelTrialType:AutoInitUi()
    self.TxtTitle = self.Transform:Find("TxtTitle"):GetComponent("Text")
    self.ImgArrowUp = self.Transform:Find("ImgArrowUp"):GetComponent("Image")
    self.ImgArrowDown = self.Transform:Find("ImgArrowDown"):GetComponent("Image")
    self.BtnClick = self.Transform:Find("BtnClick"):GetComponent("Button")
    self.ImgAfter = self.Transform:Find("BtnClick/ImgAfter"):GetComponent("Image")
    self.ImgFront = self.Transform:Find("BtnClick/ImgFront"):GetComponent("Image")
    self.SViewTrialTypeList = self.Transform:Find("SViewTrialTypeList"):GetComponent("ScrollRect")
    self.GridTrialTypeItem = self.Transform:Find("SViewTrialTypeList/Viewport/GridTrialTypeItem")
    self.TxtNameA = self.Transform:Find("SViewTrialTypeList/Viewport/GridTrialTypeItem/TxtName"):GetComponent("Text")
end

function XUiPanelTrialType:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelTrialType:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelTrialType:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelTrialType:AutoAddListener()
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
end
-- auto

function XUiPanelTrialType:OnBtnClickClick(eventData)
    if XDataCenter.TrialManager.FinishTrialType() == TrialTypeCfg.TrialBackEnd and XDataCenter.TrialManager.TrialRewardGetedFinish() then
        self.CurScrollState = not self.CurScrollState
        self.SViewTrialTypeList.gameObject:SetActive(self.CurScrollState)
        self.ImgArrowUp.gameObject:SetActive(self.CurScrollState)
        self.ImgArrowDown.gameObject:SetActive(not self.CurScrollState)
        if self.CurScrollState and not self.InitEd then
            self:UpdateTrialTypeList()
        end
    else
        local msg = CS.XTextManager.GetText("TrialNoFinishTips")
        XUiManager.TipMsg(msg,XUiManager.UiTipType.Success)
    end
end

return XUiPanelTrialType
