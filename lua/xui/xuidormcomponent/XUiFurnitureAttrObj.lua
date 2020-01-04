local XUiFurnitureAttrObj = XClass(XLuaBehaviour)

function XUiFurnitureAttrObj:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform

    XTool.InitUiObject(self)
end


function XUiFurnitureAttrObj:Show(roomId, furnitureId, transform, text, progress, color,offset)
    self.FurnitureId = furnitureId
    self.TargetTransform = transform
    self.CurRoomId = roomId

    self.ScoreText.text = text
    self.Scrollbar.value = 0
    self.Scrollbar.size = progress
    color = string.sub(color, 2, string.len(color))
    self.Handle.color = XUiHelper.Hexcolor2Color(color)

    self.Offset = offset

end

function XUiFurnitureAttrObj:Hide()
    self.TargetTransform = nil
    self.GameObject:SetActiveEx(false)
end

function XUiFurnitureAttrObj:Update()
    if XTool.UObjIsNil(self.Transform) or not self.GameObject.activeSelf then
        return
    end

    if XTool.UObjIsNil(self.TargetTransform) then
        return
    end

    self:UpdateTransform(self.TargetTransform)
end

function XUiFurnitureAttrObj:UpdateTransform(transform)
    local pos = transform.position + CS.UnityEngine.Vector3(0, self.Offset,0)
    local viewPos = XHomeDormManager.GetWorldToViewPoint(self.CurRoomId, pos)
    self.Transform.localPosition = viewPos
end

return XUiFurnitureAttrObj