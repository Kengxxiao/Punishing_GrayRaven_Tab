local XUiDraw = XLuaUiManager.Register(XLuaUi, "UiDraw")
local drawControl = require("XUi/XUiDraw/XUiDrawControl")
local XUiGridSuitDetail = require("XUi/XUiEquipAwarenessReplace/XUiGridSuitDetail")
local gridParams = { ShowUp = true }
local IndexBaseRule = 1
local IndexPreview = 2
local IndexEventRule = 4
function XUiDraw:OnAwake()
    self:InitAutoScript()
end

function XUiDraw:OnStart(groupId, closeCb, backGround)
    self.GroupId = groupId
    self.CloseCb = closeCb
    self.BackGroundPath = backGround
    XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    local list = XDataCenter.DrawManager.GetDrawInfoListByGroupId(groupId)
    local bool = #list > 1
    self.BtnOptionalDraw.gameObject:SetActiveEx(bool)
    self.UpShows = {}
    self.UpSuitShows = {}
    self.BottomInfoTxts = {}
    self.FirstAnim = true
    local upShow = XUiGridCommon.New(self, self.GridCommon)
    table.insert(self.UpShows, upShow)
    local drawInfo = XDataCenter.DrawManager.GetUseDrawInfoByGroupId(groupId)
    self.DrawControl = drawControl.New(self, drawInfo, function(info)
        self:UpdateItemCount()
    end, self)
    self:UpdateInfo(drawInfo)
    self.ImgMask.gameObject:SetActiveEx(false)
    self:LoadMainRule()
    self:UpdateResetTime()
    self:InitDrawBackGround(self.BackGroundPath)
    self.PanelCharacterBottomInfo.gameObject:SetActiveEx(false)
end

function XUiDraw:LoadMainRule()
    local groupRule = XDataCenter.DrawManager.GetDrawGroupRule(self.GroupId)
    self.TxtTitle.text = groupRule.TitleCN
    local mainRules = groupRule.MainRules
    local mainRule = mainRules[1]
    for i = 2, #mainRules do
        mainRule = mainRule .. "\n" .. mainRules[i]
    end
    self.TxtDesc.text = mainRule
end

function XUiDraw:UpdateResetTime()
    local groupInfo = XDataCenter.DrawManager.GetDrawGroupInfoByGroupId(self.GroupId)
    if groupInfo and groupInfo.EndTime > 0 then
        local remainTime = groupInfo.EndTime - XTime.GetServerNowTimestamp()
        XCountDown.CreateTimer(self.GameObject.name, remainTime)
        XCountDown.BindTimer(self.GameObject, self.GameObject.name, function(v, oldV)
            if groupInfo.Type == XDataCenter.DrawManager.DrawEventType.Activity then
                self.TxtRemainTime.text = CS.XTextManager.GetText("DrawResetTimeActivity", XUiHelper.GetTime(v, XUiHelper.TimeFormatType.DRAW))
            elseif groupInfo.Type == XDataCenter.DrawManager.DrawEventType.OldActivity then
                self.TxtRemainTime.text = CS.XTextManager.GetText("DrawResetTimeOldActivity", XUiHelper.GetTime(v, XUiHelper.TimeFormatType.DRAW))
            else
                self.TxtRemainTime.text = CS.XTextManager.GetText("DrawResetTime", XUiHelper.GetTime(v, XUiHelper.TimeFormatType.DRAW))
            end
        end)
        self.TxtRemainTime.gameObject:SetActiveEx(false)
    else
        self.TxtRemainTime.gameObject:SetActiveEx(false)
    end
end

function XUiDraw:UpdateInfo(drawInfo)
    local groupInfo = XDataCenter.DrawManager.GetDrawGroupInfoByGroupId(self.GroupId)
    self.DrawInfo = drawInfo
    self.DrawControl:Update(self.DrawInfo)
    local icon = XDataCenter.ItemManager.GetItemBigIcon(drawInfo.UseItemId)
    self.ImgUseItemIcon:SetRawImage(icon)
    local combination = XDataCenter.DrawManager.GetDrawCombination(drawInfo.Id)
    self.PanelUp.gameObject:SetActiveEx(false)
    self.PanelSuitUpShow.gameObject:SetActiveEx(false)
    self.BtnPreviewLeft.gameObject:SetActiveEx(false)
    self.PanelCharacter.gameObject:SetActiveEx(false)
    self.PanelNewUp.gameObject:SetActiveEx(false)
    if combination then
        if combination.Type == XDrawConfigs.CombinationsTypes.Normal then
            self:UpdateLeftUpInfo(combination)
        elseif combination.Type == XDrawConfigs.CombinationsTypes.Aim then
            self:UpdateLeftUpInfo(combination)
        elseif combination.Type == XDrawConfigs.CombinationsTypes.NewUp then
            self.PanelNewUp.gameObject:SetActiveEx(true)
            self:UpdateNewUpInfo(combination)
        elseif combination.Type == XDrawConfigs.CombinationsTypes.Furniture then
            self:UpdateLeftUpInfo(combination)
        elseif combination.Type == XDrawConfigs.CombinationsTypes.EquipSuit then
            self:UpdateLeftSuitUpInfo(combination)
        elseif combination.Type == XDrawConfigs.CombinationsTypes.CharacterUp then
            self.PanelCharacter.gameObject:SetActiveEx(true)
            self:UpdateCharacterInfo(combination)
        end
    end
    self:UpdateItemCount()
    CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.PanelLeft)

    if groupInfo.Type == XDataCenter.DrawManager.DrawEventType.NewHand then
        if drawInfo.MaxBottomTimes == XDataCenter.DrawManager.GetDrawGroupRule(self.GroupId).NewHandBottomCount then
            self.PanelNewHand.gameObject:SetActiveEx(true)
            self.NewHandCount.text = CS.XTextManager.GetText("DrawNewHandCount",drawInfo.BottomTimes.."/"..drawInfo.MaxBottomTimes)
        else
            self.PanelNewHand.gameObject:SetActiveEx(false)
        end
    else
        self.PanelNewHand.gameObject:SetActiveEx(false)
    end
    self:UpdateCharacterTxt()
end
--更新一般物品Up保底显示列表（左边）
function XUiDraw:UpdateLeftUpInfo(combination)
    local parentObj = nil
    local startIndex = 1
    if combination.Type == XDrawConfigs.CombinationsTypes.Aim then
        parentObj = self.PanelUpShow
        self.PanelUp.gameObject:SetActiveEx(true)
        startIndex = 1
    end
    local list = combination and combination.GoodsId or {}
    for i = startIndex, #list do
        if not self.UpShows[i] then
            local go = CS.UnityEngine.Object.Instantiate(self.GridCommon, parentObj)
            local upShow = XUiGridCommon.New(self, go)
            table.insert(self.UpShows, upShow)
        end
        local id = list[i]

        self.UpShows[i]:Refresh(list[i], gridParams)
    end

    for i = #list + 1, #self.UpShows do
        self.UpShows[i].GameObject:SetActiveEx(false)
    end
    
    if #list > 0 then
        self.BtnPreviewLeft.gameObject:SetActiveEx(true)
    else
        self.BtnPreviewLeft.gameObject:SetActiveEx(false)
    end
end
--更新Up保底显示列表（意识组合Up类）（左边）
function XUiDraw:UpdateLeftSuitUpInfo(combination)
    self.GridSuitCommon.gameObject:SetActiveEx(false)
    self.PanelSuitUpShow.gameObject:SetActiveEx(true)
    self.PanelUp.gameObject:SetActiveEx(false)

    if self.DrawInfo then
        local list = combination and combination.GoodsId or {}
        for i = 1, #list do
            if not self.UpSuitShows[i] then
                local go = CS.UnityEngine.Object.Instantiate(self.GridSuitCommon, self.PanelSuitUpShow)
                go.gameObject:SetActiveEx(true)
                local upShow = XUiGridSuitDetail.New(go, self)
                table.insert(self.UpSuitShows, upShow)
            end
            local id = list[i]

            self.UpSuitShows[i]:Refresh(list[i], nil, true)
        end

        for i = #list + 1, #self.UpSuitShows do
            self.UpSuitShows[i].GameObject:SetActiveEx(false)
        end
        
        if #list > 0 then
            self.BtnPreviewLeft.gameObject:SetActiveEx(true)
        else
            self.BtnPreviewLeft.gameObject:SetActiveEx(false)
        end
    end
end
--更新角色Up保底显示信息（左边）
function XUiDraw:UpdateCharacterInfo(combination)
    --self.TxtBottomTimes.text = CS.XTextManager.GetText("DrawRuleHint","asd","asd")--, self.DrawInfo.BottomTimes
    if self.DrawInfo then
        -- self.ImgBottomIco = self.Transform:Find("SafeAreaContentPane/PanelDrawGroup/PanelDraw/PanelLeft/PanelCharacter/PanelCharacterBottom/UpCharacter/ImgBottomIco"):GetComponent("RawImage")
        -- self.ImgBottomRank = self.Transform:Find("SafeAreaContentPane/PanelDrawGroup/PanelDraw/PanelLeft/PanelCharacter/PanelCharacterBottom/UpCharacter/ImgBottomRank"):GetComponent("RawImage")
        self.GoodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(combination.GoodsId[1])
        self.ImgBottomIco:SetRawImage(self.GoodsShowParams.Icon)
        local quality = XCharacterConfigs.GetCharMinQuality(combination.GoodsId[1])
        self.ImgBottomRank:SetRawImage(XCharacterConfigs.GetCharQualityIcon(quality))
        if #combination.GoodsId > 1 then
            -- self.Transform:Find("SafeAreaContentPane/PanelDrawGroup/PanelDraw/PanelLeft/PanelCharacter/PanelCharacterUpShow/UpCharacter2").gameObject:SetActiveEx(true)
            -- self.ImgBottomIco2 = self.Transform:Find("SafeAreaContentPane/PanelDrawGroup/PanelDraw/PanelLeft/PanelCharacter/PanelCharacterUpShow/UpCharacter2/ImgBottomIco2"):GetComponent("RawImage")
            -- self.ImgBottomRank2 = self.Transform:Find("SafeAreaContentPane/PanelDrawGroup/PanelDraw/PanelLeft/PanelCharacter/PanelCharacterUpShow/UpCharacter2/ImgBottomRank2"):GetComponent("RawImage")
            self.UpCharacter2.gameObject:SetActiveEx(true)
            self.GoodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(combination.GoodsId[2])
            self.ImgBottomIco2:SetRawImage(self.GoodsShowParams.Icon)
            local quality = XCharacterConfigs.GetCharMinQuality(combination.GoodsId[2])
            self.ImgBottomRank2:SetRawImage(XCharacterConfigs.GetCharQualityIcon(quality))
        else
            -- self.Transform:Find("SafeAreaContentPane/PanelDrawGroup/PanelDraw/PanelLeft/PanelCharacter/PanelCharacterUpShow/UpCharacter2").gameObject:SetActiveEx(false)
            self.UpCharacter2.gameObject:SetActiveEx(false)
        end
    end
end

--更新角色Up保底显示信息（左边）
function XUiDraw:UpdateNewUpInfo(combination)
    self.NewUpItem.gameObject:SetActiveEx(false)
    self.NewUpCharacter.gameObject:SetActiveEx(false)
    self.BtnPreviewLeft.gameObject:SetActiveEx(true)
    if self.DrawInfo then
        if XArrangeConfigs.GetType(combination.GoodsId[1]) ~= XArrangeConfigs.Types.Character then
            local upShow = XUiGridCommon.New(self, self.NewUpItem)
            upShow:Refresh(combination.GoodsId[1], gridParams)
            self.NewUpItem.gameObject:SetActiveEx(true)
        else
            self.GoodsShowParams = XGoodsCommonManager.GetGoodsShowParamsByTemplateId(combination.GoodsId[1])
            self.ImgNewUpIco:SetRawImage(self.GoodsShowParams.Icon)
            local quality = XCharacterConfigs.GetCharMinQuality(combination.GoodsId[1])
            self.ImgNewUpRank:SetRawImage(XCharacterConfigs.GetCharQualityIcon(quality))

            if self.GoodsShowParams.Quality then
                local qualityIcon = self.GoodsShowParams.QualityIcon

                if qualityIcon then
                    self:SetUiSprite(self.ImgQuality, qualityIcon)
                else
                    XUiHelper.SetQualityIcon(self, self.ImgQuality, self.GoodsShowParams.Quality)
                end
            end

            self.NewUpCharacter.gameObject:SetActiveEx(true)
        end
    end
end

function XUiDraw:UpdateCharacterTxt()
    local combination = XDataCenter.DrawManager.GetDrawCombination(self.DrawInfo.Id)
    if combination then
        if combination.Type == XDrawConfigs.CombinationsTypes.CharacterUp then
            self.TxtBottomTimes.text = CS.XTextManager.GetText("DrawBottomTimes", self.DrawInfo.BottomTimes)
        end
        if combination.Type == XDrawConfigs.CombinationsTypes.NewUp then
            local type = XDataCenter.DrawManager.GetDrawGroupRule(self.GroupId).UpType
            local quality = XDataCenter.DrawManager.GetDrawGroupRule(self.GroupId).UpQuality
            local probability = XDataCenter.DrawManager.GetDrawGroupRule(self.GroupId).UpProbability
            self.TxtNewUpTimes.text = CS.XTextManager.GetText("DrawRuleHint",quality,type,probability)
        end
    end
end

function XUiDraw:UpdateItemCount()
    if not self.DrawInfo then
        return
    end
    self.TxtUseItemCount.text = XDataCenter.ItemManager.GetItem(self.DrawInfo.UseItemId).Count
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiDraw:InitAutoScript()
    self:AutoAddListener()
end

function XUiDraw:AutoAddListener()
    self:RegisterClickEvent(self.BtnCloseBottomInfo, self.OnBtnCloseBottomInfoClick)
    self:RegisterClickEvent(self.ScrollView, self.OnScrollViewClick)
    self:RegisterClickEvent(self.Scrollbar, self.OnScrollbarClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnCharacterBottomInfo, self.OnBtnCharacterBottomInfoClick)
    self:RegisterClickEvent(self.BtnOptionalDraw, self.OnBtnOptionalDrawClick)
    self:RegisterClickEvent(self.BtnUseItem, self.OnBtnUseItemClick)
    self:RegisterClickEvent(self.BtnPreview, self.OnBtnPreviewClick)
    self:RegisterClickEvent(self.BtnDrawRule, self.OnBtnDrawRuleClick)
    self:RegisterClickEvent(self.BtnMainRule, self.OnBtnMainRuleClick)
    self:RegisterClickEvent(self.BtnPreviewLeft, self.OnBtnPreviewLeftClick)
    self:RegisterClickEvent(self.BtnNewUpInfo, self.OnBtnCharacterBottomInfoClick)
end
-- auto

function XUiDraw:OnScrollViewClick(eventData)

end

function XUiDraw:OnScrollbarClick(eventData)

end

function XUiDraw:OnBtnCloseBottomInfoClick(eventData)
    for k, v in pairs(self.BottomInfoTxts) do
        CS.UnityEngine.Object.Destroy(v.gameObject)
    end
    self.BottomInfoTxts = {}
    self.PanelCharacterBottomInfo.gameObject:SetActiveEx(false)
end

function XUiDraw:OnBtnCharacterBottomInfoClick(eventData)
    self.BtnDrawRule.interactable = false
    XLuaUiManager.Open("UiDrawLog",self.DrawInfo,IndexEventRule,function()
            self.BtnDrawRule.interactable = true
        end)
end
function XUiDraw:OnBtnMainRuleClick(...)
    self:OnBtnDrawRuleClick(...)
end

function XUiDraw:OnBtnPreviewLeftClick(...)
    self:OnBtnPreviewClick(...)
end

function XUiDraw:OnBtnBackClick(...)
    self:Close()
end

function XUiDraw:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiDraw:OnBtnOptionalDrawClick(...)
    self:OpenChildUi("UiDrawOptional", self.GroupId, self.DrawInfo, self, function(drawId)
        local drawInfo = XDataCenter.DrawManager.GetDrawInfo(drawId)
        self:UpdateInfo(drawInfo)
        self:PlaySpcalAnime()
    end)
end

function XUiDraw:OnBtnPreviewClick(...)
    self.BtnDrawRule.interactable = false
    XLuaUiManager.Open("UiDrawLog",self.DrawInfo,IndexPreview,function()
            self.BtnDrawRule.interactable = true
        end)
end

function XUiDraw:OnBtnDrawRuleClick(...)
    self.BtnDrawRule.interactable = false
    XLuaUiManager.Open("UiDrawLog",self.DrawInfo,IndexBaseRule,function()
        self.BtnDrawRule.interactable = true
    end)
end

function XUiDraw:OnBtnUseItemClick(...)
    local data = XDataCenter.ItemManager.GetItem(self.DrawInfo.UseItemId)
    XLuaUiManager.Open("UiTip", data)
end

function XUiDraw:HideUiView(onAnimFinish)
    self.OpenSound = CS.XAudioManager.PlaySound(XSoundManager.UiBasicsMusic.UiDrawCard_BoxOpen)
    
    self:PlayAnimation("DrawRetract", function()
            onAnimFinish()
    end, function()
            self.ImgMask.gameObject:SetActiveEx(true)
            end)
    -- XUiHelper.PlayAnimation(self, "DrawRetract", function()
    --     self.ImgMask.gameObject:SetActiveEx(true)
    -- end, function() onAnimFinish() end)
end

function XUiDraw:ResetScene()
    XRTextureManager.SetTextureCahe(self.RImgDrawCard)
end

function XUiDraw:PushShow(drawInfo, rewardList)
    self:OpenChildUi("UiDrawShow")
    self.PanelNewHand.gameObject:SetActiveEx(false)
    self:FindChildUiObj("UiDrawShow"):SetData(drawInfo, rewardList, function()
            if self.OpenSound then
                self.OpenSound:Stop()
            end
            self:PushResult(drawInfo, rewardList)
            self:UpdateInfo(drawInfo)
            local groupInfo = XDataCenter.DrawManager.GetDrawGroupInfoByGroupId(self.GroupId)
            if groupInfo.Type == XDataCenter.DrawManager.DrawEventType.NewHand then
                if drawInfo.MaxBottomTimes == XDataCenter.DrawManager.GetDrawGroupRule(self.GroupId).NewHandBottomCount then
                    self.PanelNewHand.gameObject:SetActiveEx(true)
                else
                    self.PanelNewHand.gameObject:SetActiveEx(false)
                end
            else
                self.PanelNewHand.gameObject:SetActiveEx(false)
            end

    end, self.BackGround)
end

function XUiDraw:PushResult(drawInfo, rewardList)
    XLuaUiManager.Open("UiDrawResult", drawInfo, rewardList, function() end)
end

function XUiDraw:OnDestroy()
    XCountDown.RemoveTimer(self.Name)
    if self.CloseCb then
        self.CloseCb()
    end
end

function XUiDraw:OnEnable()
    XUiHelper.SetDelayPopupFirstGet(true)
    self.ImgMask.gameObject:SetActiveEx(true)
    self:PlayAnimation("DrawBegan", function() self.ImgMask.gameObject:SetActiveEx(false) end)
    self:PlaySpcalAnime()
    self.PlayableDirector = self.BackGround:GetComponent("PlayableDirector")
    self.PlayableDirector:Stop()
    self.PlayableDirector:Evaluate()
end

function XUiDraw:PlaySpcalAnime()
    local combination = XDataCenter.DrawManager.GetDrawCombination(self.DrawInfo.Id)
    if combination then
        if combination.Type == XDrawConfigs.CombinationsTypes.Aim then
            if self.FirstAnim then
                self.FirstAnim = false
            else
                self:PlayAnimation("AniZixuan")
            end
        end
    end
end

function XUiDraw:OnDisable()
    XUiHelper.SetDelayPopupFirstGet()
end


function XUiDraw:InitDrawBackGround(backgroundName)
    local root = self:GetSceneRoot().transform
    self.BackGround = root.parent.parent:FindTransform("GroupBase"):LoadPrefab(backgroundName)
    CS.XShadowHelper.AddShadow(self.BackGround:FindTransform("BoxModeParent").gameObject)
end