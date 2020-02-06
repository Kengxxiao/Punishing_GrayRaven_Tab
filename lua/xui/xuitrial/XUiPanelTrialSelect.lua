local XUiPanelTrialSelect = XClass()
local XUiGridTrialDesItem = require("XUi/XUiTrial/XUiGridTrialDesItem")

function XUiPanelTrialSelect:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    self.RewardPanelList = {}
    XTool.InitUiObject(self)
    self:AddListener()
    self:InitUiAfterAuto()
end

function XUiPanelTrialSelect:InitUiAfterAuto()
    self.DynamicDesTable = XDynamicTableNormal.New(self.SViewTrialDesList.gameObject)
    self.DynamicDesTable:SetProxy(XUiGridTrialDesItem)
    self.DynamicDesTable:SetDelegate(self)
end

function XUiPanelTrialSelect:UpdataView(itemData)
    if not itemData then
        return
    end

    -- 设置说明
    self.TxtDes.text = itemData.Explain

    -- 设置名字
    self.TxtName.text = itemData.Name

    -- 设置图片
    local iconpath = itemData.BigPicture
    self.ImgIconA:SetRawImage(iconpath)

    -- 设置奖励
    local id = itemData.Id
    local flage = XDataCenter.TrialManager.TrialLevelFinished(id)
    if not flage or (flage and not XDataCenter.TrialManager.TrialRewardGeted(id)) then
        self.UiContent.gameObject:SetActiveEx(true)
        self:SetReward(itemData)
    else
        self.UiContent.gameObject:SetActiveEx(false)
    end

    -- 设置描述
    self.Des = itemData.Des
    self.DynamicDesTable:SetDataSource(itemData.Des)
    self.DynamicDesTable:ReloadDataASync(1)

    -- 等级
    self.StageId = itemData.StageId
    local stafecfg = XDataCenter.FubenManager.GetStageCfg(self.StageId)
    local level = stafecfg.RecommandLevel or 1
    self.TxtLevel.text = level

    -- 电量
    local active = stafecfg.RequireActionPoint or 0
    self.TxtNums.text = active

    -- 设置战斗力
    self:SetAbility(itemData)

    -- 设置进度
    self:SetPro(itemData)
end

function XUiPanelTrialSelect:SetPro(itemData)
    if itemData.Type == XDataCenter.TrialManager.TrialTypeCfg.TrialFor then
        self.TxtPro.text = string.format("%s/%s", itemData.Id, XTrialConfigs.GetForTotalLength())
    else
        self.TxtPro.text =
            string.format(
            "%s/%s",
            itemData.Id - XTrialConfigs.GetForTotalLength(),
            XTrialConfigs.GetBackEndTotalLength()
        )
    end
end

function XUiPanelTrialSelect:SetAbility(itemData)
    local charlist = XDataCenter.CharacterManager.GetCharacterList()
    local maxAbility = 0

    for i, v in pairs(charlist) do
        local ability = v.Ability or 0
        if ability > maxAbility then
            maxAbility = ability
        end
    end

    local ability = itemData.AvgAbility
    
    if ability < maxAbility then
        self.ImgEnough.gameObject:SetActive(true)
        self.ImgNotEnough.gameObject:SetActive(false)
        self.TxtFight.text = CS.XTextManager.GetText("AbilityCurrentSufficientTips", ability, math.floor(maxAbility))
    else
        self.ImgEnough.gameObject:SetActive(false)
        self.ImgNotEnough.gameObject:SetActive(true)
        self.TxtFightA.text = CS.XTextManager.GetText("AbilityCurrentInSufficientTips", ability, math.floor(maxAbility))
    end
end

function XUiPanelTrialSelect:SetReward(itemData)
    local rewards = XRewardManager.GetRewardList(itemData.RewardId)
    if not rewards then
        return
    end

    self.RewardListData = rewards
    local rewardCount = #rewards
    for i = 1, rewardCount do
        local panel = self.RewardPanelList[i]
        if not panel then
            local ui = CS.UnityEngine.Object.Instantiate(self.PanelReward)
            ui.transform:SetParent(self.UiContent, false)
            ui.gameObject:SetActive(true)
            ui.gameObject.name = string.format("PanelReward%d", i)
            panel = XUiGridCommon.New(self.UiRoot, ui)
            table.insert(self.RewardPanelList, i, panel)
        end
    end

    for i = 1, #self.RewardPanelList do
        self.RewardPanelList[i].GameObject:SetActive(i <= rewardCount)
        if i <= rewardCount then
            self.RewardPanelList[i]:Refresh(rewards[i])
        end
    end
end


-- [监听动态列表事件]
function XUiPanelTrialSelect:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self.UiRoot)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.Des[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
    end
end

-- 打开界面
function XUiPanelTrialSelect:OpenView(data)
    self.UiRoot:PlayAnimation("AniTrialDetailsOpen")
    self.GameObject:SetActive(true)
    self.ViewData = data
    self:UpdataView(data)
    self.UiRoot:CloseMainView()
    self.UiRoot:ClostMainListItemFx()
end

-- 关闭界面
function XUiPanelTrialSelect:CloseView(data)
    self.UiRoot:SetListItemFx()
    self.GameObject:SetActive(false)
    self.UiRoot:ReturnPreTrialBg()
    self.UiRoot.TrialMain.GameObject:SetActive(true)
end

function XUiPanelTrialSelect:AddListener()
   self.BtnEnterB.CallBack = function()self:OnBtnEnterBClick()end
end

function XUiPanelTrialSelect:OnSViewRewardListAClick(eventData)
end

function XUiPanelTrialSelect:OnBtnEnterBClick(eventData)
    if self.StageId then
        self.UiRoot:CloseSelectView()
        local Stage = XDataCenter.FubenManager.GetStageCfg(self.StageId)
        CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_ENTERFIGHT, Stage)
    end
end

function XUiPanelTrialSelect:OnGetEvents()
    return {XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL, XEventId.EVENT_FUBEN_ENTERFIGHT}
end
--事件监听
function XUiPanelTrialSelect:OnNotify(evt, ...)
    if evt == XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL then
    elseif evt == XEventId.EVENT_FUBEN_ENTERFIGHT then
        self:EnterFight(...)
    end
end

function XUiPanelTrialSelect:EnterFight(stage)
    if not XDataCenter.FubenManager.CheckPreFight(stage) then
        return
    end
    if not XDataCenter.FubenManager.CheckPreFight(stage) then      
        return
    end
    if XDataCenter.BfrtManager.CheckStageTypeIsBfrt(stage.StageId) then
        local groupId = XDataCenter.BfrtManager.GetGroupIdByBaseStage(stage.StageId)
        XLuaUiManager.Open("UiBfrtDeploy", groupId)
    else
        XLuaUiManager.Open("UiNewRoomSingle", stage.StageId)
    end
end
return XUiPanelTrialSelect
