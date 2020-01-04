local XUiDormFieldGuideSeleItem = XClass()
local TabState = {
    Normal = 0,
    Press = 1,
    Select = 2,
    Disable = 3,
}

function XUiDormFieldGuideSeleItem:Ctor(ui,uiroot)
    self.PoolObjs = {}
    self.CurObjs = {}
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    self.OnEnterClickCb = function() self:OnClickEnterSetListData() end
    self.UiRoot:RegisterClickEvent(self.Transform,self.OnEnterClickCb)
    self.XUiBtn = self.Transform:GetComponent(typeof(CS.XUiComponent.XUiButton))
end

function XUiDormFieldGuideSeleItem:OnClickEnterSetListData()
    if not self.UiRoot or not self.ItemData then
        return
    end

    self.UiRoot:OnClickEnterSetListData(self.ItemData.Id)
end

-- 更新数据
function XUiDormFieldGuideSeleItem:OnRefresh(itemData)
    if not itemData then
        return
    end
    
    self.ItemData = itemData
    local name = itemData.SuitName or ""
    self.XUiBtn:SetName(name)
end

-- 设置状态
function XUiDormFieldGuideSeleItem:SetState(state)
    if self.CurState ~= state then     
        self.CurState = state  
        if not state then
            self.XUiBtn:SetButtonState(TabState.Select)
        else
            self.XUiBtn:SetButtonState(TabState.Normal)
        end
    end
end

return XUiDormFieldGuideSeleItem