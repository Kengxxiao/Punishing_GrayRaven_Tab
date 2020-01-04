XUiPanelSkillInfo = XClass()

local MAX_SUB_SKILL_GRID_COUNT = 6
local MAX_MAIN_SKILL_GRID_COUNT = 5
local MAX_CONDITION_COUNT = 3

function XUiPanelSkillInfo:Ctor(ui, parent, rootUi)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.Parent = parent
    self.RootUi = rootUi
    self:InitAutoScript()
    self.GridSkillInfo.gameObject:SetActive(false)
    self.GridSubSkill.gameObject:SetActive(false)
    self.SkillInfoGo = {}
    table.insert(self.SkillInfoGo, self.GridSkillInfo)
    self.SkillInfoGrids = {}
    self:Refresh()
    self:InitSubSkillGrids()
end

function XUiPanelSkillInfo:InitSubSkillGrids()
    self.SubSkillGrids = {}
    for i = 1, MAX_SUB_SKILL_GRID_COUNT do
        local item = CS.UnityEngine.Object.Instantiate(self.GridSubSkill)  -- 复制一个item
        local grid = XUiGridSubSkill.New(item, i, function(subSkill, index)
            self:UpdateSubSkillInfoPanel(subSkill, index)
        end)
        grid.GameObject:SetActive(false)
        grid.Transform:SetParent(self.PanelSubSkillList, false)
        table.insert(self.SubSkillGrids, grid)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelSkillInfo:InitAutoScript()
    self:AutoInitUi()
    XTool.InitUiObject(self)
    self:AutoAddListener()
end

function XUiPanelSkillInfo:AutoInitUi()
    self.PanelSkillBig = self.Transform:Find("PaneSkillInfo/PanelSkillBig")
    self.ImgSkillPointIcon = self.Transform:Find("PaneSkillInfo/PanelSkillBig/ImgSkillPointIcon"):GetComponent("Image")
    self.TxtSkillType = self.Transform:Find("PaneSkillInfo/PanelSkillBig/TxtSkillType"):GetComponent("Text")
    self.TxtSkillName = self.Transform:Find("PaneSkillInfo/PanelSkillBig/TxtSkillName"):GetComponent("Text")
    self.TxtSkillLevel = self.Transform:Find("PaneSkillInfo/PanelSkillBig/TxtSkillLevel"):GetComponent("Text")
    self.BtnSkillpointAdd = self.Transform:Find("SkillPoint/BtnSkillpointAdd"):GetComponent("Button")
    self.TxtSkillNumber = self.Transform:Find("SkillPoint/TxtSkillNumber"):GetComponent("Text")
    self.RImgSkillIcon = self.Transform:Find("SkillPoint/RImgSkillIcon"):GetComponent("RawImage")
    self.PanelSubSkillList = self.Transform:Find("PaneSkillInfo/PanelSubSkillList")
    self.GridSubSkill = self.Transform:Find("PaneSkillInfo/PanelSubSkillList/GridSubSkill")
    self.PanelScroll = self.Transform:Find("PaneSkillInfo/PanelScroll")
    self.GridSkillInfo = self.Transform:Find("PaneSkillInfo/PanelScroll/GridSkillInfo")
    self.BtnHuadong = self.Transform:Find("PaneSkillInfo/BtnHuadong"):GetComponent("Button")
    self.BtnHuadong1 = self.Transform:Find("PaneSkillInfo/BtnHuadong1"):GetComponent("Button")
    self.PanelCondition = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelCondition")
    self.TxtConditionBad = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelCondition/TxtConditionBad"):GetComponent("Text")
    self.TxtConditionOk = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelCondition/TxtConditionOk"):GetComponent("Text")
    self.PanelConsume = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume")
    self.PanelSkillPoint = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume/PanelSkillPoint")
    self.PanelSkillPointBad = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume/PanelSkillPoint/PanelSkillPointBad")
    self.TxtSkillPointBad = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume/PanelSkillPoint/PanelSkillPointBad/TxtSkillPointBad"):GetComponent("Text")
    self.PanelSkillPointOk = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume/PanelSkillPoint/PanelSkillPointOk")
    self.TxtSkillPointOk = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume/PanelSkillPoint/PanelSkillPointOk/TxtSkillPointOk"):GetComponent("Text")
    self.PanelCoin = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume/PanelCoin")
    self.PanelCoinBad = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume/PanelCoin/PanelCoinBad")
    self.TxtCoinBad = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume/PanelCoin/PanelCoinBad/TxtCoinBad"):GetComponent("Text")
    self.PanelCoinOk = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume/PanelCoin/PanelCoinOk")
    self.TxtCoinOk = self.Transform:Find("PaneSkillInfo/SubSkillInfo/PanelConsume/PanelCoin/PanelCoinOk/TxtCoinOk"):GetComponent("Text")
end

function XUiPanelSkillInfo:RegisterClickEvent(uiNode, func)
    if func == nil then
        XLog.Error("XUiPanelSkillInfo:RegisterClickEvent: func is nil")
        return
    end

    if type(func) ~= "function" then
        XLog.Error("XUiPanelSkillInfo:RegisterClickEvent: func is not a function")
    end

    local listener = function(...)
        func(self, ...)
    end

    CsXUiHelper.RegisterClickEvent(uiNode, listener)
end

function XUiPanelSkillInfo:AutoAddListener()
    self:RegisterClickEvent(self.BtnSkillpointAdd, self.OnBtnSkillpointAddClick)
    self:RegisterClickEvent(self.BtnHuadong, self.OnBtnHuadongClick)
    self:RegisterClickEvent(self.BtnHuadong1, self.OnBtnHuadong1Click)
    self:RegisterClickEvent(self.BtnUpgrade, self.OnBtnUpgradeClick)
    self:RegisterClickEvent(self.BtnUnlock, self.OnBtnUnlockClick)
end
-- auto

function XUiPanelSkillInfo:OnBtnUpgradeClick(eventData)
    if (not self:CheckUpgradeSubSkill()) then
        return
    end

    if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(XDataCenter.ItemManager.ItemId.Coin,
            self.CurSubSkill.config.UseCoin,
            1,
            function() 
                self:OnBtnUpgradeClick()
            end,
            "CharacterUngradeSkillCoinNotEnough") then
        return
    end
    
    XDataCenter.CharacterManager.UpgradeSubSkillLevel(self.CharacterId, self.CurSubSkill.SubSkillId, function ()
        XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_INCREASE_TIP, CS.XTextManager.GetText("CharacterUngradeSkillComplete"))
        self:RefreshData()
        self:Refresh()
    end)
end

function XUiPanelSkillInfo:OnBtnUnlockClick(eventData)
    if (not self:CheckUpgradeSubSkill()) then
        return
    end
    
    if not XDataCenter.ItemManager.DoNotEnoughBuyAsset(XDataCenter.ItemManager.ItemId.Coin,
            self.CurSubSkill.config.UseCoin,
            1,
            function() 
                self:OnBtnUnlockClick()
            end,
            "CharacterUngradeSkillCoinNotEnough") then
        return
    end

    XDataCenter.CharacterManager.UnlockSubSkill(self.CurSubSkill.SubSkillId, self.CharacterId, function()
        XEventManager.DispatchEvent(XEventId.EVENT_CHARACTER_INCREASE_TIP, CS.XTextManager.GetText("CharacterUnlockSkillComplete"))
        self:RefreshData()
        self:Refresh()
    end)
end

function XUiPanelSkillInfo:OnBtnSkillpointAddClick(...)
    local id = XDataCenter.ItemManager.ItemId.SkillPoint
    XLuaUiManager.Open("UiTip", XDataCenter.ItemManager.GetItem(id))
end

function XUiPanelSkillInfo:OnBtnHuadongClick(...)
    if self.Pos then
        self:GotoSkill(self.Pos + 1)
    end
end

function XUiPanelSkillInfo:OnBtnHuadong1Click(...)
    if self.Pos then
        self:GotoSkill(self.Pos - 1)
    end
end

function XUiPanelSkillInfo:GotoSkill(index)
    if self.Parent.SkillGrids[index] then
        self.Parent.SkillGrids[index]:OnBtnIconBgClick()
    end
    self:UpdateArrowView()
end

function XUiPanelSkillInfo:UpdateArrowView()
    self.BtnHuadong.gameObject:SetActive(not (self.Pos == MAX_MAIN_SKILL_GRID_COUNT))
    self.BtnHuadong1.gameObject:SetActive(not (self.Pos == 1))
end

function XUiPanelSkillInfo:CheckUpgradeSubSkill()
    local subSkill = self.CurSubSkill
    local conditions = subSkill.config.ConditionId
    if not conditions then
        return true
    end

    for _, conditionId in pairs(conditions) do
        local passCondition = true
        local conditionDes = ""
        if conditionId ~= 0 then
            passCondition, conditionDes = XConditionManager.CheckCondition(conditionId, self.CharacterId)
            if not passCondition then
                XUiManager.TipMsg(conditionDes)
                return false
            end
        end
    end

    if (not XDataCenter.CharacterManager.IsUseItemEnough(XDataCenter.ItemManager.ItemId.SkillPoint, self.CurSubSkill.config.UseSkillPoint)) then
        XUiManager.TipText("CharacterUngradeSkillSkillPointNotEnough")
        return false
    end
    
    return true
end

function XUiPanelSkillInfo:ShowPanel(characterId, skills, pos)
    self.CharacterId = characterId or self.CharacterId
    self.Skills = skills
    self.Pos = pos
    self.Skill = skills[pos]
    self.IsShow = true
    self.GameObject:SetActive(true)

    for i, skill in pairs(skills) do
        local grid = self.SkillInfoGrids[i]
        if (grid == nil) then
            local ui_item = self.SkillInfoGo[i]
            if (ui_item == nil) then
                ui_item = CS.UnityEngine.Object.Instantiate(self.GridSkillInfo)
                table.insert(self.SkillInfoGo, ui_item)
            end
            grid = XUiGridSkillInfo.New(ui_item, skill)
            grid.Transform:SetParent(self.PanelScroll, false)
            table.insert(self.SkillInfoGrids, grid)
        else
            grid:UpdateData(skill)
        end

        grid.CurveValue = 0
        grid.GameObject:SetActive(true)
    end

    self:RefreshPanel(characterId, self.Skill)
    self:RefreshData()
    -- 默认点击
    if self.SubSkillGrids[1] then
        self.SubSkillGrids[1]:OnBtnSubSkillIconBgClick()
    end

    self:UpdateArrowView()
    self.Parent.SkillInfoQiehuan:PlayTimelineAnimation()
end

function XUiPanelSkillInfo:RefreshData()
    local characterId = self.CharacterId
    if not characterId then return end

    self.Skills = XCharacterConfigs.GetCharacterSkills(characterId)
    local skill = self.Skills[self.Skill.config.Pos]
    local grid = self.SkillInfoGrids[self.Pos]
    for i = 1, #self.SkillInfoGrids do
        self.SkillInfoGrids[i].GameObject:SetActive(self.Pos == i)
    end
    if (grid) then
        grid:UpdateData(skill)
    end
    self.Parent:UpdateSkill()
    self:RefreshPanel(self.CharacterId, skill)
    self:RefreshBigSkill(skill)
end

function XUiPanelSkillInfo:RefreshBigSkill(skill)
    self.RootUi:SetUiSprite(self.ImgSkillPointIcon, skill.Icon)
    self.TxtSkillType.text = skill.TypeDes
    self.TxtSkillName.text = skill.Name

    local totalResonanceLevel = 0
    for _, skillId in pairs(skill.SkillIdList) do
        totalResonanceLevel = totalResonanceLevel + XDataCenter.CharacterManager.GetResonanceSkillLevel(self.CharacterId, skillId)
    end

    local totalLevel = totalResonanceLevel + skill.TotalLevel
    self.TxtSkillLevel.text = totalLevel
end

function XUiPanelSkillInfo:RefreshPanel(characterId, skill)
    self.CharacterId = characterId or self.CharacterId

    self.Skill = skill
    self:UpdateSubSkillList(skill.subSkills)

    for i, sub_skill in ipairs(skill.subSkills) do
        if (i == self.CurSubSkillIndex) then
            self:UpdateSubSkillInfoPanel(sub_skill, self.CurSubSkillIndex)
            break
        end
    end
end

function XUiPanelSkillInfo:UpdateSubSkillList(subSkillList, cb)
    for _, grid in pairs(self.SubSkillGrids) do
        grid:Reset()
    end

    local count = #subSkillList

    if count > MAX_SUB_SKILL_GRID_COUNT then
        XLog.Warning("max subskill grid count is " .. MAX_SUB_SKILL_GRID_COUNT)
        count = MAX_SUB_SKILL_GRID_COUNT
    end

    for i = 1, count do
        local sub_skill = subSkillList[i]
        local grid = self.SubSkillGrids[i]
        grid:UpdateGrid(self.CharacterId, sub_skill)
        grid.GameObject.name = sub_skill.SubSkillId

        if i == 1 then
            grid:SetSelect(true)
        end
    end

    XEventManager.DispatchEvent(XEventId.EVENT_GUIDE_STEP_OPEN_EVENT)


    if (cb) then
        cb()
    end
end

function XUiPanelSkillInfo:UpdateSubSkillInfoPanel(subSkill, index)
    if not subSkill then return end

    if self.CurSubSkillIndex then
        self.SubSkillGrids[self.CurSubSkillIndex]:SetSelect(false)
    end

    local grid = self.SkillInfoGrids[self.Pos]
    if grid then
        local resonanceLevel = XDataCenter.CharacterManager.GetResonanceSkillLevel(self.CharacterId, subSkill.SubSkillId)
        grid:SetSubInfo(subSkill.Level, index, resonanceLevel)
    end

    self.CurSubSkillIndex = index
    self.SubSkillGrids[self.CurSubSkillIndex]:SetSelect(true)
    self.CurSubSkill = subSkill

    for _, grid in pairs(self.SubSkillGrids) do
        grid:ResetSelect(subSkill.SubSkillId)
    end

    local min_max = XCharacterConfigs.GetSubSkillMinMaxLevel(subSkill.SubSkillId)
    if (subSkill.Level >= min_max.Max) then
        self.PanelCondition.gameObject:SetActive(false)
        self.PanelConsume.gameObject:SetActive(false)
        self.BtnUpgrade.gameObject:SetActive(false)
        self.BtnUnlock.gameObject:SetActive(false)
        self.PanelMaxLevel.gameObject:SetActive(true)
        return
    else
        self.PanelMaxLevel.gameObject:SetActive(false)
    end

    local passCondition = true
    local conditionDes = ""
    local conditions = subSkill.config.ConditionId
    if conditions then
        for _, conditionId in pairs(conditions) do
            if conditionId ~= 0 then
                passCondition, conditionDes = XConditionManager.CheckCondition(conditionId, self.CharacterId)
                if not passCondition then
                    break
                end
            end
        end
    end

    self.PanelConsume.gameObject:SetActive(passCondition)
    self.PanelCondition.gameObject:SetActive(not passCondition)
    self.TxtConditionOk.gameObject:SetActive(passCondition)
    self.TxtConditionBad.gameObject:SetActive(not passCondition)

    if passCondition then
        self.TxtConditionOk.text = conditionDes
        --消耗技能点
        local showSkillPoint = subSkill.config.UseSkillPoint > 0
        self.PanelSkillPoint.gameObject:SetActive(showSkillPoint)
        if showSkillPoint then
            local isSkillPointMeet = XDataCenter.CharacterManager.IsUseItemEnough({ XDataCenter.ItemManager.ItemId.SkillPoint }, { subSkill.config.UseSkillPoint })
            if isSkillPointMeet then
                self.TxtSkillPointOk.text = subSkill.config.UseSkillPoint
            else
                self.TxtSkillPointBad.text = subSkill.config.UseSkillPoint
            end
            self.PanelSkillPointBad.gameObject:SetActive(not isSkillPointMeet)
            self.PanelSkillPointOk.gameObject:SetActive(isSkillPointMeet)
        end

        --消耗螺母
        local showCoin = subSkill.config.UseCoin > 0
        self.PanelCoin.gameObject:SetActive(showCoin)
        if showCoin then
            local isUseCoinMeet = XDataCenter.CharacterManager.IsUseItemEnough({ XDataCenter.ItemManager.ItemId.Coin }, { subSkill.config.UseCoin })
            if isUseCoinMeet then
                self.TxtCoinOk.text = subSkill.config.UseCoin
            else
                self.TxtCoinBad.text = subSkill.config.UseCoin
            end
            self.PanelCoinBad.gameObject:SetActive(not isUseCoinMeet)
            self.PanelCoinOk.gameObject:SetActive(isUseCoinMeet)
        end

        if not showCoin and not showSkillPoint then
            self.PanelConsume.gameObject:SetActive(false)
        end
    else
        self.TxtConditionBad.text = conditionDes
    end

    if (subSkill.Level <= 0) then
        self.BtnUnlock:SetDisable(not passCondition)
        self.BtnUnlock.gameObject:SetActive(true)
        self.BtnUpgrade.gameObject:SetActive(false)
    elseif (subSkill.Level < min_max.Max and subSkill.Level > 0) then
        local canUpdate = XDataCenter.CharacterManager.CheckCanUpdateSkill(self.CharacterId, subSkill.SubSkillId, subSkill.Level)
        self.BtnUpgrade:SetDisable(not canUpdate)
        self.BtnUpgrade.gameObject:SetActive(true)
        self.BtnUnlock.gameObject:SetActive(false)
    end
end

function XUiPanelSkillInfo:HidePanel()
    self.IsShow = false
    self.GameObject:SetActive(false)
    if (self.ScrollFlow) then
        self.ScrollFlow:Dispose()
    end
    self.CurSubSkillIndex = nil
    self.CurSubSkill = nil
    self.Parent.BtnSkillTeach.gameObject:SetActive(true)
end

function XUiPanelSkillInfo:Refresh()  --读取数据
    local item = XDataCenter.ItemManager.GetItem(XDataCenter.ItemManager.ItemId.SkillPoint)
    local count = item ~= nil and tostring(item.Count) or "0"
    local icon = XDataCenter.ItemManager.GetItemIcon(XDataCenter.ItemManager.ItemId.SkillPoint)
    self.TxtSkillNumber.text = count
    self.RImgSkillIcon:SetRawImage(icon)
end