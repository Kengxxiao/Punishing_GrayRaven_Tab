local XUiEquipStrengthenSkip = XLuaUiManager.Register(XLuaUi, "UiEquipStrengthenSkip")

function XUiEquipStrengthenSkip:OnAwake()
    self:InitAutoScript()
    self.PanelGridSkip.gameObject:SetActive(false)
end

function XUiEquipStrengthenSkip:OnStart(skipIds)
    self.GridPool = {}
    self:Refresh(skipIds)
end

function XUiEquipStrengthenSkip:Refresh(skipIds)
    
    XUiHelper.CreateTemplates(self, self.GridPool, skipIds, XUiGridSkip.New, self.PanelGridSkip, self.PanelContent, function(grid, data)
        grid:Refresh(data)
    end)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiEquipStrengthenSkip:InitAutoScript()
    self:AutoAddListener()
end

function XUiEquipStrengthenSkip:AutoAddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnTanchuangClose, self.OnBtnCloseClick)
end
-- auto
function XUiEquipStrengthenSkip:OnBtnCloseClick(eventData)
    self:Close()
end