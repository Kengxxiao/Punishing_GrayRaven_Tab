XUiPanelCourseReward = XClass()

function XUiPanelCourseReward:Ctor(rootUi, ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)
    self.GridRewardList = {}
    self.BtnComfirm.CallBack = function() self:OnBtnComfirmClick() end
    self.GridReward.gameObject:SetActive(false)
end

function XUiPanelCourseReward:OnBtnComfirmClick(...)
    self:HidePanel()
end

function XUiPanelCourseReward:ShowPanel(rewardId, name)
    local rewardList = XRewardManager.GetRewardList(rewardId)

    for i = 1, #rewardList do
        local grid = self.GridRewardList[i]
        if not grid then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridReward)
            grid = XUiGridCommon.New(self.RootUi, ui)
            grid.Transform:SetParent(self.PanelRewardContent, false)
            self.GridRewardList[i] = grid
        end

        grid:Refresh(rewardList[i])
        grid.GameObject:SetActive(true)
    end

    for i = #rewardList + 1, #self.GridRewardList do
        self.GridRewardList[i].GameObject:SetActive(false)
    end

    local text = CS.XTextManager.GetText("CoureDesc", name)
    self.TxtDesc.text = text

    self.GameObject:SetActive(true)
end

function XUiPanelCourseReward:HidePanel()
    self.GameObject:SetActive(false)
end
