local XUiDrawActivityControl = XClass()
local characterRecord = require("XUi/XUiDraw/XUiDrawTools/XUiDrawCharacterRecord")

local MAX_GACHA_BTN_COUNT = 2

function XUiDrawActivityControl:Ctor(rootUi, gachaCfg, gachaCb, uiDraw)
    self.RootUi = rootUi
    self.GachaCfg = gachaCfg
    self.GachaCb = gachaCb
    self.UiDraw = uiDraw
    self.IsCanGacha = true
    self:InitRes()
    self:InitButtons()
    return self
end

function XUiDrawActivityControl:InitRes()
    self.UseItemIcon = XDataCenter.ItemManager.GetItemBigIcon(self.GachaCfg.ConsumeId)
end

function XUiDrawActivityControl:InitButtons()
    for i = 1, MAX_GACHA_BTN_COUNT do
        local btnName = "BtnDraw" .. i
        local btn = XUiHelper.TryGetComponent(self.RootUi.PanelDrawButtons, btnName)
        if btn then
            self:InitButton(btn, i)
        end
    end
end

function XUiDrawActivityControl:InitButton(btn, index)
    --@DATA
    local gachaCount = self.GachaCfg.BtnGachaCount[index]
    btn.transform:Find("TxtDrawDesc"):GetComponent("Text").text = CS.XTextManager.GetText("DrawCount", gachaCount)
    local itemIcon = btn.transform:Find("ImgUseItemIcon"):GetComponent("RawImage")
    itemIcon:SetRawImage(self.UseItemIcon)
    btn.transform:Find("TxtUseItemCount"):GetComponent("Text").text = gachaCount * self.GachaCfg.ConsumeCount

    self.RootUi:RegisterClickEvent(btn:GetComponent("Button"), function()
            self.UiDraw:UpdateItemCount()
            self:OnDraw(gachaCount)
    end)
end

function XUiDrawActivityControl:ShowGacha()

    XDataCenter.AntiAddictionManager.BeginDrawCardAction()
    self.UiDraw.OpenSound = CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiDrawCard_GachaOpen)
    
    if self.GachaCb then
        self.GachaCb()
    end
    
    if self.RewardList and #self.RewardList > 0 then
        self.IsCanGacha = true
        self.UiDraw:PushShow(self.RewardList)
    else
        self.UiDraw:PushShow(self.RewardList)
    end
    
    self.UiDraw:UpDataPreviewData()
    self.UiDraw.IsReadyForGacha = false
end


function XUiDrawActivityControl:OnDraw(gachaCount)
    if XDataCenter.EquipManager.CheakBoxOverLimitOfDraw() then
       return 
    end

    local ownItemCount = XDataCenter.ItemManager.GetItem(self.GachaCfg.ConsumeId).Count
    local lackItemCount = self.GachaCfg.ConsumeCount * gachaCount - ownItemCount
    if lackItemCount > 0 then
        XUiManager.TipError(CS.XTextManager.GetText("DrawNotEnoughError"))
        return 
    end
    local dtCount = XDataCenter.GachaManager.GetMaxCountOfAll() - XDataCenter.GachaManager.GetCurCountOfAll()
    if dtCount < gachaCount then
        XUiManager.TipMsg(CS.XTextManager.GetText("GachaIsNotEnough"))
        return
    end
    if not XDataCenter.GachaManager.CheckGachaIsOpenById(self.GachaCfg.Id,true) then
       return 
    end
    if self.IsCanGacha then
        self.IsCanGacha = false
        
        characterRecord.Record()
        self.UiDraw.ImgMask.gameObject:SetActiveEx(true)
        
        XDataCenter.GachaManager.DoGacha(self.GachaCfg.Id, gachaCount, function(rewardList)
                self.UiDraw:PlayAnimation("DrawRetract",function()
                        self.UiDraw.IsReadyForGacha = true
                end)
                self.RewardList = rewardList
            end)
    end
end

return XUiDrawActivityControl