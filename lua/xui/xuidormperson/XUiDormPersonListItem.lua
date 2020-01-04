local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local V3O = Vector3.one
local XUiDormPersonSingleItem = require("XUi/XUiDormPerson/XUiDormPersonSingleItem")
local XUiDormPersonListItem = XClass()
local Next = _G.next
local DormPersonMaxCount = 3
local DormManager

function XUiDormPersonListItem:Ctor(ui)
    self.PoolObjs = {}
    self.CurObjs = {}
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    DormManager = XDataCenter.DormManager
    XTool.InitUiObject(self)
end

function XUiDormPersonListItem:Init(uiroot)
    self.UiRoot = uiroot
end

-- 更新数据
function XUiDormPersonListItem:OnRefresh(itemData,curDormId)
    if not itemData then
        return
    end

    self.ItemData = itemData
    if curDormId ~= itemData.DormitoryId then
        self.PanelName.gameObject:SetActive(true)
        self.TxtName.text = itemData.DormitoryName
        self.PanelNameAtPresent.gameObject:SetActive(false)
    else
        self.PanelName.gameObject:SetActive(false)
        self.TxtNameAtPresent.text = itemData.DormitoryName
        self.PanelNameAtPresent.gameObject:SetActive(true)
    end

    self.CharacterIds = XTool.Clone(itemData.CharacterIdList or {})

    local len = #self.CharacterIds
    for i=1,DormPersonMaxCount-len do
        table.insert(self.CharacterIds,-1)
    end

    local index = 0
    for k,v in ipairs(self.CharacterIds) do
        if not self.CurObjs[k] then
            local item = self:GetItem(index)
            self.CurObjs[k] = item
        end
        index = index + 1
        self.CurObjs[k]:SetState(true)
        self.CurObjs[k]:OnRefresh(v,itemData.DormitoryId)
    end

    if self.PreLen and self.PreLen > index then
        for i = index+1,self.PreLen do
            self:RecycleItem(table.remove(self.CurObjs))
        end
    end
    self.PreLen = index
end

function XUiDormPersonListItem:GetItem(index)
    if #self.PoolObjs>0 then
        return table.remove(self.PoolObjs)
    end
    
    local obj = Object.Instantiate(self.PersonSingleItem)
    obj.transform:SetParent(self.PersonList,false)
    obj.transform.localScale = V3O
    obj.gameObject.name = index
    local item = XUiDormPersonSingleItem.New(obj,self.UiRoot)
    item:SetState(true)
    return item
end

function XUiDormPersonListItem:RecycleItem(item)
    if not item then 
        return 
    end
    
    item:SetState(false)
    table.insert(self.PoolObjs,item)
end

return XUiDormPersonListItem
