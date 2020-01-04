local CSXTextManagerGetText = CS.XTextManager.GetText

local CAMERA_NUM = 5

local XUiCharacter = XLuaUiManager.Register(XLuaUi, "UiCharacter")

function XUiCharacter:OnAwake()
    self:InitDynamicTable()
    self:AutoAddListener()
    
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self.GridCharacterNew.gameObject:SetActive(false)
    self.PanelTeamBtn.gameObject:SetActive(false)

    --kkkttt Late Delete Me:暂时屏蔽新功能入口
    local tempGo = self.Transform:Find("SafeAreaContentPane/BtnLensOut")
    if not XTool.UObjIsNil(tempGo) then
        tempGo.gameObject:SetActiveEx(false)
    end
end

function XUiCharacter:OnStart(characterId, characterList, openFromTeamInfo, forbidGotoEquip, skipToProperty)
    self:InitSceneRoot()

    self.CharacterId = characterId
    self.SpecialCharacterList = characterList

    if openFromTeamInfo then
        self.TeamCharIdMap = openFromTeamInfo.TeamCharIdMap
        self.TeamSelectPos = openFromTeamInfo.TeamSelectPos
        self.TeamResultCb = openFromTeamInfo.TeamResultCb
    end
    
    if forbidGotoEquip then
        self.BtnOwnedDetail.gameObject:SetActive(false)
        self.BtnFashion.gameObject:SetActive(false)
        self.ForbidGotoEquip = true
    end

    self.SkipToProperty = skipToProperty
end

function XUiCharacter:OnEnable()
    CS.XGraphicManager.UseUiLightDir = true
    -- 父UI的OnEnable中无法正确检测子UI的打开关闭状态，故需自己维护一个变量
    if not self.ChildOpen then
        self:UpdateCharacterList(self.CharacterId, self.SpecialCharacterList)
    else
        self:UpdateCurCharacterInfo()
    end
end

function XUiCharacter:OnDisable()
    CS.XGraphicManager.UseUiLightDir = false
end

function XUiCharacter:OnGetEvents()
    return { XEventId.EVENT_CHARACTER_SYN }
end

function XUiCharacter:OnNotify(evt, ...)
    local args = { ... }
    local characterId = args[1]

    if evt == XEventId.EVENT_CHARACTER_SYN then
        self:UpdateCharacterList(characterId)
    end
end

function XUiCharacter:InitSceneRoot()
    local root = self:GetSceneRoot().transform

    self.PanelRoleModel = root:FindTransform("PanelRoleModel")
    self.ImgEffectHuanren = root:FindTransform("ImgEffectHuanren")
    self.CameraFar = {
        root:FindTransform("UiCamFarLv"),
        root:FindTransform("UiCamFarGrade"),
        root:FindTransform("UiCamFarQuality"),
        root:FindTransform("UiCamFarSkill"),
        root:FindTransform("UiCamFarrExchange"),
    }
    self.CameraNear = {
        root:FindTransform("UiCamNearLv"),
        root:FindTransform("UiCamNearGrade"),
        root:FindTransform("UiCamNearQuality"),
        root:FindTransform("UiCamNearSkill"),
        root:FindTransform("UiCamNearrExchange"),
    }
end

function XUiCharacter:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.SViewCharacterList)
    self.DynamicTable:SetProxy(XUiGridCharacterNew)
    self.DynamicTable:SetDelegate(self)
end

function XUiCharacter:UpdateCharacterList(characterId, specialCharList)
    local index = 1
    local characterList = specialCharList or XDataCenter.CharacterManager.GetCharacterList()
    if characterId then
        for k, v in pairs(characterList) do
            if v.Id == characterId then
                index = k
                break
            end
        end
    else
        characterId = characterList[1].Id
    end
    self.CharacterId = characterId
    self.CharacterList = characterList
    self.InTeamCheckTable = XDataCenter.TeamManager.GetInTeamCheckTable()

    self.DynamicTable:SetDataSource(characterList)
    self.DynamicTable:ReloadDataASync(index)

    self:UpdateCurCharacterInfo()
end

function XUiCharacter:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.CharacterList[index]
        grid:Reset()
        grid:UpdateGrid(data)
        grid:SetInTeam(self.InTeamCheckTable[data.Id])
        if self.CharacterId == data.Id then
            self.CurSelectGrid = grid
        end
        grid:SetSelect(self.CharacterId == data.Id)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local characterId = self.CharacterList[index].Id
        if XCharacterConfigs.GetCharacterTemplate(characterId).Foreshow == 0 then
            if self.CharacterId ~= characterId then
                if self.CurSelectGrid then
                    self.CurSelectGrid:SetSelect(false)
                end
                grid:SetSelect(true)
                self.CurSelectGrid = grid
                self.CharacterId = characterId
                self:UpdateCurCharacterInfo()
            end
        else
            XUiManager.TipMsg(CSXTextManagerGetText("ComingSoon"), XUiManager.UiTipType.Tip)
        end
    end
end

function XUiCharacter:UpdateCurCharacterInfo()
    local characterId = self.CharacterId

    self:UpdateRoleModel(function(model)
        self.PanelDrag.Target = model.transform
    end, true)

    if self.SkipToProperty and not self.ChildOpen then
        self:OpenOneChildUi("UiPanelCharProperty", self)
        self.ChildOpen = true
        self.SkipToProperty = false
        return
    end

    if not self.ChildOpen then
        local isOwn = XDataCenter.CharacterManager.IsOwnCharacter(characterId)
        if isOwn then
            local childUi = self:FindChildUiObj("UiCharacterOwnedInfo") 
            childUi:PreSetCharacterId(characterId)
            if not XLuaUiManager.IsUiShow("UiCharacterOwnedInfo") then
                self:OpenOneChildUi("UiCharacterOwnedInfo", self.ForbidGotoEquip, function ()
                    self:OpenOneChildUi("UiPanelCharProperty", self)
                    self.ChildOpen = true
                end)
            else
                childUi:UpdateView(characterId)
                childUi:PlayAnimation("AnimEnable")
            end
        else
            local childUi = self:FindChildUiObj("UiCharacterUnOwnedInfo") 
            childUi:PreSetCharacterId(characterId)
            if not XLuaUiManager.IsUiShow("UiCharacterUnOwnedInfo") then
                self:OpenOneChildUi("UiCharacterUnOwnedInfo", characterId)
            else
                childUi:UpdateView(characterId)
                childUi:PlayAnimation("AnimEnable")
            end
        end
    end

    if self.TeamCharIdMap then
        self:UpdateTeamBtn()
    end
end

function XUiCharacter:UpdateCamera(index)
    self.CurCameraIndex = index
    for i = 1, CAMERA_NUM do
        if self.CurCameraIndex ~= i then
            self.CameraFar[i].gameObject:SetActive(false)
            self.CameraNear[i].gameObject:SetActive(false)
        end
    end

    if self.CameraFar[self.CurCameraIndex] then
        self.CameraFar[self.CurCameraIndex].gameObject:SetActive(true)
    end
    if self.CameraNear[self.CurCameraIndex] then
        self.CameraNear[self.CurCameraIndex].gameObject:SetActive(true)
    end
end

--更新模型
function XUiCharacter:UpdateRoleModel(callback, showEffect)
    if not self.InitRoleMode then
        self.InitRoleMode = true
        self.RoleModelPanel = XUiPanelRoleModel.New(self.PanelRoleModel, self.Name, nil, true, nil, true)
    end

    self.RoleModelPanel:UpdateCharacterModel(self.CharacterId, self.PanelRoleModel, XModelManager.MODEL_UINAME.XUiCharacter, function(model)
        if callback then callback(model) end
        if showEffect and self.ImgEffectHuanren then
            self.ImgEffectHuanren.gameObject:SetActive(false)
            self.ImgEffectHuanren.gameObject:SetActive(true)
        end
    end)
end

function XUiCharacter:UpdateTeamBtn()
    if not next(self.TeamCharIdMap) then
        return
    end

    local isInTeam = false
    local characterId = self.CharacterId
    for k, v in pairs(self.TeamCharIdMap) do
        if characterId == v then
            isInTeam = true
            break
        end
    end
    self.BtnQuitTeam.gameObject:SetActive(isInTeam)
    self.BtnJoinTeam.gameObject:SetActive(not isInTeam)
    self.ImgEnjoinTeam.gameObject:SetActive(false)
end

function XUiCharacter:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClick)
    self:RegisterClickEvent(self.BtnJoinTeam, self.OnBtnJoinTeamClick)
    self:RegisterClickEvent(self.BtnQuitTeam, self.OnBtnQuitTeamClick)
    self:RegisterClickEvent(self.BtnFashion, self.OnBtnFashionClick)
    self:RegisterClickEvent(self.BtnOwnedDetail, self.OnBtnOwnedDetailClick)
end

function XUiCharacter:OnBtnBackClick()
    if XLuaUiManager.IsUiShow("UiPanelCharacterExchange") then
        self:CloseChildUi("UiPanelCharacterExchange")
        return
    end

    if XLuaUiManager.IsUiShow("UiPanelCharProperty") then
        local propertyChildUi = self:FindChildUiObj("UiPanelCharProperty")
        if not propertyChildUi:RecoveryPanel() then
            self:CloseChildUi("UiPanelCharProperty")
            self.ChildOpen = false
            self:UpdateCharacterList(self.CharacterId)
            self:UpdateCamera(XCharacterConfigs.XUiCharacter_Camera.MAIN)
        end
        return
    end

    self:Close()
end

function XUiCharacter:OnBtnMainUiClick()
    XLuaUiManager.RunMain()
end

function XUiCharacter:OnBtnHelpClick(eventData)
    XUiManager.ShowHelpTip("Character")
end

function XUiCharacter:OnBtnJoinTeamClick()
    local id = self.CharacterId
    for k, v in pairs(self.TeamCharIdMap) do
        if v == id then
            self.TeamCharIdMap[k] = 0
            break
        end
    end

    self.TeamCharIdMap[self.TeamSelectPos] = id
    if self.TeamResultCb then
        self.TeamResultCb(self.TeamCharIdMap)
    end
    
    self:Close()
end

function XUiCharacter:OnBtnQuitTeamClick()
    local count = 0
    for k, v in pairs(self.TeamCharIdMap) do
        if v > 0 then
            count = count + 1
        end
    end

    local id = self.CharacterId
    for k, v in pairs(self.TeamCharIdMap) do
        if v == id then
            self.TeamCharIdMap[k] = 0
            break
        end
    end

    if self.TeamResultCb then
        self.TeamResultCb(self.TeamCharIdMap)
    end

    self:Close()
end

function XUiCharacter:OnBtnFashionClick(...)
    XLuaUiManager.Open("UiFashion", self.CharacterId)
end

function XUiCharacter:OnBtnOwnedDetailClick(...)
    XLuaUiManager.Open("UiCharacterDetail", self.CharacterId)
end

function XUiCharacter:OpenChangeCharacterView()
    self:OpenOneChildUi("UiPanelCharacterExchange", self, function(characterId)
        self:UpdateCharacterList(characterId, nil)
        self:OpenOneChildUi("UiPanelCharProperty", self)
        self.ChildOpen = true
    end)

    self:UpdateCamera(XCharacterConfigs.XUiCharacter_Camera.EXCHANGE)
    self.Transform:PlayLegacyAnimation("AniChaExchangeBegin")
    self.SViewCharacterList.gameObject:SetActiveEx(false)
    self.BtnFashion.gameObject:SetActiveEx(false)
    self.BtnOwnedDetail.gameObject:SetActiveEx(false)
end