local XUiPurchaseLBTipsListItem = XClass()
local TextManager = CS.XTextManager
local PurchaseManager
local LBGetTypeConfig

function XUiPurchaseLBTipsListItem:Ctor(ui)
    PurchaseManager = XDataCenter.PurchaseManager
    LBGetTypeConfig = XPurchaseConfigs.LBGetTypeConfig
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    
end

-- 更新数据
function XUiPurchaseLBTipsListItem:OnRefresh(itemdata)
    if not itemdata then
        return
    end

    self.ItemData = itemdata
    self.GridItemUI:Refresh(itemdata)
end

function XUiPurchaseLBTipsListItem:Init(root)
    self.GridItemUI = XUiGridCommon.New(root,self.GridItem)
end

return XUiPurchaseLBTipsListItem