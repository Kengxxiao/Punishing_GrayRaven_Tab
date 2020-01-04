local CLOSE_TIME = 2

local XUiGridEquipReplaceAttr = require("XUi/XUiEquipReplaceNew/XUiGridEquipReplaceAttr")

local XUiEquipBreakThroughPopUp = XLuaUiManager.Register(XLuaUi, "UiEquipBreakThroughPopUp")

function XUiEquipBreakThroughPopUp:OnAwake()
    self.GridEquipReplaceAttr.gameObject:SetActive(false)
end

function XUiEquipBreakThroughPopUp:OnStart(nextLevel, curAttrMap, preAttrMap, closeCb)
    self.NextLevel = nextLevel
    self.CurAttrMap = curAttrMap
    self.PreAttrMap = preAttrMap
    self.CloseCb = closeCb
    self.BtnClose.CallBack = function ()
        self:Close()
    end
end

function XUiEquipBreakThroughPopUp:OnEnable()
    self:InitEquipPreInfo()
    self:AddCloseTimer()
end

function XUiEquipBreakThroughPopUp:OnDestroy()
    self:ClearCloseTimer()
    if self.CloseCb then self.CloseCb() end
end

function XUiEquipBreakThroughPopUp:InitEquipPreInfo()
    self.TxtNextLevel.text = self.NextLevel

    self.AttrGridList = {}
    for attrIndex, attrInfo in pairs(self.CurAttrMap) do
        local ui = CS.UnityEngine.Object.Instantiate(self.GridEquipReplaceAttr)
        self.AttrGridList[attrIndex] = XUiGridEquipReplaceAttr.New(ui, CS.XTextManager.GetText("EquipBreakThroughPopUpAttrPrefix", attrInfo.Name))
        self.AttrGridList[attrIndex].Transform:SetParent(self.PanelAttrParent, false)
        self.AttrGridList[attrIndex].GameObject:SetActive(true)
        self.AttrGridList[attrIndex]:UpdateData(attrInfo.Value, self.PreAttrMap[attrIndex].Value)
    end
end

function XUiEquipBreakThroughPopUp:AddCloseTimer()
    self:ClearCloseTimer()
    local time = 0
    local function action()
        time = time + 1
        if time == CLOSE_TIME then
            self:Close()
        end
    end
    self.Timer = CS.XScheduleManager.Schedule(action, CS.XScheduleManager.SECOND, CLOSE_TIME, 0)
end

function XUiEquipBreakThroughPopUp:ClearCloseTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end
