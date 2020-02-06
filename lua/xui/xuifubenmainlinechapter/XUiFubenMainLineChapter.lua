local XUiGridChapter = require("XUi/XUiFubenMainLineChapter/XUiGridChapter")

local XUiFubenMainLineChapter = XLuaUiManager.Register(XLuaUi, "UiFubenMainLineChapter")

function XUiFubenMainLineChapter:OnAwake()
    self:InitAutoScript()
end

function XUiFubenMainLineChapter:OnStart(chapter, stageId, hideDiffTog)
    self.UnderBg = self.Transform:Find("SafeAreaContentPane/ImageUnder")
    self.SafeAreaContentPane = self.Transform:Find("SafeAreaContentPane")
    self.Camera = self.Transform:GetComponent("Canvas").worldCamera
    self.Chapter = chapter
    self.StageId = stageId
    self.GridTreasureList = {}
    self.GridChapterList = {} --存的是各种Chapter的预制体实例列表
    self.CurChapterGrid = nil
    self.CurChapterGridName = ""
    self.PanelStageDetailInst = nil
    self.PanelBfrtStageDetailInst = nil
    self.CurDiff = chapter.Difficult or XDataCenter.FubenManager.DifficultNightmare --据点战Chpater没有难度配置

    self.PanelTreasure.gameObject:SetActive(false)
    self.ImgRedProgress.gameObject:SetActive(false)

    -- 注册红点事件
    XEventManager.AddEventListener(XEventId.EVENT_BOUNTYTASK_TASK_COMPLETE_NOTIFY, self.SetupBountyTask, self)
    self.RedPointId = XRedPointManager.AddRedPointEvent(self.ImgRedProgress, self.OnCheckRewards, self, { XRedPointConditions.Types.CONDITION_MAINLINE_CHAPTER_REWARD }, nil, false)
    self.RedPointBfrtId = XRedPointManager.AddRedPointEvent(self.ImgRedProgressA, self.OnCheckBfrtRewards, self, { XRedPointConditions.Types.CONDITION_BFRT_CHAPTER_REWARD }, nil, false)

    -- 注册stage事件
    XEventManager.AddEventListener(XEventId.EVENT_FUBEN_STAGE_SYNC, self.OnSyncStage, self)

    -- 难度toggle
    if not hideDiffTog then
        self.IsShowDifficultPanel = false
        self:UpdateDifficultToggles()
    else
        self.PanelTopDifficult.gameObject:SetActive(false)
    end

    -- 赏金任务
    self:InitBountyTask()
    self:SetupBountyTask()
end

function XUiFubenMainLineChapter:OnOpenInit()
    XDataCenter.FubenManager.UiFubenMainLineChapterInst = self
end

function XUiFubenMainLineChapter:GoToLastPassStage()
    local lastPassStageId = XDataCenter.FubenMainLineManager.GetLastPassStage(self.Chapter.ChapterId)
    if self.CurChapterGrid then
        self.CurChapterGrid:GoToStage(lastPassStageId)
    end
end

-- 打开关卡详情
function XUiFubenMainLineChapter:OpenStage(stageId, needRefreshChapter)
    local orderId
    if XDataCenter.BfrtManager.CheckStageTypeIsBfrt(stageId) then
        local groupId = XDataCenter.BfrtManager.GetGroupIdByStageId(stageId)
        orderId = XDataCenter.BfrtManager.GetGroupOrderId(groupId)
        self.CurDiff = XDataCenter.FubenManager.DifficultNightmare
        XDataCenter.FubenMainLineManager.SetCurDifficult(self.CurDiff)
    else
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        orderId = stageInfo.OrderId
        self.CurDiff = stageInfo.Difficult
        XDataCenter.FubenMainLineManager.SetCurDifficult(self.CurDiff)
    end

    self:UpdateDifficultToggles()

    if needRefreshChapter then
        local chapter = self:GetChapterCfgByStageId(stageId)
        self:UpdateCurChapter(chapter)
    end
    self.CurChapterGrid:ClickStageGridByIndex(orderId)
end

function XUiFubenMainLineChapter:EnterFight(stage)
    if not XDataCenter.FubenManager.CheckPreFight(stage) then
        return
    end

    if XDataCenter.BfrtManager.CheckStageTypeIsBfrt(stage.StageId) then
        --据点战副本类型先跳转到作战部署界面
        local groupId = XDataCenter.BfrtManager.GetGroupIdByBaseStage(stage.StageId)
        XLuaUiManager.Open("UiBfrtDeploy", groupId)
    else
        XLuaUiManager.Open("UiNewRoomSingle", stage.StageId)
    end
end

function XUiFubenMainLineChapter:OnCheckRewards(count, chapterId)
    if self.ImgRedProgress and chapterId == self.Chapter.ChapterId then
        self.ImgRedProgress.gameObject:SetActive(count >= 0)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiFubenMainLineChapter:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiFubenMainLineChapter:AutoInitUi()
    self.PanelTreasure = self.Transform:Find("SafeAreaContentPane/PanelTreasure")
    self.BtnTreasureBg = self.Transform:Find("SafeAreaContentPane/PanelTreasure/BtnTreasureBg"):GetComponent("Button")
    self.PanelReward = self.Transform:Find("SafeAreaContentPane/PanelTreasure/PanelReward")
    self.TxtTreasureTitle = self.Transform:Find("SafeAreaContentPane/PanelTreasure/PanelReward/TxtTreasureTitle"):GetComponent("Text")
    self.PanelTreasureGrade = self.Transform:Find("SafeAreaContentPane/PanelTreasure/PanelReward/PanelTreasureGrade")
    self.PanelGradeContent = self.Transform:Find("SafeAreaContentPane/PanelTreasure/PanelReward/PanelTreasureGrade/Viewport/PanelGradeContent")
    self.GridTreasureGrade = self.Transform:Find("SafeAreaContentPane/PanelTreasure/PanelReward/PanelTreasureGrade/Viewport/PanelGradeContent/GridTreasureGrade")
    self.Scrollbar = self.Transform:Find("SafeAreaContentPane/PanelTreasure/PanelReward/PanelTreasureGrade/Scrollbar"):GetComponent("Scrollbar")
    self.PanelMainlineChapter = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter")
    self.PanelTop = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelTop")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelTop/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelTop/BtnMainUi"):GetComponent("Button")
    self.PanelChapterName = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelChapterName")
    self.TxtChapter = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelChapterName/TxtChapter"):GetComponent("Text")
    self.TxtChapterName = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelChapterName/TxtChapterName"):GetComponent("Text")
    self.PanelBottom = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelBottom")
    self.PanelJundu = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelBottom/PanelJundu")
    self.ImgJindu = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelBottom/PanelJundu/ImgJindu"):GetComponent("Image")
    self.ImgLingqu = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelBottom/PanelJundu/ImgLingqu"):GetComponent("Image")
    self.BtnTreasure = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelBottom/PanelJundu/BtnTreasure"):GetComponent("Button")
    self.RImgBgIcon = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelBottom/PanelJundu/RImgBgIcon"):GetComponent("RawImage")
    self.PanelDesc = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelBottom/PanelDesc")
    self.TxtStarNum = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelBottom/PanelDesc/TxtStarNum"):GetComponent("Text")
    self.ImgRedProgress = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelBottom/PanelDesc/ImgRedProgress"):GetComponent("Image")
    self.PanelTopDifficult = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelTopDifficult")
    self.BtnNormal = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelTopDifficult/BtnNormal"):GetComponent("Button")
    self.PanelNormalOn = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelTopDifficult/BtnNormal/PanelNormalOn")
    self.PanelNormalOff = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelTopDifficult/BtnNormal/PanelNormalOff")
    self.BtnHard = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelTopDifficult/BtnHard"):GetComponent("Button")
    self.PanelHardOn = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelTopDifficult/BtnHard/PanelHardOn")
    self.PanelHardOff = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelTopDifficult/BtnHard/PanelHardOff")
    self.PanelMoney = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelMoney")
    self.PanelMoenyGroup = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelMoney/PanelMoenyGroup")
    self.PanelBountyTask = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelMoney/PanelMoenyGroup/PanelBountyTask")
    self.PanelStart = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelMoney/PanelMoenyGroup/PanelBountyTask/PanelStart")
    self.BtnSkip = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelMoney/PanelMoenyGroup/PanelBountyTask/PanelStart/BtnSkip"):GetComponent("Button")
    self.TxtLevel = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelMoney/PanelMoenyGroup/PanelBountyTask/PanelStart/TxtLevel"):GetComponent("Text")
    self.PanelComplete = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelMoney/PanelMoenyGroup/PanelBountyTask/PanelComplete")
    self.BtnBountyTask = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelMoney/PanelMoenyGroup/PanelBountyTask/PanelComplete/BtnBountyTask"):GetComponent("Button")
    self.PanelChapter = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelChapter")
    self.BtnCloseDifficult = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/BtnCloseDifficult"):GetComponent("Button")
    self.BtnCloseDetail = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/BtnCloseDetail"):GetComponent("Button")
    self.PanelActivityTime = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelActivityTime")
    self.TxtLeftTime = self.Transform:Find("SafeAreaContentPane/PanelMainlineChapter/PanelActivityTime/TxtLeftTime"):GetComponent("Text")
end

function XUiFubenMainLineChapter:AutoAddListener()
    self:RegisterClickEvent(self.BtnTreasureBg, self.OnBtnTreasureBgClick)
    self:RegisterClickEvent(self.Scrollbar, self.OnScrollbarClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnTreasure, self.OnBtnTreasureClick)
    self:RegisterClickEvent(self.BtnNormal, self.OnBtnNormalClick)
    self:RegisterClickEvent(self.BtnHard, self.OnBtnHardClick)
    self:RegisterClickEvent(self.BtnSkip, self.OnBtnSkipClick)
    self:RegisterClickEvent(self.BtnBountyTask, self.OnBtnBountyTaskClick)
    self:RegisterClickEvent(self.BtnCloseDifficult, self.OnBtnCloseDifficultClick)
    self:RegisterClickEvent(self.BtnCloseDetail, self.OnBtnCloseDetailClick)
end
-- auto
function XUiFubenMainLineChapter:OnBtnCloseDetailClick(eventData)
    self:OnCloseStageDetail()
end

function XUiFubenMainLineChapter:OnBtnCloseDifficultClick(eventData)
    self:UpdateDifficultToggles()
end

function XUiFubenMainLineChapter:OnScrollbarClick(eventData)

end

function XUiFubenMainLineChapter:OnBtnSkipClick(eventData)

end

function XUiFubenMainLineChapter:OnBtnBountyTaskClick(eventData)

end

function XUiFubenMainLineChapter:OnBtnBackClick(...)
    if self:CloseStageDetail() then
        return
    end
    self:Close()
end

function XUiFubenMainLineChapter:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiFubenMainLineChapter:OpenDifficultPanel()

end

function XUiFubenMainLineChapter:OnBtnNormalClick(...)
    if self.IsShowDifficultPanel then
        if self.CurDiff ~= XDataCenter.FubenManager.DifficultNormal then
            local chapterInfo = XDataCenter.FubenMainLineManager.GetChapterInfoForOrderId(XDataCenter.FubenManager.DifficultNormal, self.Chapter.OrderId)
            if not (chapterInfo and chapterInfo.Unlock) then
                XUiManager.TipMsg(XDataCenter.FubenManager.GetFubenOpenTips(chapterInfo.FirstStage), XUiManager.UiTipType.Wrong)
                return
            end
            self.CurDiff = XDataCenter.FubenManager.DifficultNormal
            XDataCenter.FubenMainLineManager.SetCurDifficult(self.CurDiff)
            self:RefreshForChangeDiff()
        end
        self:UpdateDifficultToggles()
    else
        self:UpdateDifficultToggles(true)
    end
end

function XUiFubenMainLineChapter:OnBtnHardClick(...)
    if self.IsShowDifficultPanel then
        if self.CurDiff ~= XDataCenter.FubenManager.DifficultHard then
            -- 检查困难开启
            if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.FubenDifficulty) then
                return
            end

            -- 检查困难这个章节解锁
            local chapterInfo = XDataCenter.FubenMainLineManager.GetChapterInfoForOrderId(XDataCenter.FubenManager.DifficultHard, self.Chapter.OrderId)
            if not chapterInfo or not chapterInfo.IsOpen then
                XUiManager.TipMsg(CS.XTextManager.GetText("FubenNeedComplatePreChapter"), XUiManager.UiTipType.Wrong)
                return
            end
            self.CurDiff = XDataCenter.FubenManager.DifficultHard
            XDataCenter.FubenMainLineManager.SetCurDifficult(self.CurDiff)
            self:RefreshForChangeDiff()
        end
        self:UpdateDifficultToggles()
    else
        self:UpdateDifficultToggles(true)
    end
end

function XUiFubenMainLineChapter:UpdateDifficultToggles(showAll)
    if showAll then
        self:SetBtnTogleActive(true, true, true)
        self.BtnCloseDifficult.gameObject:SetActive(true)
    else
        if self.CurDiff == XDataCenter.FubenManager.DifficultNormal then
            self:SetBtnTogleActive(true, false, false)
            self.BtnNormal.transform:SetAsFirstSibling()
        elseif self.CurDiff == XDataCenter.FubenManager.DifficultHard then
            self:SetBtnTogleActive(false, true, false)
            self.BtnHard.transform:SetAsFirstSibling()
        else
            self:SetBtnTogleActive(false, false, true)
        end
        self.BtnCloseDifficult.gameObject:SetActive(false)
    end
    self.IsShowDifficultPanel = showAll
    --progress
    local pageDatas = XDataCenter.FubenMainLineManager.GetChapterMainTemplates(self.CurDiff)
    local chapterIds = {}
    for _, v in pairs(pageDatas) do
        if v.OrderId == self.Chapter.OrderId then
            chapterIds = v.ChapterId
            break
        end
    end
    self.TxtNormalProgress.text = XDataCenter.FubenMainLineManager.GetProgressByChapterId(chapterIds[1])
    self.TxtHardProgress.text = XDataCenter.FubenMainLineManager.GetProgressByChapterId(chapterIds[2])
    -- 抢先体验活动倒计时
    self:UpdateActivityTime()
end

function XUiFubenMainLineChapter:UpdateChapterTxt()
    self.TxtChapter.text = "0" .. self.Chapter.OrderId
    self.TxtChapterName.text = self.Chapter.ChapterEn
end

function XUiFubenMainLineChapter:SetBtnTogleActive(isNormal, isHard, isNightmare)
    self.BtnNormal.gameObject:SetActive(isNormal)

    self.BtnHard.gameObject:SetActive(isHard)
    if isHard then
        local hardOpen = XFunctionManager.JudgeCanOpen(XFunctionManager.FunctionName.FubenDifficulty)
        local chapterInfo = XDataCenter.FubenMainLineManager.GetChapterInfoForOrderId(XDataCenter.FubenManager.DifficultHard, self.Chapter.OrderId)
        hardOpen = hardOpen and chapterInfo and chapterInfo.IsOpen
        self.PanelHardOn.gameObject:SetActive(hardOpen)
        self.PanelHardOff.gameObject:SetActive(not hardOpen)
    end
end

function XUiFubenMainLineChapter:RefreshForChangeDiff()
    XDataCenter.FubenMainLineManager.SetCurDifficult(self.CurDiff)
    local chapter
    if self:CheckIsBfrtType() then
        local chapterInfo = XDataCenter.BfrtManager.GetChapterInfoForOrder(self.Chapter.OrderId)
        chapter = XDataCenter.BfrtManager.GetChapterCfg(chapterInfo.ChapterId)
    else
        local chapterList = XDataCenter.FubenMainLineManager.GetChapterList(self.CurDiff)
        chapter = XDataCenter.FubenMainLineManager.GetChapterCfg(chapterList[self.Chapter.OrderId])
    end

    self:UpdateCurChapter(chapter)
    self:PlayAnimation("AnimEnable2")
end

function XUiFubenMainLineChapter:SetPanelBottomActive(isActive)
    self.PanelBottom.gameObject:SetActive(isActive)
end

function XUiFubenMainLineChapter:UpdateCurChapter(chapter)
    if not chapter then
        return
    end
    self.Chapter = chapter

    for _, v in pairs(self.GridChapterList) do
        v:Hide()
    end

    local data = {
        Chapter = self.Chapter,
        HideStageCb = handler(self, self.HideStageDetail),
        ShowStageCb = handler(self, self.ShowStageDetail),
    }

    if self:CheckIsBfrtType() then
        data.StageList = XDataCenter.BfrtManager.GetBaseStageList(self.Chapter.ChapterId)
    else
        data.StageList = XDataCenter.FubenMainLineManager.GetStageList(self.Chapter.ChapterId)
    end

    local grid = self.CurChapterGrid
    local prefabName = self.Chapter.PrefabName
    if self.CurChapterGridName ~= prefabName then
        local gameObject = self.PanelChapter:LoadPrefab(prefabName)
        if gameObject == nil or not gameObject:Exist() then
            return
        end

        grid = XUiGridChapter.New(self, gameObject)
        grid.Transform:SetParent(self.PanelChapter, false)
        self.CurChapterGridName = prefabName
        self.CurChapterGrid = grid
        self.GridChapterList[prefabName] = grid
    end

    grid:UpdateChapterGrid(data)
    grid:Show()
    if self:CheckIsBfrtType() then
        self:UpdatePanelBfrtTask()
    else
        self:UpdateChapterStars()
    end

    if self.StageId then
        self:OpenStage(self.StageId)
        self.StageId = nil
    end

    XEventManager.DispatchEvent(XEventId.EVENT_GUIDE_STEP_OPEN_EVENT)
    self:UpdateChapterTxt()
end

function XUiFubenMainLineChapter:CheckDetailOpen()
    local childUi = self:GetCurDetailChildUi()
    return XLuaUiManager.IsUiShow(childUi)
end

function XUiFubenMainLineChapter:ShowStageDetail(stage)
    self.PanelMoney.gameObject:SetActive(false)
    self.Stage = stage
    local childUi = self:GetCurDetailChildUi()
    self:OpenOneChildUi(childUi, self)
end

function XUiFubenMainLineChapter:OnEnterStory(stageId)
    self.Stage = XDataCenter.FubenManager.GetStageCfg(stageId)

    local childUi = self:GetCurDetailChildUi()
    self:OpenOneChildUi(childUi, self)
end

function XUiFubenMainLineChapter:HideStageDetail()
    if not self.Stage then
        return
    end

    local childUi = self:GetCurDetailChildUi()
    local childUiObj = self:FindChildUiObj(childUi)
    if childUiObj then
        childUiObj:Hide()
    end
end

function XUiFubenMainLineChapter:OnCloseStageDetail()
    if self.BountyInfo and #self.BountyInfo.TaskCards > 0 then
        local taskCards = self.BountyInfo.TaskCards
        for i = 1, XDataCenter.BountyTaskManager.MAX_BOUNTY_TASK_COUNT do
            if taskCards[i] and taskCards[i].Status ~= XDataCenter.BountyTaskManager.BountyTaskStatus.AcceptReward then
                self.PanelMoney.gameObject:SetActive(true)
            end
        end
    end
    if self.CurChapterGrid then
        self.CurChapterGrid:CancelSelect()
    end
end

function XUiFubenMainLineChapter:UpdateBfrtRewards()
    local chapterId = self.Chapter.ChapterId
    local taskId = XDataCenter.BfrtManager.GetBfrtTaskId(chapterId)
    local taskConfig = XDataCenter.TaskManager.GetTaskTemplate(taskId)
    local rewardId = taskConfig.RewardId
    local rewards = XRewardManager.GetRewardList(rewardId)

    self.BfrtRewardGrids = self.BfrtRewardGrids or {}
    local rewardsNum = #rewards
    for i = 1, rewardsNum do
        local grid = self.BfrtRewardGrids[i]
        if not grid then
            local go = i == 1 and self.GridCommonPopUp or CS.UnityEngine.Object.Instantiate(self.GridCommonPopUp)
            grid = XUiGridCommon.New(self, go)
            self.BfrtRewardGrids[i] = grid
        end
        grid:Refresh(rewards[i])
        grid.Transform:SetParent(self.PanelBfrtRewrds, false)
        grid.GameObject:SetActiveEx(true)
    end
    for i = rewardsNum + 1, #self.BfrtRewardGrids do
        self.BfrtRewardGrids[i].GameObject:SetActiveEx(false)
    end
end

function XUiFubenMainLineChapter:OnCheckBfrtRewards(count)
    self.ImgRedProgressA.gameObject:SetActive(count >= 0)
end

function XUiFubenMainLineChapter:UpdatePanelBfrtTask()
    local chapterId = self.Chapter.ChapterId
    self.ImgJindu.gameObject:SetActive(false)
    self.ImgLingqu.gameObject:SetActive(XDataCenter.BfrtManager.CheckAllTaskRewardHasGot(chapterId))
    self.PanelDesc.gameObject:SetActive(false)
    self.PanelBfrtTask.gameObject:SetActive(true)

    self:UpdateBfrtRewards()
    XRedPointManager.Check(self.RedPointBfrtId, self.Chapter.ChapterId)
end

function XUiFubenMainLineChapter:UpdateChapterStars()
    local curStars = 0
    local totalStars = 0
    curStars,totalStars = XDataCenter.FubenMainLineManager.GetChapterStars(self.Chapter.ChapterId)
    
    self.ImgJindu.fillAmount = totalStars > 0 and curStars / totalStars or 0
    self.ImgJindu.gameObject:SetActive(true)
    self.TxtStarNum.text = CS.XTextManager.GetText("Fract", curStars, totalStars)

    local received = true
    local chapterTemplate = XDataCenter.FubenMainLineManager.GetChapterCfg(self.Chapter.ChapterId)
    for k, v in pairs(chapterTemplate.TreasureId) do
        if not XDataCenter.FubenMainLineManager.IsTreasureGet(v) then
            received = false
            break
        end
    end
    self.ImgLingqu.gameObject:SetActive(received)

    self.PanelBfrtTask.gameObject:SetActive(false)
    self.PanelDesc.gameObject:SetActive(true)
    XRedPointManager.Check(self.RedPointId, self.Chapter.ChapterId)
end

function XUiFubenMainLineChapter:OnBtnTreasureClick()
    if self:CloseStageDetail() then
        return
    end
    if self:CheckIsBfrtType() then
        local chapterId = self.Chapter.ChapterId
        if XDataCenter.BfrtManager.CheckAllTaskRewardHasGot(chapterId) then
            XUiManager.TipText("TaskAlreadyFinish")
            return
        elseif not XDataCenter.BfrtManager.CheckAnyTaskRewardCanGet(chapterId) then
            XUiManager.TipText("TaskDoNotFinish")
            return
        end

        local taskId = XDataCenter.BfrtManager.GetBfrtTaskId(chapterId)
        XDataCenter.TaskManager.FinishTask(taskId, function(rewardGoodsList)
            XUiManager.OpenUiObtain(rewardGoodsList)
            self:UpdatePanelBfrtTask()
        end)
    else
        self:InitTreasureGrade()
        self.PanelTreasure.gameObject:SetActive(true)
        self.PanelTop.gameObject:SetActive(false)
        self.PanelBottom.gameObject:SetActive(false)
    end
    self:PlayAnimation("TreasureEnable")
end

function XUiFubenMainLineChapter:CloseStageDetail()
    if self:CheckDetailOpen() then
        if self.CurChapterGrid then
            self.CurChapterGrid:ScrollRectRollBack()
        end
        self:HideStageDetail()
        return true
    end
    return false
end

function XUiFubenMainLineChapter:OnBtnTreasureBgClick()
    self:PlayAnimation("TreasureDisable", handler(self, function()
        self.PanelTreasure.gameObject:SetActive(false)
        self.PanelTop.gameObject:SetActive(true)
        self.PanelBottom.gameObject:SetActive(true)
        if not self:CheckIsBfrtType() then
            self:UpdateChapterStars()
        end
    end))
end

-- 初始化 treasure grade grid panel，填充数据
function XUiFubenMainLineChapter:InitTreasureGrade()
    local baseItem = self.GridTreasureGrade
    baseItem.gameObject:SetActive(false)

    local targetList = self.Chapter.TreasureId
    if not targetList then
        return
    end

    local offsetValue = 260
    local gridCount = #targetList
    local fieldCount = self.PanelGradeContent.childCount

    for i = 1, gridCount do
        local offerY = (1 - i) * offsetValue
        local grid = self.GridTreasureList[i]
        if not grid then
            local item = CS.UnityEngine.Object.Instantiate(baseItem)  -- 复制一个item
            grid = XUiGridTreasureGrade.New(self, item)
            grid.Transform:SetParent(self.PanelGradeContent, false)
            grid.Transform.localPosition = CS.UnityEngine.Vector3(item.transform.localPosition.x, item.transform.localPosition.y + offerY, item.transform.localPosition.z)
            self.GridTreasureList[i] = grid
        end
        local treasureCfg = XDataCenter.FubenMainLineManager.GetTreasureCfg(targetList[i])
        local chapterInfo = XDataCenter.FubenMainLineManager.GetChapterInfo(self.Chapter.ChapterId)
        grid:UpdateGradeGrid(chapterInfo.Stars, treasureCfg, self.Chapter.ChapterId)
        grid:InitTreasureList()
        grid.GameObject:SetActive(true)
    end

    for j = 1, #self.GridTreasureList do
        if j > gridCount then
            self.GridTreasureList[j].GameObject:SetActive(false)
        end
    end
end

function XUiFubenMainLineChapter:OnSyncStage(stageId)
    if not stageId then
        return
    end
    local stageData = XDataCenter.FubenManager.GetStageData(stageId)
    if not stageData then
        return
    end
    if stageData.PassTimesToday > 1 then
        return
    end
    if not self.CurDiff or self.CurDiff < 0 then
        return
    end

    local chapter = self:GetChapterCfgByStageId(stageId)
    if chapter then
        self:UpdateCurChapter(chapter)
    end
end

function XUiFubenMainLineChapter:OnEnable()
    if self.GridChapterList then
        for k, v in pairs(self.GridChapterList) do
            v:OnEnable()
        end
    end

    self:UpdateDifficultToggles()
    self:OnOpenInit()
    self:UpdateCurChapter(self.Chapter)
    self:SetupBountyTask()

    -- 首次进入
    if not self.Opened then
        self:GoToLastPassStage()
        self.Opened = true
    end

end

function XUiFubenMainLineChapter:OnDisable()
    if self.GridChapterList then
        for k, v in pairs(self.GridChapterList) do
            v:OnDisable()
        end
    end

    local childUi = self:GetCurDetailChildUi()
    self:CloseChildUi(childUi)

    self:OnCloseStageDetail()
end

function XUiFubenMainLineChapter:OnDestroy()
    self:DestroyActivityTimer()
    XDataCenter.FubenManager.UiFubenMainLineChapterInst = nil
    XEventManager.RemoveEventListener(XEventId.EVENT_FUBEN_STAGE_SYNC, self.OnSyncStage, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_BOUNTYTASK_TASK_COMPLETE_NOTIFY, self.SetupBountyTask, self)
end

--设置任务卡
function XUiFubenMainLineChapter:InitBountyTask()
    self.TaskGrid = {}
    self.TaskGrid[1] = XUiPanelBountyTask.New(self.PanelBountyTask, self)
    self.PanelMoney.gameObject:SetActive(false)

    for i = 2, XDataCenter.BountyTaskManager.MAX_BOUNTY_TASK_COUNT do
        local ui = CS.UnityEngine.Object.Instantiate(self.PanelBountyTask)
        self.TaskGrid[i] = XUiPanelBountyTask.New(ui, self)
        self.TaskGrid[i].Transform:SetParent(self.PanelMoenyGroup, false)
        self.TaskGrid[i].GameObject:SetActive(false)
    end
end

--设置赏金任务标签
function XUiFubenMainLineChapter:SetupBountyTask()
    self.PanelMoney.gameObject:SetActive(false)

    self.BountyInfo = XDataCenter.BountyTaskManager.GetBountyTaskInfo()
    if not self.BountyInfo or #self.BountyInfo.TaskCards <= 0 then
        self.PanelMoney.gameObject:SetActive(false)
        return
    end


    local taskCards = self.BountyInfo.TaskCards
    for i = 1, XDataCenter.BountyTaskManager.MAX_BOUNTY_TASK_COUNT do
        if taskCards[i] and taskCards[i].Status ~= XDataCenter.BountyTaskManager.BountyTaskStatus.AcceptReward then
            self.TaskGrid[i]:SetupContent(taskCards[i])
            self.TaskGrid[i].GameObject:SetActive(true)
            self.PanelMoney.gameObject:SetActive(true)

        else
            self.TaskGrid[i]:SetActive(false)
        end
    end
end

function XUiFubenMainLineChapter:CheckIsBfrtType()
    return self.CurDiff and self.CurDiff == XDataCenter.FubenManager.DifficultNightmare
end

function XUiFubenMainLineChapter:GetChapterCfgByStageId(stageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
    local chapter
    if XDataCenter.BfrtManager.CheckStageTypeIsBfrt(stageId) then
        chapter = XDataCenter.BfrtManager.GetChapterCfg(stageInfo.ChapterId)
    elseif stageInfo.Type == XDataCenter.FubenManager.StageType.Mainline then
        chapter = XDataCenter.FubenMainLineManager.GetChapterCfg(stageInfo.ChapterId)
    else
        return
    end

    return chapter
end

function XUiFubenMainLineChapter:OnGetEvents()
    return { XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL, XEventId.EVENT_FUBEN_ENTERFIGHT }
end

--事件监听
function XUiFubenMainLineChapter:OnNotify(evt, ...)
    if evt == XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL then
        self:OnCloseStageDetail()
    elseif evt == XEventId.EVENT_FUBEN_ENTERFIGHT then
        self:EnterFight(...)
    end
end

function XUiFubenMainLineChapter:UpdateActivityTime()
    if self:CheckIsBfrtType() or not XDataCenter.FubenMainLineManager.IsMainLineActivityOpen() then
        self:DestroyActivityTimer()
        self.PanelActivityTime.gameObject:SetActive(false)
        return
    end

    self:CreateActivityTimer()

    local curDiffHasActivity = XDataCenter.FubenMainLineManager.CheckDiffHasAcitivity(self.Chapter)
    self.PanelActivityTime.gameObject:SetActive(curDiffHasActivity)
end

function XUiFubenMainLineChapter:CreateActivityTimer()
    self:DestroyActivityTimer()

    local time = XTime.GetServerNowTimestamp()
    local endTime = XDataCenter.FubenMainLineManager.GetActivityEndTime()
    self.TxtLeftTime.text = XUiHelper.GetTime(endTime - time, XUiHelper.TimeFormatType.ACTIVITY)
    self.ActivityTimer = CS.XScheduleManager.ScheduleForever(function(...)
        if XTool.UObjIsNil(self.TxtLeftTime) then
            self:DestroyActivityTimer()
            return
        end

        local leftTime = endTime - time
        time = time + 1

        if leftTime >= 0 then
            self.TxtLeftTime.text = XUiHelper.GetTime(leftTime, XUiHelper.TimeFormatType.ACTIVITY)
        else
            self:DestroyActivityTimer()
            XDataCenter.FubenMainLineManager.OnActivityEnd()
        end
    end, CS.XScheduleManager.SECOND, 0)
end

function XUiFubenMainLineChapter:DestroyActivityTimer()
    if self.ActivityTimer then
        CS.XScheduleManager.UnSchedule(self.ActivityTimer)
        self.ActivityTimer = nil
    end
end

function XUiFubenMainLineChapter:GetCurDetailChildUi()
    local stageCfg = self.Stage
    if not stageCfg then return "" end

    if XDataCenter.BfrtManager.CheckStageTypeIsBfrt(stageCfg.StageId) then
        return "UiBfrtStageDetail"
    elseif stageCfg.StageType == XFubenConfigs.STAGETYPE_STORY or stageCfg.StageType == XFubenConfigs.STAGETYPE_STORYEGG then
        return "UiStoryStageDetail"
    else
        return "UiFubenMainLineDetail"
    end
end

function XUiFubenMainLineChapter:GoToStage(stageId)
    if self.CurChapterGrid then
        self.CurChapterGrid:GoToStage(stageId)
    end
end
