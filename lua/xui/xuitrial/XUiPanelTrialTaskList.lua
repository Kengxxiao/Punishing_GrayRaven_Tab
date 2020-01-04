local XUiPanelTrialTaskList = XClass()
local XUiPanelTrialGrid = require("XUi/XUiTrial/XUiPanelTrialGrid")

function XUiPanelTrialTaskList:Ctor(ui, uiRoot, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    self.Parent = parent
    self.animationunlockcb = function()self:HandleRewardTypeTips()end
    self:InitAutoScript()
    self:InitUiAfterAuto()
end

function XUiPanelTrialTaskList:InitUiAfterAuto()
    self.DynamicTable = XDynamicTableNormal.New(self.SViewTaskList.gameObject)
    self.DynamicTable:SetProxy(XUiPanelTrialGrid)
    self.DynamicTable:SetDelegate(self)
end

-- trialtype,1:前段 other:后段
function XUiPanelTrialTaskList:UpdateTaskList(trialtype)
    if self.PreTrialType == trialtype then
        for i=1,self.CurListLen do
            local grid = self.DynamicTable:GetGridByIndex(i)
            if grid then
                local data = self.TaskListData[i]
                grid:OnRefresh(data)
            end
        end
        return
    end

    if trialtype == XDataCenter.TrialManager.TrialTypeCfg.TrialFor then
        self.TaskListData = XTrialConfigs.GetForTotalData()
    else
        self.TaskListData = XTrialConfigs.GetBackEndTotalData()
    end
    if not self.TaskListData then
        return
    end
    self.PreTrialType = trialtype
    self.CurListLen = #self.TaskListData
    self.DynamicTable:SetDataSource(self.TaskListData)
    self.DynamicTable:ReloadDataASync(1)
end

-- 处理前段刚打完
function XUiPanelTrialTaskList:ForTrialFinish()
    if XDataCenter.TrialManager.TrialRewardGetedFinish() and not XDataCenter.TrialManager.TypeRewardByTrialtype(XDataCenter.TrialManager.TrialTypeCfg.TrialFor) then
        self.UiRoot:HandleForTrialFinish()
    end
end 

-- 处理后段段刚打完
function XUiPanelTrialTaskList:BackEndTrialFinish()
    if not XDataCenter.TrialManager.BackEndTrialFinishJust() or not XDataCenter.TrialManager.TrialRewardGetedBackEndFinish() then
        return
    end
    self.UiRoot:HandleBackFinishTips()
end 

-- [监听动态列表事件]
function XUiPanelTrialTaskList:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot, self.Parent)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.TaskListData[index]
        grid:OnRefresh(data,self.CurOpenFxState)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        if not self.CurOpenFxState then
            return
        end
        if self.CurTipsShow then
            return 
        end
        local data = self.TaskListData[index]
        local trialid = data.Id
        if XDataCenter.TrialManager.TrialLevelFinished(trialid) then
            if not XDataCenter.TrialManager.TrialRewardGeted(trialid) then
                grid:CloseFx()
                self.UiRoot:OpenRewardViewNow(true)
                XDataCenter.TrialManager.OnTrialPassRewardRequest(
                    trialid,
                    function(rewardGoodsList)
                        self.CurTipsShow = true
                        XUiManager.OpenUiObtain(rewardGoodsList,nil,function ()
                            local msg = ""
                            if data.Type == XDataCenter.TrialManager.TrialTypeCfg.TrialBackEnd then
                                msg = CS.XTextManager.GetText("TrialLevelFinish",XDataCenter.TrialManager:TrialRewardGetedBackEndCount(), XTrialConfigs.GetBackEndTotalLength())
                            else
                                msg = CS.XTextManager.GetText("TrialLevelFinish",XDataCenter.TrialManager:TrialRewardGetedForCount(), XTrialConfigs.GetForTotalLength())
                            end
                            grid:SetTrialItemState() 
                            self.UiRoot:OpenRewardViewNow(false)
                            XUiManager.TipMsg(msg,XUiManager.UiTipType.Success,function()
                                XLuaUiManager.Close("UiObtain")
                                self.CurTrialType = data.Type
                                grid:AfterRewardGetedPro(self.animationunlockcb)   
                            end)                          
                        end                    
                        )
                    end
                )
            else
                -- -- 提示玩家已經打完
                -- local msg = CS.XTextManager.GetText("TrialFinish")
                -- XUiManager.TipMsg(msg)
                self.UiRoot:OpenSelectView(data)
            end
        elseif not XDataCenter.TrialManager.TrialLevelLock(trialid) then
            -- 提示玩家没有解锁
            local msg = CS.XTextManager.GetText("TrialUnLock")
            XUiManager.TipMsg(msg)
        else           
            self.UiRoot:OpenSelectView(data)
        end
    end
end
-- 动画播结束后再处理大奖的弹出tips
function XUiPanelTrialTaskList:HandleRewardTypeTips()
    self.CurTipsShow = false
    if not self.CurTrialType then
        return
    end

    if self.CurTrialType == XDataCenter.TrialManager.TrialTypeCfg.TrialFor then
        self:ForTrialFinish()
     else
        self:BackEndTrialFinish()
     end
end

-- 重新设置list的item的状态.
function XUiPanelTrialTaskList:SetListItemFx()
    for i=1,self.CurListLen do
        local grid = self.DynamicTable:GetGridByIndex(i)
        if grid then
            grid:SetTrialItemRewardFx()
        end
    end
end

-- 关闭list的item的特效，防止特效透ui。
function XUiPanelTrialTaskList:ClostListItemFx()
    for i=1,self.CurListLen do
        local grid = self.DynamicTable:GetGridByIndex(i)
        if grid then
            grid:CloseFx()
        end
    end
end

function XUiPanelTrialTaskList:OpenFxFinish(state)
    self.CurOpenFxState = state
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelTrialTaskList:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelTrialTaskList:AutoInitUi()
    self.SViewTaskList = self.Transform:Find("SViewTaskList"):GetComponent("ScrollRect")
    self.PanelTrialGrid = self.Transform:Find("SViewTaskList/Viewport/PanelTrialGrid")
end

function XUiPanelTrialTaskList:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelTrialTaskList:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelTrialTaskList:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelTrialTaskList:AutoAddListener()
end
-- auto

function XUiPanelTrialTaskList:OnSViewTaskListClick(eventData)
end

return XUiPanelTrialTaskList
