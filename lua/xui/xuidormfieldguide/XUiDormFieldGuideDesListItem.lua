local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local V3O = Vector3.one
local XUiDormFieldGuideDesListItem = XClass()

function XUiDormFieldGuideDesListItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiDormFieldGuideDesListItem:Init(parent)
    self.Parent = parent
end

-- 更新数据
function XUiDormFieldGuideDesListItem:OnRefresh(itemData)
    if not itemData then
        return
    end 
    
    self.TxtDes.text = itemData
end

return XUiDormFieldGuideDesListItem
