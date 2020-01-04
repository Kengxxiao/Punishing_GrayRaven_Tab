XUiPanelFavorabilityMain = XClass()

local FuncType = {
    File = 1,
    Story = 2,
    Gift = 3,
}

local ExpSchedule = nil
local Delay_Second = CS.XGame.ClientConfig:GetInt("FavorabilityDelaySecond") / 1000
local blue = "#87C8FF"
local white = "#ffffff"

function XUiPanelFavorabilityMain:Ctor(ui, uiRoot)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiRoot
    XTool.InitUiObject(self)
    self.IsExpTweening = false
    self:InitUiAfterAuto()
end

function XUiPanelFavorabilityMain:InitUiAfterAuto()

    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    self.RedPointDocumentId = XRedPointManager.AddRedPointEvent(self.ImgRedPoint0, nil, self, { XRedPointConditions.Types.CONDITION_FAVORABILITY_DOCUMENT }, { CharacterId = characterId })
    self.RedPointPlotId = XRedPointManager.AddRedPointEvent(self.ImgRedPoint1, nil, self, { XRedPointConditions.Types.CONDITION_FAVORABILITY_PLOT }, { CharacterId = characterId })

    self.BtnReturn.CallBack = function() self:OnBtnReturnClick() end
    self.BtnMainUi.CallBack = function() self:OnBtnMainUiClick() end

    -- 初始化按钮
    self.BtnTabList = {}
    self.BtnTabList[FuncType.File] = self.BtnFile
    self.BtnTabList[FuncType.Story] = self.BtnScenario
    self.BtnTabList[FuncType.Gift] = self.BtnGift
    self.MenuBtnGroup:Init(self.BtnTabList, function(index) self:OnBtnTabListClick(index) end)
    self.CurrentSelectTab = FuncType.File
    -- self.LastSelectTab = FuncType.File
    self.MenuBtnGroup:SelectIndex(self.CurrentSelectTab)
end

-- [刷新主界面]
function XUiPanelFavorabilityMain:RefreshDatas()
    self:UpdateDatas()
end



function XUiPanelFavorabilityMain:UpdateDatas()
    self.PanelMenu.gameObject:SetActive(true)

    self:UpdateAllInfos()
end

function XUiPanelFavorabilityMain:UpdateAllInfos(doAnim)
    -- 好感度信息
    self:UpdateMainInfo(doAnim)    

    -- 红点checkcheck
    self:CheckLockAndReddots()
end

function XUiPanelFavorabilityMain:UpdateMainInfo(doAnim)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local curExp = tonumber(XDataCenter.FavorabilityManager.GetCurrCharacterExp(characterId))
    local trustLv = XDataCenter.FavorabilityManager.GetCurrCharacterFavorabilityLevel(characterId)
    local name = XCharacterConfigs.GetCharacterName(characterId)
    local tradeName = XCharacterConfigs.GetCharacterTradeName(characterId)
    self.TxtRoleName.text = string.format("%s %s", name, tradeName)
    
    local curFavorabilityTableData = XDataCenter.FavorabilityManager.GetFavorabilityTableData(characterId)
    if curFavorabilityTableData == nil then return end
    if not doAnim then
        self.ImgExp.fillAmount = curExp / (tonumber(curFavorabilityTableData.Exp) * 1.0)
        self.TxtLevel.text = trustLv
    end
    self.UiRoot:SetUiSprite(self.ImgHeart, XFavorabilityConfigs.GetTrustLevelIconByLevel(trustLv))
    self.TxtFavorabilityLv.text = XDataCenter.FavorabilityManager.GetFavorabilityColorWorld(trustLv, curFavorabilityTableData.Name)--curFavorabilityTableData.Name
    
    self:UpdateExpNum(white)

    self:CheckExp(characterId)
end

function XUiPanelFavorabilityMain:UpdatePreviewExp(args)
    if not args then 
        self:ResetPreviewExp()
        return 
    end
    
    local trustItem = args[1]
    local count = args[2]
    if not trustItem or count==nil or count <= 0 then
        self:ResetPreviewExp()
        return
    end
    
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local isMax = XDataCenter.FavorabilityManager.IsMaxFavorabilityLevel(characterId)
    if isMax then
        return
    end
    
    local curExp = tonumber(XDataCenter.FavorabilityManager.GetCurrCharacterExp(characterId))

    local curFavorabilityTableData = XDataCenter.FavorabilityManager.GetFavorabilityTableData(characterId)
    if not curFavorabilityTableData then
        self:ResetPreviewExp()
        return
    end

    local favorExp = trustItem.Exp
    for k, v in pairs(trustItem.FavorCharacterId) do
        if v == characterId then
            favorExp = trustItem.FavorExp
            break
        end
    end

    
    local totalExp = curExp + count * favorExp
    local expFillAmount = totalExp / (tonumber(curFavorabilityTableData.Exp) * 1.0)
    expFillAmount = (expFillAmount >= 1) and 1 or expFillAmount
    self.ImgExpUp.fillAmount = expFillAmount
    
    self:UpdateExpNum(blue, totalExp)
end

function XUiPanelFavorabilityMain:ResetPreviewExp()
    self.ImgExpUp.fillAmount = 0
    self:UpdateExpNum(white)
end

function XUiPanelFavorabilityMain:UpdateExpNum(color, showExp)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local curFavorabilityTableData = XDataCenter.FavorabilityManager.GetFavorabilityTableData(characterId)
    local curExp = tonumber(XDataCenter.FavorabilityManager.GetCurrCharacterExp(characterId))
    curExp = (showExp == nil) and curExp or showExp
    
    local isMax = XDataCenter.FavorabilityManager.IsMaxFavorabilityLevel(characterId)
    if isMax then
        curExp = 0
    end

    if curFavorabilityTableData == nil then return end
    if curFavorabilityTableData.Exp <= 0 then
        self.TxtFavorabilityExpNum.text = string.format("%d", curExp)
    else
        self.TxtFavorabilityExpNum.text = string.format("<color=%s>%d</color> / %s", color, curExp, tostring(curFavorabilityTableData.Exp))
    end
end

-- [发送检查红点事件]
function XUiPanelFavorabilityMain:CheckLockAndReddots()
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    XRedPointManager.Check(self.RedPointDocumentId, { CharacterId = characterId })
    XRedPointManager.Check(self.RedPointPlotId, { CharacterId = characterId })
end

-- [关闭功能按钮界面]
function XUiPanelFavorabilityMain:CloseFuncBtns()
    self.PanelMenu.gameObject:SetActive(false)
end

-- [点击的功能是否开启，如果未开启，提示]
function XUiPanelFavorabilityMain:CheckClickIsLock(funcName)
    local isOpen = XFunctionManager.JudgeCanOpen(funcName)
    local uplockTips = XFunctionManager.GetFunctionOpenCondition(funcName)
    if not isOpen then
        XUiManager.TipError(uplockTips)
    end
    return isOpen
end

-- [打开档案]
function XUiPanelFavorabilityMain:OnBtnFileClick(eventData)
    if not self:CheckClickIsLock(XFunctionManager.FunctionName.FavorabilityFile) then return end
    self.UiRoot:OpenInformationView()
end

-- [打开剧情]
function XUiPanelFavorabilityMain:OnBtnScenarioClick(eventData)
    if not self:CheckClickIsLock(XFunctionManager.FunctionName.FavorabilityStory) then return end
    self.UiRoot:OpenPlotView()
end

-- [打开礼物]
function XUiPanelFavorabilityMain:OnBtnGiftClick(eventData)
    if not self:CheckClickIsLock(XFunctionManager.FunctionName.FavorabilityGift) then return end
    self.UiRoot:OpenGiftView()
end

function  XUiPanelFavorabilityMain:OnBtnTabListClick(index)
    if self.LastSelectTab then
        self.UiRoot:PlayBaseTabAnim()
    end
    self.LastSelectTab = self.CurrentSelectTab
    self.CurrentSelectTab = index

    if index == FuncType.File then
        self:OnBtnFileClick()
    elseif index == FuncType.Story then
        self:OnBtnScenarioClick()
    elseif index == FuncType.Gift then
        self:OnBtnGiftClick()
    end
end

-- [返回]
function XUiPanelFavorabilityMain:OnBtnReturnClick(eventData)
    self.UiRoot:SetCurrFavorabilityCharacter(nil)
    self.UiRoot:Close()
end

function XUiPanelFavorabilityMain:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiPanelFavorabilityMain:DoFillAmountTween(lastLevel, lastExp, totalExp, isReset)
    local characterId = self.UiRoot:GetCurrFavorabilityCharacter()
    local levelUpDatas = XFavorabilityConfigs.GetTrustExpById(characterId)
    if not levelUpDatas or not levelUpDatas[lastLevel] then 
        self:UpdateAnimInfo(characterId)
        return 
    end
    if isReset then
        self.ImgExp.fillAmount = 0
    else
        XLuaUiManager.SetMask(true)
    end
    
    self.IsExpTweening = true
    local progress = 1
    if lastExp + totalExp < levelUpDatas[lastLevel].Exp then
        progress = (lastExp + totalExp) / levelUpDatas[lastLevel].Exp
        totalExp = 0
    else
        totalExp = totalExp - (levelUpDatas[lastLevel].Exp - lastExp)
    end
    self.ImgExp:DOFillAmount(progress, Delay_Second)
    ExpSchedule = CS.XScheduleManager.ScheduleOnce(function()
        local maxLevel = XFavorabilityConfigs.GetMaxFavorabilityLevel(characterId)
        if totalExp <= 0 or maxLevel == lastLevel then
            self:UpdateAnimInfo(characterId)
            self:UnScheduleExp()
        else
            self.TxtLevel.text = lastLevel + 1
            self:DoFillAmountTween(lastLevel+ 1, 0, totalExp, true)
        end
    end, Delay_Second * 1000 + 20)
end

-- 动画执行不了则走这里
function XUiPanelFavorabilityMain:UpdateAnimInfo(characterId)
    local trustLv = XDataCenter.FavorabilityManager.GetCurrCharacterFavorabilityLevel(characterId)
    self.TxtLevel.text = trustLv
    self:CheckExp(characterId)
end

function XUiPanelFavorabilityMain:CheckExp(characterId)
    local isMax = XDataCenter.FavorabilityManager.IsMaxFavorabilityLevel(characterId)
    if isMax then
        self.ImgExp.fillAmount = 0
        self.TxtFavorabilityExpNum.text = 0
        return 
    end

    local curExp = tonumber(XDataCenter.FavorabilityManager.GetCurrCharacterExp(characterId))
    if curExp <= 0 and self.ImgExp.fillAmount >= 1 then
        self.ImgExp.fillAmount = 0
    end
end

function XUiPanelFavorabilityMain:UnScheduleExp()
    if ExpSchedule then
        CS.XScheduleManager.UnSchedule(ExpSchedule)
        ExpSchedule = nil
        self.IsExpTweening = false
        XLuaUiManager.SetMask(false)
    end
end

function XUiPanelFavorabilityMain:OnClose()
    self:UnScheduleExp()
end

function XUiPanelFavorabilityMain:SetTopControlActive(isActive)
    self.TopControl.gameObject:SetActive(isActive)
end

return XUiPanelFavorabilityMain
