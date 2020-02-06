local XUiBfrtRoomCharacter = XLuaUiManager.Register(XLuaUi, "UiBfrtRoomCharacter")

local XUiGridBfrtCharacter = require("XUi/XUiBfrt/XUiGridBfrtCharacter")
local ANIMATION_OPEN = "AniBfrtRoomCharacterBegin"
local CONDITION_HEX_COLOR = { 
    [true] = "000000FF",
    [false] = "BC0F23FF",
}

function XUiBfrtRoomCharacter:OnAwake()
    self:InitAutoScript()
    self:InitComponentState()
end

function XUiBfrtRoomCharacter:OnStart(viewData)
    local root = self:GetSceneRoot().transform
    self.PanelRoleModel = root:FindTransform("PanelRoleModel")
    self.ImgEffectHuanren = root:FindTransform("ImgEffectHuanren")

    self:RefreshView(viewData)
    self:PlayAnimation(ANIMATION_OPEN)
    --XUiHelper.PlayAnimation(self, ANIMATION_OPEN, nil, nil)
end

function XUiBfrtRoomCharacter:OnEnable()
    CS.XGraphicManager.UseUiLightDir = true

    self:UpdateCharacterList()
    self:UpdateInTeamCharacter()
    self:UpdateSelectCharacter()
    self:UpdateCurCharacterGrid()
end

function XUiBfrtRoomCharacter:OnDisable()
    CS.XGraphicManager.UseUiLightDir = false
end

function XUiBfrtRoomCharacter:InitComponentState()
    self.GridBfrtCharacter.gameObject:SetActive(false)
    self.BtnJoinTeam.gameObject:SetActive(false)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiBfrtRoomCharacter:RefreshView(viewData)
    self:UpdateViewData(viewData)
    self:UpdateTxtRequireAbility()
end

function XUiBfrtRoomCharacter:UpdateViewData(viewData)
    if not viewData.TeamCharacterIdList or not viewData.TeamSelectPos then
        XLog.Error("XUiBfrtRoomCharacter:UpdateViewData error: TeamCharacterIdList or TeamSelectPos do not exist!")
        return
    end

    self.RequireAbility = viewData.RequireAbility
    self.TeamCharacterIdList = viewData.TeamCharacterIdList
    self.TeamSelectPos = viewData.TeamSelectPos
    self.EchelonIndex = viewData.EchelonIndex
    self.EchelonType = viewData.EchelonType
    self.CheckIsInTeamListCb = viewData.CheckIsInTeamListCb
    self.CharacterSwapEchelonCb = viewData.CharacterSwapEchelonCb
    self.TeamResultCb = viewData.TeamResultCb
    self.OwnCharacterList = XDataCenter.CharacterManager.GetOwnCharacterList()
    table.sort(self.OwnCharacterList, function(leftCharacter, rightCharacter)
        return self:CharcterSortFunc(leftCharacter, rightCharacter)
    end)
    self.RoleModelPanel = XUiPanelRoleModel.New(self.PanelRoleModel, self.Name, nil, true, nil, true)
end

function XUiBfrtRoomCharacter:UpdateTxtRequireAbility()
    self.TxtRequireAbility.text = self.RequireAbility
    self.TxtEchelonName.text = XDataCenter.BfrtManager.GetEchelonNameTxt(self.EchelonType, self.EchelonIndex)
end

function XUiBfrtRoomCharacter:UpdateTxtRequireAbilityColor()
    local curCharacter = XDataCenter.CharacterManager.GetCharacter(self.CurCharacterId)
    local passed = curCharacter and curCharacter.Ability >= self.RequireAbility or false
    self.TxtRequireAbility.color = XUiHelper.Hexcolor2Color(CONDITION_HEX_COLOR[passed])
end

function XUiBfrtRoomCharacter:UpdateCharacterList()
    if not self.OwnCharacterList then
        XLog.Error("XUiBfrtRoomCharacter:UpdateCharacterList error: self.OwnCharacterList do not exist!")
        return
    end

    self.CharacterGrids = self.CharacterGrids or {}
    for i = 1, #self.OwnCharacterList do
        local character = self.OwnCharacterList[i]
        local grid = self.CharacterGrids[character.Id]
        if not grid then
            local item = CS.UnityEngine.Object.Instantiate(self.GridBfrtCharacter)
            grid = XUiGridBfrtCharacter.New(self, item, character)
            grid.Transform:SetParent(self.PanelRoleContent, false)
            self.CharacterGrids[character.Id] = grid
        else
            grid:Refresh(character)
        end
    end
end

function XUiBfrtRoomCharacter:UpdateInTeamCharacter()
    for characterId, grid in pairs(self.CharacterGrids) do
        grid:SetInTeam(self.CheckIsInTeamListCb(characterId))
    end
end

function XUiBfrtRoomCharacter:UpdateSelectCharacter()
    if self.DefaultSelectId then return end
    local selectId = self.TeamCharacterIdList[self.TeamSelectPos]
    if not selectId or selectId == 0 then
        selectId = self.OwnCharacterList[1].Id
    end

    self:CenterToGrid(self.CharacterGrids[selectId])
    self:OnSelectCharacter(selectId)
    self.DefaultSelectId = selectId
end

function XUiBfrtRoomCharacter:CenterToGrid(grid)
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

function XUiBfrtRoomCharacter:OnSelectCharacter(selectId)
    if not selectId then
        return
    end

    if self.CurCharacterId == selectId then
        return
    end

    self.CurCharacterId = selectId

    if self.CurCharacterGrid then
        self.CurCharacterGrid:SetSelect(false)
    end

    self.CurCharacterGrid = self.CharacterGrids[self.CurCharacterId]
    self.CurCharacterGrid:SetSelect(true)
    self:UpdateCurCharacterGrid()
end

function XUiBfrtRoomCharacter:UpdateCurCharacterGrid()
    local character = XDataCenter.CharacterManager.GetCharacter(self.CurCharacterId)
    self.CurCharacterGrid:Refresh(character)
    self:UpdateTeamBtn()
    self:UpdateTxtRequireAbilityColor()
    self:UpdateRoleModel(self.PanelRoleModel, XModelManager.MODEL_UINAME.XUiCharacter)
end

function XUiBfrtRoomCharacter:UpdateTeamBtn()
    if not (self.TeamCharacterIdList and next(self.TeamCharacterIdList)) then
        return
    end

    local isInTeam = self:CheckCharacterInTeam(self.CurCharacterId)
    self.BtnQuitTeam.gameObject:SetActive(isInTeam)
    self.BtnJoinTeam.gameObject:SetActive(not isInTeam)
end

function XUiBfrtRoomCharacter:UpdateRoleModel(targetPanelRole, targetUiName)
    local charaterFunc = function(model)
        if not model then
            return
        end
        self.PanelDrag:GetComponent("XDrag").Target = model.transform
        self.ImgEffectHuanren.gameObject:SetActive(false)
        self.ImgEffectHuanren.gameObject:SetActive(true)
    end
    self.RoleModelPanel:UpdateCharacterModel(self.CurCharacterId, targetPanelRole, targetUiName, charaterFunc)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiBfrtRoomCharacter:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiBfrtRoomCharacter:AutoInitUi()
    self.BtnFashion = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnFashion"):GetComponent("Button")
    self.BtnConsciousness = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnConsciousness"):GetComponent("Button")
    self.BtnJoinTeam = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnJoinTeam"):GetComponent("Button")
    self.BtnQuitTeam = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnQuitTeam"):GetComponent("Button")
    self.SViewCharacterList = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/Left/SViewCharacterList"):GetComponent("ScrollRect")
    self.PanelRoleContent = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/Left/SViewCharacterList/Viewport/PanelRoleContent")
    self.GridBfrtCharacter = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/Left/SViewCharacterList/Viewport/PanelRoleContent/GridBfrtCharacter")
    self.PanelDrag = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/PanelDrag")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/Top/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/Top/BtnMainUi"):GetComponent("Button")
    self.BtnWeapon = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnWeapon"):GetComponent("Button")
end

function XUiBfrtRoomCharacter:AutoAddListener()
    self:RegisterClickEvent(self.BtnFashion, self.OnBtnFashionClick)
    self:RegisterClickEvent(self.BtnConsciousness, self.OnBtnConsciousnessClick)
    self:RegisterClickEvent(self.BtnJoinTeam, self.OnBtnJoinTeamClick)
    self:RegisterClickEvent(self.BtnQuitTeam, self.OnBtnQuitTeamClick)
    self:RegisterClickEvent(self.SViewCharacterList, self.OnSViewCharacterListClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnWeapon, self.OnBtnWeaponClick)
end
-- auto

function XUiBfrtRoomCharacter:OnSViewCharacterListClick(eventData)

end
function XUiBfrtRoomCharacter:OnBtnConsciousnessClick(eventData)
    XLuaUiManager.Open("UiEquipAwarenessReplace", self.CurCharacterId, nil, true)
end

function XUiBfrtRoomCharacter:OnBtnWeaponClick(eventData)
    XLuaUiManager.Open("UiEquipReplaceNew", self.CurCharacterId, nil, true)
end

function XUiBfrtRoomCharacter:OnBtnFashionClick(...)
    XLuaUiManager.Open("UiFashion", self.CurCharacterId)
end

function XUiBfrtRoomCharacter:OnBtnJoinTeamClick(...)
    local echelonIndex, echelonType = self.CheckIsInTeamListCb(self.CurCharacterId)
    if echelonIndex and echelonType then
        local title = CS.XTextManager.GetText("BfrtDeployTipTitle")
        local characterName = XCharacterConfigs.GetCharacterName(self.CurCharacterId)
        local oldEchelon = XDataCenter.BfrtManager.GetEchelonNameTxt(echelonType, echelonIndex)
        local newEchelon = XDataCenter.BfrtManager.GetEchelonNameTxt(self.EchelonType, self.EchelonIndex)
        local content = CS.XTextManager.GetText("BfrtDeployTipContent", characterName, oldEchelon, newEchelon)

        XUiManager.DialogTip(title, content, XUiManager.DialogType.Normal, nil, function()
            self.CharacterSwapEchelonCb(self.CurCharacterId, self.TeamCharacterIdList[self.TeamSelectPos])
            self.TeamCharacterIdList[self.TeamSelectPos] = self.CurCharacterId
            self:Close()
        end)
    else
        self:QuitTeam(self.CurCharacterId)
        self.TeamCharacterIdList[self.TeamSelectPos] = self.CurCharacterId
        self:Close()
    end
end

function XUiBfrtRoomCharacter:OnBtnQuitTeamClick(...)
    self:QuitTeam(self.CurCharacterId)
    self:Close()
end

function XUiBfrtRoomCharacter:OnBtnBackClick(...)
    self:Close()
end

function XUiBfrtRoomCharacter:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiBfrtRoomCharacter:QuitTeam(characterId)
    for index, existCharacterId in pairs(self.TeamCharacterIdList) do
        if characterId == existCharacterId then
            self.TeamCharacterIdList[index] = 0
            return
        end
    end
end

function XUiBfrtRoomCharacter:Close()
    if self.TeamResultCb then
        self.TeamResultCb(self.TeamCharacterIdList)
    end

    self.super.Close(self)
end

function XUiBfrtRoomCharacter:CheckCharacterInTeam(checkCharacterId)
    for _, characterId in pairs(self.TeamCharacterIdList) do
        if checkCharacterId == characterId then
            return true
        end
    end
    return false
end

function XUiBfrtRoomCharacter:CharcterSortFunc(leftCharacter, rightCharacter)
    local leftNotInTeam = not self:CheckCharacterInTeam(leftCharacter.Id)
    local leftNotInTeamList = self.CheckIsInTeamListCb(leftCharacter.Id) == nil
    local leftAbility = leftCharacter.Ability
    local leftLevel = leftCharacter.Level
    local leftQuality = leftCharacter.Quality
    local leftPriority = XCharacterConfigs.GetCharacterPriority(leftCharacter.Id)

    local rightNotInTeam = not self:CheckCharacterInTeam(rightCharacter.Id)
    local rightNotInTeamList = self.CheckIsInTeamListCb(rightCharacter.Id) == nil
    local rightAbility = rightCharacter.Ability
    local rightLevel = rightCharacter.Level
    local rightQuality = rightCharacter.Quality
    local rightPriority = XCharacterConfigs.GetCharacterPriority(rightCharacter.Id)

    if leftNotInTeam ~= rightNotInTeam then
        return leftNotInTeam
    end

    if leftNotInTeamList ~= rightNotInTeamList then
        return leftNotInTeamList
    end

    return (leftAbility > rightAbility or leftAbility == rightAbility and
    (leftLevel > rightLevel or leftLevel == rightLevel and
    (rightQuality > rightQuality or rightQuality == rightQuality and
    rightPriority > rightPriority)))
end