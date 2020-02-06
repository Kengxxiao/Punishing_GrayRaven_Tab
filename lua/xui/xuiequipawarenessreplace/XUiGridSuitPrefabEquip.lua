local XUiGridEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridEquip")

local XUiGridSuitPrefabEquip = XClass()

function XUiGridSuitPrefabEquip:Ctor(ui, parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    XTool.InitUiObject(self)
end

function XUiGridSuitPrefabEquip:Refresh(conflictInfo)
    self.RImgHead:SetRawImage(XDataCenter.CharacterManager.GetCharRoundnessHeadIcon(conflictInfo.CharacterId))
    local grid = XUiGridEquip.New(self.GridEquip)
    grid:InitRootUi(self.Parent)
    grid:Refresh(conflictInfo.EquipId)
end

return XUiGridSuitPrefabEquip