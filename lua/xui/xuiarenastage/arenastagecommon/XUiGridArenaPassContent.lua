local XUiGridArenaPassContent = XClass()

function XUiGridArenaPassContent:Ctor(ui, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.RootUi = rootUi
    XTool.InitUiObject(self)

    self.GridPlayer.gameObject:SetActive(false)

    self.PlayerList = {}
    table.insert(self.PlayerList, self.GridPlayer)
end

function XUiGridArenaPassContent:SetMetaData(data)
    if not data then
        return
    end

    for i, v in ipairs(self.PlayerList) do
        v.gameObject:SetActive(false)
    end

    for i, playerInfo in ipairs(data.PlayerInfoList) do
        local grid = self.PlayerList[i]
        if not grid then
            local go = CS.UnityEngine.GameObject.Instantiate(self.GridPlayer.gameObject)
            grid = go.transform
            grid:SetParent(self.GridPlayer.parent, false)
            table.insert(self.PlayerList, grid)
        end
        grid.gameObject:SetActive(true)

        local icon = XUiHelper.TryGetComponent(grid, "Bg/RImgHeadIcon", "RawImage")
        local nickname = XUiHelper.TryGetComponent(grid, "TxtNickname", "Text")
        local btnHead = XUiHelper.TryGetComponent(grid, "BtnHead", "Button")

        CsXUiHelper.RegisterClickEvent(btnHead, function()
            if playerInfo.Id == XPlayer.Id then
                return
            end
            XDataCenter.PersonalInfoManager.ReqShowInfoPanel(playerInfo.Id)
        end , true)

        nickname.text = playerInfo.Name
        local info = XPlayerManager.GetHeadPortraitInfoById(playerInfo.CurrHeadPortraitId)
        if (info ~= nil and info.ImgSrc ~= nil) then
            icon:SetRawImage(info.ImgSrc)
        end

        grid:SetSiblingIndex(i - 1)
    end
end

return XUiGridArenaPassContent
