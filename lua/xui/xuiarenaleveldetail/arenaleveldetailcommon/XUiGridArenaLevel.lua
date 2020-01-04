local XUiGridArenaLevel = XClass()

function XUiGridArenaLevel:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridArenaLevel:ResetData(data, rootUi)
    local arenaLevel = XDataCenter.ArenaManager.GetCurArenaLevel()
    local cfg = XArenaConfigs.GetArenaLevelCfgByLevel(data.ArenaLv)
    self.ImgCurLevel.gameObject:SetActive(data.ArenaLv == arenaLevel)
    self.RImgIcon:SetRawImage(cfg.Icon)
end

function XUiGridArenaLevel:SetSelect(isSelected)
    self.ImgSelected.gameObject:SetActive(isSelected)
end

return XUiGridArenaLevel
