local XUiDormMainAttItem = XClass()

function XUiDormMainAttItem:Ctor(ui,uiroot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)
end

-- 更新数据
function XUiDormMainAttItem:OnRefresh(itemdata)
    if not itemdata then
        return
    end

    self.Uiroot:SetUiSprite(self.ImgDes,itemdata[1])
    self.TxtNum.text = itemdata[2]
end

return XUiDormMainAttItem