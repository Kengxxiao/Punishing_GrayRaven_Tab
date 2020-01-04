local XUiPurchaseHKListItem = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local Next = _G.next

function XUiPurchaseHKListItem:Ctor(ui,uiroot)
    PurchaseManager = XDataCenter.PurchaseManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Uiroot = uiroot
    XTool.InitUiObject(self)
end

-- 更新数据
function XUiPurchaseHKListItem:OnRefresh(itemdata)
    if not itemdata then
        return
    end
    self.ItemData = itemdata
end

function XUiPurchaseHKListItem:Init(uiroot,parent)
    self.UiRoot = uiroot
    self.Parent = parent
end

return XUiPurchaseHKListItem