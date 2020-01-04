XUiGridCourse = XClass()

local PotPostion = {
    [1] = {--有经历节点
        [1] = { x = 129, w = 248 },
        [2] = { x = 127, w = 247 },
        [3] = { x = 129, w = 250 }
    },
    [2] = {--功能开启
        [1] = { x = 130, w = 240 },
        [2] = { x = 130, w = 250 },
        [3] = { x = 130, w = 255 }
    },
    [3] = {--普通节点
        [1] = { x = 130, w = 245 },
        [2] = { x = 93, w = 250 },
        [3] = { x = 127, w = 245 }
    }
}

function XUiGridCourse:Ctor(rootUi, ui, stroyUi, nextCb, indexCb)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.StroyUi = stroyUi
    self.NextCallBack = nextCb
    self.IndexCallBack = indexCb
    self.CourseData = nil

    XTool.InitUiObject(self)
    self.RectLine = self.PanelNoPassedLine
    self.BtnClick.CallBack = function() self:OnBtnClickClick() end
end

function XUiGridCourse:Refresh(courseData, lastStageId, nextChapterId)
    self.CourseData = courseData
    self.LastStageId = lastStageId
    self.NextChapterId = nextChapterId

    local stageInfo = XDataCenter.FubenManager.GetStageInfo(courseData.StageId)
    -- local isPassedLineShow = false
    -- local nextStageId = stageInfo.NextStageId
    -- if nextStageId and nextStageId > 0 then
    --     local nextStageInfo = XDataCenter.FubenManager.GetStageInfo(nextStageId)
    --     if nextStageInfo and nextStageInfo.Passed then
    --         isPassedLineShow = true
    --     end
    -- end
    -- local preStageInfo = nil
    
    -- if courseData and #courseData.PreStageId > 0 then
    --     for k, preStageId in pairs(courseData.PreStageId or {}) do
    --         preStageInfo = XDataCenter.FubenManager.GetStageInfo(preStageId)
    --     end
    -- end

    self.PanelNothing.gameObject:SetActive(true)
    self.PanelCurDot.gameObject:SetActive(true)
    self.PanelDot.gameObject:SetActive(false)
    self.PanelReward.gameObject:SetActive(courseData.CouresType == XDataCenter.TaskManager.CourseType.Reward)
    self.PanelDesc.gameObject:SetActive(courseData.CouresType == XDataCenter.TaskManager.CourseType.Function)
    -- self.PanelPassedLine.gameObject:SetActive(isPassedLineShow)
    -- self.PanelNoPassedLine.gameObject:SetActive(courseData.StageId ~= lastStageId)

    if courseData.CouresType == XDataCenter.TaskManager.CourseType.Reward then
        if stageInfo.Passed then
            local canGet = XDataCenter.TaskManager.CheckCourseCanGet(courseData.StageId)
            self.PanelFinish.gameObject:SetActive(not canGet)
            self.PanelEffect.gameObject:SetActive(canGet)
        else
            self.PanelFinish.gameObject:SetActive(false)
            self.PanelEffect.gameObject:SetActive(false)
        end

        local grid = XUiGridCommon.New(self.RootUi, self.GridCommon)
        local data = {
            TemplateId = courseData.ShowId,
            Star = 0
        }
        grid:Refresh(data)
    elseif courseData.CouresType == XDataCenter.TaskManager.CourseType.Function then
        self.PanelPassDesc.gameObject:SetActive(stageInfo.Passed)
        self.PanelNoPassDesc.gameObject:SetActive(not stageInfo.Passed)

        self.TxtDesc.text = courseData.Tip
        self.TxtDescEn.text = courseData.TipEn
        self.TxtNoPassDesc.text = courseData.Tip
        self.TxtNoPassDescEn.text = courseData.TipEn
    end

    self.TxtStage.text = courseData.Name
    self.TxtCurStage.text = courseData.Name
    self.TxtStage.gameObject:SetActive(not stageInfo.Passed)
    self.TxtCurStage.gameObject:SetActive(stageInfo.Passed)
    self.EmptyRaycastClick.raycastTarget = stageInfo.Passed

    self:SetRectLine(courseData.CouresType, courseData.NextCouresType)
end

function XUiGridCourse:SetRectLine(curType, nextType)
    local h = self.RectLine.rect.height
    local y, z = -68, 0
    local potPostion = PotPostion[curType][nextType]
    if potPostion then
        self.RectLine.sizeDelta = CS.UnityEngine.Vector2(potPostion.w, h)
        self.RectLine.localPosition = CS.UnityEngine.Vector3(potPostion.x, y, z)
    end
end

function XUiGridCourse:OnBtnClickClick(...)
    if self.CourseData.CouresType ~= XDataCenter.TaskManager.CourseType.Reward then
        return
    end

    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.CourseData.StageId)

    if stageInfo.Passed then

        local canGet = XDataCenter.TaskManager.CheckCourseCanGet(self.CourseData.StageId)
        if canGet then
            local rewardList = XRewardManager.GetRewardList(self.CourseData.RewardId)
            if rewardList then
                local weaponCount = 0
                local chipCount = 0
                for i = 1, #rewardList do
                    local id = rewardList[i].Id or rewardList[i].TemplateId
                    if XDataCenter.EquipManager.IsClassifyEqualByTemplateId(rewardsId,XEquipConfig.Classify.Weapon) then
                        weaponCount = weaponCount + 1
                    elseif XDataCenter.EquipManager.IsClassifyEqualByTemplateId(rewardsId,XEquipConfig.Classify.Awareness) then
                        chipCount = chipCount + 1
                    end
                end

                if weaponCount > 0 and XDataCenter.EquipManager.CheckBagCount(weaponCount, XEquipConfig.Classify.Weapon) == false or
                chipCount > 0 and XDataCenter.EquipManager.CheckBagCount(chipCount, XEquipConfig.Classify.Awareness) == false then
                    return
                end
            end

            local func = function(allRewardGet)
                if self.LastStageId and self.NextChapterId then
                    local lastStageInfo = XDataCenter.FubenManager.GetStageInfo(self.LastStageId)
                    if allRewardGet and lastStageInfo.Passed then
                        if self.NextCallBack then
                            self.NextCallBack(self.NextChapterId)
                            return
                        end
                    end
                end
                if self.IndexCallBack then self.IndexCallBack() end
                self.PanelFinish.gameObject:SetActive(true)
                self.PanelEffect.gameObject:SetActive(false)
            end
            XDataCenter.TaskManager.GetCourseReward(self.CourseData.StageId, func)
        end
        
    end
end