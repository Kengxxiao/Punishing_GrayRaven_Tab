XUiPanelDetailTeamItem = XClass()

function XUiPanelDetailTeamItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelDetailTeamItem:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelDetailTeamItem:AutoInitUi()
    self.TxtVoteNum = self.Transform:Find("TxtVoteNum"):GetComponent("Text")
    self.BtnVote = self.Transform:Find("RootPanelBtn/BtnVote"):GetComponent("Button")
    self.PanelCharItem1 = self.Transform:Find("layout/PanelCharItem1")
    self.TxtName1 = self.Transform:Find("layout/PanelCharItem1/TxtName1"):GetComponent("Text")
    self.RImgQuality1 = self.Transform:Find("layout/PanelCharItem1/RImgQuality1"):GetComponent("RawImage")
    self.PanelCharItem2 = self.Transform:Find("layout/PanelCharItem2")
    self.TxtName2 = self.Transform:Find("layout/PanelCharItem2/TxtName2"):GetComponent("Text")
    self.RImgQuality2 = self.Transform:Find("layout/PanelCharItem2/RImgQuality2"):GetComponent("RawImage")
    self.PanelCharItem3 = self.Transform:Find("layout/PanelCharItem3")
    self.TxtName3 = self.Transform:Find("layout/PanelCharItem3/TxtName3"):GetComponent("Text")
    self.RImgQuality3 = self.Transform:Find("layout/PanelCharItem3/RImgQuality3"):GetComponent("RawImage")
    self.TxtRank = self.Transform:Find("RootPanelRank/TxtRank"):GetComponent("Text")
    self.PanelImgVoted = self.Transform:Find("RootPanelBtn/PanelImgVoted")
end

function XUiPanelDetailTeamItem:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelDetailTeamItem:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelDetailTeamItem:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelDetailTeamItem:AutoAddListener()
    self:RegisterClickEvent(self.BtnVote, self.OnBtnVoteClick)
end
-- auto
function XUiPanelDetailTeamItem:Init(rootUi)
    self.RootUi = rootUi
end

function XUiPanelDetailTeamItem:UpdateView(recommendConfig, rank, curCharacterId)
    self.VoteId = recommendConfig.Id
    self.CurCharacterId = curCharacterId

    self.TxtRank.text = rank

    local template = XCharacterConfigs.GetCharDetailParnerTemplate(self.VoteId)
    local charList = template.CharacterRecomend

    for i = 1, 3 do
        local templateId = nil
        if i == 1 then
            templateId = self.CurCharacterId
        else
            templateId = charList[i - 1]
        end

        local indexKey = string.format("CharGrid%s", i)
        local itemKey = string.format("PanelCharItem%s", i)
        local grid = self[indexKey]
        if not grid then
            grid = XUiGridCommon.New(self.RootUi, self[itemKey])
            self[indexKey] = grid
        end
        grid:Refresh(templateId)

        local quality = XCharacterConfigs.GetCharMinQuality(templateId)
        self["RImgQuality" .. i]:SetRawImage(XCharacterConfigs.GetCharacterQualityIcon(quality))
        self["TxtName" .. i].text = XCharacterConfigs.GetCharacterFullNameStr(templateId)
    end

    self:UpdateVoteView()
end

function XUiPanelDetailTeamItem:UpdateVoteView()
    local voteMo = XDataCenter.VoteManager.GetVote(self.VoteId)
    local isGroupVoted = XDataCenter.VoteManager.IsGroupVoted(voteMo.GroupId)
    local isVoteSelected = XDataCenter.VoteManager.IsVoteSelected(voteMo.GroupId, self.VoteId)

    self.BtnVote.gameObject:SetActive(not isGroupVoted)
    self.PanelImgVoted.gameObject:SetActive(isGroupVoted and isVoteSelected)
    self.TxtVoteNum.text = tostring(voteMo.VoteNum)
end

function XUiPanelDetailTeamItem:OnBtnVoteClick(...)
    XUiHelper.StopAnimation()
    --XUiHelper.PlayAnimation(self.GameObject, "AniPanelTeamInfoVote")
    XDataCenter.VoteManager.AddVote(self.VoteId)
end

return XUiPanelDetailTeamItem