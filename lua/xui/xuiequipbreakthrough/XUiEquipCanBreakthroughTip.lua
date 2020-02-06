local XUiEquipCanBreakthroughTip = XLuaUiManager.Register(XLuaUi, "UiEquipCanBreakthroughTip")

function XUiEquipCanBreakthroughTip:OnStart(equipId, changeTxt, closeCb, setMask)
    self.EquipId = equipId
    self.CloseCb = closeCb
    self.SetMask = setMask

    if changeTxt then
        self.TxtDes.text = changeTxt
        self.ChangeTxt = true
    end
end

function XUiEquipCanBreakthroughTip:OnEnable()
    if self.SetMask then
        self:PlayAnimationWithMask("AnimShow", function()
            self:CloseSelf()
        end)
    else
        self:PlayAnimation("AnimShow", function()
            self:CloseSelf()
        end)
    end
end

function XUiEquipCanBreakthroughTip:OnDestroy()
    CsXGameEventManager.Instance:Notify(XEventId.EVENT_EQUIP_CAN_BREAKTHROUGH_TIP_CLOSE, self.EquipId)
    self.SetMask = nil
end

function XUiEquipCanBreakthroughTip:CloseSelf()
    if not self.GameObject.activeInHierarchy then return end
    self:Close()
    if self.CloseCb then self.CloseCb() end
end