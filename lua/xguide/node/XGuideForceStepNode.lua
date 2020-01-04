local GuideForceStepNode = XLuaBehaviorManager.RegisterNode(XLuaBehaviorNode, "GuideForceStep", CsBehaviorNodeType.Action, true, false)
local GuideForceStepType = {
    RunMain = 100, --返回主界面
    OpenUi = 200, --打开不带参数的UI（Par1:Ui名字）
    OpenFubenUi = 201, --打开副本页面（Par1:难度ID）
    ClickMainLineBanner = 300, --点击主线副本章节（Par1:主章节ID）
    ClickFubenStage = 301, --点击关卡（Par1:关卡ID）
    ClickStartFight = 302, --点击作战开始进入战前准备（Par1:关卡ID）
    ClickEnterFight = 303, --点击开始战斗进入关卡（Par1:关卡ID）
    GetTaskReward = 400, --领取任务奖励（Par1:奖励ID）
    SetUpEquip = 500, --装备意识
    OpenAwarenessReplace = 600, --打开意识装备界面(Par1:位置)
    OpenAwarenessDetail = 700, --打开意识详情界面（Par1:意识ID）
    ClickAwarenessPos = 800, --选择意识装备栏（Par1:位置）
    GetLiFu = 900, --领取丽芙
    OpenCharacterUi = 901, --打开角色培养界面
    SelectCharacterList = 1000, --选取角色养成列表（Par1:角色ID）
    ClickButtonLevelUp = 1100, --点击培养按钮
    ClickButtonLevel = 1200, --点击升级按钮
    ClickLevelUpItem = 1300, --点击经验物品
    LevelUp = 1400, --升级
    ClickTaskJump = 1500, --点击任务跳转（BtnSkip）
    ClickNewRoomChar1 = 1600, --点击出战页面第一个角色槽位
    ClickSelectChar = 1700, --点击选择一个角色
    ConformSelectChar = 1800, --确认选人
    SelectSkillLevelTab = 1900, --养成界面选择技能tab
    SelectSkillBall = 2000, --养成界面选择技能tab后选择技能球
    SelectSkillBallLevelUp = 2100, --养成界面选择技能tab后选择技能球后点升级
}
--引导开启节点
function GuideForceStepNode:OnStart()
    -- self.GuideId = self.BehaviorTree:GetLocalField("GuideId").Value
end

function GuideForceStepNode:OnEnter()
    local type = self.Fields["Type"]
    if type == GuideForceStepType.RunMain then

        if not XLuaUiManager.IsUiShow("UiMain") then
            CsXUiManager.Instance:RunMain()
        end

    elseif type == GuideForceStepType.OpenUi then

        local cb = function(ui)
            self.Agent:SetVarDicByKey(self.Fields["Par1"], ui)
        end
        XLuaUiManager.OpenWithCallback(self.Fields["Par1"], cb, chapter)

    elseif type == GuideForceStepType.OpenFubenUi then

        XLuaUiManager.Open("UiFuben")

    elseif type == GuideForceStepType.ClickMainLineBanner then

        local chapter = XDataCenter.FubenMainLineManager.GetChapterCfgByChapterMain(tonumber(self.Fields["Par1"]), CS.XGame.Config:GetInt("FubenDifficultNormal"))
        local cb = function(ui)
            self.Agent:SetVarDicByKey("UiFubenMainLineChapter", ui)
        end
        XLuaUiManager.OpenWithCallback("UiFubenMainLineChapter", cb, chapter)

    elseif type == GuideForceStepType.ClickFubenStage then

        local stage = XDataCenter.FubenManager.GetStageCfg(tonumber(self.Fields["Par1"]))
        local ui = self.Agent:GetVarDicByKey("UiFubenMainLineChapter")
        if ui then
            ui:OpenOneChildUi("UiFubenMainLineDetail", stage)
        end

    elseif type == GuideForceStepType.ClickStartFight then

        local stage = XDataCenter.FubenManager.GetStageCfg(tonumber(self.Fields["Par1"]))
        local cb = function(ui)
            self.Agent:SetVarDicByKey("UiNewRoomSingle", ui)
        end
        XLuaUiManager.OpenWithCallback("UiNewRoomSingle", cb, stage.StageId)

    elseif type == GuideForceStepType.ClickEnterFight then

        local stage = XDataCenter.FubenManager.GetStageCfg(tonumber(self.Fields["Par1"]))
        local teamId = CS.XGame.Config:GetInt("TypeIdMainLine")
        XDataCenter.FubenManager.EnterFight(stage, XDataCenter.TeamManager.GetPlayerTeam(teamId).TeamId, false)

    elseif type == GuideForceStepType.GetTaskReward then

        XDataCenter.TaskManager.FinishTask(tonumber(self.Fields["Par1"]), function(rewardGoodsList)
            XUiManager.OpenUiObtain(rewardGoodsList)
        end)

    elseif type == GuideForceStepType.SetUpEquip then

        XDataCenter.EquipManager.PutOn(self.Agent:GetVarDicByKey("UiEquipCharacterId"), self.Agent:GetVarDicByKey("UiEquipSelectEquipId"))

    elseif type == GuideForceStepType.OpenAwarenessReplace then

        local cb = function(ui)
            ui.UiProxy.UiLuaTable.CharacterId = tonumber(self.Fields["Par1"])
            self.Agent:SetVarDicByKey("UiEquipAwarenessReplace", ui)
            self.Agent:SetVarDicByKey("UiEquipCharacterId", tonumber(self.Fields["Par1"]))
        end
        XLuaUiManager.OpenWithCallback("UiEquipAwarenessReplace", cb, tonumber(self.Fields["Par1"]), tonumber(self.Fields["Par2"]))

    elseif type == GuideForceStepType.OpenAwarenessDetail then

        local ui = self.Agent:GetVarDicByKey("UiEquipAwarenessReplace")
        if ui then
            local templateId = tonumber(self.Fields["Par1"])
            ui.UiProxy.UiLuaTable.SelectEquipId = XDataCenter.EquipManager.GetFirstEquip(templateId).Id
            ui:OpenOneChildUi("UiEquipAwarenessPopup", ui.UiProxy.UiLuaTable, false)
            self.Agent:SetVarDicByKey("UiEquipSelectEquipId", ui.UiProxy.UiLuaTable.SelectEquipId)
        end

    elseif type == GuideForceStepType.ClickAwarenessPos then

        local ui = self.Agent:GetVarDicByKey("UiEquipAwarenessReplace")
        if ui then
            ui.UiProxy.UiLuaTable:SelectEquipSite(tonumber(self.Fields["Par1"]))
        end

    elseif type == GuideForceStepType.GetLiFu then

        XDataCenter.TaskManager.GetCourseReward(tonumber(self.Fields["Par1"]))

    elseif type == GuideForceStepType.OpenCharacterUi then

        local cb = function(ui)
            self.Agent:SetVarDicByKey("UiCharacter", ui)
        end
        XLuaUiManager.OpenWithCallback("UiCharacter", cb)

    elseif type == GuideForceStepType.SelectCharacterList then

        local ui = self.Agent:GetVarDicByKey("UiCharacter")
        if ui then
            local characterId = tonumber(self.Fields["Par1"])
            ui.UiProxy.UiLuaTable:UpdateCharacterList(characterId)
        end

    elseif type == GuideForceStepType.ClickButtonLevelUp then

        local ui = self.Agent:GetVarDicByKey("UiCharacter")
        if ui then
            ui.UiProxy.UiLuaTable:FindChildUiObj("UiCharacterOwnedInfo"):OnBtnLevelUpClick()
        end

    elseif type == GuideForceStepType.ClickButtonLevel then

        local ui = self.Agent:GetVarDicByKey("UiCharacter")
        if ui then
            ui.UiProxy.UiLuaTable:FindChildUiObj("UiPanelCharProperty").PanelsMap[1]:OnBtnLevelUpButtonClick()
        end

    elseif type == GuideForceStepType.ClickLevelUpItem then

        local ui = self.Agent:GetVarDicByKey("UiCharacter")
        if ui then
            ui.UiProxy.UiLuaTable:FindChildUiObj("UiPanelCharProperty").PanelsMap[1].SelectLevelItems:DealSelectItem(1, 1)
        end

    elseif type == GuideForceStepType.LevelUp then

        local ui = self.Agent:GetVarDicByKey("UiCharacter")
        if ui then
            ui.UiProxy.UiLuaTable:FindChildUiObj("UiPanelCharProperty").PanelsMap[1].SelectLevelItems:SendLevelExpItems()
        end

    elseif type == GuideForceStepType.ClickTaskJump then

        local taskId = tonumber(self.Fields["Par1"])
        local skipId = XDataCenter.TaskManager.GetTaskTemplate(taskId).SkipId
        XFunctionManager.SkipInterface(skipId)

    elseif type == GuideForceStepType.ClickNewRoomChar1 then

        local ui = self.Agent:GetVarDicByKey("UiNewRoomSingle")
        if ui then
            ui.UiProxy.UiLuaTable:OnBtnChar1Click()
        end

    elseif type == GuideForceStepType.ClickSelectChar then

        local ui = self.AgentProxy:GetUi("UiMainLineRoomCharacter")
        if ui then
            ui:SelectCharacter(tonumber(self.Fields["Par1"]))
        end

    elseif type == GuideForceStepType.ConformSelectChar then

        local ui = self.AgentProxy:GetUi("UiMainLineRoomCharacter")
        if ui then
            ui:OnBtnJoinTeamClick()
        end

    elseif type == GuideForceStepType.SelectSkillLevelTab then

        local ui = self.Agent:GetVarDicByKey("UiCharacter")
        if ui then
            ui.UiProxy.UiLuaTable:FindChildUiObj("UiPanelCharProperty"):OnClickTabCallBack(4)
        end

    elseif type == GuideForceStepType.SelectSkillBall then

        local ui = self.Agent:GetVarDicByKey("UiCharacter")
        if ui then
            ui.UiProxy.UiLuaTable:FindChildUiObj("UiPanelCharProperty").PanelsMap[4]:OnSelectSkill(1)
        end

    elseif type == GuideForceStepType.SelectSkillBallLevelUp then

        local cb = function()
            XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_INCREASE_TIP, CS.XTextManager.GetText("CharacterUngradeSkillComplete"))
            local ui = self.AgentProxy:GetUi("UiPanelCharProperty")
            if ui then
                ui:RefreshData()
                ui:Refresh()
            end
        end
        XDataCenter.CharacterManager.UpgradeSubSkillLevel(tonumber(self.Fields["Par1"]), tonumber(self.Fields["Par2"]), cb)

    end



    self.Node.Status = CsNodeStatus.SUCCESS
end