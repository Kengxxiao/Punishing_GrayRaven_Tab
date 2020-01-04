local XUiRoomCharacter = XLuaUiManager.Register(XLuaUi, "UiRoomCharacter")

function XUiRoomCharacter:OnAwake()
    self:InitAutoScript()

    local root = self:GetSceneRoot().transform
    self.PanelRoleModel = self:GetSceneRoot().transform:FindTransform("PanelRoleModel")
    self.ImgEffectHuanren = root:FindTransform("ImgEffectHuanren")

    self.GridCharacter.gameObject:SetActive(false)
end

function XUiRoomCharacter:OnStart(teamCharIdMap, teamSelectPos, cb, stageType, isHideQuitButton)
    self.RoleModelPanel = XUiPanelRoleModel.New(self.PanelRoleModel, self.Name, nil, true)
    self.CharacterGrids = {}
    self.StageType = stageType
    self.IsHideQuitButton = isHideQuitButton
    self:Reset()
    self:OnOpenInTeam(teamCharIdMap, teamSelectPos, cb)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiRoomCharacter:Reset()
    self.TeamCharIdMap = nil
    self.TeamSelectPos = nil
    self.TeamResultCb = nil
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiRoomCharacter:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiRoomCharacter:AutoInitUi()
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/Top/BtnBack"):GetComponent("Button")
    self.BtnJoinTeam = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnJoinTeam"):GetComponent("Button")
    self.BtnConsciousness = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnConsciousness"):GetComponent("Button")
    self.BtnQuitTeam = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnQuitTeam"):GetComponent("Button")
    self.SViewCharacterList = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/Left/SViewCharacterList"):GetComponent("ScrollRect")
    self.PanelRoleContent = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/Left/SViewCharacterList/Viewport/PanelRoleContent")
    self.GridCharacter = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/Left/SViewCharacterList/Viewport/PanelRoleContent/GridCharacter")
    self.BtnFashion = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnFashion"):GetComponent("Button")
    self.PanelRoleModel = self.Transform:Find("SafeAreaContentPane/ModelRoot/NearRoot/PanelRoleModel")
    self.PanelDrag = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/PanelDrag")
    self.BtnWeapon = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnWeapon"):GetComponent("Button")
    self.TxtRequireAbility = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/TxtRequireAbility"):GetComponent("Text")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/Top/BtnMainUi"):GetComponent("Button")
end

function XUiRoomCharacter:AutoAddListener()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnJoinTeam, self.OnBtnJoinTeamClick)
    self:RegisterClickEvent(self.BtnConsciousness, self.OnBtnConsciousnessClick)
    self:RegisterClickEvent(self.BtnQuitTeam, self.OnBtnQuitTeamClick)
    self:RegisterClickEvent(self.SViewCharacterList, self.OnSViewCharacterListClick)
    self:RegisterClickEvent(self.BtnFashion, self.OnBtnFashionClick)
    self:RegisterClickEvent(self.BtnWeapon, self.OnBtnWeaponClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end
-- auto
function XUiRoomCharacter:OnBtnWeaponClick(eventData)
    XLuaUiManager.Open("UiEquipReplaceNew", self.CurCharacter.Id, nil, true)
end

function XUiRoomCharacter:OnBtnConsciousnessClick(eventData)
    XLuaUiManager.Open("UiEquipAwarenessReplace", self.CurCharacter.Id, nil, true)
end

function XUiRoomCharacter:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiRoomCharacter:OnSViewCharacterListClick(eventData)

end
--初始化音效
function XUiRoomCharacter:InitBtnSound()
    self.SpecialSoundMap[self:GetAutoKey(self.BtnBack, "onClick")] = XSoundManager.UiBasicsMusic.Return
    self.SpecialSoundMap[self:GetAutoKey(self.BtnEquip, "onClick")] = XSoundManager.UiBasicsMusic.Fuben_UiMainLineRoomCharacter_Equip
    self.SpecialSoundMap[self:GetAutoKey(self.BtnFashion, "onClick")] = XSoundManager.UiBasicsMusic.Fuben_UiMainLineRoomCharacter_Fashion
    self.SpecialSoundMap[self:GetAutoKey(self.BtnJoinTeam, "onClick")] = XSoundManager.UiBasicsMusic.Fuben_UiMainLineRoomCharacter_JoinTeam
    self.SpecialSoundMap[self:GetAutoKey(self.BtnQuitTeam, "onClick")] = XSoundManager.UiBasicsMusic.Fuben_UiMainLineRoomCharacter_QuitTeam
end

function XUiRoomCharacter:OnSViewCharacterListValueChanged(...)

end

function XUiRoomCharacter:OnEnable()
    self:SelectCharacter()
end

function XUiRoomCharacter:OnOpenInTeam(teamCharIdMap, teamSelectPos, cb)
    if teamCharIdMap == nil or teamSelectPos == nil then
        XLog.Error("XUiCharacter:OnOpenInTeam error: params error")
        return
    end

    self.TeamCharIdMap = teamCharIdMap
    self.TeamSelectPos = teamSelectPos
    self.TeamResultCb = cb

    local selectId = teamCharIdMap[teamSelectPos]
    local charlist = XDataCenter.CharacterManager.GetCharacterListInTeam(teamCharIdMap, selectId > 0)

    self:UpdateCharacterList(charlist, function()
        if not selectId or selectId == 0 then
            selectId = charlist[1].Id
        end

        self:SelectCharacter(selectId)

        for _, id in pairs(teamCharIdMap) do
            if id > 0 then
                self.CharacterGrids[id]:SetInTeam(true)
            end
        end
    end)
end

function XUiRoomCharacter:CenterToGrid(grid)
    local normalizedPosition
    local count = self.SViewCharacterList.content.transform.childCount
    local index = grid.Transform:GetSiblingIndex()
    if index > count / 2 then
        normalizedPosition = (index + 1) / count
    else
        normalizedPosition = (index - 1) / count
    end

    self.SViewCharacterList.verticalNormalizedPosition = math.max(0, math.min(1, (1 - normalizedPosition)))
end

function XUiRoomCharacter:SelectCharacter(id)
    local grid = self.CharacterGrids[id]
    if grid then
        self:CenterToGrid(grid)
    end

    local character = grid and grid.Character
    self:UpdateInfo(character)
end

function XUiRoomCharacter:UpdateCharacterList(charList, cb)
    if not charList then
        XLog.Error("XUiCharacter:UpdateCharacterList error: character list is nil")
        return
    end

    for _, item in pairs(self.CharacterGrids) do
        item:Reset()
    end

    local baseItem = self.GridCharacter
    local count = #charList

    for i = 1, count do
        local char = charList[i]
        local grid = self.CharacterGrids[char.Id]
        if not grid then
            local item = CS.UnityEngine.Object.Instantiate(baseItem)
            grid = XUiGridCharacter.New(self, item, char, function(character)
                self:UpdateInfo(character)
            end)

            grid.GameObject.name = char.Id
            grid.Transform:SetParent(self.PanelRoleContent, false)
            self.CharacterGrids[char.Id] = grid
        else
            grid.GameObject.name = char.Id
        end

        grid:UpdateGrid(char)
        if self.StageType == XDataCenter.FubenManager.StageType.BossSingle then
            local maxStamina = XDataCenter.FubenBossSingleManager.MAX_STAMINA
            local curStamina = XDataCenter.FubenBossSingleManager.MAX_STAMINA - XDataCenter.FubenBossSingleManager.GetCharacterChallengeCount(char.Id)
            grid:UpdateStamina(curStamina, maxStamina)
        elseif self.StageType == XDataCenter.FubenManager.StageType.Explore then
            local maxStamina = XDataCenter.FubenExploreManager.GetMaxEndurance(XDataCenter.FubenExploreManager.GetCurChapterId())
            local curStamina = maxStamina - XDataCenter.FubenExploreManager.GetEndurance(XDataCenter.FubenExploreManager.GetCurChapterId(), char.Id)
            grid:UpdateStamina(curStamina, maxStamina)
        end
        grid.GameObject:SetActive(true)
        grid.Transform:SetAsLastSibling()
    end

    if cb then
        cb()
    end
end

function XUiRoomCharacter:UpdateInfo(character)
    if self.CurCharacter == character then
        return
    end

    if character then
        self.CurCharacter = character
    end

    if self.CurCharacterGrid then
        self.CurCharacterGrid:SetSelect(false)
    end

    self.CurCharacterGrid = self.CharacterGrids[self.CurCharacter.Id]
    self.CurCharacterGrid:UpdateGrid()
    self.CurCharacterGrid:SetSelect(true)
    self:UpdateTeamBtn()
    self:UpdateRoleModel(self.PanelRoleModel, XModelManager.MODEL_UINAME.XUiCharacter)
end

function XUiRoomCharacter:UpdateTeamBtn()
    if not (self.TeamCharIdMap and next(self.TeamCharIdMap)) then
        return
    end

    --在当前操作的队伍中
    local isInTeam = false
    for k, v in pairs(self.TeamCharIdMap) do
        if self.CurCharacter.Id == v then
            isInTeam = true
            break
        end
    end

    local needShowBtnQuitTeam = isInTeam
    self.NeedShowBtnJoinTeam = not isInTeam

    self.BtnQuitTeam.gameObject:SetActive(needShowBtnQuitTeam and not self.IsHideQuitButton)
    self.BtnJoinTeam.gameObject:SetActive(false)
end

function XUiRoomCharacter:UpdateRoleModel(targetPanelRole, targetUiName)
    local func = function(name, model)

        self.BtnJoinTeam.gameObject:SetActive(self.NeedShowBtnJoinTeam)
    end

    local charaterFunc = function(model)
        if not model then
            return
        end
        self.PanelDrag:GetComponent("XDrag").Target = model.transform
        self.ImgEffectHuanren.gameObject:SetActive(false)
        self.ImgEffectHuanren.gameObject:SetActive(true)
    end

    self.RoleModelPanel:UpdateCharacterModel(self.CurCharacter.Id, targetPanelRole, targetUiName, charaterFunc, func)
end

function XUiRoomCharacter:OnBtnBackClick(...)
    if self.TeamResultCb then
        self.TeamResultCb(self.TeamCharIdMap)
    end
    self:Close()
end


function XUiRoomCharacter:OnBtnJoinTeamClick(...)
    local id = self.CurCharacter.Id
    if self.StageType == XDataCenter.FubenManager.StageType.BossSingle then
        local challengeCount = XDataCenter.FubenBossSingleManager.GetCharacterChallengeCount(id)
        if challengeCount >= XDataCenter.FubenBossSingleManager.MAX_STAMINA then
            XUiManager.TipCode(XCode.FubenBossSingleCharacterPointsNotEnough)
            return
        end
    end

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

function XUiRoomCharacter:OnBtnQuitTeamClick(...)
    local count = 0
    for k, v in pairs(self.TeamCharIdMap) do
        if v > 0 then
            count = count + 1
        end
    end

    local id = self.CurCharacter.Id
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

function XUiRoomCharacter:OnBtnFashionClick(...)
    XLuaUiManager.Open("UiFashion", self.CurCharacter.Id)
end

-- function XUiRoomCharacter:OnDestroy()
--     if self.TeamResultCb then
--         self.TeamResultCb(self.TeamCharIdMap)
--     end
-- end