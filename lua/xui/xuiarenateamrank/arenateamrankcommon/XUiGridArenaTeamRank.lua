local XUiGridArenaTeamRank = XClass()

function XUiGridArenaTeamRank:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
end

function XUiGridArenaTeamRank:ResetData(rank, data, rootUi, totalRank)
    if not self.GameObject:Exist() then
        return
    end
    
    if not data then
        return
    end

    if rank == 1 then
        self.TxtRank.text = CS.XTextManager.GetText("Rank1Color", rank)
    elseif rank == 2 then 
        self.TxtRank.text = CS.XTextManager.GetText("Rank2Color", rank)
    elseif rank == 3 then 
        self.TxtRank.text = CS.XTextManager.GetText("Rank3Color", rank)
    else
        if totalRank and rank > 100 and totalRank > 0 then
            local rankRate = math.ceil(rank / totalRank * 100)
            if rankRate >= 100 then
                rankRate = 99
            end
            local rankRateDesc = rankRate .. "%"
            self.TxtRank.text = CS.XTextManager.GetText("RankOtherColor", rankRateDesc)
        else
            self.TxtRank.text = CS.XTextManager.GetText("RankOtherColor", rank)
        end
    end

    if self.ImgTeamBg then
        self.ImgTeamBg.gameObject:SetActive(rank % 2 == 0)
    end
    
    self.TxtPoint.text = data.Point

    local captain = data.Captain

    for i = 1, 3 do
        local grid = self["GridMember" .. i]
        local headIcon = XUiHelper.TryGetComponent(grid, "RImgHeadIcon", "RawImage")
        local headIconEffect = XUiHelper.TryGetComponent(grid, "RImgHeadIcon/Effect", "XUiEffectLayer")
        local nickname = XUiHelper.TryGetComponent(grid, "TxtNickname", "Text")
        local captainTrans = XUiHelper.TryGetComponent(grid, "ImgCaptain", nil)
        local btnHead = XUiHelper.TryGetComponent(grid, "BtnHead", "Button")

        CsXUiHelper.RegisterClickEvent(btnHead, function()
            local player = data.PlayerList[i]
            if not player or player.Id == XPlayer.Id then
                return
            end
            XDataCenter.PersonalInfoManager.ReqShowInfoPanel(player.Id)
        end , true)

        local info = data.PlayerList[i]
        if info then
            headIcon.gameObject:SetActive(true)
            nickname.gameObject:SetActive(true)

            nickname.text = info.Name
            captainTrans.gameObject:SetActive(info.Id == captain)
            local head_info = XPlayerManager.GetHeadPortraitInfoById(info.CurrHeadPortraitId)
            if (head_info ~= nil) then
                headIcon:SetRawImage(head_info.ImgSrc)
                if head_info.Effect then
                    headIconEffect.gameObject:LoadPrefab(head_info.Effect)
                    headIconEffect.gameObject:SetActiveEx(true)
                    headIconEffect:Init()
                else
                    headIconEffect.gameObject:SetActiveEx(false)
                end
            end
        else
            headIcon.gameObject:SetActive(false)
            nickname.gameObject:SetActive(false)
            captainTrans.gameObject:SetActive(false)
        end
    end
end

return XUiGridArenaTeamRank