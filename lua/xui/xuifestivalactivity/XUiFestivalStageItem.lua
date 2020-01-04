XUiFestivalStageItem = XClass()

function XUiFestivalStageItem:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
end

function XUiFestivalStageItem:SetNormalStage(stageId, stageIndex, stagePrefix)
    self.PanelStageNormal.gameObject:SetActiveEx(not self.IsLock)
    if not self.IsLock then
        local stageCfg = XDataCenter.FubenManager.GetStageCfg(stageId)
        self.RImgFightActiveNor:SetRawImage(stageCfg.Icon)
        self.TxtStageOrder.text = string.format("%s%d",stagePrefix, stageIndex)
    end
end

function XUiFestivalStageItem:SetLockStage(stageId, stageIndex, stagePrefix)
    self.PanelStageLock.gameObject:SetActiveEx(self.IsLock)
    if self.IsLock then
        self.TxtStageOrder.text = string.format("%s%d",stagePrefix, stageIndex)
    end
end

function XUiFestivalStageItem:SetPassStage(stageInfo)
    self.PanelStagePass.gameObject:SetActiveEx(stageInfo.Passed)
end

function XUiFestivalStageItem:UpdateNode(festivalId, stageId)
    self.FestivalId = festivalId
    self.StageId = stageId
    self.StageIndex = XDataCenter.FubenFestivalActivityManager.GetStageIndex(self.FestivalId, self.StageId)
    local festivalTemplate = XFestivalActivityConfig.GetFestivalById(self.FestivalId)
    local stageCfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    local stageInfo = XDataCenter.FubenManager.GetStageInfo(self.StageId)
    self.PrefabType = XDataCenter.FubenFestivalActivityManager.GetStageShowType(self.StageId)
    local stagePrefabName = (self.PrefabType == XDataCenter.FubenFestivalActivityManager.StageFuben) and festivalTemplate.GridFubenPrefab or festivalTemplate.GridStoryPrefab
    
    local isOpen, description = XDataCenter.FubenFestivalActivityManager.CheckFestivalStageOpen(stageId)
    self.GameObject:SetActiveEx(isOpen)
    local gridGameObject = self.Transform:LoadPrefab(stagePrefabName)
    local uiObj = gridGameObject.transform:GetComponent("UiObject")
    for i = 0, uiObj.NameList.Count - 1 do
        self[uiObj.NameList[i]] = uiObj.ObjList[i]
    end
    self.BtnStage.CallBack = function() self:OnBtnStageClick() end
    
    self.IsLock = not isOpen
    self.Description = description

    self:SetNormalStage(self.StageId, self.StageIndex, festivalTemplate.StagePrefix)
    self:SetLockStage(self.StageId, self.StageIndex, festivalTemplate.StagePrefix)
    self:SetPassStage(stageInfo)

    local isEgg = XDataCenter.FubenFestivalActivityManager.IsEgg(self.StageId)
    self.ImgStageOrder.gameObject:SetActiveEx(not isEgg)
    self.ImgStageHide.gameObject:SetActiveEx(isEgg)
    if self.ImgHideLine then
        self.ImgHideLine.gameObject:SetActiveEx(isEgg)
    end

end

function XUiFestivalStageItem:OnBtnStageClick()
    if self.StageId and self.FestivalId then
        if not self.IsLock then
            self.RootUi:UpdateNodesSelect(self.StageId)
            -- 打开详细界面
            self.RootUi:OpenStageDetails(self.StageId, self.FestivalId)
            self.RootUi:PlayScrollViewMove(self.Transform)
        else
            XUiManager.TipMsg(self.Description)
        end

    end
end

function XUiFestivalStageItem:SetNodeSelect(isSelect)
    if not self.IsLock then
        self.ImageSelected.gameObject:SetActiveEx(isSelect)
    end
end

function XUiFestivalStageItem:ResetItemPosition(upposition)
    if self.ImgHideLine then
        local rect = self.ImgHideLine:GetComponent("RectTransform").rect
        self.Transform.localPosition = CS.UnityEngine.Vector3(upposition.x, upposition.y - rect.height, upposition.z)
    end
end

return XUiFestivalStageItem