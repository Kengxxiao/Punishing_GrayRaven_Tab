local XUiGridInfoChallengeItem = XClass()
local XUiGridInfoBuffItem = require("XUi/XUiFubenBabelTower/XUiGridInfoBuffItem")

function XUiGridInfoChallengeItem:Ctor(ui, buffGroupId, itemType)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.BuffGroupId = buffGroupId
    self.ItemType = itemType
    self.BuffItemList = {}
    XTool.InitUiObject(self)
    self:Refresh(self.BuffGroupId, self.ItemType)
end

function XUiGridInfoChallengeItem:Refresh(buffGroupId, itemType)
    self.BuffGroupId = buffGroupId
    self.ItemType = itemType
    self.BuffGroupConfigs = XFubenBabelTowerConfigs.GetBabelBuffGroupConfigs(self.BuffGroupId)
    self.BuffGroupTemplate = XFubenBabelTowerConfigs.GetBabelTowerBuffGroupTemplate(self.BuffGroupId)
    
    self.TxtChallengeTitle.text = self.BuffGroupConfigs.Name
    self.TxtChallenge.text = self.BuffGroupConfigs.Desc
    self:RefreshBuffItems()
end

function XUiGridInfoChallengeItem:RefreshBuffItems()
    for i=1, #self.BuffGroupTemplate.BuffId do
        if not self.BuffItemList[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.ImgChallenge)
            go.transform:SetParent(self.ChallengeContainer, false)
            go.gameObject:SetActiveEx(true)
            local challengeItem = XUiGridInfoBuffItem.New(go, self.BuffGroupTemplate.BuffId[i], self.ItemType)
            table.insert(self.BuffItemList, challengeItem)
        else
            self.BuffItemList[i]:Refresh(self.BuffGroupTemplate.BuffId[i], self.ItemType)
        end
    end
    for i = #self.BuffGroupTemplate.BuffId + 1, #self.BuffItemList do
        self.BuffItemList[i].GameObject:SetActiveEx(false)
    end
end

return XUiGridInfoChallengeItem