local XUiPanelTouch = XClass()

function XUiPanelTouch:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    self.Camera = rootUi.Transform:GetComponent("Canvas").worldCamera
    XTool.InitUiObject(self)
end

function XUiPanelTouch:InitRoomId(curRoomId)
    self.CurRoomId = curRoomId
    self:Hide()
end

function XUiPanelTouch:RefreshTouchState(touchState)
    if touchState == XDormConfig.TouchState.Touch or touchState == XDormConfig.TouchState.TouchHate then
        self.ImgTouch.gameObject:SetActive(true)
        self.ImgWaterGun.gameObject:SetActive(false)
        self.ImgPlay.gameObject:SetActive(false)
    elseif touchState == XDormConfig.TouchState.WaterGun then
        self.ImgTouch.gameObject:SetActive(false)
        self.ImgWaterGun.gameObject:SetActive(true)
        self.ImgPlay.gameObject:SetActive(false)
    elseif touchState == XDormConfig.TouchState.Play then
        self.ImgTouch.gameObject:SetActive(false)
        self.ImgWaterGun.gameObject:SetActive(false)
        self.ImgPlay.gameObject:SetActive(true)
    else
        if self.LastState ~= XDormConfig.TouchState.WaterGun then
            self.ImgTouch.gameObject:SetActive(false)
            self.ImgWaterGun.gameObject:SetActive(false)
            self.ImgPlay.gameObject:SetActive(false)
        end
    end

    self.LastState = touchState
end

function XUiPanelTouch:UpdateTransform(screenPoint)
    if not screenPoint then 
        return
    end

    local screenPointV2 = CS.UnityEngine.Vector2(screenPoint.x, screenPoint.y)
    local hasValue, v2 = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.PanelTouchContainer, screenPointV2, self.Camera)
    
    if hasValue then
        self.Transform.localPosition = CS.UnityEngine.Vector3(v2.x, v2.y, 0)
    end 
end

function XUiPanelTouch:Show(characterId, touchState, screenPoint, propNum)
    if touchState == XDormConfig.TouchState.Hate then
        return 
    end

    if propNum and propNum > 0 and touchState == XDormConfig.TouchState.Touch then
        self.PanelFilled.gameObject:SetActive(true)
        self.ImgFilled.fillAmount = propNum
    else
        self.PanelFilled.gameObject:SetActive(false)
    end

    self.CharacterId = characterId
    self:UpdateTransform(screenPoint)
    self:RefreshTouchState(touchState)
    self.GameObject:SetActive(true)
end

function XUiPanelTouch:Hide()
    self.GameObject:SetActive(false)
end

return XUiPanelTouch