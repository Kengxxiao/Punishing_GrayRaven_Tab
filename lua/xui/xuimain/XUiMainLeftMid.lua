XUiMainLeftMid = XClass()
local TextManager = CS.XTextManager

function XUiMainLeftMid:Ctor(rootUi)
    self.Transform = rootUi.PanelLeftMid.gameObject.transform
    XTool.InitUiObject(self)
    self.RootUi = rootUi
    --ClickEvent
    self.BtnGiftExpire.CallBack = function() self:OnBtnGiftExpire() end
    self.BtnAutoFight.CallBack = function() self:OnBtnAutoFight() end
    --RedPoint
end

function XUiMainLeftMid:OnEnable()
    self.PanelAutoFight.gameObject:SetActive(XDataCenter.AutoFightManager.GetRecordCount() > 0)
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_START, self.OnAutoFightStart, self)
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_CHANGE, self.OnAutoFightChange, self)
    XEventManager.AddEventListener(XEventId.EVENT_AUTO_FIGHT_REMOVE, self.OnAutoFightRemove, self)
    -- XEventManager.AddEventListener(XEventId.EVENT_LB_EXPIRE_NOTIFY, self.UpdatePurchaseGift, self)
    self:SetPurchaseGiftExpire()
end

function XUiMainLeftMid:OnDisable()
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_START, self.OnAutoFightStart, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_CHANGE, self.OnAutoFightChange, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_AUTO_FIGHT_REMOVE, self.OnAutoFightRemove, self)
    -- XEventManager.RemoveEventListener(XEventId.EVENT_LB_EXPIRE_NOTIFY, self.UpdatePurchaseGift, self)
    self.PanelGiftExpire.gameObject:SetActiveEx(false)
end

function XUiMainLeftMid:OnBtnGiftExpire(eventData)
    XLuaUiManager.Open("UiPurchase", XPurchaseConfigs.TabsConfig.LB)
end

function XUiMainLeftMid:OnBtnAutoFight(eventData)
    XLuaUiManager.Open("UiAutoFightList")
end


--自动战斗
function XUiMainLeftMid:OnAutoFightStart()
    if not self.PanelAutoFight.gameObject.activeSelf then
        self.PanelAutoFight.gameObject:SetActive(true)
    end
end

--自动战斗
function XUiMainLeftMid:OnAutoFightChange(count)
    local active = count > 0
    local go = self.ImgAutoFightRedPoint.gameObject
    if go.activeSelf == active then
        return
    end
    go:SetActive(active)
end

--自动战斗
function XUiMainLeftMid:OnAutoFightRemove()
    local cnt = XDataCenter.AutoFightManager.GetRecordCount()
    if cnt > 0 then
        return
    end
    local go = self.PanelAutoFight.gameObject
    if go.activeSelf == false then
        return
    end
    go:SetActive(false)
end

-- 礼包
function XUiMainLeftMid:UpdatePurchaseGift(count)
    if count == 0 or count == nil then
        self.PanelGiftExpire.gameObject:SetActiveEx(false)
    else
        self.PanelGiftExpire.gameObject:SetActiveEx(true)
        if count == 1 then
            self.BtnGiftExpire:SetName(TextManager.GetText("PurchaseGiftValitimeTips1"))
        else
            self.BtnGiftExpire:SetName(TextManager.GetText("PurchaseGiftValitimeTips2"))
        end
    end
end

function XUiMainLeftMid:SetPurchaseGiftExpire()
    if self.IsFirstExpire then
        return
    end

    self.IsFirstExpire = true
    local count = XDataCenter.PurchaseManager.ExpireCount
    self:UpdatePurchaseGift(count)
end