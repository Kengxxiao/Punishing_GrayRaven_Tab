-- 房间分数控件
XUiRoomScore = XClass()

function XUiRoomScore:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.GridTypePool = {}

    XTool.InitUiObject(self)

end

function XUiRoomScore:SetScore(oldFurnitureAttrs, newFurnitureAttrs)

    local oldScores = oldFurnitureAttrs.TotalScore
    local newScores = newFurnitureAttrs.TotalScore

    self.TxtTotalScore.text = newScores

    self.ImgScoreDown.gameObject:SetActive(newScores < oldScores)
    self.ImgScoreUp.gameObject:SetActive(newScores > oldScores)

    local compareAttrs = {}
    for i=1, #oldFurnitureAttrs.AttrList do
        compareAttrs[i] = {
            AttrKey = i,
            AttrOldVal = oldFurnitureAttrs.AttrList[i],
            AttrNewVal = newFurnitureAttrs.AttrList[i]
        }
    end


    XUiHelper.CreateTemplates(self.RootUi, self.GridTypePool, compareAttrs, XUiGridAttributeComparable.New, self.GridAttribute, self.PanelTxtGroup, XUiGridAttributeComparable.Init)
    self.GridAttribute.gameObject:SetActive(false)
end


return XUiRoomScore