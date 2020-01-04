local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local V3O = Vector3.one
local XUiDormPersonSelectListItem = XClass()
local TextManager = CS.XTextManager
local DormManager
local XUiDormPersonAttDesItem = require("XUi/XUiDormPerson/XUiDormPersonAttDesItem")

function XUiDormPersonSelectListItem:Ctor(ui)
    DormManager = XDataCenter.DormManager
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.PreSeleState = false
    self.BtnClickCb = function()self:OnBtnClick()end
    self.Lovetxt = TextManager.GetText("DormLove") or ""
    self.Liketxt = TextManager.GetText("DormLike") or ""
    XTool.InitUiObject(self)
    self.WorkingText.text = TextManager.GetText("DormWorkingText")
end

function XUiDormPersonSelectListItem:Init(ui,uiroot,dormid)
    self.Parent = ui
    self.UiRoot = uiroot
    self.DormId = dormid
end

function XUiDormPersonSelectListItem:SetSelectState()
    local dormid = self.Parent:GetCurSeleDormId()
    local cfg = XDormConfig.GetDormitoryCfgById(dormid)
    if not cfg then
        return
    end
    
    if self.IsWorking then
        self.CurSeleState = false
        XUiManager.TipText("DormWorkingText")
        return 
    end

    self.CurSeleState = not self.CurSeleState
    if self.CurSeleState then
        local d = self.Parent:GetTotalSeleCharacter()
        local selecount = #d
        if selecount ~= 0 and selecount  >= cfg.CharCapacity then
            self.CurSeleState = false
            XUiManager.TipText("DormFullPersonTips")
            return
        end
    end
    
    self:SelectState(self.CurSeleState)
end

function XUiDormPersonSelectListItem:SelectState(state)
    self.ImgSelect.gameObject:SetActive(state)
    self.Parent:UpdateSeleCharacter(self.ItemData,state)
    self.ItemData.CurSeleState = state
end

-- 更新数据
function XUiDormPersonSelectListItem:OnRefresh(itemData)
    if not itemData then
        return
    end
    
    self.ItemData = itemData
    self.Dormid = itemData.DormitoryId
    local characterid = itemData.CharacterId

    if self.Dormid == -1 then
        if itemData.CurSeleState == nil then       
            self.CurSeleState = false
        else
            self.CurSeleState = itemData.CurSeleState
        end
        self.ImgDorm.gameObject:SetActive(false)
        self.ImgSelect.gameObject:SetActive(self.CurSeleState)
        if self.CurSeleState then
            self.Parent:UpdateSeleCharacter(self.ItemData,self.CurSeleState)
        end
    else
        local curseleDormId = self.Parent:GetCurSeleDormId()
        self.ImgDorm.gameObject:SetActive(true)
        self.TxtHostelName.text = DormManager.GetDormName(self.Dormid) or ""
        if itemData.CurSeleState == nil then
            local state = curseleDormId == self.Dormid
            itemData.CurSeleState = state
            self.CurSeleState = state
        else
            self.CurSeleState = itemData.CurSeleState
        end
        self.ImgSelect.gameObject:SetActive(self.CurSeleState)
        if self.CurSeleState then
            self.Parent:UpdateSeleCharacter(self.ItemData,self.CurSeleState)
        end
    end
    local charStyleConfig = XDormConfig.GetCharacterStyleConfigById(characterid)
    if not charStyleConfig then 
        return
    end
    if charStyleConfig then
        self.TxtName.text = charStyleConfig.Name
    end
    
    if DormManager.IsWorking(characterid) then
        self.ImgWorking.gameObject:SetActive(true)
        self.IsWorking = true
    else
        self.ImgWorking.gameObject:SetActive(false)
        self.IsWorking = false
    end

    local loveicon = DormManager.GetCharacterLikeIconById(characterid, XDormConfig.CharacterLikeType.LoveType)
    local likeicon = DormManager.GetCharacterLikeIconById(characterid, XDormConfig.CharacterLikeType.LikeType)

    if not self.loveitem then
        self.loveitem = self:GetItem()
        self.loveitem:SetState(true)
    end
    self.loveitem:OnRefresh(self.Lovetxt,loveicon)

    if not self.likeitem then
        self.likeitem = self:GetItem()
        self.likeitem:SetState(true)
    end
    self.likeitem:OnRefresh(self.Liketxt,likeicon)

    local iconpath = XDormConfig.GetCharacterStyleConfigQIconById(characterid)
    if iconpath then
        self.ImgIcon:SetRawImage(iconpath,nil,true)
    end
    self.GameObject.name = characterid
end

function XUiDormPersonSelectListItem:GetItem()
    local obj = Object.Instantiate(self.Item)
    obj.transform:SetParent(self.DesItems,false)
    obj.transform.localScale = V3O
    local item = XUiDormPersonAttDesItem.New(obj,self.UiRoot)
    return item
end

return XUiDormPersonSelectListItem
