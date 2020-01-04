local XUiDormVisitTypeListItem = XClass()
local TabState = {
    Normal = 0,
    Press = 1,
    Select = 2,
    Disable = 3,
}
function XUiDormVisitTypeListItem:Ctor(ui)
    self.PoolObjs = {}
    self.CurObjs = {}
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.XUiBtn = self.Transform:GetComponent(typeof(CS.XUiComponent.XUiButton))
end

function XUiDormVisitTypeListItem:Init(ui,uiroot)
    self.Parent = ui
    self.UiRoot = uiroot
end

-- 更新数据
function XUiDormVisitTypeListItem:OnRefresh(itemData)
    if not itemData then
        return
    end

    self.XUiBtn:SetName(itemData)
end

-- 设置状态
function XUiDormVisitTypeListItem:SetState(state)
    if self.CurState ~= state then     
        self.CurState = state
        if not state then
            self.XUiBtn:SetButtonState(TabState.Select)
        else
            self.XUiBtn:SetButtonState(TabState.Normal)
        end
    end
end
return XUiDormVisitTypeListItem
