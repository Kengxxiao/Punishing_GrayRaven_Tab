local XUiDormWorkGridItem = require("XUi/XUiDormWork/XUiDormWorkGridItem")
local XUiDormWorkListItem = XClass()

function XUiDormWorkListItem:Ctor(ui)
    self.WordItemStates = {}
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)

end

function XUiDormWorkListItem:CreateItem()
    self.items = {}
    local item0 = XUiDormWorkGridItem.New(self.WordItemState0,self.Parent)
    local item1 = XUiDormWorkGridItem.New(self.WordItemState1,self.Parent)
    local item2 = XUiDormWorkGridItem.New(self.WordItemState2,self.Parent)
    item0.GameObject:SetActive(false)
    item1.GameObject:SetActive(false)
    item2.GameObject:SetActive(false)
    self.items[1] = item0
    self.items[2] = item1
    self.items[3] = item2
end

function XUiDormWorkListItem:Init(parent)
    self.Parent = parent
    self:CreateItem()
end

-- 更新数据
function XUiDormWorkListItem:OnRefresh(itemData,index)
    if not itemData then
        return
    end 

    local count = 0
    for i,v in pairs(itemData) do
        local item = self.items[i]
        if item then
            item.GameObject:SetActive(true)
            item:OnRefresh(v,index + count)
            count = count + 1
        end
    end

    for i=count+1,3 do
        self.items[i].GameObject:SetActive(false)
    end
end

return XUiDormWorkListItem
