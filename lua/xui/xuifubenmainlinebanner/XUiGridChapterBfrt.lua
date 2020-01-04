local CSGetText = CS.XTextManager.GetText

local XUiGridChapterBfrt = XClass()

function XUiGridChapterBfrt:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)

    self.BtnUnlockCover.CallBack = function()
        local chapterId = self.ChapterId
        local chapterCfg = XDataCenter.BfrtManager.GetChapterCfg(chapterId)
        local chapterInfo = XDataCenter.BfrtManager.GetChapterInfo(chapterId)

        local conditionId = chapterCfg.ActivityCondition
        if conditionId ~= 0 then
            local ret, des = XConditionManager.CheckCondition(chapterCfg.ActivityCondition)
            if not ret then
                XUiManager.TipMsg(des)
                return
            end
        end

        if not chapterInfo.Unlock then
            XUiManager.TipMsg(CSGetText("BfrtChapterUnlockCondition"))
            return
        end
    end
end

function XUiGridChapterBfrt:RefreshDatas(chapterId)
    self.ChapterId = chapterId

    local chapterCfg = XDataCenter.BfrtManager.GetChapterCfg(chapterId)
    self.RImgIcon:SetRawImage(chapterCfg.Cover)
    self.TxtOrder.text = chapterCfg.ChapterName
    self.TxtName.text = chapterCfg.ChapterEn

    local passCount = XDataCenter.BfrtManager.GetChapterPassCount(chapterId)
    local totalCount = XDataCenter.BfrtManager.GetGroupCount(chapterId)
    self.TxtProgress.text = CSGetText("BfrtChapterProgress", passCount, totalCount)

    local chapterInfo = XDataCenter.BfrtManager.GetChapterInfo(chapterId)
    if chapterInfo.Unlock then
        self.BtnUnlockCover.gameObject:SetActiveEx(false)
    else
        self.TxtUnlockCondition.text = CSGetText("BfrtChpaterLocked", passCount, totalCount)
        self.BtnUnlockCover.gameObject:SetActiveEx(true)
    end

    self.ImgActivityTab.gameObject:SetActiveEx(chapterInfo.IsActivity)
    XRedPointManager.CheckOnce(self.OnCheckRedPoint, self, { XRedPointConditions.Types.CONDITION_BFRT_CHAPTER_REWARD }, chapterId)
end

function XUiGridChapterBfrt:OnCheckRedPoint(count)
    self.ImgRedDot.gameObject:SetActiveEx(count >= 0)
end

return XUiGridChapterBfrt