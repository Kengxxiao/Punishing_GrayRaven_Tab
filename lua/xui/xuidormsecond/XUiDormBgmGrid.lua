local XUiDormBgmGrid = XClass()

function XUiDormBgmGrid:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self.GridNameItem.CallBack = function() self:OnBgmSelect() end
end

function XUiDormBgmGrid:Init(parent)
    self.Parent = parent
end

-- 更新数据
function XUiDormBgmGrid:Refresh(index,data)
    if not data then
        return
    end

    self.Data = data
    self.Index = index

    self.TxtNormalName.text = data.Name
    self.TxtPressName.text = data.Name
    self.TxtSelectName.text = data.Name
end

function XUiDormBgmGrid:OnBgmSelect()
    if not self.Parent then
        return
    end

    self:SetSelect(true)
    self.Parent:SelectBgm(self.Index,self.Data)
end


function XUiDormBgmGrid:SetSelect(bSelect)
    local btnState = bSelect and XUiButtonState.Select or XUiButtonState.Normal
    self.GridNameItem:SetButtonState(btnState)
end

return XUiDormBgmGrid
