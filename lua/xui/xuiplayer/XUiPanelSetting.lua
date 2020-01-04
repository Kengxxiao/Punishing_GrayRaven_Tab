local XUiPanelSetting = XLuaUiManager.Register(XLuaUi, "UiPanelSetting")

local MAX_CHARACTER = 3
function XUiPanelSetting:OnStart(root)
    self.UiRoot = root
    self.UiRoot.UiPanelSetting = self
    self.BtnSave.CallBack = function() self:OnBtnSave() end
    self.BtnView.CallBack = function() self:OnBtnView() end
    self.BtnCharacter1.CallBack = function() self:OnBtnCharacter(1) end
    self.BtnCharacter2.CallBack = function() self:OnBtnCharacter(2) end
    self.BtnCharacter3.CallBack = function() self:OnBtnCharacter(3) end
    self.RImgCharacter = { self.RImgCharacter1, self.RImgCharacter2, self.RImgCharacter3 }
    self.CharacterList = XPlayer.ShowCharacters
end

function XUiPanelSetting:OnEnable()
    self:UpdateCharacterHead()
end

function XUiPanelSetting:OnBtnSave()
    self.UiRoot.NeedSave = false
    XDataCenter.PlayerInfoManager.SaveData(self.CharacterList)
end

function XUiPanelSetting:OnBtnCharacter(index)
    local curTeam = {}
    for i = 1, MAX_CHARACTER do
        curTeam[i] = self.CharacterList[i] or 0
    end
    XLuaUiManager.Open("UiMainLineRoomCharacter", curTeam, index, function(resTeam)
        self.CharacterList = {}
        for i = 1, #resTeam do
            if resTeam[i] ~= 0 then
                table.insert(self.CharacterList, resTeam[i])
            end
        end
        self.UiRoot.CharacterList = self.CharacterList
        self:CheckSave()
        self:UpdateCharacterHead()
    end)
end

function XUiPanelSetting:CheckSave()
    for i = 1, MAX_CHARACTER do
        if self.CharacterList[i] ~= XPlayer.ShowCharacters[i] then
            self.UiRoot.NeedSave = true
        end
    end
end

function XUiPanelSetting:UpdateCharacterHead()
    for i = 1, #self.RImgCharacter do
        if self.CharacterList[i] then
            self.RImgCharacter[i].gameObject:SetActive(true)
            local charIcon = XDataCenter.CharacterManager.GetCharSmallHeadIcon(self.CharacterList[i])
            self.RImgCharacter[i]:SetRawImage(charIcon)
        else
            self.RImgCharacter[i].gameObject:SetActive(false)
        end
    end
end

function XUiPanelSetting:OnBtnView()
    XDataCenter.PlayerInfoManager.RequestPlayerInfoData(XPlayer.Id, function(data)
            XPlayer.SetPlayerLikes(data.Likes)
        XLuaUiManager.Open("UiPlayerInfo", data)
    end)
end