XUiGridMedal = XClass()

function XUiGridMedal:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiGridMedal:AutoAddListener()
    self.BtnSelect.CallBack = function()
        self:OnBtnSelect()
    end
end

function XUiGridMedal:OnBtnSelect(...)
    self.Base:OpenMedalDetail(true)
    self.Base:SetDetail(self.MedalId)
    self:ShowRedPoint(false)
    XEventManager.DispatchEvent(XEventId.EVENT_MEDAL_IN_DETAIL)
end

function XUiGridMedal:UpdateGrid(chapter,parent)
    self.Base = parent
    self.MedalId = chapter.Id
    if chapter.MedalImg ~= nil then
        self.ImgMedalIcon:SetRawImage(chapter.MedalImg)
        self.ImgMedalIconlock:SetRawImage(chapter.MedalImg)
    end
    self.TxtMedalName.text = chapter.Name
    self:ShowLock(not XPlayer.IsMedalUnlock(self.MedalId))
    self:ShowUesing(XPlayer.CurrMedalId == self.MedalId)
end

function XUiGridMedal:ShowUesing(bShow)
    self.LabelPress.gameObject:SetActiveEx(bShow)
end

function XUiGridMedal:ShowLock(Lock)
    self.LabelLock.gameObject:SetActiveEx(Lock)
    self.ImgMedalIcon.gameObject:SetActiveEx(not Lock)
end

function XUiGridMedal:ShowRedPoint(bShow)
    self.Red.gameObject:SetActiveEx(bShow)
end