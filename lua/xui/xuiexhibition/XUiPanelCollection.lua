local XUiPanelCollection = XClass()

function XUiPanelCollection:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
end

function XUiPanelCollection:Refresh()
    local collectionRate = XDataCenter.ExhibitionManager.GetCollectionRate()
    self.TxtPanelCollectionRate.text = math.floor(collectionRate * 100)
    self.ImgRate.fillAmount = collectionRate
    local totalCharacterNum = XDataCenter.ExhibitionManager.GetCollectionTotalNum()
    local curFinishNum = XDataCenter.ExhibitionManager.GetTaskFinishNum()

    self.TxtNumNew.text = curFinishNum[XCharacterConfigs.GrowUpLevel.New]
    self.TxtTotalNew.text = totalCharacterNum
    self.ImgRateNew.fillAmount = curFinishNum[XCharacterConfigs.GrowUpLevel.New] / totalCharacterNum

    self.TxtNumLower.text = curFinishNum[XCharacterConfigs.GrowUpLevel.Lower]
    self.TxtTotalLower.text = totalCharacterNum
    self.ImgRateLower.fillAmount = curFinishNum[XCharacterConfigs.GrowUpLevel.Lower] / totalCharacterNum

    self.TxtNumMiddle.text = curFinishNum[XCharacterConfigs.GrowUpLevel.Middle]
    self.TxtTotalMiddle.text = totalCharacterNum
    self.ImgRateMiddle.fillAmount = curFinishNum[XCharacterConfigs.GrowUpLevel.Middle] / totalCharacterNum

    self.TxtNumHigher.text = curFinishNum[XCharacterConfigs.GrowUpLevel.Higher]
    self.TxtTotalHigher.text = totalCharacterNum
    self.ImgRateHigher.fillAmount = curFinishNum[XCharacterConfigs.GrowUpLevel.Higher] / totalCharacterNum

    self.InfoLabelNew.text = XExhibitionConfigs.GetExhibitionLevelNameByLevel(XCharacterConfigs.GrowUpLevel.New)
    self.InfoLabelLower.text = XExhibitionConfigs.GetExhibitionLevelNameByLevel(XCharacterConfigs.GrowUpLevel.Lower)
    self.InfoLabelMiddle.text = XExhibitionConfigs.GetExhibitionLevelNameByLevel(XCharacterConfigs.GrowUpLevel.Middle)
    self.InfoLabelHigher.text = XExhibitionConfigs.GetExhibitionLevelNameByLevel(XCharacterConfigs.GrowUpLevel.Higher)
end

function XUiPanelCollection:Show()
    self:Refresh()
    self.GameObject:SetActive(true)
end

function XUiPanelCollection:Hide()
    self.GameObject:SetActive(false)
end

return XUiPanelCollection