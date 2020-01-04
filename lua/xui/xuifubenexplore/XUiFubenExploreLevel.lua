local XUiFubenExploreLevel = XLuaUiManager.Register(XLuaUi, "UiFubenExploreLevel")
function XUiFubenExploreLevel:OnAwake()
    self:AddListener()
end

function XUiFubenExploreLevel:OnStart(chapterId)
    self.ChapterId = chapterId
    self.BannerList = {}
    self.QuickJumpBtnList = {}
    self.BuffList = {}
    self.BuffDetailList = {}
    self.BtnNormalDot.gameObject:SetActive(false)
    self.ExploreBuff.gameObject:SetActive(false)
    self.ExploreBuffDetail.gameObject:SetActive(false)
    self:InitDragPanel()
    self:Init()
    XEventManager.AddEventListener(XEventId.EVENT_FUBEN_EXPLORE_UPDATE, self.Init, self)
    XEventManager.AddEventListener(XEventId.EVENT_FUBEN_EXPLORE_UPDATEBUFF, self.UpdateBuffList, self)
end

function XUiFubenExploreLevel:OnEnable()
    if XDataCenter.FubenExploreManager.GetExploreProgress(self.ChapterId) ~= 1 then
        --选择最近的可打节点去focuse
        self:AutoFocus()
    end
end

function XUiFubenExploreLevel:OnDestroy(chapterId)
    if self.LoadResource then
        self.LoadResource:Release()
    end
    XEventManager.RemoveEventListener(XEventId.EVENT_FUBEN_EXPLORE_UPDATE, self.Init, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_FUBEN_EXPLORE_UPDATEBUFF, self.UpdateBuffList, self)
end

function XUiFubenExploreLevel:AddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnBuff, self.OnBtnBuffClick)
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnReward, self.OnBtnRewardClick)
    self.BtnHelpCourse.CallBack = function()
        self:OnBtnHelpCourseClick()
    end
end

function XUiFubenExploreLevel:OnBtnRewardClick(...)
    local chapterData = XFubenExploreConfigs.GetChapterData(self.ChapterId)
    if XDataCenter.FubenExploreManager.GetChapterData(self.ChapterId) ~= nil
    and XDataCenter.FubenExploreManager.GetChapterData(self.ChapterId).RewardStatus == 1 then
        XUiManager.TipError(CS.XTextManager.GetText("ExploreRewardError"))
    else
        if XDataCenter.FubenExploreManager.GetExploreProgress(self.ChapterId) == 1 then
            XDataCenter.FubenExploreManager.GetChapterReward(self.ChapterId, function() self:CompleteInit() end)
        else
            local data = XRewardManager.GetRewardList(chapterData.RewardId)
            XUiManager.OpenUiTipReward(data, CS.XTextManager.GetText("ExploreRewardTitle"))
        end
    end

end

function XUiFubenExploreLevel:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
    --self.PanelDragArea:EndFocus()
end

function XUiFubenExploreLevel:OnBtnBackClick(...)
    self:Close()
end

function XUiFubenExploreLevel:OnBtnBuffClick(...)
    self.PanelBuffDetail.gameObject:SetActive(true)
    self:PlayAnimation("AnimBuffDetailEnable")
end

function XUiFubenExploreLevel:OnBtnCloseClick(...)
    self.PanelBuffDetail.gameObject:SetActive(false)
end

function XUiFubenExploreLevel:OnBtnHelpCourseClick(...)
    XUiManager.ShowHelpTip("Explore")
end

function XUiFubenExploreLevel:OnQuickJumpClick(nodeInfo)
    self.PanelDragArea:FocusTarget(self:GetNodeObj(nodeInfo), 1, 0.5, CS.UnityEngine.Vector3.zero, function() self:OnLevelNodeClick(nodeInfo) end)
    --self.PanelDragArea:StartFocus(self:GetNodeObj(nodeInfo).transform.position, 1, 0.5, CS.UnityEngine.Vector3.zero, true, function() XLog.Debug("StartFinish!!!!") end)
end

function XUiFubenExploreLevel:InitDragPanel()
    local chapterData = XFubenExploreConfigs.GetChapterData(self.ChapterId)
    local prefabName = string.format(chapterData.ChapterPrefab)
    self.LoadResource = CS.XResourceManager.Load(prefabName);
    self.DragPanel = CS.UnityEngine.Object.Instantiate(self.LoadResource.Asset)
    self.DragPanel.transform:SetParent(self.FullScreenBackground, false)
    self.PanelDragArea = self.DragPanel:GetComponentInChildren(typeof(CS.XDragArea))
    self.LayerLevel = self.PanelDragArea.gameObject.transform:Find("LayerLevel")
end

function XUiFubenExploreLevel:CompleteInit()
    self.PanelFullExplore.gameObject:SetActive(true)
    self:PlayAnimation("AnimFullExploreEnable", function()
        self:PlayAnimation("AnimFullExploreDisable", function()
            self:Close()
        end)
    end)
end

function XUiFubenExploreLevel:Init()
    local chapterData = XFubenExploreConfigs.GetChapterData(self.ChapterId)
    --生成可拖动区域内的所有节点
    --获取这一章表所有的关卡(处理后)
    self.AllNodeList = XDataCenter.FubenExploreManager.GetAllNodeData(self.ChapterId)
    local useNodeList = {}
    for i = 1, #self.AllNodeList do
        if self.AllNodeList[i].State ~= XFubenExploreConfigs.NodeStateEnum.Invisivle then
            table.insert(useNodeList, self.AllNodeList[i])
        end
    end

    for i = 1, #useNodeList do
        if self.BannerList[useNodeList[i].tableData.Id] == nil then
            local tempLevelNodeObj
            if useNodeList[i].tableData.IsBossNode then
                tempLevelNodeObj = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("FubenExploreBossLevel"))
            else
                tempLevelNodeObj = CS.UnityEngine.Object.Instantiate(self.Obj:GetPrefab("FubenExploreLevel"))
            end
            local parentObj = self.LayerLevel.transform:Find(useNodeList[i].tableData.Id)
            parentObj.gameObject:SetActive(true)
            tempLevelNodeObj.transform:SetParent(parentObj, false)
            tempLevelNodeObj.transform:SetAsLastSibling()
            local tempLevelNode = XUiFubenExploreLevelNode.New(tempLevelNodeObj, useNodeList[i], self, function(nodeInfo) self:OnLevelNodeClick(nodeInfo) end)
            self.BannerList[useNodeList[i].tableData.Id] = tempLevelNode
        else
            self.BannerList[useNodeList[i].tableData.Id]:UpdateNode(useNodeList[i])
        end
    end

    --生成所有可到达节点按钮
    self.CanPlayList = {}
    for i = 1, #self.AllNodeList do
        if self.AllNodeList[i].State == XFubenExploreConfigs.NodeStateEnum.Availavle then
            table.insert(self.CanPlayList, self.AllNodeList[i])
        end
    end
    for i = 1, #self.CanPlayList do
        if self.QuickJumpBtnList[i] == nil then
            local tempBtn = CS.UnityEngine.Object.Instantiate(self.BtnNormalDot)
            tempBtn.transform:SetParent(self.PanelNodeList, false)
            tempBtn.gameObject:SetActive(true)
            self.QuickJumpBtnList[i] = XUiFubenExploreQuickJumpBtn.New(tempBtn, self.CanPlayList[i], function(nodeInfo) self:OnQuickJumpClick(nodeInfo) end)
        else
            self.QuickJumpBtnList[i]:UpdateNode(self.CanPlayList[i])
            self.QuickJumpBtnList[i].GameObject:SetActiveEx(true)
        end
    end
    for i = #self.CanPlayList + 1, #self.QuickJumpBtnList do
        self.QuickJumpBtnList[i].GameObject:SetActiveEx(false)
    end

    --更新探索率
    local progress = XDataCenter.FubenExploreManager.GetExploreProgress(self.ChapterId)
    local progressInt = math.floor(progress * 100)
    self.TxtProgress.text = string.format("%d%%", progressInt)
    self.ImgProgress.fillAmount = progress
    self.ImgRedPoint.gameObject:SetActive(XDataCenter.FubenExploreManager.IsChapterRedPoint(self.ChapterId))
    --0未领取，1已领取
    if XDataCenter.FubenExploreManager.GetChapterData(self.ChapterId) ~= nil
    and XDataCenter.FubenExploreManager.GetChapterData(self.ChapterId).RewardStatus == 1 then
        self.ImgComplete.gameObject:SetActive(true)
    else
        self.ImgComplete.gameObject:SetActive(false)
    end
    --更新buff以及章节名
    self.TxtTitle.text = chapterData.Name
    self.TxtChapterId.text = chapterData.Id
    self:UpdateBuffList()

    --为了粒子层正常，更新canvas的order
    self:InitCanvas()
end

function XUiFubenExploreLevel:InitCanvas()
    self.PanelTopareaCanvas.sortingOrder = self.UiFubenExploreLevelCanvas.sortingOrder + 5
    self.PanelTopCenterCanvas.sortingOrder = self.UiFubenExploreLevelCanvas.sortingOrder + 5
    self.PanelBottomLeftCanvas.sortingOrder = self.UiFubenExploreLevelCanvas.sortingOrder + 5
    self.PanelFullExploreCanvas.sortingOrder = self.UiFubenExploreLevelCanvas.sortingOrder + 5
    self.PanelBuffDetailCanvas.sortingOrder = self.UiFubenExploreLevelCanvas.sortingOrder + 5
end

function XUiFubenExploreLevel:AutoFocus()
    if #self.CanPlayList > 0 then
        local nearestNode = self.CanPlayList[1]
        local minDis = CS.UnityEngine.Vector3.Distance(self:GetNodeObj(self.CanPlayList[1]).transform.position, self.DragPanel.gameObject.transform.position)
        for i = 2, #self.CanPlayList do
            local tempDis = CS.UnityEngine.Vector3.Distance(self:GetNodeObj(self.CanPlayList[i]).transform.position, self.DragPanel.gameObject.transform.position)
            if tempDis < minDis then
                nearestNode = self.CanPlayList[i]
                minDis = tempDis
            end
        end
        self.PanelDragArea:FocusTarget(self:GetNodeObj(nearestNode), 1, 0.5, CS.UnityEngine.Vector3.zero)
    end
end

function XUiFubenExploreLevel:UpdateBuffList()
    --小buffIco
    local allBuff = XFubenExploreConfigs.GetChapterBuff(self.ChapterId)
    for i = 1, #allBuff do
        if self.BuffList[i] == nil then
            local tempBuff = CS.UnityEngine.Object.Instantiate(self.ExploreBuff)
            tempBuff.transform:SetParent(self.BtnBuff.transform, false)
            tempBuff.gameObject:SetActive(true)
            self.BuffList[i] = XUiFubenExploreBuff.New(tempBuff, allBuff[i])
        else
            self.BuffList[i]:Update(allBuff[i])
        end
    end

    for i = #allBuff + 1, #self.BuffList do
        self.BuffList[i].GameObject:SetActive(false)
    end
    --大BuffList
    for i = 1, #allBuff do
        if self.BuffDetailList[i] == nil then
            local tempBuff = CS.UnityEngine.Object.Instantiate(self.ExploreBuffDetail)
            tempBuff.transform:SetParent(self.DetailBuffListPanel.transform, false)
            tempBuff.gameObject:SetActive(true)
            self.BuffDetailList[i] = XUiFubenExploreBuffDetail.New(tempBuff, allBuff[i])
        else
            self.BuffDetailList[i]:Update(allBuff[i])
        end
    end

    for i = #allBuff + 1, #self.BuffDetailList do
        self.BuffDetailList[i].GameObject:SetActive(false)
    end
end

function XUiFubenExploreLevel:GetNodeObj(nodeInfo)
    for k, v in pairs(self.BannerList) do
        if v.NodeInfo.tableData.Id == nodeInfo.tableData.Id then
            return v.GameObject.transform
        end
    end
end

function XUiFubenExploreLevel:OnLevelNodeClick(nodeInfo)
    --锁定的点了不能进
    if nodeInfo.State == XFubenExploreConfigs.NodeStateEnum.Visivle then
        local unLockText = ""
        local unLockTextSeparate = CS.XTextManager.GetText("ExploreBuffUnlockSeparate")
        for i = 1, #nodeInfo.tableData.PreOpenId do
            if not XDataCenter.FubenExploreManager.IsNodeFinish(self.ChapterId, nodeInfo.tableData.PreOpenId[i]) then
                local lockNodeInfo = XFubenExploreConfigs.GetLevel(nodeInfo.tableData.PreOpenId[i])
                if i >= 2 then
                    unLockText = unLockText .. unLockTextSeparate .. lockNodeInfo.Name
                else
                    unLockText = lockNodeInfo.Name
                end
            end
        end
        XUiManager.TipError(CS.XTextManager.GetText("ExploreBuffUnlock", unLockText))
        return
    end

    XDataCenter.FubenExploreManager.SetCurNodeId(nodeInfo.tableData.Id)
    --剧情节点
    if nodeInfo.tableData.Type == XFubenExploreConfigs.NodeTypeEnum.Story then
        XLuaUiManager.Open("UiEnterFight", nodeInfo.tableData.Type, nodeInfo.tableData.Title, nodeInfo.tableData.Explain, nodeInfo.tableData.EnterIco, nodeInfo.tableData.RewardId, function()
            CS.Movie.XMovieManager.Instance:PlayById(nodeInfo.tableData.TypeValue, function()
                if not XDataCenter.FubenExploreManager.IsNodeFinish(self.ChapterId, nodeInfo.tableData.Id) then
                    XDataCenter.FubenExploreManager.FinishNode(self.ChapterId, nodeInfo.tableData.Id, function()
                        self:Init()
                        self:AutoFocus()
                    end)
                end
            end)
        end)
    end

    --战斗节点
    if nodeInfo.tableData.Type == XFubenExploreConfigs.NodeTypeEnum.Stage then
        XLuaUiManager.Open("UiEnterFight", nodeInfo.tableData.Type, nodeInfo.tableData.Title, nodeInfo.tableData.Explain, nodeInfo.tableData.EnterIco, nodeInfo.tableData.RewardId, function()
            XLuaUiManager.Open("UiNewRoomSingle", nodeInfo.tableData.TypeValue)
        end)
    end
end