local XUiPurchaseYKListItem = XClass()
local TextManager = CS.XTextManager
local PurchaseManager

function XUiPurchaseYKListItem:Ctor(ui,uiroot)
    PurchaseManager = XDataCenter.PurchaseManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)
end

-- 更新数据
function XUiPurchaseYKListItem:OnRefresh(itemdata)
    if not itemdata then
        return
    end
    self.ItemData = itemdata
end

function XUiPurchaseYKListItem:Init(uiroot,parent)
    self.UiRoot = uiroot
    self.Parent = parent
end

return XUiPurchaseYKListItem