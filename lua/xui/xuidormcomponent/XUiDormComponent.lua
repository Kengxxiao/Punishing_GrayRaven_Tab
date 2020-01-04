local XUiDormComponent = XLuaUiManager.Register(XLuaUi, "UiDormComponent")
local XUiGrid3DObj = require("XUi/XUiDormComponent/XUiGrid3DObj")
local XUiGridDialogBox = require("XUi/XUiDormComponent/XUiGridDialogBox")
local XUiPanelExp = require("XUi/XUiDormComponent/XUiPanelExp")
local XUiPanelExpDetail = require("XUi/XUiDormComponent/XUiPanelExpDetail")
local XUiPanelPutOn = require("XUi/XUiDormComponent/XUiPanelPutOn")
local XUiPanelTouch = require("XUi/XUiDormComponent/XUiPanelTouch")
local XUiFurnitureAttrObj = require("XUi/XUiDormComponent/XUiFurnitureAttrObj")

function XUiDormComponent:OnAwake()
    self.CurDormSecond = true
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_MOOD_CHANGED, self.OnCharacterMoodChange, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_VITALITY_CHANGED, self.OnCharacterVitaltyChange, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_PUT_ON, self.OnCharacterPutOn, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_PUT_DOWN, self.OnCharacterPutDown, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_CATCH, self.OnCharacterCatch, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_EXIT, self.OnCharacterExit, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_ROOM, self.OnEnterRoom, self)
    XEventManager.AddEventListener(XEventId.EXIT_DORM_ROOM, self.CloseComponent, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_TOUCH_SHOW, self.OnTouchShow, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_TOUCH_SHOW_VIEW, self.OnTouchShow, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_TOUCH_HIDE, self.OnTouchHide, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_SHOW_DIALOBOX, self.OnShowDialoBox, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_HIDE_DIALOBOX, self.OnHideDialoBox, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_SHOW_3DIOBJ, self.OnShow3DObj, self)
    XEventManager.AddEventListener(XEventId.EVENT_CHARACTER_HIDE_3DIOBJ, self.OnHide3DObj, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_EXP_DETAIL_SHOW, self.OnExpDetailShow, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_EXP_DETAIL_HIDE, self.OnExpDetailHide, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_TOUCH_ENTER, self.OnExpShow, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_EXP_SHOW, self.OnExpShow, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_EXP_HIDE, self.OnExpHide, self)

    XEventManager.AddEventListener(XEventId.EVENT_DORM_HIDE_COMPONET, self.HieComponent, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_CLOSE_COMPONET, self.CloseComponent, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_SECOND_STATE, self.DormSecondState, self)

    CsXGameEventManager.Instance:RegisterEvent(XEventId.EVENT_DORM_FURNITURE_ATTR_TAG_DETAIL,handler(self,self.ShowFurnitureAttr))
    CsXGameEventManager.Instance:RegisterEvent(XEventId.EVENT_DORM_FURNITURE_HIDE_ATTR_TAG_DETAIL,handler(self,self.HideFurnitureAttr))
    CsXGameEventManager.Instance:RegisterEvent(XEventId.EVENT_DORM_FURNITURE_HIDE_ALL_ATTR_TAG_DETAIL,handler(self,self.HideAllFurnitureAttr))

end

function XUiDormComponent:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_MOOD_CHANGED, self.OnCharacterMoodChange, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_VITALITY_CHANGED, self.OnCharacterVitaltyChange, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_PUT_ON, self.OnCharacterPutOn, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_PUT_DOWN, self.OnCharacterPutDown, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_CATCH, self.OnCharacterCatch, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_EXIT, self.OnCharacterExit, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_ROOM, self.OnEnterRoom, self)
    XEventManager.RemoveEventListener(XEventId.EXIT_DORM_ROOM, self.CloseComponent, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_TOUCH_SHOW, self.OnTouchShow, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_TOUCH_SHOW_VIEW, self.OnTouchShow, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_TOUCH_HIDE, self.OnTouchHide, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_SHOW_DIALOBOX, self.OnShowDialoBox, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_HIDE_DIALOBOX, self.OnHideDialoBox, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_SHOW_3DIOBJ, self.OnShow3DObj, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CHARACTER_HIDE_3DIOBJ, self.OnHide3DObj, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_EXP_DETAIL_SHOW, self.OnExpDetailShow, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_EXP_DETAIL_HIDE, self.OnExpDetailHide, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_TOUCH_ENTER, self.OnExpShow, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_EXP_SHOW, self.OnExpShow, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_EXP_HIDE, self.OnExpHide, self)

    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_HIDE_COMPONET, self.HieComponent, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_CLOSE_COMPONET, self.CloseComponent, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_SECOND_STATE, self.DormSecondState, self)

    CsXGameEventManager.Instance:RemoveEvent(XEventId.EVENT_DORM_FURNITURE_ATTR_TAG_DETAIL,handler(self,self.ShowFurnitureAttr))
    CsXGameEventManager.Instance:RemoveEvent(XEventId.EVENT_DORM_FURNITURE_HIDE_ATTR_TAG_DETAIL,handler(self,self.HideFurnitureAttr))
    CsXGameEventManager.Instance:RemoveEvent(XEventId.EVENT_DORM_FURNITURE_HIDE_ALL_ATTR_TAG_DETAIL,handler(self,self.HideAllFurnitureAttr))

end

function XUiDormComponent:DormSecondState(state)
    self.CurDormSecond = state
end

function XUiDormComponent:OnStart()
    self.DialogGridsDir = {} 
    self.DialogGridsList = {}

    self.Obj3DGridsDir = {} 
    self.Obj3DGridsList = {}

    self.FurnitureScoreDic = {}

    self.UiPanelExp = XUiPanelExp.New(self, self.PanelExp)
    self.UiPanelTouch = XUiPanelTouch.New(self, self.PanelTouch)
    self.UiPanelExpDetail = XUiPanelExpDetail.New(self, self.PanelExpDetail)
    self.UiPanelPutOn = XUiPanelPutOn.New(self, self.PanelPutOn)

    self.UiPanelExp.GameObject:SetActive(false)
    self.UiPanelExpDetail.GameObject:SetActive(false)
    self.UiPanelPutOn.GameObject:SetActive(false)
    self.UiPanelTouch.GameObject:SetActive(false)
    self.GridDialogBox.gameObject:SetActive(false)
    self.Grid3DObj.gameObject:SetActive(false)
end

function XUiDormComponent:OnEnterRoom(curRoomId)
    self.CurRoomId = curRoomId

    self.UiPanelExp:InitRoomId(curRoomId)
    self.UiPanelExpDetail:InitRoomId(curRoomId)
    self.UiPanelPutOn:InitRoomId(curRoomId)  
    self.UiPanelTouch:InitRoomId(curRoomId)
end

function XUiDormComponent:OnCharacterMoodChange(characterId, changeValue)
    self.UiPanelExp:UpdateExpInfo(characterId, changeValue)
    self.UiPanelExpDetail:UpdateExpInfo(characterId)
end

function XUiDormComponent:OnCharacterVitaltyChange(characterId)
    self.UiPanelExpDetail:UpdateInfo(characterId)
end

----------------------- 外部调用 ------------------------------------

-- 对话气泡显示
function XUiDormComponent:OnShowDialoBox(characterId, contextId, transform, cb)
    -- 处理已经在显示中
    if self.DialogGridsDir[characterId] then
        self.DialogGridsDir[characterId]:RefreshContext(contextId)
        return
    end

    -- 处理缓存中的
    if #self.DialogGridsList > 0 then 
       local temp = table.remove(self.DialogGridsList, 1)
       temp:Show(self.CurRoomId, characterId, contextId, transform, cb)
       self.DialogGridsDir[characterId] = temp
       return
    end

    -- 重新实例一个
    local grid = CS.UnityEngine.Object.Instantiate(self.GridDialogBox)
    local gridBox = XUiGridDialogBox.New(self, grid)
    gridBox:Show(self.CurRoomId, characterId, contextId, transform, cb)
    grid.transform:SetParent(self.DialogContainer, false)
    self.DialogGridsDir[characterId] = gridBox
end

-- 对话气泡隐藏
function XUiDormComponent:OnHideDialoBox(characterId)
    if not self.DialogGridsDir[characterId] then
        return
    end

    self.DialogGridsDir[characterId]:Hide()
    table.insert(self.DialogGridsList, self.DialogGridsDir[characterId])
    self.DialogGridsDir[characterId] = nil
end

-- 3DUI显示
function XUiDormComponent:OnShow3DObj(characterId, effectId, transform, bindWorldPos)
    -- 处理已经在显示中
    if self.Obj3DGridsDir[characterId] then
        self.Obj3DGridsDir[characterId]:RefreshEffect(effectId, bindWorldPos)
        return
    end

    -- 处理缓存中的
    if #self.Obj3DGridsList > 0 then 
        local temp = table.remove(self.Obj3DGridsList, 1) 
        temp:Show(characterId, effectId, transform, bindWorldPos)
        self.Obj3DGridsDir[characterId] = temp
        return
    end

    -- 重新实例一个
    local grid = CS.UnityEngine.Object.Instantiate(self.Grid3DObj)
    local gridBox = XUiGrid3DObj.New(grid)
    gridBox:Show(characterId, effectId, transform, bindWorldPos)
    self.Obj3DGridsDir[characterId] = gridBox
end

-- 3DUI隐藏
function XUiDormComponent:OnHide3DObj(characterId)
    if not self.Obj3DGridsDir[characterId] then
        return
    end

    self.Obj3DGridsDir[characterId]:Hide()
    table.insert(self.Obj3DGridsList, self.Obj3DGridsDir[characterId])
    self.Obj3DGridsDir[characterId].Transform:SetParent(self.Obje3DContainer, false)
    self.Obj3DGridsDir[characterId] = nil
end

-- 抚摸显示
function XUiDormComponent:OnTouchShow(touchState, characterId, point, propNum)
    self.UiPanelTouch:Show(characterId, touchState, point, propNum)
end

-- 抚摸隐藏
function XUiDormComponent:OnTouchHide()
    self.UiPanelTouch:Hide()
    self.UiPanelExp:Hide(true)
    self:OnExpDetailHide()
end

-- 抓起构造体
function XUiDormComponent:OnCharacterCatch()
    self.UiPanelPutOn:Catch()
end

-- 抓起构造体读条放下
function XUiDormComponent:OnCharacterExit()
    self.UiPanelPutOn:Close()
end

-- 构造体抓起读条
function XUiDormComponent:OnCharacterPutOn(characterId, transform)
    self.UiPanelPutOn:Show(characterId, transform) 
end

-- 放下构造体
function XUiDormComponent:OnCharacterPutDown()
    self.UiPanelPutOn:Hide() 
end

-- 显示体力详情
function XUiDormComponent:OnExpDetailShow(characterId, transform)
    if not self.CurDormSecond then
        return
    end
    self.CharacterId = characterId
    self.Transform = transform
    self.UiPanelExpDetail:Show(characterId, transform)
end

-- 隐藏体力详情
function XUiDormComponent:OnExpDetailHide()
    self.UiPanelExpDetail:Hide()
end

-- 显示心情条
function XUiDormComponent:OnExpShow(characterId)
    local trans = XHomeCharManager.GetSelectCharacter().Transform
    self.UiPanelExp:Show(characterId, trans)
end

-- 隐藏心情条
function XUiDormComponent:OnExpHide()
    self.UiPanelExp:Hide(false)
end

-- 设置心情条是否再爱抚中
function XUiDormComponent:SetExpOffset(isFondle)
    self.UiPanelExp:UpdateOffset(isFondle)
end

-- 隐藏所有组建
function XUiDormComponent:HieComponent()
    self.UiPanelExp:Hide(true)
    self.UiPanelExpDetail:Hide()
    self.UiPanelTouch:Hide()
    self.UiPanelPutOn:Hide() 

    for _, v in pairs(self.DialogGridsDir) do
        v:Hide()
        table.insert(self.DialogGridsList, v)
    end

    for _, v in pairs(self.Obj3DGridsDir) do
        v:Hide()
        table.insert(self.Obj3DGridsList, v)
        v.Transform:SetParent(self.Obje3DContainer, false)
    end

    self.Obj3DGridsDir = {}
    self.DialogGridsDir = {}
end

--显示家具属性
function XUiDormComponent:ShowFurnitureAttr(evt,args)
    local furnitureAttrObj = nil
    local furnitureId = args[1]

    if not self.FurnitureScoreContainer or XTool.UObjIsNil(self.FurnitureScoreContainer) then
        return
    end

    if not self.FurnitureScoreDic[furnitureId] then
        local obj = self.FurnitureScoreContainer:Spawn()
        furnitureAttrObj = XUiFurnitureAttrObj.New(self,obj)
        self.FurnitureScoreDic[furnitureId] = furnitureAttrObj
    else
        furnitureAttrObj = self.FurnitureScoreDic[furnitureId]
    end

    self.FurnitureScoreContainer.gameObject:SetActiveEx(true)

    furnitureAttrObj:Show(args[0],args[1],args[2],args[3],args[4],args[5],args[6])
end

--隐藏家具属性
function XUiDormComponent:HideFurnitureAttr(evt,args)
    local furnitureAttrObj = nil
    local furnitureId = args[0]

    if not self.FurnitureScoreContainer or XTool.UObjIsNil(self.FurnitureScoreContainer) then
        return
    end


    if self.FurnitureScoreDic[furnitureId] then
        furnitureAttrObj = self.FurnitureScoreDic[furnitureId]
        self.FurnitureScoreContainer:Despawn(furnitureAttrObj.GameObject)
        furnitureAttrObj:Hide()
        self.FurnitureScoreDic[furnitureId] = nil
    end

end

--隐藏家具属性
function XUiDormComponent:HideAllFurnitureAttr(evt)

    if not self.FurnitureScoreContainer or XTool.UObjIsNil(self.FurnitureScoreContainer) then
        return
    end

    if self.FurnitureScoreDic then
        for k,v in pairs(self.FurnitureScoreDic) do
            self.FurnitureScoreContainer:Despawn(v.GameObject)
            v:Hide()
        end
    end

    XHomeDormManager.FurnitureShowAttrType = -1
    self.FurnitureScoreContainer.gameObject:SetActiveEx(false)
    self.FurnitureScoreDic = {}
end



-- 关闭
function XUiDormComponent:CloseComponent()
    self:HideAllFurnitureAttr()
    self:Close()
end