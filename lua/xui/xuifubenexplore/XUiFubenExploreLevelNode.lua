XUiFubenExploreLevelNode = XClass()
function XUiFubenExploreLevelNode:Ctor(ui, nodeInfo, rootUi, cb)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.NodeInfo = nodeInfo
    self.ShowDetail = false
    local behaviour = self.Transform.gameObject:AddComponent(typeof(CS.XLuaBehaviour))
    if self.Update then
        behaviour.LuaUpdate = function() self:Update() end
    end
    self.ShowDetailMinScale = CS.XGame.ClientConfig:GetFloat("ExploreShowDetailMinScale")
    self.DetailFadeTime = CS.XGame.ClientConfig:GetFloat("ExploreDetailFadeTime")
    self.Cb = cb
    XTool.InitUiObject(self)
    self.BtnNode.CallBack = function() self:OnBtnNodeClick() end
    self:UpdateNode()
end

function XUiFubenExploreLevelNode:OnBtnNodeClick(...)
    self.Cb(self.NodeInfo)
end

function XUiFubenExploreLevelNode:UpdateNode(nodeInfo)
    if nodeInfo ~= nil then
        self.NodeInfo = nodeInfo
    end
    --初始默认值
    self.ImgKeyNode.gameObject:SetActive(false)
    self.PanelStrory.gameObject:SetActive(false)
    self.RImgNodeIco.gameObject:SetActive(false)
    self.PanelComplete.gameObject:SetActive(false)
    self.PanelLock.gameObject:SetActive(false)
    self.PanelReward.gameObject:SetActive(false)
    self.PanelSelect.gameObject:SetActive(false)
    --关键关卡（右上角标识）
    if self.NodeInfo.tableData.IsKeyNode then
        self.ImgKeyNode.gameObject:SetActive(true)
    end
    --关卡类型
    if self.NodeInfo.tableData.Type == XFubenExploreConfigs.NodeTypeEnum.Story then
        self.PanelStrory.gameObject:SetActive(true)
    elseif self.NodeInfo.tableData.Type == XFubenExploreConfigs.NodeTypeEnum.Battle then
        self.RImgNodeIco.gameObject:SetActive(true)
    end
    --状态
    if self.NodeInfo.State == XFubenExploreConfigs.NodeStateEnum.Complete then
        self.PanelComplete.gameObject:SetActive(true)
        self.RImgNodeIco.gameObject:SetActive(true)
    elseif self.NodeInfo.State == XFubenExploreConfigs.NodeStateEnum.Visivle then
        self.PanelLock.gameObject:SetActive(true)
        self.RImgNodeIco.gameObject:SetActive(true)
    elseif self.NodeInfo.State == XFubenExploreConfigs.NodeStateEnum.Availavle then
        self.RImgNodeIco.gameObject:SetActive(true)
        self.PanelSelect.gameObject:SetActive(true)
    end
    --战利品
    if self.NodeInfo.tableData.RewardId > 0 then
        self.PanelReward.gameObject:SetActive(true)
        self.RImgRewardIco:SetRawImage(self.NodeInfo.tableData.RewardIcon)
    end
    --背景图片
    self.RImgNodeIco:SetRawImage(self.NodeInfo.tableData.Icon)
    --头像
    self.RImgRole:SetRawImage(self.NodeInfo.tableData.CharacterIcon)
    --关卡名
    self.TxtLevelID.text = self.NodeInfo.tableData.Name
    --时间
    self.TxtLevelTime.text = self.NodeInfo.tableData.TimeDesc
end

function XUiFubenExploreLevelNode:Update()
    local curScale = self.RootUi.PanelDragArea.gameObject.transform.localScale.x
    if curScale > self.ShowDetailMinScale and not self.ShowDetail then
        self.ShowDetail = true
        if self.TweenFade ~= nil then
            self.TweenFade:Kill()
        end
        self.TweenFade = self.PanelHideCanvasGroup:DOFade(1, self.DetailFadeTime)
    elseif curScale < self.ShowDetailMinScale and self.ShowDetail then
        self.ShowDetail = false
        if self.TweenFade ~= nil then
            self.TweenFade:Kill()
        end
        self.TweenFade = self.PanelHideCanvasGroup:DOFade(0, self.DetailFadeTime)
    end
end