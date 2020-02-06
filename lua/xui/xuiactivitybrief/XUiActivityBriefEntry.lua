local TimeFormat = "MM/dd"
local TimestampToGameDateTimeString = XTime.TimestampToGameDateTimeString
local CSXTextManagerGetText = CS.XTextManager.GetText

local XUiActivityBriefEntry = XLuaUiManager.Register(XLuaUi, "UiActivityBriefEntry")

function XUiActivityBriefEntry:OnStart(firstOpen)
    if firstOpen then
        self:PlayAnimation("AnimEnable1")
    else
        self:PlayAnimation("AnimEnable2")
    end
    --XRedPointManager.AddRedPointEvent(self.BtnActivityBabelTower, self.BaBelTowerRedDot, self, {XRedPointConditions.Types.CONDITION_TASK_TYPE}, XDataCenter.TaskManager.TaskType.BabelTower)
end

function XUiActivityBriefEntry:OnEnable()
    self:InitActivityMainLine()
    self:InitActivityPrequel()
    --self:InitActivityBossOnline()
    self:InitActivityBabelTower()
    self:InitActivityBranch()
    self:InitActivityBossSingle()
end

function XUiActivityBriefEntry:InitActivityBossSingle()
    local beginTime = XDataCenter.FubenActivityBossSingleManager.GetActivityBeginTime()
    local fightEndTime = XDataCenter.FubenActivityBossSingleManager.GetFightEndTime()
    local endTime = XDataCenter.FubenActivityBossSingleManager.GetActivityEndTime()
    local inTime, timeStr, aheadTime = self:InitAcitivityTime(beginTime, fightEndTime, endTime)

    local functionId = XFunctionManager.FunctionName.FubenActivitySingleBoss
    self.BtnActivityBossSingle:SetNameByGroup(0, timeStr)

    local isOpen = XFunctionManager.JudgeCanOpen(functionId) and inTime
    self.BtnActivityBossSingle:SetDisable(not isOpen)

    local config = XActivityBriefConfigs.GetActivityGroupConfig(XActivityBriefConfigs.ActivityGroupId.BossSingle)
    local skipId = config.SkipId
    self.BtnActivityBossSingle.CallBack = function()
        if not XFunctionManager.DetectionFunction(functionId) then
            return
        end

        if not inTime then
            local notInTimeStr = aheadTime and "ActivityBossSingleNotOpen" or "ActivityBossSingleOver"
            XUiManager.TipText(notInTimeStr)
            return
        end

        XFunctionManager.SkipInterface(skipId)
    end
end

function XUiActivityBriefEntry:InitActivityBranch()
    local beginTime = XDataCenter.FubenActivityBranchManager.GetActivityBeginTime()
    local fightEndTime = XDataCenter.FubenActivityBranchManager.GetFightEndTime()
    local endTime = XDataCenter.FubenActivityBranchManager.GetActivityEndTime()
    local inTime, timeStr, aheadTime = self:InitAcitivityTime(beginTime, fightEndTime, endTime)

    local functionId = XFunctionManager.FunctionName.FubenActivityBranch
    self.BtnActivityBranch:SetNameByGroup(0, timeStr)

    local isOpen = XFunctionManager.JudgeCanOpen(functionId) and inTime
    self.BtnActivityBranch:SetDisable(not isOpen)

    local config = XActivityBriefConfigs.GetActivityGroupConfig(XActivityBriefConfigs.ActivityGroupId.Branch)
    local skipId = config.SkipId
    self.BtnActivityBranch.CallBack = function()
        if not XFunctionManager.DetectionFunction(functionId) then
            return
        end

        if not inTime then
            local notInTimeStr = aheadTime and "ActivityBranchNotOpen" or "ActivityBranchOver"
            XUiManager.TipText(notInTimeStr)
            return
        end

        XFunctionManager.SkipInterface(skipId)
    end
end

function XUiActivityBriefEntry:InitActivityBabelTower()
    local curActivityNo = XDataCenter.FubenBabelTowerManager.GetCurrentActivityNo()
    local beginTime = XDataCenter.FubenBabelTowerManager.GetActivityBeginTime(curActivityNo)
    local fightEndTime = XDataCenter.FubenBabelTowerManager.GetFightEndTime(curActivityNo)
    local endTime = XDataCenter.FubenBabelTowerManager.GetActivityEndTime(curActivityNo)
    local inTime, timeStr, aheadTime = self:InitAcitivityTime(beginTime, fightEndTime, endTime)
    
    self.BtnActivityBabelTower:SetNameByGroup(0, timeStr)
    
    local functionId = XFunctionManager.FunctionName.BabelTower
    local isOpen = XFunctionManager.JudgeCanOpen(functionId) and inTime
    self.BtnActivityBabelTower:SetDisable(not isOpen)
    
    local config = XActivityBriefConfigs.GetActivityGroupConfig(XActivityBriefConfigs.ActivityGroupId.BabelTower)
    local skipId = config.SkipId
    self.BtnActivityBabelTower.CallBack = function()
        if not XFunctionManager.DetectionFunction(functionId) then
            return
        end
        
        if not inTime then
            local notInTimeStr = aheadTime and "ActivityBabelTowerNotInTime" or "ActivityBabelTowerOver"
            XUiManager.TipText(notInTimeStr)
            return
        end
        
        XFunctionManager.SkipInterface(skipId)
    end
end

function XUiActivityBriefEntry:InitAcitivityTime(beginTime, fightEndTime, endTime)
    local inTime, timeStr, aheadTime = false, "", false

    local nowTime = XTime.GetServerNowTimestamp()
    if nowTime >= beginTime and nowTime < fightEndTime then
        inTime = true
        aheadTime = false
    elseif nowTime >= fightEndTime and nowTime < endTime then
        inTime = false
        aheadTime = false
    elseif nowTime >= endTime then
        inTime = false
        aheadTime = false
    else
        inTime = false
        aheadTime = true
    end

    local beginTimeStr = TimestampToGameDateTimeString(beginTime, TimeFormat)
    local endTimeStr = TimestampToGameDateTimeString(fightEndTime, TimeFormat)
    timeStr = CSXTextManagerGetText("ActivityBriefFightTime", beginTimeStr, endTimeStr)

    return inTime, timeStr, aheadTime
end

function XUiActivityBriefEntry:InitActivityMainLine()
    local config = XActivityBriefConfigs.GetActivityGroupConfig(XActivityBriefConfigs.ActivityGroupId.MainLine)
    self.BtnActivityMainLine:SetNameByGroup(0, config.Name)

    local functionId = XFunctionManager.FunctionName.FubenActivityMainLine
    local isOpen = XFunctionManager.JudgeCanOpen(functionId) and XDataCenter.FubenMainLineManager.IsMainLineActivityOpen()
    self.BtnActivityMainLine:SetDisable(not isOpen)

    local skipId = config.SkipId
    self.BtnActivityMainLine.CallBack = function()
        if not XFunctionManager.DetectionFunction(functionId) then
            return
        end

        if not isOpen then
            XUiManager.TipText("ActivityBriefMainlineNotInTime")
            return
        end

        XFunctionManager.SkipInterface(skipId)
    end
end

function XUiActivityBriefEntry:InitActivityBossOnline()
    local config = XActivityBriefConfigs.GetActivityGroupConfig(XActivityBriefConfigs.ActivityGroupId.BossOnline)
    self.BtnActivityBossOnline:SetNameByGroup(0, config.Name)

    local functionId = XFunctionManager.FunctionName.FubenActivityOnlineBoss
    local isOpen = XFunctionManager.JudgeCanOpen(functionId) and XDataCenter.FubenBossOnlineManager.GetIsActivity()
    self.BtnActivityBossOnline:SetDisable(not isOpen)

    local skipId = config.SkipId
    self.BtnActivityBossOnline.CallBack = function()
        if not XFunctionManager.DetectionFunction(functionId) then
            return
        end

        if not isOpen then
            XUiManager.TipText("ActivityBossOnlineOver")
            return
        end

        XFunctionManager.SkipInterface(skipId)
    end
end



function XUiActivityBriefEntry:InitActivityPrequel()
    local config = XActivityBriefConfigs.GetActivityGroupConfig(XActivityBriefConfigs.ActivityGroupId.Prequel)
    self.BtnActivityPrequel:SetNameByGroup(0, config.Name)

    local functionId = XFunctionManager.FunctionName.Prequel
    local isOpen = XFunctionManager.JudgeCanOpen(functionId) and XDataCenter.PrequelManager.IsInActivity()
    self.BtnActivityPrequel:SetDisable(not isOpen)

    local skipId = config.SkipId
    self.BtnActivityPrequel.CallBack = function()
        if not XFunctionManager.DetectionFunction(functionId) then
            return
        end

        if not isOpen then
            XUiManager.TipText("ActivityBriefPrequelNotInTime")
            return
        end

        XFunctionManager.SkipInterface(skipId)
    end
end


function XUiActivityBriefEntry:BaBelTowerRedDot(count)
    self.BtnActivityBabelTower:ShowReddot(count >= 0)
end