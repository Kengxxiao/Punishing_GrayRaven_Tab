local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local V3O = Vector3.one
local ItemType = {
    Normal = 1,
    Add = 2
}
local XUiDormPersonAttDesItem = require("XUi/XUiDormPerson/XUiDormPersonAttDesItem")
local XUiDormPersonSingleItem = XClass()
local TextManager = CS.XTextManager
local MaxVitalValue = 100
local MaxMoodValue = 100
local DormManager

function XUiDormPersonSingleItem:Ctor(ui,uiroot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    DormManager = XDataCenter.DormManager
    MaxVitalValue = XDormConfig.DORM_VITALITY_MAX_VALUE
    MaxMoodValue = XDormConfig.DORM_MOOD_MAX_VALUE
    self.UiRoot = uiroot
    self.PoolObjs = {}
    self.CurObjs = {}
    XTool.InitUiObject(self)
    local btnclick = function() self:OnBtnClick() end
    self.UiRoot:RegisterClickEvent(self.Transform,btnclick)
    self.Lovetxt = TextManager.GetText("DormLove") or ""
    self.Liketxt = TextManager.GetText("DormLike") or ""
    self.WorkingText.text = TextManager.GetText("DormWorkingText")
end

function XUiDormPersonSingleItem:OnBtnClick()
    self.UiRoot:SetSelectList(self.DormId)
end

function XUiDormPersonSingleItem:SetState(state)
    if not self.GameObject then 
        return
    end

    self.GameObject:SetActive(state)
end

-- 更新数据
function XUiDormPersonSingleItem:OnRefresh(characterId,dormId)
    if not characterId or not dormId then
        return
    end
    
    self.DormId = dormId
    if characterId == -1 then
        self.ItemType = ItemType.Add
        self.ItemAdd.gameObject:SetActive(true)
        self.ItemNormal.gameObject:SetActive(false)
        return
    end
    
    local iconpath = XDormConfig.GetCharacterStyleConfigQIconById(characterId)
    if iconpath then
        self.ImgIcon:SetRawImage(iconpath,nil,true)
    end
    self.ItemType = ItemType.Normal
    self.ItemAdd.gameObject:SetActive(false)
    self.ItemNormal.gameObject:SetActive(true)

    if DormManager.IsWorking(characterId) then
        self.ImgWorking.gameObject:SetActive(true)
    else
        self.ImgWorking.gameObject:SetActive(false)
    end

    local curvital = DormManager.GetVitalityById(characterId)
    self.TxtCount.text = TextManager.GetText("DormVilityTxt",curvital,MaxVitalValue)
    local curmood = DormManager.GetMoodById(characterId)
    self.ImgProgress.fillAmount = curmood/MaxMoodValue
    self.ImgProgress.color = XDormConfig.GetMoodStateColor(curmood)
    local moodConfig = XDormConfig.GetMoodStateByMoodValue(curmood)
    self.UiRoot:SetUiSprite(self.ImgMood,moodConfig.Icon)

    local loveicon = DormManager.GetCharacterLikeIconById(characterId, XDormConfig.CharacterLikeType.LoveType)
    local likeicon = DormManager.GetCharacterLikeIconById(characterId, XDormConfig.CharacterLikeType.LikeType)
    
    if not self.Loveitem then
        self.Loveitem = self:GetItem()
        self.Loveitem:SetState(true)
    end
    self.Loveitem:OnRefresh(self.Lovetxt,loveicon)
    
    if not self.Likeitem then
        self.Likeitem = self:GetItem()
        self.Likeitem:SetState(true)
    end
    self.Likeitem:OnRefresh(self.Liketxt,likeicon)
end

function XUiDormPersonSingleItem:GetItem()   
    local obj = Object.Instantiate(self.DesSingleItem)
    obj.transform:SetParent(self.DesItems.transform,false)
    obj.transform.localScale = V3O
    local item = XUiDormPersonAttDesItem.New(obj,self.UiRoot)
    return item
end

return XUiDormPersonSingleItem
