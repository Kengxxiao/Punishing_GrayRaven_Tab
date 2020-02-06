local XUiGridEquip = require("XUi/XUiEquipAwarenessReplace/XUiGridEquip")
local XUiGridEquipReplaceAttr = require("XUi/XUiEquipReplaceNew/XUiGridEquipReplaceAttr")
local XUiGridResonanceSkill = require("XUi/XUiEquipResonanceSkill/XUiGridResonanceSkill")

local XUiEquipReplaceNew = XLuaUiManager.Register(XLuaUi, "UiEquipReplaceNew")

function XUiEquipReplaceNew:OnAwake()
    self:AutoAddListener()
    self:InitComponentStatus()
end

function XUiEquipReplaceNew:OnStart(charid, closecallback, notShowStrengthenBtn)
    self.IsAscendOrder = false --初始降序
    self.NotShowStrengthenBtn = notShowStrengthenBtn or false
    self:InitViewData(charid, closecallback)
    self:InitDynamicTable()

    self.ImgAscend.gameObject:SetActive(self.IsAscendOrder)
    self.ImgDescend.gameObject:SetActive(not self.IsAscendOrder)
end

function XUiEquipReplaceNew:OnEnable()
    self:UpdateView()
end

function XUiEquipReplaceNew:OnDestroy()
    if self.CloseCallback then
        self.CloseCallback(self.CharacterId, self.ChangeEquipSuccess)
    end
end

--注册监听事件
function XUiEquipReplaceNew:OnGetEvents()
    return {
        XEventId.EVENT_EQUIP_PUTON_NOTYFY,
        XEventId.EVENT_EQUIP_LOCK_STATUS_CHANGE_NOTYFY,
        XEventId.EVENT_EQUIP_STRENGTHEN_NOTYFY,
        XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY,
        XEventId.EVENT_EQUIP_RESONANCE_ACK_NOTYFY,
    }
end

--处理事件监听
function XUiEquipReplaceNew:OnNotify(evt, ...)
    local args = { ... }
    local equipId = args[1]

    if evt == XEventId.EVENT_EQUIP_PUTON_NOTYFY then
        self.UsingEquipId = equipId
        self:OnPutOnEquip()
    elseif evt == XEventId.EVENT_EQUIP_LOCK_STATUS_CHANGE_NOTYFY then
        self:OnEquipLockStatusChange(equipId)
        self:UpdateEquipGridList()
    elseif evt == XEventId.EVENT_EQUIP_STRENGTHEN_NOTYFY or evt == XEventId.EVENT_EQUIP_BREAKTHROUGH_NOTYFY or evt == XEventId.EVENT_EQUIP_RESONANCE_ACK_NOTYFY then
        self:UpdateView()
    end
end

function XUiEquipReplaceNew:InitComponentStatus()
    self.GridEquip.gameObject:SetActive(false)
    self.GridEquipReplaceAttr.gameObject:SetActive(false)
    self.GridEquipReplaceAttr.gameObject:SetActive(false)
    self.GridResonanceSkill.gameObject:SetActive(false)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
end

function XUiEquipReplaceNew:InitViewData(characterid, closecallback)
    self.CharacterId = characterid
    self.CloseCallback = closecallback
    self.AttrGridList = {}
    self.GridResonanceSkills = {}
    self.PriorSortType = XEquipConfig.PriorSortType.Star
    local equipId = XDataCenter.EquipManager.GetCharacterWearingWeaponId(self.CharacterId)  --初始为角色身上的装备
    self.SelectEquipId = equipId
    self.UsingEquipId = equipId
end

function XUiEquipReplaceNew:UpdateView()
    self.WeaponIdList = XDataCenter.EquipManager.GetCanUseWeaponIds(self.CharacterId)
    self:OnPutOnEquip()
    self:SelectSortType()
    self:OnSelectEquip()
end

function XUiEquipReplaceNew:InitDynamicTable()
    self.DynamicTable = XDynamicTableNormal.New(self.PanelEquipScroll)
    self.DynamicTable:SetProxy(XUiGridEquip)
    self.DynamicTable:SetDelegate(self)
end

function XUiEquipReplaceNew:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:InitRootUi(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local equipId = self.WeaponIdList[index]
        grid:Refresh(equipId)

        local isSelected = equipId == self.SelectEquipId
        grid:SetSelected(isSelected)
        if isSelected then
            self.LastSelectGrid = grid
        end
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self.SelectEquipId = self.WeaponIdList[index]
        self:OnSelectEquip()
        if self.LastSelectGrid then
            self.LastSelectGrid:SetSelected(false)
        end
        self.LastSelectGrid = grid
        self.LastSelectGrid:SetSelected(true)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RELOAD_COMPLETED then
        XEventManager.DispatchEvent(XEventId.EVENT_GUIDE_STEP_OPEN_EVENT)
    end
end

function XUiEquipReplaceNew:OnPutOnEquip()
    self:UpdateCompareAttr()
    self:UpdateBtnEquipStatus()
    self:SelectSortType()
end

function XUiEquipReplaceNew:OnEquipLockStatusChange(equipId)
    if equipId ~= self.SelectEquipId then return end
    local equip = XDataCenter.EquipManager.GetEquip(equipId)

    self.BtnLock.gameObject:SetActive(equip.IsLock)
    self.BtnUnlock.gameObject:SetActive(not equip.IsLock)
end

function XUiEquipReplaceNew:SelectSortType()
    XDataCenter.EquipManager.SortEquipIdListByPriorType(self.WeaponIdList, self.PriorSortType)
    if self.IsAscendOrder then
        self.WeaponIdList = XTool.ReverseList(self.WeaponIdList)
    end
    self:UpdateEquipGridList()
end

function XUiEquipReplaceNew:UpdateEquipGridList()
    self:UsingWeaponFirstInList()
    self.DynamicTable:SetDataSource(self.WeaponIdList)
    self.DynamicTable:ReloadDataASync(#self.WeaponIdList > 0 and 1 or -1)

    self:PlayAnimation("LeftQieHuan")
end

function XUiEquipReplaceNew:UpdateResonanceSkills()
    local skillCount = 0

    local resonanceSkillNum = XDataCenter.EquipManager.GetResonanceSkillNum(self.SelectEquipId)
    for pos = resonanceSkillNum, 1, -1 do
        if XDataCenter.EquipManager.CheckEquipPosResonanced(self.SelectEquipId, pos) then
            if not self.GridResonanceSkills[pos] then
                local item = CS.UnityEngine.Object.Instantiate(self.GridResonanceSkill)  -- 复制一个item
                self.GridResonanceSkills[pos] = XUiGridResonanceSkill.New(item, self.SelectEquipId, pos, self.CharacterId, function(equipId, pos, characterId)
                    XLuaUiManager.Open("UiEquipResonanceSkillDetailInfo", equipId, pos, characterId)
                end)
                self.GridResonanceSkills[pos].Transform:SetParent(self.PanelSkills, false)
            end

            self.GridResonanceSkills[pos]:SetEquipIdAndPos(self.SelectEquipId, pos)
            self.GridResonanceSkills[pos]:Refresh()
            self.GridResonanceSkills[pos].GameObject:SetActive(true)
            self.GridResonanceSkills[pos].Transform:SetAsFirstSibling()

            skillCount = skillCount + 1
        else
            if self.GridResonanceSkills[pos] then
                self.GridResonanceSkills[pos].GameObject:SetActive(false)
            end
        end
    end

    if skillCount == 0 then
        for _, grid in pairs(self.GridResonanceSkills) do
            grid.GameObject:SetActive(false)
        end
    end

    for pos = 1, XEquipConfig.MAX_RESONANCE_SKILL_COUNT do
        self["ImgBg" .. pos].gameObject:SetActive(pos > skillCount and pos <= resonanceSkillNum)
    end

    if resonanceSkillNum == 0 then
        self.PanelResonanceSkill.gameObject:SetActive(false)
    else
        self.PanelResonanceSkill.gameObject:SetActive(true)
    end
end

function XUiEquipReplaceNew:OnSelectEquip()
    self:UpdateSelectEquip()
    self:UpdateCompareAttr()
    self:UpdateBtnEquipStatus()
    self:OnEquipLockStatusChange(self.SelectEquipId)
    self:UpdateResonanceSkills()
end

function XUiEquipReplaceNew:UpdateSelectEquip()
    local equip = XDataCenter.EquipManager.GetEquip(self.SelectEquipId)
    local weaponSkillInfo = XDataCenter.EquipManager.GetOriginWeaponSkillInfo(equip.TemplateId)

    self.RImgEquipIcon:SetRawImage(XDataCenter.EquipManager.GetWeaponTypeIconPath(self.SelectEquipId))
    self.TxtEquipName.text = XDataCenter.EquipManager.GetEquipName(equip.TemplateId)
    self.TxtEquipLevel.text = equip.Level
    self.TxtSkillDes.text = weaponSkillInfo.Description

    local noSkill = not weaponSkillInfo.Description and not weaponSkillInfo.Name
    self.PanelSkillDes.gameObject:SetActive(not noSkill)

    for i = 1, XEquipConfig.MAX_STAR_COUNT do
        if i <= XDataCenter.EquipManager.GetEquipStar(equip.TemplateId) then
            self["ImgStar" .. i].gameObject:SetActive(true)
        else
            self["ImgStar" .. i].gameObject:SetActive(false)
        end
    end
end

function XUiEquipReplaceNew:UpdateCompareAttr()
    if not self.UsingEquipId or not self.SelectEquipId then return end
    local curAttrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.UsingEquipId)
    local newAttrMap = XDataCenter.EquipManager.GetEquipAttrMap(self.SelectEquipId)

    for key, attrInfo in pairs(curAttrMap) do
        local curAttrValue = curAttrMap[key] and curAttrMap[key].Value or 0
        local newAttrValue = newAttrMap[key] and newAttrMap[key].Value or 0

        if not self.AttrGridList[key] then
            local ui = CS.UnityEngine.Object.Instantiate(self.GridEquipReplaceAttr)
            self.AttrGridList[key] = XUiGridEquipReplaceAttr.New(ui, curAttrMap[key].Name)
            self.AttrGridList[key].Transform:SetParent(self.PanelAttrParent, false)
        end

        self.AttrGridList[key]:UpdateData(curAttrValue, newAttrValue)
        self.AttrGridList[key].GameObject:SetActive(true)
    end

    self:PlayAnimation("RightQieHuan")
end

function XUiEquipReplaceNew:UpdateBtnEquipStatus()
    if self.UsingEquipId == self.SelectEquipId then
        --当前角色使用中
        self.BtnTakeOn.gameObject:SetActive(false)
        self.ImgEquipOn.gameObject:SetActive(true)
    else
        self.BtnTakeOn.gameObject:SetActive(true)
        self.ImgEquipOn.gameObject:SetActive(false)
    end

    self.BtnStrengthen.gameObject:SetActive(not self.NotShowStrengthenBtn)
end

function XUiEquipReplaceNew:AutoAddListener()
    self:RegisterClickEvent(self.BtnTakeOn, self.OnBtnTakeOnClick)
    self:RegisterClickEvent(self.BtnStrengthen, self.OnBtnStrengthenClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMain, self.OnBtnMainClick)
    self:RegisterClickEvent(self.BtnOrder, self.OnBtnOrderClick)
    self:RegisterClickEvent(self.BtnLock, self.OnBtnLockClick)
    self:RegisterClickEvent(self.BtnUnlock, self.OnBtnUnlockClick)
    self.DrdSort.onValueChanged:AddListener(function()
        self.PriorSortType = self.DrdSort.value
        self:SelectSortType()
    end)
end

function XUiEquipReplaceNew:OnBtnOrderClick(...)
    self.IsAscendOrder = not self.IsAscendOrder
    self.WeaponIdList = XTool.ReverseList(self.WeaponIdList)
    self:UpdateEquipGridList()
    self.ImgAscend.gameObject:SetActive(self.IsAscendOrder)
    self.ImgDescend.gameObject:SetActive(not self.IsAscendOrder)
end

function XUiEquipReplaceNew:OnBtnLockClick(...)
    XDataCenter.EquipManager.SetLock(self.SelectEquipId, false)
end

function XUiEquipReplaceNew:OnBtnUnlockClick(...)
    XDataCenter.EquipManager.SetLock(self.SelectEquipId, true)
end

function XUiEquipReplaceNew:OnBtnStrengthenClick(...)
    XLuaUiManager.Open("UiEquipDetail", self.SelectEquipId, nil, self.CharacterId)
end

function XUiEquipReplaceNew:OnBtnTakeOnClick(...)
    local equip = XDataCenter.EquipManager.GetEquip(self.SelectEquipId)
    local characterId = equip.CharacterId
    --其他角色使用中
    if characterId and characterId > 0 then
        --自己穿戴了专属装备
        local specialCharacterId = XDataCenter.EquipManager.GetEquipSpecialCharacterId(self.UsingEquipId)
        if specialCharacterId and specialCharacterId > 0 then
            XUiManager.TipText("EquipWithSpecialCharacterIdCanNotBeReplaced")
            return
        end

        local fullName = XCharacterConfigs.GetCharacterFullNameStr(characterId)
        local content = string.gsub(CS.XTextManager.GetText("EquipReplaceTip", fullName), " ", "")
        XUiManager.DialogTip(CS.XTextManager.GetText("TipTitle"), content, XUiManager.DialogType.Normal, function() end, function()
            XDataCenter.EquipManager.PutOn(self.CharacterId, self.SelectEquipId)
            self.ChangeEquipSuccess = true
        end)
    else
        XDataCenter.EquipManager.PutOn(self.CharacterId, self.SelectEquipId)
        self.ChangeEquipSuccess = true
    end
end

function XUiEquipReplaceNew:OnBtnBackClick(...)
    self:Close()
end

function XUiEquipReplaceNew:OnBtnMainClick(...)
    XLuaUiManager.RunMain()
end

function XUiEquipReplaceNew:UsingWeaponFirstInList()
    local usingEquipId
    for index, equipId in pairs(self.WeaponIdList) do
        if equipId == self.UsingEquipId then
            usingEquipId = table.remove(self.WeaponIdList, index)
        end
    end
    if usingEquipId then
        table.insert(self.WeaponIdList, 1, usingEquipId)
    end
end

function XUiEquipReplaceNew:GuideGetDynamicTableIndex(id)
    for i, v in ipairs(self.WeaponIdList) do
        local equip = XDataCenter.EquipManager.GetEquip(v)
        if tostring(equip.TemplateId) == id then
            return i
        end
    end

    return -1
end