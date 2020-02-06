local XUiGridSuitPrefabEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridSuitPrefabEquip")

local XUiEquipSuitPrefabConflict = XLuaUiManager.Register(XLuaUi, "UiEquipSuitPrefabConflict")

function XUiEquipSuitPrefabConflict:OnAwake()
    self:AutoAddListener()
end

function XUiEquipSuitPrefabConflict:OnStart(conflictInfoList, confirmCb)
    self.ConflictInfoList = conflictInfoList
    self.ConfirmCb = confirmCb
    self:InitGrids()
end

function XUiEquipSuitPrefabConflict:InitGrids()
    self.GridSuitPrefabEquip.gameObject:SetActiveEx(false)
    for _, conflictInfo in pairs(self.ConflictInfoList) do
        local item = CS.UnityEngine.Object.Instantiate(self.GridSuitPrefabEquip)
        local grid = XUiGridSuitPrefabEquip.New(item, self)
        grid:Refresh(conflictInfo)
        grid.GameObject:SetActiveEx(true)
        grid.Transform:SetParent(self.PanelContent.transform, false)
    end
end

function XUiEquipSuitPrefabConflict:AutoAddListener()
    self.BtnClose.CallBack = function() self:Close() end
    self.BtnTanchuangClose.CallBack = function() self:Close() end
    self.BtnNameCancel.CallBack = function() self:Close() end
    self.BtnNameSure.CallBack = function()
        self.ConfirmCb()
        self:Close()
    end
end