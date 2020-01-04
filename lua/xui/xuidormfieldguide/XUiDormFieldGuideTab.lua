local XUiDormFieldGuideTab = XClass()

function XUiDormFieldGuideTab:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiDormFieldGuideTab:SetName(name)
    self.BtnTab:SetName(name)
end


function XUiDormFieldGuideTab:SetSuitBgm(bgm)
    self.ImgSongNormal.gameObject:SetActiveEx(bgm ~= nil)
    self.ImgSongPress.gameObject:SetActiveEx(bgm ~= nil)
    self.ImgSongSelect.gameObject:SetActiveEx(bgm ~= nil)
    self.ImgSongDisable.gameObject:SetActiveEx(bgm ~= nil)

end


return XUiDormFieldGuideTab