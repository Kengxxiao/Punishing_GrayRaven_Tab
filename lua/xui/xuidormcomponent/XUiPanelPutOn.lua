local XUiPanelPutOn = XClass(XLuaBehaviour)

function XUiPanelPutOn:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiPanelPutOn:InitRoomId(curRoomId)
    self.CurRoomId = curRoomId
    self:Hide()
end

function XUiPanelPutOn:PlayAnima()
    self.PanelCountdown.gameObject:SetActive(true)
    self.ImgPutDown.gameObject:SetActive(false)
    self.ImgPutOn.gameObject:SetActive(false)

    self.ImgCountdown.fillAmount = 0
    local time = CS.XGame.ClientConfig:GetFloat("DormPutOnAnimaTime")
    self.AnimaTimer = XUiHelper.Tween(time, function(f)
        if not self.GameObject.activeSelf or XTool.UObjIsNil(self.Transform) then
            return
        end

        self.ImgCountdown.fillAmount = f
    end)
end

function XUiPanelPutOn:UpdateTransform(transform)
    local pos = transform.position + self.Offset
    local viewPos = XHomeDormManager.GetWorldToViewPoint(self.CurRoomId, pos)

    self.Transform.localPosition = viewPos
end

function XUiPanelPutOn:Show(characterId, transform)
    self.CharacterId = characterId
    local styleConfig = XDormConfig.GetCharacterStyleConfigById(characterId)
    self.Offset = CS.UnityEngine.Vector3(0, styleConfig.PutOnWidgetHight, 0) 
    self.TargetTransform = transform
    self:UpdateTransform(self.TargetTransform)

    self.GameObject:SetActive(true)
    self:PlayAnima()
end

function XUiPanelPutOn:Catch()
    self.PanelCountdown.gameObject:SetActive(false)
    self.ImgPutDown.gameObject:SetActive(false)
    self.ImgPutOn.gameObject:SetActive(false)
end

function XUiPanelPutOn:Hide()
    self.PanelCountdown.gameObject:SetActive(false)
    self.ImgPutDown.gameObject:SetActive(false)
    self.ImgPutOn.gameObject:SetActive(false)

    CS.XScheduleManager.ScheduleOnce(function()
        if not self.GameObject.activeSelf or XTool.UObjIsNil(self.Transform) then
            return
        end
        
        self:Close()
    end, 100)
end

function XUiPanelPutOn:Close()
    self.PanelCountdown.gameObject:SetActive(false)
    self.ImgPutDown.gameObject:SetActive(false)
    self.ImgPutOn.gameObject:SetActive(false)

    if self.AnimaTimer ~= nil then
        CS.XScheduleManager.UnSchedule(self.AnimaTimer)
        self.AnimaTimer = nil
    end

    self.TargetTransform = nil
    self.GameObject:SetActive(false)
end

function XUiPanelPutOn:Update()
    if not self.GameObject.activeSelf or XTool.UObjIsNil(self.Transform) then
        return
    end

    if XTool.UObjIsNil(self.TargetTransform) then 
        return
    end
    
    self:UpdateTransform(self.TargetTransform)
end

return XUiPanelPutOn