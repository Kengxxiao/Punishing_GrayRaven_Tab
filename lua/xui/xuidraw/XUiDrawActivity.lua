local XUiDrawActivity = XLuaUiManager.Register(XLuaUi, "UiDrawActivity")
local drawActivityControl = require("XUi/XUiDraw/XUiDrawActivityControl")
local LevelMax = 6
local type = {IN = 1, OUT = 2}
function XUiDrawActivity:OnStart(id, startCb,closeCb, backGround)
    self.CloseCb = closeCb
    self.BackGroundPath = backGround
    if startCb then
        startCb()
    end
    self.PreviewList = {}
    self.GachaId = id
    self.GachaCfg = XDataCenter.GachaManager.GetGachaCfgById(id)
    self.DrawActivityControl = drawActivityControl.New(self, self.GachaCfg, function(info)
            self:UpdateItemCount()
        end, self)
    self.ImgMask.gameObject:SetActiveEx(false)
    self:UpdateInfo()
    self:InitDrawBackGround(self.BackGroundPath)
    self:SetBtnCallBack()
    
    self:InitPanelPreview()
end

function XUiDrawActivity:SetBtnCallBack()
    self.BtnBack.CallBack = function()
        self:OnBtnBackClick()
    end
    self.BtnMainUi.CallBack = function()
        self:OnBtnMainUiClick()
    end
    self.BtnMore.CallBack = function()
        self:OnBtnMore()
    end
    self.BtnUseItem.CallBack = function()
        self:OnBtnUseItemClick()
    end
end

function XUiDrawActivity:OnEnable()
    self.IsReadyForGacha = false
    XUiHelper.SetDelayPopupFirstGet(true)
    self.ImgMask.gameObject:SetActiveEx(true)
    self:PlayAnimation("DrawBegan", function() self.ImgMask.gameObject:SetActiveEx(false) end)
    --self.PlayableDirector = self.BackGround:GetComponent("PlayableDirector")
    
    self.GachaShowLoop = self.BackGround.transform:Find("BoxEffect/Loop")
    if self.GachaShowLoop then
        self.CurLoop = self.GachaShowLoop:LoadPrefab(XUiConfigs.GetComponentUrl("UiGachaLoop"))
        self.CurLoop.gameObject:SetActiveEx(true)
    end
    
    for i=1,LevelMax do
        self.PlayableDirector = XUiHelper.TryGetComponent(self.BackGround.transform, "TimeLine/Level"..i, "PlayableDirector")
        if self.PlayableDirector then
            self.PlayableDirector:Stop()
            self.PlayableDirector:Evaluate() 
        end
    end
    
    self:PlayLoopAnime()
end

function XUiDrawActivity:PlayLoopAnime()
    self.PlayableDirector = XUiHelper.TryGetComponent(self.BackGround.transform, "TimeLine/Loop", "PlayableDirector")
    if self.PlayableDirector then
        self.PlayableDirector.gameObject:SetActiveEx(true)
        self.PlayableDirector:Play()
        self.PlayGachaAnim = true
        local behaviour = self.GameObject:AddComponent(typeof(CS.XLuaBehaviour))
        if self.Update then
            behaviour.LuaUpdate = function() self:Update() end
        end
    end
    
end

function XUiDrawActivity:Update()
    if self.PlayGachaAnim then
        if self.PlayableDirector.time >= self.PlayableDirector.duration - 0.1 then
            if self.IsReadyForGacha then
                self.DrawActivityControl:ShowGacha()
            end
        end
    end
end

function XUiDrawActivity:OnDisable()
    XUiHelper.SetDelayPopupFirstGet()
end

function XUiDrawActivity:OnDestroy()
    if self.CloseCb then
        self.CloseCb()
    end
end

function XUiDrawActivity:OnBtnBackClick(...)
    self:Close()
end

function XUiDrawActivity:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiDrawActivity:OnBtnMore(...)
    self.PanelPreview.gameObject:SetActiveEx(true)
    self:PlayAnimation("PanelPreviewEnable")
end

function XUiDrawActivity:OnBtnUseItemClick(...)
    local data = XDataCenter.ItemManager.GetItem(self.GachaCfg.ConsumeId)
    XLuaUiManager.Open("UiTip", data)
end

function XUiDrawActivity:InitPanelPreview()
    self.AllPreviewPanel = {}
    local tmpGachaInfo = {}
    self.PreviewList[type.IN] = {}
    self.PreviewList[type.OUT] = {}
    self.AllPreviewPanel.Transform = self.PanelPreview.transform
    XTool.InitUiObject(self.AllPreviewPanel)
    self.AllPreviewPanel.BtnPreviewConfirm.CallBack = function()
        self.PanelPreview.gameObject:SetActiveEx(false)
    end
    self.AllPreviewPanel.BtnPreviewClose.CallBack = function()
        self.PanelPreview.gameObject:SetActiveEx(false)
    end
    tmpGachaInfo = XDataCenter.GachaManager.GetGachaInfosById(self.GachaId)
    self:SetPreviewData(tmpGachaInfo,self.AllPreviewPanel.GridDrawActivity, self.AllPreviewPanel.PanelDrawItemSP,self.AllPreviewPanel.PanelDrawItemNA,self.PreviewList[type.IN],type.IN)
    self:SetPreviewData(tmpGachaInfo,self.GridDrawActivity, nil, nil,self.PreviewList[type.OUT],type.OUT)
    
    self.AllPreviewPanel.TxetFuwenben.text = CS.XTextManager.GetText("AlreadyobtainedCount", XDataCenter.GachaManager.GetCurCountOfAll(),XDataCenter.GachaManager.GetMaxCountOfAll())
    self.TxtNumber.text = XDataCenter.GachaManager.GetCurCountOfAll().."/"..XDataCenter.GachaManager.GetMaxCountOfAll()
    
end

function XUiDrawActivity:UpdateInfo()
    local icon = XDataCenter.ItemManager.GetItemBigIcon(self.GachaCfg.ConsumeId)
    self.ImgUseItemIcon:SetRawImage(icon)
    self:UpdateItemCount()
end

function XUiDrawActivity:UpdateItemCount()
    self.TxtUseItemCount.text = XDataCenter.ItemManager.GetItem(self.GachaCfg.ConsumeId).Count
end

function XUiDrawActivity:InitDrawBackGround(backgroundName)
    local root = self:GetSceneRoot().transform
    self.BackGround = root.parent.parent:FindTransform("GroupBase"):LoadPrefab(backgroundName)
    --CS.XShadowHelper.AddShadow(self.BackGround:FindTransform("BoxModeParent").gameObject)
end

function XUiDrawActivity:PushShow(rewardList)
    self:OpenChildUi("UiDrawActivityShow")
    self:FindChildUiObj("UiDrawActivityShow"):SetData(rewardList, function()
            if self.OpenSound then
                self.OpenSound:Stop()
            end
            self:PushResult(rewardList)
            self:UpdateInfo()
        end, self.BackGround)
    if self.CurLoop and not XTool.UObjIsNil(self.CurLoop.gameObject) then
        self.CurLoop.gameObject:SetActiveEx(false)
    end
    self.PlayableDirector:Stop()
end

function XUiDrawActivity:PushResult(rewardList)
    XLuaUiManager.Open("UiDrawResult", nil, rewardList, function() end)
end

function XUiDrawActivity:SetPreviewData(gachaInfo,obj,parentSP,parentNA,previewList,previewType)
    local count = 1
    for k,v in pairs(gachaInfo) do
        local go = nil
        if previewType == type.IN then
            if v.Rare and parentSP then
                go = CS.UnityEngine.Object.Instantiate(obj, parentSP)
            elseif (not v.Rare) and parentNA then
                go = CS.UnityEngine.Object.Instantiate(obj, parentNA)
            end
        else
            if v.Rare then
                go = self["GridDrawActivity"..count]
                count = count + 1
            end
        end
        
        if go then
            local item = XUiGridCommon.New(self, go)
            local tmpData = {}
            previewList[k] = item
            tmpData.TemplateId = v.TemplateId
            tmpData.Count = v.Count
            item:Refresh(tmpData,nil,nil,nil,v.CurCount) 
        end
    end
end

function XUiDrawActivity:UpDataPreviewData()
    local gachaInfo = XDataCenter.GachaManager.GetGachaInfosById(self.GachaId)
    for i = 1,2 do
        for k,v in pairs(self.PreviewList[i] or {}) do
            local tmpData = {}
            tmpData.TemplateId = gachaInfo[k].TemplateId
            tmpData.Count = gachaInfo[k].Count
            v:Refresh(tmpData,nil,nil,nil,gachaInfo[k].CurCount)
        end
    end
    self.AllPreviewPanel.TxetFuwenben.text = CS.XTextManager.GetText("AlreadyobtainedCount", XDataCenter.GachaManager.GetCurCountOfAll(),XDataCenter.GachaManager.GetMaxCountOfAll())
    self.TxtNumber.text = XDataCenter.GachaManager.GetCurCountOfAll().."/"..XDataCenter.GachaManager.GetMaxCountOfAll()
end
