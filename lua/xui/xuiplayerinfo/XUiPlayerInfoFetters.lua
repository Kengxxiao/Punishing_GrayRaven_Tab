XUiPlayerInfoFetters = XClass()
function XUiPlayerInfoFetters:Ctor(ui, isFriend, exp)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self.BtnClose.CallBack = function() self.GameObject:SetActive(false) end
    self:UpdateInfo(isFriend, exp)
end

function XUiPlayerInfoFetters:UpdateInfo(isFriend, exp)
    if isFriend then
        self.PanelNormal.gameObject:SetActive(true)
        self.PanelNone.gameObject:SetActive(false)
        local fettersData = XPlayerInfoConfigs.GetLevelDataByExp(exp)
        self.TxtLevel.text = fettersData.Level
        self.TxtAdd.text = fettersData.Add .. "%"
        local max = XPlayerInfoConfigs.GetCurLevelExp(fettersData.Level) - XPlayerInfoConfigs.GetCurLevelExp(fettersData.Level - 1)
        local cur = exp - XPlayerInfoConfigs.GetCurLevelExp(fettersData.Level - 1)
        self.TxtMax.text = "/" .. max
        self.TxtCur.text = cur
        local progress = 0
        if max ~= 0 then
            progress = cur / max
        end
        self.ImgProgress.fillAmount = 0
        self.ImgProgress:DOFillAmount(progress, 0.3)
    else
        self.PanelNormal.gameObject:SetActive(false)
        self.PanelNone.gameObject:SetActive(true)
    end
end

return XUiPlayerInfoFetters