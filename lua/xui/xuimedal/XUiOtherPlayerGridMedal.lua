XUiOtherPlayerGridMedal = XClass()

function XUiOtherPlayerGridMedal:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:AutoAddListener()
    self.IsLock = false
end

function XUiOtherPlayerGridMedal:AutoAddListener()
    self.BtnMedal.CallBack = function()
        self:OnBtnMedal()
    end
end

function XUiOtherPlayerGridMedal:OnBtnMedal(...)
    if not self.IsLock then
        self:OnOpenMedalDetail(
        self:CreatePlayerMedal(XDataCenter.MedalManager.InType.OtherPlayer, self.MedalId, self.MedalInfos)
        )
    end
end

function XUiOtherPlayerGridMedal:UpdateGrid(chapter, medalInfos)
    self.MedalId = chapter.Id
    self.MedalInfos = medalInfos
    if chapter.MedalImg ~= nil then
        self.IconMedalUnLock:SetRawImage(chapter.MedalImg)
        self.IconMedalLock:SetRawImage(chapter.MedalImg)
    end
    self:ShowLock(self:CheakMedalUnlock(self.MedalId))
end

function XUiOtherPlayerGridMedal:ShowLock(unLock)
    self.IconMedalUnLock.gameObject:SetActiveEx(unLock)
    self.IsLock = not unLock
end

function XUiOtherPlayerGridMedal:CheakMedalUnlock(id)
    for k, v in pairs(self.MedalInfos) do
        if v.Id == id then
            return true
        end
    end
    return false
end

function XUiOtherPlayerGridMedal:CreatePlayerMedal(inType, skipMedalId, detailInfos)
    local playerMedal = {}
    playerMedal.InType = inType
    playerMedal.SkipMedalId = skipMedalId
    playerMedal.DetailInfos = detailInfos
    return playerMedal
end

function XUiOtherPlayerGridMedal:OnOpenMedalDetail(playerMedal)
    local selectBtnId = 4
    XLuaUiManager.Open("UiPlayer", nil, selectBtnId, nil, playerMedal, false)
end