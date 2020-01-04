local XUiHelp = XLuaUiManager.Register(XLuaUi, "UiHelp")
local XUiGridHelpCourse = require("XUi/XUiHelpCourse/XUiGridHelpCourse")

function XUiHelp:OnAwake()

end

function XUiHelp:OnStart(config)
    self.Config = config
    self:RegisterClickEvent(self.BtnMask, self.OnBtnMaskClick)
    self:InitDynamicTable()
end

function XUiHelp:InitDynamicTable()
    self.DynamicTable = XDynamicTableCurve.New(self.PanelHelp.gameObject)
    self.DynamicTable:SetProxy(XUiGridHelpCourse)
    self.DynamicTable:SetDelegate(self)
end

function XUiHelp:OnEnable()
    if not self.Config then
        return
    end
    self.Icons = self.Config.ImageAsset
    self.Length = #self.Icons
    self.DynamicTable:SetDataSource(self.Config.ImageAsset)
    self.DynamicTable:ReloadData()
end

--动态列表事件
function XUiHelp:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        --  grid:SetRootUi(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:Refresh(self.Icons[index + 1], index + 1, self.Length)
    end
end

function XUiHelp:OnBtnMaskClick()
    self:Close()
end