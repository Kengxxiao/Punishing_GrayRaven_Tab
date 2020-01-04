local XUiGuildMainInfo = XClass()

function XUiGuildMainInfo:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot

    XTool.InitUiObject(self)
    self:InitChildView()
end

function XUiGuildMainInfo:OnEnable()
    self.GameObject:SetActiveEx(true)
end

function XUiGuildMainInfo:OnDisable()
    self.GameObject:SetActiveEx(false)
end

function XUiGuildMainInfo:InitChildView()
    -- self.ImgGuildIcon
    -- self.TxtGuildName
    -- self.TxtLeader
    -- self.TxtMemberCount
    -- self.TextLvNum
    -- self.IconCoin1
    -- self.TxtCoin1
    -- self.IconCoin2
    -- self.TxtCoin2
    -- self.BtnAdd
    -- self.TextInfo
    -- self.BtnDynamic
    -- self.BtnRanking
end

return XUiGuildMainInfo