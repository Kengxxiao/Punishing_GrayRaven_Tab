XUiPanelDetailEquipItem = XClass()

function XUiPanelDetailEquipItem:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()

    self.GridItem = {
        [1] = self.GridItem1,
        [2] = self.GridItem2,
        [3] = self.GridItem3,
        [4] = self.GridItem4,
        [5] = self.GridItem5,
        [6] = self.GridItem6,
    }

    self.voteId = nil

    self.GridItems = {}
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelDetailEquipItem:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiPanelDetailEquipItem:AutoInitUi()
    self.TxtVoteNum = self.Transform:Find("TxtVoteNum"):GetComponent("Text")
    self.GridItem3 = self.Transform:Find("RootPanelLayout/GridItem3")
    self.GridItem2 = self.Transform:Find("RootPanelLayout/GridItem2")
    self.GridItem1 = self.Transform:Find("RootPanelLayout/GridItem1")
    self.Panel = self.Transform:Find("RootPanelWeapon/Panel")
    self.GridEquipItem = self.Transform:Find("RootPanelWeapon/Panel/GridEquipItem")
    self.TxtRank = self.Transform:Find("RootPanelRank/TxtRank"):GetComponent("Text")
    self.GridItem4 = self.Transform:Find("RootPanelLayout/GridItem4")
    self.GridItem5 = self.Transform:Find("RootPanelLayout/GridItem5")
    self.GridItem6 = self.Transform:Find("RootPanelLayout/GridItem6")
    self.BtnVote = self.Transform:Find("RootPanelBtn/BtnVote"):GetComponent("Button")
    self.PanelImgVoted = self.Transform:Find("RootPanelBtn/PanelImgVoted")
end

function XUiPanelDetailEquipItem:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelDetailEquipItem:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelDetailEquipItem:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelDetailEquipItem:AutoAddListener()
    self:RegisterClickEvent(self.BtnVote, self.OnBtnVoteClick)
end
-- auto
function XUiPanelDetailEquipItem:Init(rootUi)
    self.RootUi = rootUi
end

function XUiPanelDetailEquipItem:UpdateView(recommendConfig, rank)
    self.VoteId = recommendConfig.Id
    self.TxtRank.text = rank

    local template = XCharacterConfigs.GetCharDetailEquipTemplate(self.VoteId)
    if not template then
        return
    end

    --刷新装备
    self.GridEquip = self.GridEquip or XUiGridCommon.New(self.RootUi, self.GridEquipItem)
    self.GridEquip:Refresh(template.EquipRecomend)

    --刷新意识
    local chipList = template.ChipRecomend
    local len = #chipList

    for i = 1, 6 do
        if self.GridItem[i] then
            local gridItem = self.GridItems[i]
            if not gridItem then
                gridItem =  XUiGridCommon.New(self.RootUi, self.GridItem[i])
                self.GridItems[i] = gridItem
            end
            gridItem:Refresh(chipList[i])
        end
    end

    self:UpdateVoteView()
end

function XUiPanelDetailEquipItem:UpdateVoteView()
    local voteMo = XDataCenter.VoteManager.GetVote(self.VoteId)
    local isGroupVoted = XDataCenter.VoteManager.IsGroupVoted(voteMo.GroupId)
    local isVoteSelected = XDataCenter.VoteManager.IsVoteSelected(voteMo.GroupId, self.VoteId)

    self.BtnVote.gameObject:SetActive(not isGroupVoted)
    self.PanelImgVoted.gameObject:SetActive(isGroupVoted and isVoteSelected)
    self.TxtVoteNum.text = tostring(voteMo.VoteNum)
end

function XUiPanelDetailEquipItem:OnBtnVoteClick(...)
    XUiHelper.StopAnimation()
    XUiHelper.PlayAnimation(self.GameObject, "AniPanelEquipInfoVote")
    XDataCenter.VoteManager.AddVote(self.VoteId)
end

return XUiPanelDetailEquipItem