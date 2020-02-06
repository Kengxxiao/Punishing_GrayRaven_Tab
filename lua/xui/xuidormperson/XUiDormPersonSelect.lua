local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local V3O = Vector3.one
local XUiDormPersonSelect = XClass()
local XUiDormPersonSelectListItem = require("XUi/XUiDormPerson/XUiDormPersonSelectListItem")
local Next = _G.next
local DormManager
local TextManager
local DormIntakeType
local DormSex

function XUiDormPersonSelect:Ctor(ui,uiroot)
    DormManager = XDataCenter.DormManager
    TextManager = CS.XTextManager
    DormIntakeType = XDormConfig.DormIntakeType
    DormSex = XDormConfig.DormSex
    self.SeleCharactList = {}
    self.SeleDormIdList = {}
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    self.Count = 0
    XTool.InitUiObject(self)
    self:AddListener()
    self:InitList()
end

function XUiDormPersonSelect:InitList()
    self.DynamicSelectTable = XDynamicTableNormal.New(self.PanelSelectList)
    self.DynamicSelectTable:SetProxy(XUiDormPersonSelectListItem)
    self.DynamicSelectTable:SetDelegate(self)
end

function XUiDormPersonSelect:SetList(dormid)
    self.DormId = dormid
    local rawdata = DormManager.GetCharactersSortedCheckInByDormId(dormid)
    self.RawListData = rawdata
    if not rawdata or not Next(rawdata) then
        self.ImgNonePerson.gameObject:SetActive(true)
    else
        self.ImgNonePerson.gameObject:SetActive(false)
    end
    self.ListData = rawdata
    self.DynamicSelectTable:SetDataSource(rawdata)
    self.DynamicSelectTable:ReloadDataASync(1)
    self.DrdSort.value = 0
end

-- [监听动态列表事件]
function XUiDormPersonSelect:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self,self.UiRoot,self.DormId)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.ListData[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        grid:SetSelectState()
    end
end


function XUiDormPersonSelect:PutAndRemoveCharacterResp()
    self.UiRoot:UpdatePersonList()
end

-- 更新选中角色 
function XUiDormPersonSelect:UpdateSeleCharacter(itemData,state)
    if not itemData then
        return
    end

    local characterid = itemData.CharacterId
    local dormid = itemData.DormitoryId
    if state then
        if not self.SeleDormIdList[characterid] and not self.SeleCharactList[characterid] then
            self.Count = self.Count + 1
        end
        self.SeleDormIdList[characterid] = dormid
        self.SeleCharactList[characterid] = characterid
    else
        if self.SeleDormIdList[characterid] and self.SeleCharactList[characterid] then
            self.Count = self.Count - 1
        end
        self.SeleDormIdList[characterid] = nil
        self.SeleCharactList[characterid] = nil
    end

    if self.Count < 0 then
        self.Count = 0
    end

    self.TxtSelectCount.text = string.format( "%s/%s",self.Count,XDormConfig.GetDormPersonCount(self.DormId))
end

function XUiDormPersonSelect:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiDormPersonSelect:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiDormPersonSelect:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiDormPersonSelect:AddListener()
    self:RegisterClickEvent(self.BtnCancel, self.BtnCancelClick)
    self:RegisterClickEvent(self.BtnTanchuangClose, self.BtnCancelClick)
    self:RegisterClickEvent(self.BtnClose, self.BtnCancelClick)
    self:RegisterClickEvent(self.BtnConfirm, self.OnBtnConfirmClick)
    self.PutAndRemoveCharacterRespCb = function() self:PutAndRemoveCharacterResp() end
    self.DrdSort.onValueChanged:AddListener(function()
        self.PriorSortType = self.DrdSort.value
        if self.PrePrior == self.PriorSortType then
            return
        end

        self.PrePrior = self.PriorSortType
        self:RefreshSelectedPanel(self.PriorSortType)
    end)
    self.BtnCancel:SetName(TextManager.GetText("CancelText"))
    self.BtnConfirm:SetName(TextManager.GetText("ConfirmText"))
    self.TxtNonePerson.text = TextManager.GetText("DormNoPerson")
end

function XUiDormPersonSelect:RefreshSelectedPanel(index)
    -- self.Count = 0
    local d = self.RawListData
    if index == DormIntakeType.All then
        -- for _,v in pairs(d)do
        --     if v and v.CharacterId then
        --         if self.SeleCharactList[v.CharacterId] then
        --             self.Count = self.Count + 1 
        --         end
        --     end 
        -- end
        self.ListData = d
        self.DynamicSelectTable:SetDataSource(d)
        self.DynamicSelectTable:ReloadDataASync(1)
        -- self.TxtSelectCount.text = string.format( "%s/%s",self.Count,XDormConfig.GetDormPersonCount(self.DormId))
        return 
    end

    self.ListData = {}
    if index == DormIntakeType.Architecture then
        for _,v in pairs(d)do
            if v and v.CharacterId then
                local t = DormManager.GetDormSex(v.CharacterId) 
                if t == DormSex.Man or t == DormSex.Woman then
                    -- if self.SeleCharactList[v.CharacterId] then
                    --     self.Count = self.Count + 1 
                    -- end
                    table.insert(self.ListData, v)
                end
            end 
        end
    elseif index == DormIntakeType.Infection then
        for _,v in pairs(d)do
            if v and v.CharacterId then
                local t = DormManager.GetDormSex(v.CharacterId) 
                if t == DormSex.Infect then
                    -- if self.SeleCharactList[v.CharacterId] then
                    --     self.Count = self.Count + 1 
                    -- end
                    table.insert(self.ListData, v)
                end
            end 
        end
    end

    self.DynamicSelectTable:SetDataSource(self.ListData)
    self.DynamicSelectTable:ReloadDataASync(1)
    -- self.TxtSelectCount.text = string.format( "%s/%s",self.Count,XDormConfig.GetDormPersonCount(self.DormId))
end

function XUiDormPersonSelect:BtnCancelClick()
    for k,v in pairs(self.ListData) do
        local grid = self.DynamicSelectTable:GetGridByIndex(k)
        if grid then
            grid:SelectState(false)
        end
    end
    
    self.DynamicSelectTable:Clear()
    self.UiRoot:PlayAnimation("SelectDisable")
    self.GameObject:SetActive(false)
end

function XUiDormPersonSelect:GetCurSeleDormId()
    return self.DormId
end

function XUiDormPersonSelect:OnBtnConfirmClick()
    if self.DormId then
        local d0,d1 = self:HandleSeleCharIds()
        if Next(d1) and not Next(d0) then
            DormManager.RequestDormitoryRemoveCharacter(d1,self.PutAndRemoveCharacterRespCb)
        elseif Next(d0) and not Next(d1) then
            DormManager.RequestDormitoryPutCharacter(self.DormId,d0,self.PutAndRemoveCharacterRespCb)
        elseif Next(d0) and Next(d1) then
            DormManager.RequestDormitoryRemoveCharacter(d1,function ()
                DormManager.RequestDormitoryPutCharacter(self.DormId,d0,self.PutAndRemoveCharacterRespCb)
            end)
        end
    end

    self:BtnCancelClick()
end

function XUiDormPersonSelect:HandleSeleCharIds()
    local data0 = {} --放进去的
    local data1 = {} --扔出来的
    local ids = DormManager.GetDormCharactersIds(self.DormId)

    for _,id in pairs(self.SeleCharactList)do
        if not ids[id] then
            if DormManager.CheckCharInDorm(id) then
                table.insert(data1,id)
            end
            table.insert(data0,id)
        end
    end

    for _,id in pairs(ids)do
        if not self.SeleCharactList[id] then
           table.insert(data1,id)
        end
    end

    return data0,data1
end

function XUiDormPersonSelect:GetTotalSeleCharacter()
    local data = {}

    for _,v in pairs(self.SeleCharactList)do
        table.insert(data,v)
    end

    return data
end
return XUiDormPersonSelect