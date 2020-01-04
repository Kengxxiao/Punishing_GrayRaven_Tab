local XUiGridGroupName = XClass()

function XUiGridGroupName:Ctor(ui, groupName)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.GroupName = groupName
    XTool.InitUiObject(self)
    self:RefreshNameInfo()
end

function XUiGridGroupName:RefreshNameInfo()
    self.TxtName.text = self.GroupName
end

function XUiGridGroupName:ResetPosition(position)
    self.Transform.position = position
end

return XUiGridGroupName