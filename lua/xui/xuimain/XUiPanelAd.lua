XUiPanelAd = XClass(XLuaBehaviour)

local NoticeRequestTimeOut = 10
local MISTAKE_DISTANCE = 5
local DefaultPicScrollInterval = 5
local PITCH_ON = CS.XGame.ClientConfig:GetString("UiMainPitchOn")
local PITCH_OFF =  CS.XGame.ClientConfig:GetString("UiMainPitchOff")
local JumpType = {
    Web = 1,
    Game = 2,
}

function XUiPanelAd:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self:InitAutoScript()
    self.ChildPosXs = {}            --广告坐标
    self.AdPrefab = {}              --广告图片
    self.PageNum = {}               --小白点表
    self.CurIndex = 1              --当前为第几图片

    self:AddPointerClickListener()
    self:UpdateAdList()
    
    XEventManager.AddEventListener(XEventId.EVENT_PLAYER_LEVEL_CHANGE, self.UpdateAdList, self)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiPanelAd:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
end

function XUiPanelAd:AutoInitUi()
    self.Panelpicture = self.Transform:Find("Map/Panelpicture")
    self.PanelSwitchover = self.Transform:Find("Map/PanelSwitchover")
    self.PanelSw = self.Transform:Find("Map/PanelSwitchover/PanelSw")
    self.CenterScroll = self.Transform:GetComponent("XUiCenterScroll")

    self:InitCenterScroll()
end

function XUiPanelAd:Update()
    if #self.AdList <= 1 then
        return
    end

    if not self.ChildPosXs or not self.AdList then
        return
    end

    if not self.ChildPosXs[self.CurIndex] or not self.AdList[self.CurIndex] then
        return
    end

    local nowPosX = self.Panelpicture.anchoredPosition.x
    local targetPosX = -self.ChildPosXs[self.CurIndex]

    if self.CurIndex == 1 and math.abs(nowPosX - targetPosX) <= MISTAKE_DISTANCE then
        self:ForceMoveToIndex(#self.AdList - 2)
    elseif self.CurIndex == #self.AdList and math.abs(nowPosX - targetPosX) <= MISTAKE_DISTANCE then
        self:ForceMoveToIndex(1)
    end
end

function XUiPanelAd:InitCenterScroll()
    self.CenterScroll:RegisterEndDragCallBack(function (index)
        local nowIndex = index + 1
        if self.CurIndex == nowIndex then
            return
        end

        local interval = DefaultPicScrollInterval
        if self.AdList and self.AdList[self.CurIndex] and self.AdList[self.CurIndex].Interval then
            interval = self.AdList[self.CurIndex].Interval
        end

        self:ClearTimer()
        self.Timer = CS.XScheduleManager.ScheduleOnce(function () 
                    self.CenterScroll:NextPage() 
                    end, interval * 1000)

        self.CurIndex = nowIndex
        self:UpdatePage()
    end)
end

function XUiPanelAd:ClearTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiPanelAd:AddPointerClickListener()
    self.UiPanelAd = self.GameObject:AddComponent(typeof(CS.XUiWidget))
    self.UiPanelAd:AddPointerClickListener(function (eventData)
        self:OnPointerClick() 
    end)
    self.UiPanelAd:AddEndDragListener(function(eventData)
        self:OnEndDrag()
    end)
    self.UiPanelAd:AddDragListener(function (eventData)
        self:OnDrag()
    end)
end

function XUiPanelAd:OnDrag()
    self.IsDraging = true
end

--停止拖动
function XUiPanelAd:OnEndDrag()
    self.IsDraging = false
end

function XUiPanelAd:ForceMoveToIndex(index)
    self.CenterScroll:SetIndex(index)
end

function XUiPanelAd:OnPointerClick()
    if self.IsDraging then
        return
    end

    if not self.AdList or not self.AdList[self.CurIndex] then
        return
    end

    local data = self.AdList[self.CurIndex]

    local jumpAddr = data.JumpAddr
    if not jumpAddr then
        return 
    end

    if tonumber(data.JumpType) == JumpType.Web then
        local url = XDataCenter.NoticeManager.UrlDecode(jumpAddr)
        if url and #url > 0 then
            CS.UnityEngine.Application.OpenURL(url)
        end    
    elseif tonumber(data.JumpType) == JumpType.Game then
        XFunctionManager.SkipInterface(tonumber(jumpAddr))
    end
end

--小球变色
function XUiPanelAd:UpdatePage()
    local index = self.CurIndex
    if index == #self.AdList then
        index = 2
    elseif self.CurIndex == 1 then
        index = #self.AdList - 1
    end
    for k, rawImage in pairs(self.PageNum) do
        rawImage:SetRawImage(PITCH_OFF)
        if k == index then
            rawImage:SetRawImage(PITCH_ON)
        end
    end
end

function XUiPanelAd:UpdateAdList()
    self.AdList = {}
    self.ChildPosXs = {}
    local dataList = XDataCenter.NoticeManager.GetMainAdList() or {}
    if #dataList > 1 then
        table.insert(self.AdList, dataList[#dataList])
        for i, v in ipairs(dataList) do
            table.insert(self.AdList, v)
        end
        table.insert(self.AdList, self.AdList[2])
    else
        self.AdList = dataList
    end

    self:UpdateAdvertising()
    self:UpdatePage()
end

function XUiPanelAd:Addadvertising(index)
    local advertising = self.Panelpicture:GetChild(0).gameObject
    advertising:SetActiveEx(false)

    local smallSp = self.PanelSw.gameObject
    smallSp:SetActiveEx(false)

    local adPrefab = CS.UnityEngine.Object.Instantiate(advertising, self.Panelpicture)
    adPrefab.gameObject:SetActiveEx(true)
    self.AdPrefab[index] = adPrefab
    
    if index > 1 and index < #self.AdList then
        local pageNum = CS.UnityEngine.Object.Instantiate(smallSp, self.PanelSwitchover)
        pageNum.gameObject:SetActiveEx(true)
        self.PageNum[index] = pageNum:GetComponent("RawImage")
    end

    self.ChildPosXs[index] = (index - 1) * self.Panelpicture:GetComponent("GridLayoutGroup").cellSize.x
    self:LoadWebTexture(index)
end

function XUiPanelAd:LoadWebTexture(index, isBackUp)
    local picAddr
    if isBackUp then
        picAddr = self.AdList[index].PicAddrSlave
    else
        picAddr = self.AdList[index].PicAddr
    end

    XDataCenter.NoticeManager.LoadPic(picAddr, function(texture)
        if XTool.UObjIsNil(self.AdPrefab[index]) then
            return
        end

        self.AdPrefab[index]:GetComponent("RawImage").texture = texture 
    end)
end

--动态获得广告个数
function XUiPanelAd:UpdateAdvertising()
    self:ClearAdvertsing()

    if #self.AdList <= 0 then
        local advertising = self.Panelpicture:GetChild(0).gameObject
        advertising:SetActiveEx(true)
        local smallSp = self.PanelSw.gameObject
        smallSp:SetActiveEx(false)
        return
    end

    for i = 1, #self.AdList do
        self:Addadvertising(i)
    end

    self.CenterScroll:UpdatePages()

    if #self.ChildPosXs > 1 then
        self:ForceMoveToIndex(1)
    end

    self.Panelpicture:SetSizeWithCurrentAnchors(CS.UnityEngine.RectTransform.Axis.Horizontal, #self.ChildPosXs * 467)
end

-- 清空广告节点
function XUiPanelAd:ClearAdvertsing()
    for k, v in pairs(self.AdPrefab) do
        CS.UnityEngine.Object.DestroyImmediate(v)
        v = nil
    end
    self.AdPrefab = {}

    for k, v in pairs(self.PageNum) do
        CS.UnityEngine.Object.Destroy(v.gameObject)
        v = nil
    end

    self.PageNum = {}
end

function XUiPanelAd:OnDestroy()
    XEventManager.RemoveEventListener(XEventId.EVENT_PLAYER_LEVEL_CHANGE, self.UpdateAdList, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_MAINUI_ENABLE, self.UpdateAdList, self)
end