local XUiGridRecommendationItem = XClass()

function XUiGridRecommendationItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridRecommendationItem:Init(uiRoot)
    self.UiRoot = uiRoot
end

-- 更新数据
function XUiGridRecommendationItem:OnRefresh(itemdata)
    if not itemdata then
        return
    end

    self.ItemData = itemdata
    self:SetData()
end

return XUiGridRecommendationItem