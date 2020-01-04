XUiPanelActivityAsset = XClass()

function XUiPanelActivityAsset:Ctor(ui, deleteDes)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.DeleteDes = deleteDes
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelActivityAsset:InitAutoScript()
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiPanelActivityAsset:AutoAddListener()
    self.BtnClick1.CallBack = function()
        self:OnBtnClick1Click()
    end
    self.BtnClick2.CallBack = function()
        self:OnBtnClick2Click()
    end
    self.BtnClick3.CallBack = function()
        self:OnBtnClick3Click()
    end
end
-- auto
function XUiPanelActivityAsset:OnBtnClick1Click(...)
    self:OnBtnClick(1)
end

function XUiPanelActivityAsset:OnBtnClick2Click(...)
    self:OnBtnClick(2)
end

function XUiPanelActivityAsset:OnBtnClick3Click(...)
    self:OnBtnClick(3)
end

function XUiPanelActivityAsset:OnBtnClick(index)
    if not self.ItemIds or not self.ItemIds[index] then
        return
    end
    local item = XDataCenter.ItemManager.GetItem(self.ItemIds[index])
    local data = {
        Id = self.ItemIds[index],
        Count = item ~= nil and tostring(item.Count) or "0"
    }
    XLuaUiManager.Open("UiTip", data)
end

function XUiPanelActivityAsset:HidePanel()
    self.GameObject:SetActive(false)
end

function XUiPanelActivityAsset:Refresh(idlist)
    --读取数据  
    if idlist == nil then
        self.GameObject:SetActive(false)
        return
    end
    self.ItemIds = idlist
    self.GameObject:SetActive(true)
    for i = 1, 3 do
        if i > #self.ItemIds then
            self["PanelSpecialTool" .. i].gameObject:SetActive(false)
        else
            self["PanelSpecialTool" .. i].gameObject:SetActive(true)
        end
    end
    
    self.PanelSpecialTool.gameObject:SetActive(self.PanelSpecialTool3.gameObject.activeSelf or self.PanelSpecialTool2.gameObject.activeSelf or self.PanelSpecialTool1.gameObject.activeSelf)
    
    local items = {}
    for _, id in pairs(self.ItemIds) do
        table.insert(items, XDataCenter.ItemManager.GetItem(id))
    end
    
    for i = 1, #items do
        local item = items[i]
        local count = item ~= nil and tostring(item.Count) or "0"
        self["PanelSpecialTool" .. i].gameObject:SetActive(true)
        self["TxtSpecialTool" .. i].text = not self.DeleteDes and CS.XTextManager.GetText("ShopActivityItemCount", count) or count
        if items[i].Template.ItemType == 2 then
            self["TxtSpecialTool" .. i].text = count .. "/" .. XDataCenter.ItemManager.GetMaxActionPoints()
        end
        
        local rImgSpecialTool = self["RImgSpecialTool" .. i]
        if rImgSpecialTool and rImgSpecialTool:Exist() then
            rImgSpecialTool:SetRawImage(items[i].Template.Icon)
        end
    end
end

