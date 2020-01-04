XUiFubenDailyStage = XClass()

local START_NUM = 1
local LockType = {
    Level = 1,
    Stage = 2,
    Passed = 3,
}

function XUiFubenDailyStage:Ctor(base,ui, stageId, exStageId, stageData, num)
    self.Base = base
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.StageData = stageData
    self.Id = stageId
    self.ExId = exStageId
    self.num = num
    self.RequireLevel = 0
    self.SelectCallBack = {}
    self:InitUiObjects()
    
end

function XUiFubenDailyStage:SetCallBack(cb)
    self.SelectCallBack = cb
end

function XUiFubenDailyStage:InitUiObjects()
    XTool.InitUiObject(self)
    self.BtnEnter.CallBack = function(...)
        self:OnBtnEnter(...)
    end
    self.TxtLevelID.text = self.StageData.Code .. "-" .. self.num
    self:ReSetStageCfg()
end

function XUiFubenDailyStage:ReSetStageCfg()
    local stageCfg = {}
    stageCfg = XDataCenter.FubenManager.GetStageCfg(self.Id)
    self.RImgNodeIco:SetRawImage(stageCfg.Icon)
    self.RequireLevel = stageCfg.RequireLevel
    self.ConditionIds = self.StageData.ConditionId
    self.Islock = false
    self.ConditionText = ""
    
    if stageCfg.RequireLevel > 0 and XPlayer.Level < stageCfg.RequireLevel then
        self.Islock = self.Islock or true
        self.LockType = LockType.Level
    end
    
    if self.num > START_NUM then
        if not XDataCenter.FubenManager.CheckStageIsPass(self.ExId) then
            self.LockType = LockType.Passed
            self.Islock = self.Islock or true
        end
    end
    
    if self.ConditionIds[self.num] ~= 0 then
        local ret, desc = XConditionManager.CheckCondition(self.ConditionIds[self.num])
        if not ret then
            self.Islock = self.Islock or true
            self.LockType = LockType.Stage
            self.ConditionText = desc
        end
    end
    
    if self.Islock then
        self.PanelLock.gameObject:SetActive(true)
    else
        self.PanelLock.gameObject:SetActive(false)
    end
    
    if XDataCenter.FubenManager.CheckStageIsPass(self.Id) then
        self.PanelComplete.gameObject:SetActive(true)
    else
        self.PanelComplete.gameObject:SetActive(false)
    end
end

function XUiFubenDailyStage:OnBtnEnter(...)
    if not self.Islock then
        local stageCfg = {}
        
        if self.SelectCallBack then
            self.SelectCallBack(self.num,true)
        end
        
        self.Base:ShowPanelAsset(false)
        
        stageCfg = XDataCenter.FubenManager.GetStageCfg(self.Id)
        XLuaUiManager.Open("UiFubenStageDetail", stageCfg,function()
                self.Base:ShowPanelAsset(true)
                if self.SelectCallBack then
                    self.SelectCallBack(0,false)
                end
        end)
    else
        if self.LockType == LockType.Level then
            XUiManager.TipError(CS.XTextManager.GetText("BaseEquipNeedLevel", self.RequireLevel))
        end
        if self.LockType == LockType.Stage and self.ConditionText ~="" then
            XUiManager.TipError(self.ConditionText)
        end
        if self.LockType == LockType.Passed then
            XUiManager.TipError(CS.XTextManager.GetText("ExploreBuffUnlock", self.StageData.Code .. "-" .. (self.num-1)))
        end
    end
end


function XUiFubenDailyStage:UpdateStage(Info)
    if self.Id == Info.CurStageId then
        self.PanelSelect.gameObject:SetActive(true)
    else
        self.PanelSelect.gameObject:SetActive(false)
    end
end
