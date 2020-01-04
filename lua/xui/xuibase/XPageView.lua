XPageView = XClass(XLuaBehaviour)
function XPageView:Ctor(rootUi, pageView, innerContainer, pageValue, dir)
    self.Dir = dir or XScrollConfig.HORIZONTAL
    self.InnerContainer = innerContainer
    self.InnerTransform = innerContainer.transform
    self.InnerGameObject = innerContainer.gameObject
    self.AniCurve = CS.UnityEngine.AnimationCurve.Linear(0, 0, 1, 1)
    self.CurPos = CS.UnityEngine.Vector3(0, 0, 0)
    local pos = self.InnerTransform.anchoredPosition
    self.OriginPos = CS.UnityEngine.Vector3(pos.x, pos.y, 0)
    self.LastValue = 0
    self:RegisterListener()
    self:SetPageWidth(pageValue)
end

function XPageView:SetPageWidth(pageValue)
    if self.Dir == XScrollConfig.HORIZONTAL then
        self.SettedPageWidth = pageValue
        self.SettedPageHeight = nil
    else
        self.SettedPageWidth = nil
        self.SettedPageHeight = pageValue
    end
    self:RefreshSizeData()
end

function XPageView:RefreshSizeData()
    local rect = self.GameObject:GetComponent("RectTransform").rect
    self.Width = rect.width
    self.Height = rect.height
    self.PageWidth = self.SettedPageWidth or rect.width
    self.PageHeight = self.SettedPageHeight or rect.height
    local innerRectTrans = self.InnerGameObject:GetComponent("RectTransform")
    rect = innerRectTrans.rect
    self.InnerWidth = rect.width
    self.InnerHeight = rect.height
    if self.Dir == XScrollConfig.HORIZONTAL then
        self.TotalPage = math.ceil((self.InnerWidth - 20) / self.PageWidth)
        self.InnerWidth = self.TotalPage * self.PageWidth
        self.Reverse = innerRectTrans.pivot.x == 0 and 1 or -1
        self.Offset = innerRectTrans.pivot.x * (self.InnerWidth - self.Width)
    else
        self.TotalPage = math.ceil((self.InnerHeight - 20) / self.PageHeight)
        self.InnerHeight = self.TotalPage * self.PageHeight
        self.Reverse = innerRectTrans.pivot.y == 0 and 1 or -1
        self.Offset = innerRectTrans.pivot.y * (self.InnerHeight - self.Height)
    end
end

function XPageView:RefreshView()
    CS.UnityEngine.Canvas.ForceUpdateCanvases()
    self:RefreshSizeData()
end

function XPageView:ScrollToPage(pageNum, time)
    self.CurAniTime = 0
    pageNum = XMath.Clamp(pageNum, 0, self.TotalPage - 1)
    if self.Dir == XScrollConfig.HORIZONTAL then
        self.LastValue = self.CurPos.x
        local targetP = XMath.Clamp( pageNum * self.PageWidth * self.Reverse, - self.Offset, self.InnerWidth - self.Width - self.Offset)
        self.Offset = targetP - self.CurPos.x
    else
        self.LastValue = self.CurPos.y
        local targetP = XMath.Clamp( pageNum * self.PageHeight * self.Reverse, - self.Offset, self.InnerHeight - self.Height - self.Offset)
        self.Offset = targetP - self.CurPos.y
    end
    self.AniTime = time or 0.2
    self.Anim = self.Offset ~= 0
end

function XPageView:GetTotalPage()
    self:RefreshSizeData()
    return self.TotalPage
end

function XPageView:GetCurPage()
    self:RefreshSizeData()
    local curPage = 0
    if self.Dir == XScrollConfig.HORIZONTAL then
        curPage = math.floor(math.abs(self.CurPos.x) / self.PageWidth)
    else
        curPage = math.floor(math.abs(self.CurPos.y) / self.PageHeight)
    end
    return curPage
end

function XPageView:NextPage(time)
    self:ScrollToPage(self:GetCurPage() + 1, time)
end

function XPageView:PrevPage(time)
    self:ScrollToPage(self:GetCurPage() - 1, time)
end

function XPageView:RegisterListener()
    self.UiWidget = self.GameObject:AddComponent(typeof(CS.XUiWidget))
    self.UiWidget:AddBeginDragListener(function(eventData) 
        self:OnBeginDrag(eventData)
    end)
    self.UiWidget:AddEndDragListener(function(eventData)
        self:OnEndDrag(eventData)
    end)
    self.UiWidget:AddDragListener(function (eventData)
        self:OnDrag(eventData)
    end)
end

function XPageView:OnBeginDrag(eventData)
    self:RefreshSizeData()
    self.StartClickPoint = eventData.position
    self.StartPos = CS.UnityEngine.Vector3( self.CurPos.x, self.CurPos.y, self.CurPos.z )
    self.DeltaPos = CS.UnityEngine.Vector3.zero
    self.Anim = false
    self.IsDrag = true
end

function XPageView:OnDrag(eventData)
    local curPos = eventData.position
    self.DeltaPos = self.StartClickPoint - curPos
    if self.Dir == XScrollConfig.HORIZONTAL then
        self:OnCalcDrag("x", "PageWidth", "InnerWidth", "Width")
    else
        self:OnCalcDrag("y", "PageHeight", "InnerHeight", "Height")
    end
end

function XPageView:OnCalcDrag(axisName, pageWidthName, totalWidthName, widthName)
    local maxPos = self[totalWidthName] - self[widthName] - self.Offset
    local minPos = - self.Offset
    local calcPos = self.StartPos[axisName] + self.DeltaPos[axisName]
    if calcPos < minPos then
        calcPos = minPos - (minPos - calcPos) / 5
    elseif calcPos > maxPos then
        calcPos = maxPos + (calcPos - maxPos) / 5
    end
    self.CurPos[axisName] = calcPos
end

function XPageView:OnCalcEnd(axisName, pageWidthName, totalWidthName, widthName)
    local animTime
    local TargetP = 0
    local checkDis = self[pageWidthName] / 4
    local startLoc = math.floor(self.CurPos[axisName] / self[pageWidthName]) * self[pageWidthName]
    local offset = self.CurPos[axisName] - startLoc
    if offset < checkDis then
        TargetP = XMath.Clamp(startLoc,  - self.Offset, self[totalWidthName] - self[widthName] - self.Offset)
    elseif offset > self[pageWidthName] - checkDis then
        TargetP = XMath.Clamp(startLoc + self[pageWidthName],  - self.Offset, self[totalWidthName] - self[widthName] - self.Offset)
    else
        if self.DeltaPos and self.DeltaPos[axisName] > 0 then
            TargetP = XMath.Clamp(startLoc + self[pageWidthName],  - self.Offset, self[totalWidthName] - self[widthName] - self.Offset)
        else
            TargetP = XMath.Clamp(startLoc,  - self.Offset, self[totalWidthName] - self[widthName])
        end
    end
    self.Offset = TargetP - self.CurPos[axisName]
    self.LastValue = self.CurPos[axisName]
    self.AniTime = XMath.Clamp(math.abs(offset * 2 / self[pageWidthName]), 0, 0.2)
end

function XPageView:OnEndDrag()
    if self.Dir == XScrollConfig.HORIZONTAL then
        self:OnCalcEnd("x", "PageWidth", "InnerWidth", "Width")
    else
        self:OnCalcEnd("y", "PageHeight", "InnerHeight", "Height")
    end
    self.IsDrag = false
    self.CurAniTime = 0
    self.Anim = self.Offset ~= 0    
end

function XPageView:Update()
    if not self.IsDrag and not self.Anim then return end
    if self.Anim then
        self.CurAniTime = self.CurAniTime + CS.UnityEngine.Time.deltaTime
        local value = 0
        if self.AniTime > 0 then
            value = self.AniCurve:Evaluate(self.CurAniTime / self.AniTime)
        else
            value = self.AniCurve:Evaluate(1)
        end
        if self.Dir == XScrollConfig.HORIZONTAL then
            self.CurPos.x = self.LastValue + self.Offset * value
        else
            self.CurPos.y = self.LastValue + self.Offset * value
        end
        if self.CurAniTime >= self.AniTime then
            self.Anim = false
        end
    end
    self.InnerTransform.anchoredPosition = CS.UnityEngine.Vector2(self.OriginPos.x - self.CurPos.x, self.OriginPos.y - self.CurPos.y)
end

function XPageView:Dispose()
    local xLuaBehaviour = self.Transform:GetComponent("XLuaBehaviour")
    if (xLuaBehaviour) then
        CS.UnityEngine.GameObject.Destroy(xLuaBehaviour)
    end

    if (self.UiWidget) then
        CS.UnityEngine.GameObject.Destroy(self.UiWidget)
    end
end