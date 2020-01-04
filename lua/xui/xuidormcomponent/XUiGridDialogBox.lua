local XUiGridDialogBox = XClass(XLuaBehaviour)

function XUiGridDialogBox:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end

function XUiGridDialogBox:RefreshContext(contextId)
    self.DailogConfig = XDormConfig.GetCharacterDialogConfig(contextId)
    if not self.DailogConfig or #self.DailogConfig.Content <= 0 then
        return
    end

    self:PlayDialog(1)
end

function XUiGridDialogBox:PlayDialog(index)
    -- 播放完对话
    if index > #self.DailogConfig.Content then
        if self.Cb then
            self.Cb()
        end
        return
    end

    local context = self.DailogConfig.Content[index] or ""
    if XDataCenter.DormManager.CheckInTouch() then
        self.TxtTouchDesc.text = string.gsub(context, "\\n", "\n")
    else
        self.TxtDesc.text = string.gsub(context, "\\n", "\n")
    end
    local time = self.DailogConfig.Time[index] or 0

    CS.XScheduleManager.ScheduleOnce(function()
        if XTool.UObjIsNil(self.Transform) or not self.GameObject.activeSelf then
            return
        end

        index = index + 1
        self:PlayDialog(index)
    end, time)
end

function XUiGridDialogBox:UpdateTransform(transform)
    local pos = transform.position + self.Offset
    local viewPos = XHomeDormManager.GetWorldToViewPoint(self.CurRoomId, pos)
    self.Transform.localPosition = viewPos
end

function XUiGridDialogBox:Show(curRoomId, characterId, contextId, transform, cb)
    self.CurRoomId = curRoomId
    self.Cb = cb

    self.TargetTransform = transform

    local styleConfig = XDormConfig.GetCharacterStyleConfigById(characterId)
    if XDataCenter.DormManager.CheckInTouch() then
        self.PanelBoxNamorl.gameObject:SetActive(false)
        self.PanelBoxTouch.gameObject:SetActive(true)
        self.Offset = CS.UnityEngine.Vector3(0, styleConfig.DailogTouchHight, 0)
    else
        self.PanelBoxNamorl.gameObject:SetActive(true)
        self.PanelBoxTouch.gameObject:SetActive(false)
        self.Offset = CS.UnityEngine.Vector3(0, styleConfig.DailogWidgetHight, 0)
    end

    self:RefreshContext(contextId)
    self:UpdateTransform(self.TargetTransform)
    self.GameObject:SetActive(true)
end

function XUiGridDialogBox:Hide()
    self.TargetTransform = nil
    self.GameObject:SetActive(false)
end

function XUiGridDialogBox:Update()
    if XTool.UObjIsNil(self.Transform) or not self.GameObject.activeSelf then
        return
    end

    if XTool.UObjIsNil(self.TargetTransform) then
        return
    end

    self:UpdateTransform(self.TargetTransform)
end

return XUiGridDialogBox