local XUiMainLineRoomCharacter = XLuaUiManager.Register(XLuaUi, "UiMainLineRoomCharacter")
local XUiMainLineRoomCharacterGrid = require("XUi/XUiMainLineRoomCharacter/XUiMainLineRoomCharacterGrid")
function XUiMainLineRoomCharacter:OnAwake()
    self:InitAutoScript()

    local root = self:GetSceneRoot().transform
    self.PanelRoleModel = self:GetSceneRoot().transform:FindTransform("PanelRoleModel")
    self.ImgEffectHuanren = root:FindTransform("ImgEffectHuanren")
    self.GridMainLineCharacter.gameObject:SetActive(false)
end

function XUiMainLineRoomCharacter:OnStart(teamCharIdMap, teamSelectPos, cb)
    self.RoleModelPanel = XUiPanelRoleModel.New(self.PanelRoleModel, self.Name, nil, true, nil, true)
    self.CharacterGrids = {}

    self.DynamicTable = XDynamicTableNormal.New(self.SViewCharacterList)
    self.DynamicTable:SetProxy(XUiMainLineRoomCharacterGrid)
    self.DynamicTable:SetDelegate(self)


    self:Reset()
    self.IsStart = true
    self:OnOpenInTeam(teamCharIdMap, teamSelectPos, cb)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiMainLineRoomCharacter:OnDisable()
    CS.XGraphicManager.UseUiLightDir = false
end

function XUiMainLineRoomCharacter:Reset()
    self.TeamCharIdMap = nil
    self.TeamSelectPos = nil
    self.TeamResultCb = nil
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiMainLineRoomCharacter:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiMainLineRoomCharacter:AutoInitUi()
    self.BtnFashion = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnFashion"):GetComponent("Button")
    self.BtnWeapon = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnWeapon"):GetComponent("Button")
    self.BtnJoinTeam = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnJoinTeam"):GetComponent("Button")
    self.BtnQuitTeam = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnQuitTeam"):GetComponent("Button")
    self.TxtRequireAbility = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/TxtRequireAbility"):GetComponent("Text")
    self.SViewCharacterList = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/Left/SViewCharacterList"):GetComponent("ScrollRect")
    self.PanelRoleContent = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/Left/SViewCharacterList/Viewport/PanelRoleContent")
    self.GridMainLineCharacter = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/Left/SViewCharacterList/Viewport/PanelRoleContent/GridMainLineCharacter")
    self.PanelDrag = self.Transform:Find("SafeAreaContentPane/CharList/CharInfo/PanelDrag")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/Top/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/Top/BtnMainUi"):GetComponent("Button")
    self.BtnConsciousness = self.Transform:Find("SafeAreaContentPane/CharList/TeamBtn/BtnConsciousness"):GetComponent("Button")
end

function XUiMainLineRoomCharacter:AutoAddListener()
    self:RegisterClickEvent(self.BtnFashion, self.OnBtnFashionClick)
    self:RegisterClickEvent(self.BtnWeapon, self.OnBtnWeaponClick)
    self:RegisterClickEvent(self.BtnJoinTeam, self.OnBtnJoinTeamClick)
    self:RegisterClickEvent(self.BtnQuitTeam, self.OnBtnQuitTeamClick)
    self:RegisterClickEvent(self.SViewCharacterList, self.OnSViewCharacterListClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnConsciousness, self.OnBtnConsciousnessClick)
end
-- auto
function XUiMainLineRoomCharacter:OnBtnWeaponClick(eventData)
    XLuaUiManager.Open("UiEquipReplaceNew", self.CurCharacter.Id, function()
        self:UpdateInfo()
    end, true)
end

function XUiMainLineRoomCharacter:OnBtnConsciousnessClick(eventData)
    XLuaUiManager.Open("UiEquipAwarenessReplace", self.CurCharacter.Id, nil, true)
end

function XUiMainLineRoomCharacter:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiMainLineRoomCharacter:OnSViewCharacterListClick(eventData)

end
--初始化音效
function XUiMainLineRoomCharacter:InitBtnSound()
    self.SpecialSoundMap[self:GetAutoKey(self.BtnBack, "onClick")] = XSoundManager.UiBasicsMusic.Return
    self.SpecialSoundMap[self:GetAutoKey(self.BtnEquip, "onClick")] = XSoundManager.UiBasicsMusic.Fuben_UiMainLineRoomCharacter_Equip
    self.SpecialSoundMap[self:GetAutoKey(self.BtnFashion, "onClick")] = XSoundManager.UiBasicsMusic.Fuben_UiMainLineRoomCharacter_Fashion
    self.SpecialSoundMap[self:GetAutoKey(self.BtnJoinTeam, "onClick")] = XSoundManager.UiBasicsMusic.Fuben_UiMainLineRoomCharacter_JoinTeam
    self.SpecialSoundMap[self:GetAutoKey(self.BtnQuitTeam, "onClick")] = XSoundManager.UiBasicsMusic.Fuben_UiMainLineRoomCharacter_QuitTeam
end


function XUiMainLineRoomCharacter:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid.RootUi = self.RootUi
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local char = self.CharList[index]

        grid:Reset()

        if self.SelectIndex == index then
            self:SetSelectCharacter(char, grid, index)
        end

        grid:SetInTeam(false)
        for _, id in pairs(self.TeamCharIdMap) do
            if id == char.Id then
                grid:SetInTeam(true)
            end
        end
        grid:UpdateGrid(char)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        local character = self.CharList[index]
        if XCharacterConfigs.GetCharacterTemplate(character.Id).Foreshow == 0 then
            self:SetSelectCharacter(character, grid, index)
        else
            XUiManager.TipMsg(CS.XTextManager.GetText("ComingSoon"), XUiManager.UiTipType.Tip)
        end
    end
end

function XUiMainLineRoomCharacter:OnSViewCharacterListValueChanged(...)

end

function XUiMainLineRoomCharacter:OnEnable()
    CS.XGraphicManager.UseUiLightDir = true
    if not self.IsStart then
        self:OnUpdate()
    end
    self.IsStart = false
end

function XUiMainLineRoomCharacter:OnUpdate()
    local selectId
    if self.CurSelectId then
        selectId = self.CurSelectId
    else
        selectId = self.TeamCharIdMap[self.TeamSelectPos]
        self.CurSelectId = selectId
    end


    local index = 1
    local charlist = XDataCenter.CharacterManager.GetCharacterListInTeam(self.TeamCharIdMap, selectId > 0)
    self.CharList = charlist

    for i, v in ipairs(charlist) do
        if v.Id == self.CurSelectId then
            index = i
        end
    end
    self.SelectIndex = index

    self.DynamicTable:SetDataSource(charlist)
    self.DynamicTable:ReloadDataSync(index)
end

function XUiMainLineRoomCharacter:OnOpenInTeam(teamCharIdMap, teamSelectPos, cb)
    if teamCharIdMap == nil or teamSelectPos == nil then
        XLog.Error("XUiCharacter:OnOpenInTeam error: params error")
        return
    end

    self.TeamCharIdMap = teamCharIdMap
    self.TeamSelectPos = teamSelectPos
    self.TeamResultCb = cb
    self:OnUpdate()
end

function XUiMainLineRoomCharacter:CenterToGrid(grid)
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

function XUiMainLineRoomCharacter:SelectCharacter(id)
    if not id then
        return
    end
    local grid = self.CharacterGrids[id]

    if not grid then
        return
    end
    self:CenterToGrid(grid)
end

--更新当前人物
function XUiMainLineRoomCharacter:UpdateInfo(character)
    if self.CurCharacterGrid == nil then
        return
    end

    self.CurCharacterGrid:UpdateGrid(character)

    self:UpdateTeamBtn()
    self:UpdateRoleModel(self.PanelRoleModel, XModelManager.MODEL_UINAME.XUiCharacter)
end

--选中
function XUiMainLineRoomCharacter:SetSelectCharacter(character, grid, index)
    if not character then
        return
    end


    if self.CurCharacterGrid then
        self.CurCharacterGrid:SetSelect(false)
    end

    self.CurCharacterGrid = grid
    self.CurCharacterGrid:SetSelect(true)



    if self.CurCharacter and self.CurCharacter.Id == character.Id then
        return
    end

    self.CurSelectId = character.Id
    self.SelectIndex = index
    self.CurCharacter = character

    self:UpdateTeamBtn()
    self:UpdateRoleModel(self.PanelRoleModel, XModelManager.MODEL_UINAME.XUiCharacter)
end


function XUiMainLineRoomCharacter:UpdateTeamBtn()
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

    self.BtnQuitTeam.gameObject:SetActive(needShowBtnQuitTeam)
    self.BtnJoinTeam.gameObject:SetActive(false)
end

function XUiMainLineRoomCharacter:UpdateRoleModel(targetPanelRole, targetUiName)
    local func = function()
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

function XUiMainLineRoomCharacter:OnBtnBackClick(...)
    self:Close()
end

function XUiMainLineRoomCharacter:OnBtnJoinTeamClick(...)
    local id = self.CurCharacter.Id
    for k, v in pairs(self.TeamCharIdMap) do
        if v == id then
            self.TeamCharIdMap[k] = 0
            break
        end
    end

    self.TeamCharIdMap[self.TeamSelectPos] = id
    if self.TeamResultCb then
        self.TeamResultCb(self.TeamCharIdMap)
        self.TeamResultCb = nil
    end

    self:Close()
end

function XUiMainLineRoomCharacter:OnBtnQuitTeamClick(...)
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
        self.TeamResultCb = nil
    end
    self:Close()
end

function XUiMainLineRoomCharacter:OnBtnFashionClick(...)
    XLuaUiManager.Open("UiFashion", self.CurCharacter.Id, function()
        self:UpdateInfo()
    end)
end

function XUiMainLineRoomCharacter:OnDestroy()
    if self.TeamResultCb then
        self.TeamResultCb(self.TeamCharIdMap)
        self.TeamResultCb = nil
    end
end