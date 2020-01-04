local XUiDormWorkMemberGridItem = XClass()
local DormWorkTimePerVitality = 0
local DormWorkRewardPerVitality = 0
local Mathf = math.floor
local MaxVitality = 100
local SelectOne = 1
local SelectStates = {
    Add = 1,
    Reduce = -1
}
local DormManager
local TextManager = CS.XTextManager

function XUiDormWorkMemberGridItem:Ctor(ui,uiroot,parent)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    self.Parent = parent
    DormManager = XDataCenter.DormManager
    self.btnClickCb = function()self:OnBtnClick()end
    XTool.InitUiObject(self)
    self.UiRoot:RegisterClickEvent(self.Transform,self.btnClickCb)
end

function XUiDormWorkMemberGridItem:OnBtnClick()
    self.CurStata = not self.CurStata
    self:OnSetState(self.CurStata)

    local cfg = DormManager.GetWorkCfg()
    if not cfg then
        return
    end

    local vitaly = Mathf(cfg.Vitality / 100)

    local money = Mathf(self.Vitality / vitaly)

    if self.CurStata then
        self.TxtTime.text = XUiHelper.GetTime(Mathf(self.Vitality * vitaly / cfg.Time), XUiHelper.TimeFormatType.HOSTEL)
        self.TxtVit.text = Mathf(self.Vitality / vitaly) * cfg.Time * vitaly
        if self.Parent:IsFullMaxWorkCount() then
            XUiManager.TipText("DormWorkTips")
            self.CurStata = false
            self:OnSetState(false)
            return
        end
        self.Parent:UpdataWorkCountAndMoney(SelectOne, money, SelectStates.Add)
        self.Parent:RecordWorkIds(self.ItemData)
    else
        self.Parent:UpdataWorkCountAndMoney(SelectOne, money, SelectStates.Reduce)
        self.Parent:RemoveWorkIds(self.ItemData)
    end
end

-- 更新数据
function XUiDormWorkMemberGridItem:OnRefresh(itemData)
    if not itemData then
        return
    end 
    
    self.CurStata = false
    self:OnSetState(false)
    self.ItemData = itemData
    local icon = DormManager.GetCharSmallHeadIcon(itemData)
    if icon then
        self.UiRoot:SetUiSprite(self.ImgIcon,icon)
    end

    self.Vitality = DormManager.GetVitalityById(self.ItemData) or 0
    
    self.TxtVitCount.text = TextManager.GetText("DormWorkVitTxt",self.Vitality,MaxVitality)
end

function XUiDormWorkMemberGridItem:OnSetState(state)
    self.ImgSele.gameObject:SetActive(state)
    self.ItemSele.gameObject:SetActive(state)
end

return XUiDormWorkMemberGridItem
