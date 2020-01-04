local XUiDormWorkMemberListItem = require("XUi/XUiDormWork/XUiDormWorkMemberListItem")
local XUiDormWorkMember = XClass()
local LineCount = 3
local Next = _G.next
local Math = math
local DormWorkMaxCount = 0
local DormManager
local TextManager = CS.XTextManager

function XUiDormWorkMember:Ctor(ui,uiroot)
    DormManager = XDataCenter.DormManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    self.CurWorkCount = 0
    self.RawWorkCount = 0
    self.CurWorkMoney = 0
    self.CurSeleWorkCharIds = {}
    XTool.InitUiObject(self)
    self:Init()
end

function XUiDormWorkMember:InitMaxCount()
    DormWorkMaxCount = 0
    local data = DormManager.GetWorkCfg()

    if data then
        DormWorkMaxCount = data.Seat or 0
    end
end

function XUiDormWorkMember:InitList()
    self.DynamicTable = XDynamicTableNormal.New(self.MemberList)
    self.DynamicTable:SetProxy(XUiDormWorkMemberListItem)
    self.DynamicTable:SetDelegate(self)
end

-- [监听动态列表事件]
function XUiDormWorkMember:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot,self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        grid:OnBtnClick()
    end
end

function XUiDormWorkMember:RecordWorkIds(characterid)
    self.CurSeleWorkCharIds[characterid] = characterid
end

function XUiDormWorkMember:RemoveWorkIds(characterid)
    self.CurSeleWorkCharIds[characterid] = nil
end

function XUiDormWorkMember:OnBtnStartWorkClick()
    local emptypos = self:GetEmptyWorkPosList()

    if Next(emptypos) == nil then
        return
    end

    local dormworklist = {}
    for _,id in pairs(self.CurSeleWorkCharIds)do
        local itemdata = {}
        itemdata.CharacterId = id
        itemdata.WorkPos = table.remove(emptypos)
        table.insert(dormworklist,itemdata)
    end
    if Next(dormworklist) == nil then
        if Next(self.ListData) ~= nil then
           XUiManager.TipText("DormWorkNoPerson", XUiManager.UiTipType.Wrong)
        else
            XUiManager.TipText("DormWorkNoPerson1", XUiManager.UiTipType.Wrong)
        end
        return
    end

    DormManager.RequestDormitoryWork(dormworklist,self.OnWorkListUpdata)
    self.CurSeleWorkCharIds = {}
    self.GameObject:SetActive(false)
end

-- 返回当前所有空的工位
function XUiDormWorkMember:GetEmptyWorkPosList()
    local emptypos = {}
    local poslist = DormManager.GetDormWorkPosData()
    for index=DormWorkMaxCount,1,-1 do
        local pos = poslist[index]
        if not pos then
            table.insert(emptypos,index)
        end
    end
    return emptypos
end

function XUiDormWorkMember:OnBtnBgClick()
    self:ClearListData()
    self.UiRoot:PlayAnimation("MemberDisable")
    self.GameObject:SetActive(false)
end

function XUiDormWorkMember:ClearListData()
    self.ListData = {}
    self.CurSeleWorkCharIds = {}
    self.DynamicTable:Clear()
end
function XUiDormWorkMember:Init()
    self:InitList()
    self:InitMaxCount()
    self.OnBtnBgClickCb = function() self:OnBtnBgClick() end
    self.OnBtnStartWorkClickCb = function() self:OnBtnStartWorkClick() end
    self.OnWorkListUpdata = function() self.UiRoot:UpdataWorkList() end
    -- self.OnWorkListUpdata = function() self.UiRoot:SetListData() end
    self.BtnCancel.CallBack = self.OnBtnBgClickCb
    self.BtnTanchuangClose.CallBack = self.OnBtnBgClickCb
    self.BtnStartWork.CallBack = self.OnBtnStartWorkClickCb
    self.XUiBtnCancel = self.BtnCancel:GetComponent("XUiButton")
    self.XUiBtnStartWork = self.BtnStartWork:GetComponent("XUiButton")
    self.XUiBtnCancel:SetName(TextManager.GetText("CancelText"))
    self.XUiBtnStartWork:SetName(TextManager.GetText("DormWorkStart"))
    self.TxtNonePerson.text = TextManager.GetText("DormWorkNoPerson1")
end

-- 更新数据
function XUiDormWorkMember:OnRefresh(count)
    self.RawWorkCount = count
    self.CurWorkCount = count
    self.CurWorkMoney = 0
    local data = DormManager.GetDormNotWorkData()
    self.ListData = data
    if not data or not Next(data) then
        self.ImgNonePerson.gameObject:SetActive(true)
    else
        self.ImgNonePerson.gameObject:SetActive(false)
    end
    self.DynamicTable:SetDataSource(data)
    self.DynamicTable:ReloadDataASync(1)
    self.TxtWorkCount.text = TextManager.GetText("DormWorkSeleCount", self.RawWorkCount, DormWorkMaxCount)
    self.TxtMoneyCount.text = 0
    self.UiRoot:PlayAnimation("MemberEnable")
end

-- 更新工位数量和产出
function XUiDormWorkMember:UpdataWorkCountAndMoney(count,money,flage)
    self.CurWorkCount = self.CurWorkCount + count*flage
    if self.CurWorkCount < self.RawWorkCount then
        self.CurWorkCount = self.RawWorkCount
    end

    self.CurWorkMoney = self.CurWorkMoney + money*flage
    self.TxtWorkCount.text = TextManager.GetText("DormWorkSeleCount", self.CurWorkCount, DormWorkMaxCount)
    self.TxtMoneyCount.text = self.CurWorkMoney
end

function XUiDormWorkMember:IsFullMaxWorkCount()
    return self.CurWorkCount >= DormWorkMaxCount
end

return XUiDormWorkMember
