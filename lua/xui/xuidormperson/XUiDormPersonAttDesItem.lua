local XUiDormPersonAttDesItem = XClass()
local TextManager = CS.XTextManager

function XUiDormPersonAttDesItem:Ctor(ui,uiroot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)
end

-- 更新数据
function XUiDormPersonAttDesItem:OnRefresh(txt,icon)
    self.TxtDes.text = txt
    if not icon or not self.Uiroot then
        return
    end

    self.Uiroot:SetUiSprite(self.ImgDes,icon)
end

function XUiDormPersonAttDesItem:SetState(state)
    if not self.GameObject then 
        return
    end

    self.GameObject:SetActive(state)
end

return XUiDormPersonAttDesItem