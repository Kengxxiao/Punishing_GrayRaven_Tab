XUiGridMainLineBanner = XClass()

function XUiGridMainLineBanner:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Transform3d = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
    self.LockTxt = self.TxtLock.text
end

function XUiGridMainLineBanner:OnCheckRewards(count, chapterId)
    if self.ImgRewards and chapterId == self.Chapter.ChapterId then
        self.ImgRewards.gameObject:SetActive(count >= 0)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridMainLineBanner:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiGridMainLineBanner:AutoInitUi()
    self.PanelChapter = self.Transform:Find("PanelChapter")
    self.PanelCd = self.Transform:Find("PanelChapter/PanelCd")
    self.ImgDisc = self.Transform:Find("PanelChapter/PanelCd/ImgDisc"):GetComponent("Image")
    self.PanelChapter = self.Transform:Find("PanelChapter/PanelChapter")
    self.PanelImgChapter = self.Transform:Find("PanelChapter/PanelChapter/PanelImgChapter")
    self.RImgChapter = self.Transform:Find("PanelChapter/PanelChapter/PanelImgChapter/RImgChapter"):GetComponent("RawImage")
    self.PanelSlide = self.Transform:Find("PanelChapter/PanelChapter/PanelImgChapter/PanelSlide")
    self.PanelDegree1 = self.Transform:Find("PanelChapter/PanelChapter/PanelImgChapter/PanelSlide/PanelDegree1")
    self.TxtPercentNormal = self.Transform:Find("PanelChapter/PanelChapter/PanelImgChapter/PanelSlide/PanelDegree1/TxtPercentNormal"):GetComponent("Text")
    self.ImgPercentNormal = self.Transform:Find("PanelChapter/PanelChapter/PanelImgChapter/PanelSlide/PanelDegree1/ImgPercentNormal"):GetComponent("Image")
    self.PanelDegree2 = self.Transform:Find("PanelChapter/PanelChapter/PanelImgChapter/PanelSlide/PanelDegree2")
    self.TxtPercentHart = self.Transform:Find("PanelChapter/PanelChapter/PanelImgChapter/PanelSlide/PanelDegree2/TxtPercentHart"):GetComponent("Text")
    self.ImgPercentHart = self.Transform:Find("PanelChapter/PanelChapter/PanelImgChapter/PanelSlide/PanelDegree2/ImgPercentHart"):GetComponent("Image")
    self.PanelDegree3 = self.Transform:Find("PanelChapter/PanelChapter/PanelImgChapter/PanelSlide/PanelDegree3")
    self.TxtPanel = self.Transform:Find("PanelChapter/PanelChapter/TxtPanel"):GetComponent("Text")
    self.TxtNum = self.Transform:Find("PanelChapter/PanelChapter/TxtPanel/TxtNum"):GetComponent("Text")
    self.TxtEN = self.Transform:Find("PanelChapter/PanelChapter/TxtPanel/TxtEN"):GetComponent("Text")
    self.ImgRewards = self.Transform:Find("PanelChapter/ImgRewards"):GetComponent("Image")
    self.BtnChapter = self.Transform:Find("PanelChapter/BtnChapter"):GetComponent("Button")
    self.PanelChapterLock = self.Transform:Find("PanelChapterLock")
    self.TxtLock = self.Transform:Find("PanelChapterLock/TxtLock"):GetComponent("Text")
    self.Imglock = self.Transform:Find("PanelChapterLock/Imglock"):GetComponent("Image")
    self.ImgRedDot = self.Transform:Find("ImgRedDot"):GetComponent("Image")
    self.PanelNewEffect = self.Transform:Find("PanelNewEffect")
    self.PanelActivityTag = self.Transform:Find("PanelActivityTag")
end

function XUiGridMainLineBanner:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiGridMainLineBanner:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiGridMainLineBanner:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiGridMainLineBanner:AutoAddListener()
    self:RegisterClickEvent(self.BtnChapter, self.OnBtnChapterClick)
end
-- auto
function XUiGridMainLineBanner:OnBtnChapterClick(eventData)

end

-- chapter 组件内容更新
function XUiGridMainLineBanner:UpdateChapterGrid(chapterMain, difficulty)
    --初始状态
    self.PanelDegree1.gameObject:SetActive(false)
    self.PanelDegree2.gameObject:SetActive(false)
    self.PanelDegree3.gameObject:SetActive(false)
    --判断活动关卡
    local chapterInfo = XDataCenter.FubenMainLineManager.GetChapterInfoByChapterMain(chapterMain.Id, difficulty)
    local isActivity = chapterInfo.IsActivity
    self.PanelActivityTag.gameObject:SetActive(isActivity)

    -- 红点&判断新关卡
    if isActivity then
        self.PanelNewEffect.gameObject:SetActive(false)
    end

    --进度展示
    if difficulty == XDataCenter.FubenMainLineManager.DifficultNormal then
        self.PanelDegree1.gameObject:SetActive(true)
        XRedPointManager.CheckOnce(self.OnCheckRedPoint, self, { XRedPointConditions.Types.CONDITION_MAINLINE_CHAPTER_REWARD }, chapterMain.ChapterId[1])
        local checkNew = XDataCenter.FubenMainLineManager.CheckChapterNew(chapterMain.ChapterId[1])
        self.PanelNewEffect.gameObject:SetActive(checkNew)
    elseif difficulty == XDataCenter.FubenMainLineManager.DifficultHard then
        self.PanelDegree2.gameObject:SetActive(true)
        XRedPointManager.CheckOnce(self.OnCheckRedPoint, self, { XRedPointConditions.Types.CONDITION_MAINLINE_CHAPTER_REWARD }, chapterMain.ChapterId[2])
        local checkNew = XDataCenter.FubenMainLineManager.CheckChapterNew(chapterMain.ChapterId[2])
        self.PanelNewEffect.gameObject:SetActive(checkNew)
    end

    -- icon&标题
    self.RImgChapter:SetRawImage(chapterMain.Icon)
    self.TxtEN.text = chapterMain.ChapterEn
    self.TxtNum.text = string.format("%02d", chapterMain.OrderId)
    -- 普通关卡
    local progress = XDataCenter.FubenMainLineManager.GetProgressByChapterId(chapterMain.ChapterId[1])
    self.TxtPercentNormal.text = progress .. "%"
    self.ImgPercentNormal.fillAmount = progress / 100

    -- 困难关卡
    progress = XDataCenter.FubenMainLineManager.GetProgressByChapterId(chapterMain.ChapterId[2])
    self.TxtPercentHart.text = progress .. "%"
    self.ImgPercentHart.fillAmount = progress / 100

    --未解锁
    if chapterInfo.Unlock then
        self.PanelChapterLock.gameObject:SetActive(false)
    else
        if isActivity then
            local _, desc = XDataCenter.FubenMainLineManager.CheckActivityCondition(chapterMain.Id)
            self.TxtLock.text = desc
        else
            self.TxtLock.text = self.LockTxt
        end
        self.PanelChapterLock.gameObject:SetActive(true)
    end
end

function XUiGridMainLineBanner:OnCheckRedPoint(count)
    if self.ImgRedDot then
        self.ImgRedDot.gameObject:SetActive(count >= 0)
    end
end