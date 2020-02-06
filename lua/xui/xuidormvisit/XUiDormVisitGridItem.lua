local XUiDormVisitGridItem = XClass()
local TextManager = CS.XTextManager
local DormManager
local DisplaySetType
local TabTypeCfg

function XUiDormVisitGridItem:Ctor(ui)
    DormManager = XDataCenter.DormManager
    TabTypeCfg = XDormConfig.VisitTabTypeCfg
    DisplaySetType = XDormConfig.VisitDisplaySetType
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.OnBtnClickcb = function() self:OnBtnClick() end
    self.OnEnterDormcb = function() self:EnterDormVisitor() end
    self.TextOnline = TextManager.GetText("DormOnline")
    self.TextOffline = TextManager.GetText("DormOffline")
    XTool.InitUiObject(self)
end

function XUiDormVisitGridItem:OnBtnClick()
    if self.ItemData.DormitoryId == 0 then
        return
    end
        
    local charId = DormManager.GetVisitorDormitoryCharacterId()
    XLuaUiManager.CloseWithCallback("UiDormVisit",function()
        DormManager.RequestDormitoryVisit(self.ItemData.PlayerId,self.ItemData.DormitoryId,charId,self.OnEnterDormcb)
    end)
end

function XUiDormVisitGridItem:EnterDormVisitor()
    local displaytype = DisplaySetType.MyFriend
    if self.UiRoot.CuTabType == TabTypeCfg.Visitor then
        displaytype = DisplaySetType.Stranger
    end

    if self.HostelSecond then
        self.HostelSecond.GameObject:SetActive(true)
        self.HostelSecond:OnRecordSelfDormId()
        DormManager.VisitDormitory(displaytype,self.ItemData.DormitoryId)
        self.HostelSecond:UpdateData(displaytype,self.ItemData.DormitoryId,self.ItemData.PlayerId)
    else
        XLuaUiManager.Open("UiDormSecond",displaytype, self.ItemData.DormitoryId,self.ItemData.PlayerId)
        DormManager.VisitDormitory(displaytype,self.ItemData.DormitoryId)
    end
end

function XUiDormVisitGridItem:Init(uiroot)
    self.UiRoot = uiroot
    self.HostelSecond = uiroot.HostelSecond
    self.UiRoot:RegisterClickEvent(self.BtnVisit,self.OnBtnClickcb)
    self.BtnView.CallBack = function() self:OnBtnViewClick() end
end

function XUiDormVisitGridItem:GetMaxScore(atts)
    local score = 0
    local index = 1
    for i,v in pairs(atts)do
        if v > score then
            index = i
            score = v
        end
    end

    return index,score
end

-- 更新数据
function XUiDormVisitGridItem:OnRefresh(itemData)
    if not itemData then
        return
    end

    self.ItemData = itemData
    local dormitoryName = itemData.DormitoryName

    if dormitoryName ~= "" then
        self.TxtName.text = TextManager.GetText("DormVisitNameStyle",itemData.PlayerName,dormitoryName)
        local index,score = self:GetMaxScore(itemData.DormitoryAttr)           
        self.TxtFeelDes.text = XFurnitureConfigs.GetDormFurnitureTypeName(index)
        self.TxtFeelCount.text = score
    else
        self.TxtName.text = TextManager.GetText("DormNoCount")
        self.TxtFeelDes.text = ""
        self.TxtFeelCount.text = ""
    end
    
    self.TxtTotalCount.text = itemData.FurnitureScore
    self.TxtFurnitureCount.text = itemData.FurnitureCount or 0

    local icon =  XPlayerManager.GetHeadPortraitInfoById(itemData.PlayerHead)
    if icon ~= nil and icon.ImgSrc ~= self.CurIcon then
        self.CurIcon = icon.ImgSrc
        self.UiRoot:SetUiSprite(self.ImgIcon,self.CurIcon)
    end
    if (icon ~= nil) then
        if icon.Effect then
            self.HeadIconEffect.gameObject:LoadPrefab(icon.Effect)
            self.HeadIconEffect.gameObject:SetActiveEx(true)
            self.HeadIconEffect:Init()
        else
            self.HeadIconEffect.gameObject:SetActiveEx(false)
        end
    end
    
    
    if itemData.IsOnline then
        self.TxtOnline.text = self.TextOnline
    else
        self.TxtOnline.text = self.TextOffline
    end
end

function XUiDormVisitGridItem:OnBtnViewClick()
    if not self.ItemData or  not self.ItemData.PlayerId then
        return 
    end
    
    --个人信息
    XDataCenter.PersonalInfoManager.ReqShowInfoPanel(self.ItemData.PlayerId)  
end

return XUiDormVisitGridItem
