local XUiDormNameGridItem = XClass()

function XUiDormNameGridItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiDormNameGridItem:Init(parent)
    self.Parent = parent
end

-- 更新数据
function XUiDormNameGridItem:OnRefresh(itemData)
    if not itemData then
        return
    end
    
    self.TxtName.text = itemData[1]
end

return XUiDormNameGridItem
