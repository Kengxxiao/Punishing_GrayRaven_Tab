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
    XTool.InitUiObject(self)
    self:InitScript()
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
function XUiPanelTrialType:InitScript()
    self:AutoAddListener()
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
