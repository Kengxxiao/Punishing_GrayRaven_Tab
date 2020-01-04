local XUiGridArenaTeamReward = XClass()

function XUiGridArenaTeamReward:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.GridUis = {}
    XTool.InitUiObject(self)

    self.GridCommon.gameObject:SetActive(false)
end

function XUiGridArenaTeamReward:ResetData(data, rootUi)
    if not data then
        return
    end
    self.RootUi = rootUi

    local rank = ""
    if data.MinRank > 0 then
        rank = rank .. data.MinRank .. "%-"
    end
    rank = rank .. data.MaxRank .. "%"
    self.TxtRankRange.text = rank

    local rankRate = XDataCenter.ArenaManager.GetMyTeamRankRate()
    self.ImgSelf.gameObject:SetActive(data.MinRank / 100 < rankRate and data.MaxRank / 100 >= rankRate)

    self.DataList = XDataCenter.MailManager.GetRewardList(data.MailId) or {}
    for _, ui in pairs(self.GridUis) do
        ui.GameObject:SetActive(false)
    end

    for i, reward in pairs(self.DataList) do
        local ui = self.GridUis[i]
        if not ui then
            local grid = CS.UnityEngine.Object.Instantiate(self.GridCommon)
            grid.transform:SetParent(self.SViewReward.transform, false)
            ui = XUiGridCommon.New(self.RootUi, grid)
            table.insert(self.GridUis, ui)
        end

        ui:Refresh(reward)
    end
end

return XUiGridArenaTeamReward
