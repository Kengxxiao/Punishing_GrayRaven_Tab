local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local V3O = Vector3.one
local XUiDormWorkMemberListItem = XClass()
local DormManager
local Mathf = math.floor
local MaxVitality = 100
local SelectOne = 1
local SelectStates = {
    Add = 1,
    Reduce = -1
}
local TextManager = CS.XTextManager

function XUiDormWorkMemberListItem:Ctor(ui)
    MaxVitality = XDormConfig.DORM_VITALITY_MAX_VALUE
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    DormManager = XDataCenter.DormManager
    XTool.InitUiObject(self)
end

function XUiDormWorkMemberListItem:Init(uiroot,parent)
    self.UiRoot = uiroot
    self.Parent = parent
end

-- 更新数据
function XUiDormWorkMemberListItem:OnRefresh(itemData)
    if not itemData then
        return
    end

    self.CurStata = false
    self:OnSetState(false)
    self.ItemData = itemData
    local icon = XDormConfig.GetCharacterStyleConfigQIconById(itemData)
    if icon then
        self.ImgIcon:SetRawImage(icon)
    end

    local eventtemp = XHomeCharManager.GetCharacterEvent(itemData,true)
    self.Events.gameObject:SetActiveEx(eventtemp)
    self.Vitality = DormManager.GetVitalityById(self.ItemData) or 0
    self.TxtVitCount.text = TextManager.GetText("DormWorkVitTxt",self.Vitality,MaxVitality)
end

function XUiDormWorkMemberListItem:OnBtnClick()
    self.CurStata = not self.CurStata
    self:OnSetState(self.CurStata)

    local cfg = DormManager.GetWorkCfg()
    if not cfg then
        return
    end

    local vitaly = Mathf(cfg.Vitality / 100)
    
    local money = Mathf(self.Vitality / vitaly)

    if self.CurStata then
        if self.Vitality < 1 or money < 1 then
            self.CurStata = false
            self:OnSetState(false)
            XUiManager.TipText("DormWorkVitNotEn")
            return
        end

        self.TxtTime.text = XUiHelper.GetTime(Mathf(self.Vitality / vitaly) * cfg.Time, XUiHelper.TimeFormatType.HOSTEL)
        self.TxtVit.text = Mathf(self.Vitality / vitaly) * vitaly
        if self.Parent:IsFullMaxWorkCount() then
            XUiManager.TipText("DormWorkTips")
            self.CurStata = false
            self:OnSetState(false)
            return
        end

        self.Parent:UpdataWorkCountAndMoney(SelectOne,money,SelectStates.Add)
        self.Parent:RecordWorkIds(self.ItemData)
    else
        self.Parent:UpdataWorkCountAndMoney(SelectOne,money,SelectStates.Reduce)
        self.Parent:RemoveWorkIds(self.ItemData)
    end
end

function XUiDormWorkMemberListItem:OnSetState(state)
    self.ItemSele.gameObject:SetActive(state)
end

return XUiDormWorkMemberListItem
