local XUiGridMultiplayerDifficultyItem = XClass()

function XUiGridMultiplayerDifficultyItem:Ctor(ui, difficulty, cb)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Difficulty = difficulty
    self.Cb = cb
    XTool.InitUiObject(self)
    self.BtnSelect.CallBack = handler(self, self.OnBtnSelectClick)
end

function XUiGridMultiplayerDifficultyItem:Refresh(levelControl)
    self.TxtRecommend.text = CS.XTextManager.GetText("MultiplayerRoomRecommendAbility", levelControl.RecommendAbility)
end

function XUiGridMultiplayerDifficultyItem:SetSelected(enable)
    self.BtnSelect.ButtonState = enable and CS.UiButtonState.Disable or CS.UiButtonState.Normal
    self.ImgSelected.gameObject:SetActive(enable)
end

function XUiGridMultiplayerDifficultyItem:OnBtnSelectClick(eventData)
    if self.Cb then
        self.Cb(self.Difficulty)
    end
end

return XUiGridMultiplayerDifficultyItem