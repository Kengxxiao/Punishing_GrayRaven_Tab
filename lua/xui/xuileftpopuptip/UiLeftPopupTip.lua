local XUiLeftPopupTip = XLuaUiManager.Register(XLuaUi, "UiLeftPopupTip")

function XUiLeftPopupTip:OnStart(title, content, closeCb)
    self.Title = title
    self.Content = content
    self.CloseCb = closeCb
    self:InitView()
end

function XUiLeftPopupTip:OnEnable()
    self:PlayAnimation("AniUnlockTip", function()
        self:Close()
    end)
    -- XUiHelper.PlayAnimation(self, "AniUnlockTip", nil, function()
    --     self:Close()
    -- end)
end

function XUiLeftPopupTip:OnDestroy()
    if self.CloseCb then self.CloseCb() end
end

function XUiLeftPopupTip:InitView()
    self.TxtTitle.text = self.Title
    self.TxtContent.text = self.Content
end