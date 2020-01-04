local XUiHostelRest = XLuaUiManager.Register(XLuaUi, "UiHostelRest")
local table_insert = table.insert

-- auto
-- Automatic generation of code, forbid to edit
function XUiHostelRest:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiHostelRest:AutoInitUi()
    self.PanelCharacterRest = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest")
    self.PanelLeftInfo = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo")
    self.SViewFloor = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/SViewFloor"):GetComponent("ScrollRect")
    self.PanelFloorContent = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/SViewFloor/Viewport/PanelFloorContent")
    self.GridFloorItem = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/SViewFloor/Viewport/PanelFloorContent/GridFloorItem")
    self.RImgCharRest = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/RImgCharRest"):GetComponent("RawImage")
    self.GridRestCharItem = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/GridRestCharItem")
    self.PanelRestContent = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent")
    self.UiSlot1 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot1")
    self.UiRestModelPos1 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot1/UiRestModelPos1")
    self.UiSlot2 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot2")
    self.UiRestModelPos2 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot2/UiRestModelPos2")
    self.UiSlot3 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot3")
    self.UiRestModelPos3 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot3/UiRestModelPos3")
    self.UiSlot4 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot4")
    self.UiRestModelPos4 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot4/UiRestModelPos4")
    self.UiSlot5 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot5")
    self.UiRestModelPos5 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot5/UiRestModelPos5")
    self.UiSlot6 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot6")
    self.UiRestModelPos6 = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/PanelRestContent/UiSlot6/UiRestModelPos6")
    self.TxtTitle = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/TxtTitle"):GetComponent("Text")
    self.TxtTitleFloor = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelLeftInfo/TxtTitleFloor"):GetComponent("Text")
    self.PanelRightInfo = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelRightInfo")
    self.SViewIdleCharList = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelRightInfo/SViewIdleCharList"):GetComponent("ScrollRect")
    self.PanelIdleCharContent = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelRightInfo/SViewIdleCharList/Viewport/PanelIdleCharContent")
    self.GridIdleCharacter = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/PanelRightInfo/SViewIdleCharList/Viewport/PanelIdleCharContent/GridIdleCharacter")
    self.RImgCharDrag = self.Transform:Find("SafeAreaContentPane/PanelCharacterRest/RImgCharDrag"):GetComponent("RawImage")
    self.PanelCharTopButton = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton")
    self.BtnBack = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnBack"):GetComponent("Button")
    self.BtnMainUi = self.Transform:Find("SafeAreaContentPane/PanelCharTopButton/BtnMainUi"):GetComponent("Button")
    self.PanelAsset = self.Transform:Find("SafeAreaContentPane/PanelAsset")
    self.PanelTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1")
    self.ImgTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1/ImgTool1"):GetComponent("Image")
    self.TxtTool1 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool1/TxtTool1"):GetComponent("Text")
    self.PanelTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2")
    self.ImgTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2/ImgTool2"):GetComponent("Image")
    self.TxtTool2 = self.Transform:Find("SafeAreaContentPane/PanelAsset/PanelTool2/TxtTool2"):GetComponent("Text")
    self.PanelRestModel = self.Transform:Find("FullScreenBackground/PanelRestModel")
    self.UiCharRestModel = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestModel")
    self.PanelModelRest1 = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestModel/PanelModelRest1")
    self.PanelModelRest2 = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestModel/PanelModelRest2")
    self.PanelModelRest3 = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestModel/PanelModelRest3")
    self.PanelModelRest4 = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestModel/PanelModelRest4")
    self.PanelModelRest5 = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestModel/PanelModelRest5")
    self.PanelModelRest6 = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestModel/PanelModelRest6")
    self.PanelModelReste = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestModel/PanelModelReste")
    self.UiCharRestDrag = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestDrag")
    self.UiCameraRestDrag = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestDrag/UiCameraRestDrag")
    self.PanelModelRestDrag = self.Transform:Find("FullScreenBackground/PanelRestModel/UiCharRestDrag/PanelModelRestDrag")
end

function XUiHostelRest:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiHostelRest:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiHostelRest:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiHostelRest:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnBack, "onClick", self.OnBtnBackClick)
    self:RegisterListener(self.BtnMainUi, "onClick", self.OnBtnMainUiClick)
end
-- auto

function XUiHostelRest:OnAwake()
    self:InitAutoScript()
end

function XUiHostelRest:OnStart()
   
    self:Init()
    self.CurFloor = 0
    self.FloorUiItem = {}
    self.RestCharUiItem = {}
    self.IdleCharUiItem = {}
    self:UpdateView()
end

function XUiHostelRest:Init()
    self.RctF = self.GameObject:GetComponent("RectTransform")
    self.GridFloorItem.gameObject:SetActive(false)
    self.GridRestCharItem.gameObject:SetActive(false)
    self.GridIdleCharacter.gameObject:SetActive(false)
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.HostelElectric, XDataCenter.ItemManager.ItemId.HostelMat)
    local tabScreenPosition = {}
    for i = 1, 6 do
        local pos = CS.XUiManager.UiCamera:WorldToViewportPoint(self["UiRestModelPos" .. i].transform.position)
        table_insert(tabScreenPosition, pos)
    end
    self.ShowModel = XUiPanelRestModel.New(self.PanelRestModel, self.RImgCharRest, self.RImgCharDrag, tabScreenPosition, self.Name)
end

function XUiHostelRest:OnBtnBackClick(...)
    --CS.XUiManager.ViewManager:Pop()
    self:Close()
end

function XUiHostelRest:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiHostelRest:OnBtnBuyJump1Click(...)

end

function XUiHostelRest:OnBtnBuyJump2Click(...)

end

function XUiHostelRest:OnBtnBuyJump3Click(...)

end

function XUiHostelRest:UpdateView()
    self:UpdateFloorList()
    self:UpdateIdleList()
end

function XUiHostelRest:UpdateFloorList()
    local maxFloor = XDataCenter.HostelManager.GetHostelMaxFloor()
    local datas = {}
    local callback = function(floor)
        self:OnSelectFloor(floor)
    end
    for i = 1, maxFloor do
        table_insert(datas, { Floor = i, CallBack = callback })
    end
    local onCreate = function(item, data)
        item:SetData(data)
    end
    XUiHelper.CreateTemplates(self, self.FloorUiItem, datas, XUiGridFloorItem.New, self.GridFloorItem.gameObject, self.PanelFloorContent, onCreate)
    if self.CurFloor == 0 then
        self:OnSelectFloor(1)
    end
end

function XUiHostelRest:OnSelectFloor(floor)
    if self.CurFloor > 0 then
        self.FloorUiItem[self.CurFloor]:SetSelect(false)
    end
    self.CurFloor = floor
    if self.CurFloor > 0 then
        self.FloorUiItem[self.CurFloor]:SetSelect(true)
    end
    self:UpdateRestList()
    local config = XDataCenter.HostelManager.GetHostelRestTemplate(self.CurFloor)
    if not config then
        return
    end
    self.TxtTitleFloor.text = config.Name
    self.TxtTitle.text = config.AreaName
end

function XUiHostelRest:UpdateRestList()
    local datas = {}
    local restCount = XDataCenter.HostelManager.GetHostelFloorRestCount(self.CurFloor)
    local charIdList = {}
    for i = 1, restCount do
        local restData = XDataCenter.HostelManager.GetHostelRestData(self.CurFloor, i)
        local Id = restData and restData.CharacterId or 0
        table_insert(datas, { Slot = i, CharId = Id })
        table_insert(charIdList, Id)
    end
    local onCreate = function(item, data)
        item:SetData(data)
        self:SetRestItemDragFunc(item, data.Slot)
        item.GameObject.transform:SetParent(self["UiSlot" .. data.Slot], false)
        item:GetRectTransform().anchoredPosition = CS.UnityEngine.Vector2.zero
    end

    self.RImgCharRest.gameObject:SetActive(true)
    XUiHelper.CreateTemplates(self, self.RestCharUiItem, datas, XUiGridRestCharItem.New, self.GridRestCharItem.gameObject, nil, onCreate)

    self.ShowModel:UpdateShowCharRest(charIdList, tabScreenPosition)
end

function XUiHostelRest:SetRestItemDragFunc(item, slot)
    if self["RestItem" .. slot] then
        return
    end
    local dragItem = item.GameObject:AddComponent(typeof(CS.XUiWidget))
    dragItem:AddBeginDragListener(function(eventData)
        self:OnRestItemBeginDrag(eventData, slot)
    end)
    dragItem:AddEndDragListener(function(eventData)
        self:OnRestItemEndDrag(eventData, slot)
    end)
    dragItem:AddDragListener(function(eventData)
        self:OnRestItemDrag(eventData, slot)
    end)
    self["RestItem" .. slot] = dragItem
end

function XUiHostelRest:OnRestItemBeginDrag(eventData, slot)
    local charid = self.RestCharUiItem[slot]:GetCharId()
    if not charid or charid == 0 then
        return
    end
    self.ShowModel:UpdateDragModel(charid)
end

function XUiHostelRest:OnRestItemDrag(eventData, slot)
    local charid = self.RestCharUiItem[slot]:GetCharId()
    if not charid or charid == 0 then
        return
    end
    local rectTransform = self.RImgCharDrag:GetComponent("RectTransform")
    local isIn, position = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.Transform, eventData.position, eventData.pressEventCamera)
    self.RImgCharDrag.transform.localPosition = CS.UnityEngine.Vector3(position.x, position.y, 0)
end

function XUiHostelRest:OnRestItemEndDrag(eventData, slot)
    local charid = self.RestCharUiItem[slot]:GetCharId()
    if not charid or charid == 0 then
        return
    end
    self.ShowModel:HideDragModel()
    local restSlot
    for i, v in ipairs(self.RestCharUiItem) do
        local isInRest = CS.UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(v:GetRectTransform(), eventData.position, eventData.pressEventCamera)
        if isInRest then
            restSlot = i
            break
        end
    end
    if restSlot then
        XDataCenter.HostelManager.ReqRestCharacter(charid, self.CurFloor, restSlot, function()
            self:UpdateRestList()
            self:UpdateIdleList()
        end)
        return
    else
        if XDataCenter.HostelManager.IsCharacterInWork(charid) then
            return
        end
    end

    local isInRest = CS.UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(self.PanelRestContent:GetComponent("RectTransform"), eventData.position, eventData.pressEventCamera)
    if isInRest then
        return
    end
    XDataCenter.HostelManager.ReqUnRestCharacter(self.CurFloor, slot, function()
        self:UpdateRestList()
        self:UpdateIdleList()
    end)
end

function XUiHostelRest:UpdateIdleList()
    local charList = XDataCenter.CharacterManager.GetOwnCharacterList() or {}
    table.sort(charList, function(a, b)
        local aIsRest = XDataCenter.HostelManager.IsCharacterInRest(a.Id)
        local bIsRest = XDataCenter.HostelManager.IsCharacterInRest(b.Id)
        if aIsRest == bIsRest then
            if aIsRest then
                return a.Id > b.Id
            else
                -- 判断条件暂时没有
                return a.Id > b.Id
            end
        else
            return bIsRest
        end
    end)

    local datas = {}
    for i, v in ipairs(charList) do
        table_insert(datas, { Index = i, Id = v.Id })
    end
    local onCreate = function(item, data)
        item:SetData(data.Index, data.Id, true)
        self:SetIdleItemDragFunc(item, data.Index)
    end
    XUiHelper.CreateTemplates(self, self.IdleCharUiItem, datas, XUiGridIdleCharacter.New, self.GridIdleCharacter.gameObject, self.PanelIdleCharContent, onCreate)
end

function XUiHostelRest:SetIdleItemDragFunc(item, index)
    if self["IdleItem" .. index] then
        return
    end
    local dragItem = item.GameObject:AddComponent(typeof(CS.XUiWidget))
    dragItem:AddBeginDragListener(function(eventData)
        self:OnIdleItemBeginDrag(eventData, index)
    end)
    dragItem:AddEndDragListener(function(eventData)
        self:OnIdleItemEndDrag(eventData, index)
    end)
    dragItem:AddDragListener(function(eventData)
        self:OnIdleItemDrag(eventData, index)
    end)
    self["IdleItem" .. index] = dragItem
end

function XUiHostelRest:OnIdleItemBeginDrag(eventData, index)
    local charid = self.IdleCharUiItem[index]:GetCharId()
    if not charid or charid == 0 then
        return
    end
    if XDataCenter.HostelManager.IsCharacterInWork(charid) then
        return
    end
    self.ShowModel:UpdateDragModel(charid)
end

function XUiHostelRest:OnIdleItemDrag(eventData, index)
    local charid = self.IdleCharUiItem[index]:GetCharId()
    if not charid or charid == 0 then
        return
    end
    local rectTransform = self.RImgCharDrag:GetComponent("RectTransform")
    local isIn, position = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.Transform, eventData.position, eventData.pressEventCamera)
    self.RImgCharDrag.transform.localPosition = CS.UnityEngine.Vector3(position.x, position.y, 0)
end

function XUiHostelRest:OnIdleItemEndDrag(eventData, index)
    local charid = self.IdleCharUiItem[index]:GetCharId()
    if not charid or charid == 0 then
        return
    end
    self.ShowModel:HideDragModel()
    local isInRest = CS.UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(self.PanelRestContent:GetComponent("RectTransform"), eventData.position, eventData.pressEventCamera)
    if not isInRest then
        return
    end
    local emptySlot = self:GetEmptySlot()
    local restSlot = 0
    local isCharRest = XDataCenter.HostelManager.IsCharacterInRest(charid)
    if emptySlot and not isCharRest then
        restSlot = emptySlot
    else
        for i, v in ipairs(self.RestCharUiItem) do
            local isInRest = CS.UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(v:GetRectTransform(), eventData.position, eventData.pressEventCamera)
            if isInRest then
                restSlot = i
                break
            end
        end
    end
    if restSlot == 0 then
        return
    end
    XDataCenter.HostelManager.ReqRestCharacter(charid, self.CurFloor, restSlot, function()
        self:UpdateRestList()
        self:UpdateIdleList()
    end)

end

function XUiHostelRest:GetEmptySlot()
    local restCount = XDataCenter.HostelManager.GetHostelFloorRestCount(self.CurFloor)
    for i = 1, restCount do
        local restData = XDataCenter.HostelManager.GetHostelRestData(self.CurFloor, i)
        if not restData or restData.CharacterId == 0 then
            return i
        end
    end
end

