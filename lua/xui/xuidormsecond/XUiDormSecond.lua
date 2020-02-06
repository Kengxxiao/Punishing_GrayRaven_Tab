local Object = CS.UnityEngine.Object
local Vector3 = CS.UnityEngine.Vector3
local V3O = Vector3.one

local XUiDormSecond = XLuaUiManager.Register(XLuaUi, "UiDormSecond")
local XUiDormNameGridItem = require("XUi/XUiDormSecond/XUiDormNameGridItem")
local XUiDormReName = require("XUi/XUiDormSecond/XUiDormReName")
local XUiDormCaress = require("XUi/XUiDormSecond/XUiDormCaress")
local XUiPanelEventShow = require("XUi/XUiDormSecond/XUiPanelEventShow")
local XUiDormBgm = require("XUi/XUiDormSecond/XUiDormBgm")


local TextManager = CS.XTextManager
local DormManager
local SocialManager
local SelfPreDormId = -1 --在访问其他人时，记录当前自己的宿舍Id。在访问返回时使用
local CurrentSchedule = nil
local V3OP
local DisplaySetType
local DormSecondEnter
local AttrType
local White = "#ffffff"
local Blue = "#34AFF8"

function XUiDormSecond:OnAwake()
    DormManager = XDataCenter.DormManager
    SocialManager = XDataCenter.SocialManager
    DisplaySetType = XDormConfig.VisitDisplaySetType
    DormSecondEnter = XDormConfig.DormSecondEnter
    AttrType = XFurnitureConfigs.AttrType
    V3OP = Vector3(-1, 1, 1)
    self.EnterBtns = {}
    XTool.InitUiObject(self)
    self:InitFun()
    self:InitUI()
    self:InitEnterCfg()
    XEventManager.AddEventListener(XEventId.EVENT_DORM_TOUCH_ENTER, self.OnOpenedCaress, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_SHOW_EVENT_CHANGE, self.OnOpenEventShow, self)
    self.PanelCaress.gameObject:SetActiveEx(false)
    self.LastMusicId = CS.XAudioManager.CurrentMusicId
    self.BgmShowState = false


    self.DormBgm = XUiDormBgm.New(self, self.MusicPlayer)
end

function XUiDormSecond:InitFun()
    self.OnBtnTaskTipsClickCb = function() self:OnBtnTaskTipsClick() end
    self.BtnClickTips.CallBack = function() self:ComfortTips() end
    self.BtnExpand.CallBack = function() self:OnBtnExpand() end
    self.BtnRename.CallBack = function() self:OpenRenameUI() end
    self.BtnHelp.CallBack = function() self:OnBtnHelpClick() end
end

function XUiDormSecond:OnBtnHelpClick()
    XUiManager.ShowHelpTip("Dorm")
end

function XUiDormSecond:OnDestroy()
    if self.EventShow then
        self.EventShow:OnEventShowDestroy()
    end
    if XLuaUiManager.IsUiLoad("UiDormMain") then
        XHomeSceneManager.ChangeBackToOverView()
    end
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_TOUCH_ENTER, self.OnOpenedCaress, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_SHOW_EVENT_CHANGE, self.OnOpenEventShow, self)

    if self.LastMusicId and self.LastMusicId > 0 then
        CS.XAudioManager.PlayMusic(self.LastMusicId)
    end
end

function XUiDormSecond:InitUI()
    self.CurScoreState = false
    self.CurInfoState = true
    self.TxtPerson.text = TextManager.GetText("DormPersonTxt")
    self.TxtRemould.text = TextManager.GetText("DormRemouldTxt")
    self.TxtMenu.text = TextManager.GetText("DormMenTxt")
    self.TxtScoreDes.text = TextManager.GetText("DormTotalScore")
    self.TxtTool.text = TextManager.GetText("DormComfortLevelTips")
    self.BtnRemould:SetName(TextManager.GetText("DormRemouldTxt"))
    self.BtnVisitor:ShowReddot(false)
    local a, b, c = DormManager.GetDormitoryScoreNames()
    self.TxtBeautiful.text = a
    self.TxtComfort.text = b
    self.TxtPractical.text = c
    self:AddListener()
    self:InitList()

    local indexA = AttrType.AttrA
    local indexB = AttrType.AttrB
    local indexC = AttrType.AttrC
    local iconA = XFurnitureConfigs.GetDormFurnitureTypeIcon(indexA)
    local iconB = XFurnitureConfigs.GetDormFurnitureTypeIcon(indexB)
    local iconC = XFurnitureConfigs.GetDormFurnitureTypeIcon(indexC)
    self:SetUiSprite(self.ImgTool1, iconA)
    self:SetUiSprite(self.ImgTool2, iconB)
    self:SetUiSprite(self.ImgTool3, iconC)
end

function XUiDormSecond:InitList()
    self.DynamicTable = XDynamicTableNormal.New(self.ViewNameList.gameObject)
    self.DynamicTable:SetProxy(XUiDormNameGridItem)
    self.DynamicTable:SetDelegate(self)
end

function XUiDormSecond:InitEnterCfg()
    self.EnterCfg = {}
    self.EnterCfg[DormSecondEnter.Des] = {["Name"] = TextManager.GetText("DormDes"),
    ["Skip"] = function() self:OpenDesUI() end,
    ["IconPath"] = CS.XGame.ClientConfig:GetString("FurnitureImgS20")
    }
    self.EnterCfg[DormSecondEnter.WareHouse] = {["Name"] = TextManager.GetText("DormWareHouse"),
    ["Skip"] = function() self:OpenWarehouse() end,
    ["IconPath"] = CS.XGame.ClientConfig:GetString("FurnitureImgS5")
    }
    self.EnterCfg[DormSecondEnter.Person] = {["Name"] = TextManager.GetText("DormPersonText"),
    ["Skip"] = function() self:OnBtnPersonClick() end,
    ["IconPath"] = CS.XGame.ClientConfig:GetString("FurnitureImgS11")
    }
    self.EnterCfg[DormSecondEnter.FieldGuilde] = {["Name"] = TextManager.GetText("DormFieldGuilde"),
    ["Skip"] = function() self:OpenFieldGuid() end,
    ["IconPath"] = CS.XGame.ClientConfig:GetString("FurnitureImgS22")
    }
    self.EnterCfg[DormSecondEnter.Buid] = {["Name"] = TextManager.GetText("DormBuild"),
    ["Skip"] = function() self:OpenBuildUI() end,
    ["IconPath"] = CS.XGame.ClientConfig:GetString("FurnitureImgS6")
    }
    self.EnterCfg[DormSecondEnter.Shop] = {["Name"] = TextManager.GetText("DormShopText"),
    ["Skip"] = function() self:OpenShopUI() end,
    ["IconPath"] = CS.XGame.ClientConfig:GetString("FurnitureImgS8")
    }
end

-- 跳到商店
function XUiDormSecond:OpenShopUI()
    XLuaUiManager.Open("UiShop", XShopManager.ShopType.Dorm)
    self.IsStatic = true
end

-- [监听动态列表事件]
function XUiDormSecond:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Init(self)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        local data = self.HostelNameDataList[index]
        grid:OnRefresh(data)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        self.CurIndex = index
        local d = self.HostelNameDataList[index]
        if self.CurDormId == d[2] then
            self.CurHostelNamesState = false
            self:SetDormListNameV(false)
            return
        end

        self.CurDormId = d[2]
        self:SetHostelNameClick()
        self:OnBtnHostelNamesClick()
        self:UpdateData(self.CurDisplayState, self.CurDormId)
        XHomeDormManager.SetSelectedRoom(self.CurDormId, true)
    end
end

-- 可以访问宿舍lsit
function XUiDormSecond:SetCurHostelList()
    local len = 0
    local data = {}
    local dormdatas = {}

    if DisplaySetType.MySelf == self.CurDisplayState then
        dormdatas = DormManager.GetDormitoryData() or {}
    else
        dormdatas = DormManager.GetDormitoryData(XDormConfig.DormDataType.Target) or {}
    end

    for _, v in pairs(dormdatas) do
        if v:WhetherRoomUnlock() then
            len = len + 1
            table.insert(data, { v:GetRoomName(), v:GetRoomId() })
        end
    end

    table.sort(data, function(a, b)
        local cfg1 = XDormConfig.GetDormitoryCfgById(a[2])
        local cfg2 = XDormConfig.GetDormitoryCfgById(b[2])
        return cfg1.InitNumber < cfg2.InitNumber
    end)
    self.HostelNameDataList = data
    self.DynamicTable:Clear()
    self.DynamicTable:SetDataSource(data)
    self.DynamicTable:ReloadDataASync(1)
    self.ImgDownUp.gameObject:SetActiveEx(len > 1)
    self.ImgArrowDown.gameObject:SetActiveEx(len > 1)
    self.ImgArrowUp.gameObject:SetActiveEx(len < 1)
end

-- 设置当前宿舍名(ClickOrInit)
function XUiDormSecond:SetHostelNameClick()
    local dormdatas = {}
    if DisplaySetType.MySelf == self.CurDisplayState then
        dormdatas = DormManager.GetDormitoryData() or {}
    else
        dormdatas = DormManager.GetDormitoryData(XDormConfig.DormDataType.Target) or {}
    end

    local d = dormdatas[self.CurDormId]
    if not d then
        return
    end
    local name = d:GetRoomName() or ""
    self.TxtTitle.text = name
end

-- 设置当前宿舍名(改名成功)
function XUiDormSecond:SetHostelName(name)
    self.TxtTitle.text = name or ""
    self:SetCurHostelList()
end

-- 设置宿舍list显示与隐藏
function XUiDormSecond:SetDormListNameV(state)
    self.ListContent.gameObject:SetActiveEx(state)
    self.ImgArrowUp.gameObject:SetActiveEx(state)
    self.ImgArrowDown.gameObject:SetActiveEx(not state)
end

function XUiDormSecond:SetSelectList(dormid)
end

function XUiDormSecond:SetSelectState(state)
    if not self.PanelSelect then
        return
    end

    self.PanelSelect.gameObject:SetActiveEx(state)
end

-- 人员
function XUiDormSecond:OnBtnPersonClick()
    XLuaUiManager.Open("UiDormPerson", self.CurDormId)
end

function XUiDormSecond:CreateDormMainItems()
end

-- 任务
function XUiDormSecond:OpenTaskUI()
    self.CurMenState = false
    self:SetEnterState(self.CurMenState)
    XLuaUiManager.Open("UiDormTask")
end

-- 建造
function XUiDormSecond:OpenBuildUI()
    self.CurMenState = false
    self:SetEnterState(self.CurMenState)
    XLuaUiManager.Open("UiFurnitureBuild")
end

-- 说明
function XUiDormSecond:OpenDesUI()
    self.CurMenState = false
    self:SetEnterState(self.CurMenState)
    XUiManager.UiFubenDialogTip("", CS.XTextManager.GetText("DormDesSecond") or "")
end

-- 仓库
function XUiDormSecond:OpenWarehouse()
    self.CurMenState = false
    self:SetEnterState(self.CurMenState)
    XLuaUiManager.Open("UiDormBag")
end

-- 改名
function XUiDormSecond:OpenRenameUI()
    self.CurMenState = false
    self:SetEnterState(self.CurMenState)
    if not self.RenameInit then
        self.RenameInit = true
        self.PanelRenameUI = XUiDormReName.New(self.PanelRename, self)
    end
    self.PanelRename.gameObject:SetActiveEx(true)
    self:PlayAnimation("PanelRenameEnable")
    self.PanelRenameUI:OnRefresh(self.CurDormId)
end

function XUiDormSecond:InitEventShow()
    if not self.EventShow then
        self.EventShow = XUiPanelEventShow.New(self, self.PanelEventShow)
    end
end

-- 访问
function XUiDormSecond:OnBtnVistorClick()
    self.CurMenState = false
    self:SetEnterState(self.CurMenState)
    self.GameObject:SetActiveEx(false)
    XLuaUiManager.Open("UiDormVisit", self)
end

-- 图鉴
function XUiDormSecond:OpenFieldGuid()
    self.CurMenState = false
    self:SetEnterState(self.CurMenState)
    XLuaUiManager.Open("UiDormFieldGuide")
end

-- 设置评分
function XUiDormSecond:SetScore()
    local scoreA, scoreB, scoreC = 0, 0, 0
    if DisplaySetType.MySelf == self.CurDisplayState then
        scoreA, scoreB, scoreC = DormManager.GetDormitoryScore(self.CurDormId)
    else
        scoreA, scoreB, scoreC = DormManager.GetDormitoryScore(self.CurDormId, XDormConfig.DormDataType.Target)
    end

    local indexA = AttrType.AttrA
    local indexB = AttrType.AttrB
    local indexC = AttrType.AttrC
    local a = XFurnitureConfigs.GetFurnitureAttrLevelNewDescription(1, indexA, scoreA)
    local b = XFurnitureConfigs.GetFurnitureAttrLevelNewDescription(1, indexB, scoreB)
    local c = XFurnitureConfigs.GetFurnitureAttrLevelNewDescription(1, indexC, scoreC)
    local totalScore = 0
    if DisplaySetType.MySelf == self.CurDisplayState then
        local newFurnitureAttrs = XHomeDormManager.GetFurnitureScoresByRoomId(self.CurDormId)
        totalScore = newFurnitureAttrs.TotalScore
    else
        local newFurnitureAttrs = DormManager.GetDormitoryTargetScore(self.CurDormId)
        if newFurnitureAttrs then
            totalScore = newFurnitureAttrs.TotalScore
        end
    end
    self.TxtScore.text = XFurnitureConfigs.GetFurnitureTotalAttrLevelNewColorDescription(1, totalScore)
    self.TxtBeautifulNum.text = a
    self.TxtComfortNum.text = b
    self.TxtPracticalNum.text = c
end

function XUiDormSecond:SetVisitState()
    if DisplaySetType.MySelf == self.CurDisplayState then
        self.PanelHomeSelf.gameObject:SetActiveEx(true)
        self.PanelHomeOthers.gameObject:SetActiveEx(false)
        self.BtnMenu.gameObject:SetActiveEx(true)
        self.BtnVisitor.gameObject:SetActiveEx(true)
        self.BtnAdd.gameObject:SetActiveEx(false)
        self.BtnRemould.gameObject:SetActiveEx(true)
        self.DormRename.gameObject:SetActiveEx(true)
        return
    end

    self.PanelHomeSelf.gameObject:SetActiveEx(false)
    self.PanelHomeOthers.gameObject:SetActiveEx(true)
    self.BtnRemould.gameObject:SetActiveEx(false)
    self.BtnVisitor.gameObject:SetActiveEx(false)
    self.BtnMenu.gameObject:SetActiveEx(false)
    self.DormRename.gameObject:SetActiveEx(false)
    if DisplaySetType.MyFriend == self.CurDisplayState then
        self.BtnAdd.gameObject:SetActiveEx(false)
    else
        self.BtnAdd.gameObject:SetActiveEx(true)
    end
end

function XUiDormSecond:OnStart(displaytype, dormId, playerId)
    self:UpdateData(displaytype, dormId)
    self:InitEventShow()
    self.IsStatic = false
    self.CurPlayerId = playerId
    self.PanelBtn.gameObject:SetActiveEx(false)
end

function XUiDormSecond:GetCurIndex(dormId)
    local index = 1
    if self.HostelNameDataList then
        for index, v in pairs(self.HostelNameDataList) do
            if v[2] == dormId then
                return index
            end
        end
    end
    return index
end

function XUiDormSecond:UpdateData(displaytype, dormId, playerId)
    self.CurDisplayState = displaytype
    self.CurDormId = dormId
    self.CurPlayerId = playerId
    self:SetScore()
    self:SetVisitState()
    self:SetHostelNameClick()
    self:SetCurHostelList()
    self.CurIndex = self:GetCurIndex(dormId)

    if DisplaySetType.MySelf ~= self.CurDisplayState then
        self.BgmShowState = false
        self.MusicPlayer.gameObject:SetActiveEx(self.BgmShowState)
    end



    self.DormBgm:UpdateBgmList(dormId,self.CurDisplayState == DisplaySetType.MySelf)
end

function XUiDormSecond:SkipDormUpdateData(dormId)
    self:UpdateData(DisplaySetType.MySelf, dormId)
end

function XUiDormSecond:OnRecordSelfDormId()
    SelfPreDormId = self.CurDormId
end

function XUiDormSecond:OnEnable()
    self.BtnPanelTask.CallBack = self.OnBtnTaskTipsClickCb
    self:SetScore()
    XDataCenter.DormManager.GetNextShowEvent()
    self:OnPlayAnimation()
    DormManager.StartDormRedTimer()
    XRedPointManager.AddRedPointEvent(self.BtnTask.ReddotObj, self.RefreshTaskTabRedDot, self, { XRedPointConditions.Types.CONDITION_DORM_MAIN_TASK_RED })
    XRedPointManager.AddRedPointEvent(self.BtnMenu.ReddotObj, self.OnCheckBuildFurniture, self, { XRedPointConditions.Types.CONDITION_FURNITURE_CREATE })
    self:RefreshTaskInfo()
    self.SkipFun = self.SkipDormUpdateData
    XEventManager.AddEventListener(XEventId.EVENT_DORM_SKIP, self.SkipFun, self)
    XEventManager.AddEventListener(XEventId.EVENT_CARESS_SHOW, self.OnCaressShow, self)
    XEventManager.AddEventListener(XEventId.EVENT_DORM_TOUCH_HIDE, self.OnCaressHide, self)
    self.DormBgm:ResetBgmList(self.CurDormId, DisplaySetType.MySelf == self.CurDisplayState )
    self:PlayAnimation("MusicPlayerQieHuan")

end

function XUiDormSecond:OnCaressHide()
    if self.CurInfoState then
        self:BtnHideCb()
    else
        self:BtnScreenShotCb()
    end
end

function XUiDormSecond:RefreshTaskTabRedDot(count)
    self.BtnTask:ShowReddot(count >= 0)
    self:RefreshTaskInfo()
end

function XUiDormSecond:RefreshTaskInfo()
    local data, tasktype, state = XDataCenter.TaskManager.GetDormTaskTips()
    if data and tasktype and state then
        self.CurTaskData = data
        self.TaskType = tasktype
        local config = XDataCenter.TaskManager.GetTaskTemplate(data.Id)
        self.CurTaskTagState = state == XDataCenter.TaskManager.TaskState.Achieved
        if self.CurTaskTagState then
            self.BtnPanelTask:SetName(string.format("<color=%s>%s</color>", Blue, config.Desc))
        else
            self.BtnPanelTask:SetName(string.format("<color=%s>%s</color>", White, config.Desc))
        end
        self.BtnPanelTask:ShowTag(not self.CurTaskTagState)
        self.BtnPanelTask:ShowReddot(self.CurTaskTagState)
    else
        self.CurTaskData = nil
        self.PanelTask.gameObject:SetActiveEx(false)
    end
end

function XUiDormSecond:PlayBgmMusic(show, bgmConfig)
    self.BgmShowState = show

    if DisplaySetType.MySelf ~= self.CurDisplayState then
        self.BgmShowState = false
    else
        CS.UnityEngine.PlayerPrefs.SetInt(tostring(self.CurDormId),bgmConfig.BgmId)
    end

    self:PlayAnimation("MusicPlayerQieHuan")
    self.MusicPlayer.gameObject:SetActiveEx(self.BgmShowState)
    CS.XAudioManager.PlayMusic(bgmConfig.BgmId)

    XHomeDormManager.DormBgm[self.CurDormId] = bgmConfig
end


function XUiDormSecond:OnCheckBuildFurniture(count)
    local red = count >= 0
    self.BtnMenu:ShowReddot(red)
    if self.EnterBtns[DormSecondEnter.Buid] then
        self.EnterBtns[DormSecondEnter.Buid]:ShowReddot(red)
    end
end

function XUiDormSecond:OnDisable()
    self.BtnPanelTask.CallBack = nil
    DormManager.StopDormRedTimer()
    self.CurHostelNamesState = false
    self:SetDormListNameV(self.CurHostelNamesState)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_SKIP, self.SkipFun, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_CARESS_SHOW, self.OnCaressShow, self)
    XEventManager.RemoveEventListener(XEventId.EVENT_DORM_TOUCH_HIDE, self.OnCaressHide, self)
    self.DormBgm:OnDisable()

end

function XUiDormSecond:OnCaressShow()
    self.BtnScreenShot.gameObject:SetActiveEx(true)
    self.BtnHide.gameObject:SetActiveEx(false)
end

function XUiDormSecond:OnGetEvents()
end

function XUiDormSecond:OnNotify(evt, ...)
end

-- 爱抚(打开)
function XUiDormSecond:OnOpenedCaress(characterId)
    self.PanelHostelName.gameObject:SetActiveEx(false)
    self.PanelCaress.gameObject:SetActiveEx(true)
    self.BtnRemould.gameObject:SetActiveEx(false)
    self.BtnVisitor.gameObject:SetActiveEx(false)
    self.PanelMenu.gameObject:SetActiveEx(false)
    self.BtnTask.gameObject:SetActiveEx(false)
    self.BtnRename.gameObject:SetActiveEx(false)
    self.BtnBack.gameObject:SetActiveEx(false)
    self.DormBgm.GameObject:SetActiveEx(false)
    self.BtnHelp.gameObject:SetActiveEx(false)
    self.TopInfos.gameObject:SetActiveEx(false)

    if not self.InitCaress then
        self.InitCaress = true
        self.PanelCaressUI = XUiDormCaress.New(self, self.PanelCaress)
    end
    self:PlayAnimation("PanelCaressEnable")
    self.PanelCaressUI:Show(characterId, self.CurDormId)
end

-- 爱抚(关闭)
function XUiDormSecond:OnCloseedCaress()
    self:PlayAnimation("PanelCaressDisable", function()
        self.PanelCaressDisable.extrapolationMode = 2
    end)
    self.PanelHostelName.gameObject:SetActiveEx(true)
    self.PanelCaress.gameObject:SetActiveEx(false)
    self.BtnRemould.gameObject:SetActiveEx(true)
    self.BtnVisitor.gameObject:SetActiveEx(true)
    self.PanelMenu.gameObject:SetActiveEx(true)
    self.BtnTask.gameObject:SetActiveEx(true)
    self.BtnRename.gameObject:SetActiveEx(true)
    self.BtnBack.gameObject:SetActiveEx(true)
    self.DormBgm.GameObject:SetActiveEx(true)
    self.BtnHelp.gameObject:SetActiveEx(true)
    self.TopInfos.gameObject:SetActiveEx(true)
    self.PanelCaressUI:OnClose(self.CurDormId)
end

function XUiDormSecond:OnOpenEventShow(data)
    self.EventShow:Show(data)
end

function XUiDormSecond:OnBtnTaskTipsClick()
    if self.CurTaskData and not self.CurTaskTagState then
        self:OnTaskSkip()
        return
    end

    local tab
    if self.CurTaskTagState then
        if self.TaskType == XDataCenter.TaskManager.TaskType.DormNormal then
            tab = XTaskConfig.PANELINDEX.Story
        else
            tab = XTaskConfig.PANELINDEX.Daily
        end
    end
    self:OnOpenTask(tab)
end

function XUiDormSecond:OnOpenTask(tab)
    XLuaUiManager.Open("UiDormTask", tab)
    self.IsStatic = true
end

function XUiDormSecond:OnBtnTaskClick()
    self:OnOpenTask()
end

function XUiDormSecond:OnTaskSkip()
    if XDataCenter.RoomManager.RoomData ~= nil then
        local title = CS.XTextManager.GetText("TipTitle")
        local cancelMatchMsg = CS.XTextManager.GetText("OnlineInstanceQuitRoom")
        XUiManager.DialogTip(title, cancelMatchMsg, XUiManager.DialogType.Normal, nil, function()
            XLuaUiManager.RunMain()
            local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.CurTaskData.Id).SkipId
            XFunctionManager.SkipInterface(skipId)
        end)
    else
        local skipId = XDataCenter.TaskManager.GetTaskTemplate(self.CurTaskData.Id).SkipId
        XFunctionManager.SkipInterface(skipId)
    end
end

function XUiDormSecond:AddListener()
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUIClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnReturnClick)
    self:RegisterClickEvent(self.BtnMenu, self.OnBtnMenuClick)
    self:RegisterClickEvent(self.BtnVisitor, self.OnBtnVistorClick)
    self:RegisterClickEvent(self.BtnClick, self.OnBtnHostelNamesClick)
    self:RegisterClickEvent(self.BtnSkipClick, self.OnBtnMenuHide)
    self:RegisterClickEvent(self.BtnRemould, self.OnBtnRemouldClick)
    self:RegisterClickEvent(self.BtnAdd, self.OnBtnAddClick)
    self:RegisterClickEvent(self.BtnRight, self.OnBtnRightClick)
    self:RegisterClickEvent(self.BtnLeft, self.OnBtnLeftClick)
    self:RegisterClickEvent(self.BtnTask, self.OnBtnTaskClick)
    self.BtnScreenShot.CallBack = function() self:BtnScreenShotCb() end
    self.BtnHide.CallBack = function() self:BtnHideCb() end
    self.BtnExpandNormalTran = self.BtnExpand.NormalObj.transform
end

function XUiDormSecond:BtnHideCb()
    self.BtnHide.gameObject:SetActiveEx(false)
    self.BtnScreenShot.gameObject:SetActiveEx(true)
    self.MusicPlayer.gameObject:SetActiveEx(self.BgmShowState)
    if self.PanelCaress.gameObject.activeSelf then
        self.PanelCaressUI.BtnBack.gameObject:SetActiveEx(true)
        self:PlayAnimation("CaressBtnEnable", function()
            if DisplaySetType.MySelf == self.CurDisplayState then
                self.PanelHomeSelf.gameObject:SetActiveEx(true)
                self.PanelHomeOthers.gameObject:SetActiveEx(false)
            else
                self.PanelHomeSelf.gameObject:SetActiveEx(false)
                self.PanelHomeOthers.gameObject:SetActiveEx(true)
            end
            XEventManager.DispatchEvent(XEventId.EVENT_DORM_EXP_SHOW)
        end)
    else
        self:PlayAnimation("BtnEnable", function()
            if DisplaySetType.MySelf == self.CurDisplayState then
                self.PanelHomeSelf.gameObject:SetActiveEx(true)
                self.PanelHomeOthers.gameObject:SetActiveEx(false)
                self.BtnRename.gameObject:SetActiveEx(true)
            else
                self.PanelHomeSelf.gameObject:SetActiveEx(false)
                self.PanelHomeOthers.gameObject:SetActiveEx(true)
                self.BtnRename.gameObject:SetActiveEx(false)
            end
            self.CurInfoState = true
            self.BtnHelp.gameObject:SetActiveEx(true)
            self.BtnBack.gameObject:SetActiveEx(true)
            self.TopInfos.gameObject:SetActiveEx(true)
            self.PanelHostelName.gameObject:SetActiveEx(true)
            XEventManager.DispatchEvent(XEventId.EVENT_DORM_SECOND_STATE, true)
        end)
    end
end

function XUiDormSecond:BtnScreenShotCb()
    self.BtnHide.gameObject:SetActiveEx(true)
    self.BtnScreenShot.gameObject:SetActiveEx(false)
    if self.PanelCaress.gameObject.activeSelf then
        self.PanelCaressUI.BtnBack.gameObject:SetActiveEx(false)
        self:PlayAnimation("CaressBtnDisable", function()
            self.PanelHomeSelf.gameObject:SetActiveEx(false)
            self.PanelHomeOthers.gameObject:SetActiveEx(false)
            self.BtnBack.gameObject:SetActiveEx(false)
            self.BtnHelp.gameObject:SetActiveEx(false)
            self.BtnRename.gameObject:SetActiveEx(false)
            self.PanelHostelName.gameObject:SetActiveEx(false)
            self.TopInfos.gameObject:SetActiveEx(false)
            self.MusicPlayer.gameObject:SetActiveEx(false)
            XEventManager.DispatchEvent(XEventId.EVENT_DORM_EXP_HIDE)
        end)
    else
        self:PlayAnimation("BtnDisable", function()
            self.PanelHomeSelf.gameObject:SetActiveEx(false)
            self.PanelHomeOthers.gameObject:SetActiveEx(false)
            self.BtnBack.gameObject:SetActiveEx(false)
            self.BtnHelp.gameObject:SetActiveEx(false)
            self.BtnRename.gameObject:SetActiveEx(false)
            self.PanelHostelName.gameObject:SetActiveEx(false)
            self.TopInfos.gameObject:SetActiveEx(false)
            self.MusicPlayer.gameObject:SetActiveEx(false)
            self.CurInfoState = false
        end)
        XEventManager.DispatchEvent(XEventId.EVENT_DORM_SECOND_STATE, false)
    end
end

function XUiDormSecond:OnBtnExpand()
    self.CurScoreState = not self.CurScoreState
    self.PanelScore.gameObject:SetActiveEx(self.CurScoreState)
    self.PanelTool1.gameObject:SetActiveEx(not self.CurScoreState)
    self.PanelTool2.gameObject:SetActiveEx(not self.CurScoreState)
    self.PanelTool3.gameObject:SetActiveEx(not self.CurScoreState)
    if self.CurScoreState then
        self.BtnExpandNormalTran.localScale = V3OP
        self.BtnClickTips.gameObject:SetActiveEx(false)
    else
        self.BtnExpandNormalTran.localScale = V3O
        self.BtnClickTips.gameObject:SetActiveEx(true)
    end
end

function XUiDormSecond:ComfortTips()
    if not CurrentSchedule then
        self.TopTips.gameObject:SetActiveEx(true)
        CurrentSchedule = CS.XScheduleManager.Schedule(function() self:ComfortTipsTimerCb() end, XDormConfig.DormComfortTime, 0)
    end
end

function XUiDormSecond:ComfortTipsTimerCb()
    self.TopTips.gameObject:SetActiveEx(false)
    CS.XScheduleManager.UnSchedule(CurrentSchedule)
    CurrentSchedule = nil
end

function XUiDormSecond:OnBtnMenuHide()
    if self.HostSecondSkipGo and self.CurMenState == true then
        self.CurMenState = false
        self:SetEnterState(self.CurMenState)
    end
end

function XUiDormSecond:OnBtnRightClick()
    if self.HostelNameDataList and #self.HostelNameDataList <= 1 then
        XUiManager.TipText("DormNoRoomsTips")
        return
    end

    local d = self.HostelNameDataList[self.CurIndex + 1]
    if not d then
        --到末了，从头开始
        self.CurIndex = 1
        d = self.HostelNameDataList[self.CurIndex]
        self:UpdateData(self.CurDisplayState, d[2])
        XHomeDormManager.SetSelectedRoom(self.CurDormId, true)
        return
    end

    if self.CurDormId == d[2] then
        return
    end

    self.CurIndex = self.CurIndex + 1
    self:UpdateData(self.CurDisplayState, d[2])
    XHomeDormManager.SetSelectedRoom(self.CurDormId, true)
end

function XUiDormSecond:OnBtnLeftClick()
    if self.HostelNameDataList and #self.HostelNameDataList <= 1 then
        XUiManager.TipText("DormNoRoomsTips")
        return
    end

    local d = self.HostelNameDataList[self.CurIndex - 1]
    if not d then
        --到末了，从头开始
        self.CurIndex = #self.HostelNameDataList
        d = self.HostelNameDataList[self.CurIndex]
        self:UpdateData(self.CurDisplayState, d[2])
        XHomeDormManager.CharacterExit(self.CurDormId)
        XHomeDormManager.SetSelectedRoom(self.CurDormId, true)
        return
    end

    if self.CurDormId == d[2] then
        return
    end

    self.CurIndex = self.CurIndex - 1
    self:UpdateData(self.CurDisplayState, d[2])
    XHomeDormManager.CharacterExit(self.CurDormId)
    XHomeDormManager.SetSelectedRoom(self.CurDormId, true)
end

function XUiDormSecond:OnBtnNextClick()
    if self.CurNextState then
        local nextdormid, flage = DormManager.GetDormitoryRecommendDataForNext(self.CurDormId)
        self.CurNextState = not flage
        self:UpdateData(DisplaySetType.Stranger, nextdormid)
        return
    end

    local predormid, flage = DormManager.GetDormitoryRecommendDataForPre(self.CurDormId)
    self.CurNextState = flage
    self:UpdateData(DisplaySetType.Stranger, predormid)
end

function XUiDormSecond:OnBtnAddClick()
    local data = DormManager.GetDormitoryData(XDormConfig.DormDataType.Target)

    if not data then
        return
    end

    local dormdata = data[self.CurDormId]
    local title = CS.XTextManager.GetText("TipTitle")
    local des = CS.XTextManager.GetText("DormVisitorFirend", dormdata.PlayerName)
    XUiManager.DialogTip(title, des, XUiManager.DialogType.Normal, nil, function()
        SocialManager.ApplyFriend(dormdata.PlayerId)
    end)
end

function XUiDormSecond:OnBtnHostelNamesClick()
    if self.HostelNameDataList and #self.HostelNameDataList <= 1 then
        return
    end

    self.CurHostelNamesState = not self.CurHostelNamesState
    self:SetDormListNameV(self.CurHostelNamesState)
end

function XUiDormSecond:OnBtnRemouldClick()
    XLuaUiManager.Open("UiFurnitureReform", self.CurDormId)
end

function XUiDormSecond:OnBtnMainUIClick()
    XEventManager.DispatchEvent(XEventId.EVENT_DORM_CLOSE_COMPONET)

    XLuaUiManager.RunMain()
    XHomeSceneManager.LeaveScene()
end

function XUiDormSecond:OnBtnReturnClick()
    if not XLuaUiManager.IsUiLoad("UiDormMain") then
        XHomeSceneManager.LeaveScene()
        XEventManager.DispatchEvent(XEventId.EVENT_DORM_CLOSE_COMPONET)
        self:Close()
        return
    end

    if self.CurDisplayState == DisplaySetType.MySelf then
        XHomeDormManager.SetSelectedRoom(self.CurDormId, false)
        self:Close()
    else
        --从其他人宿舍返回自己宿舍，把自己的数据切回来。
        if SelfPreDormId == -1 then
            local data = DormManager.GetDormitoryData(XDormConfig.DormDataType.Self)
            if data then
                for _, v in pairs(data) do
                    if v and v.Id then
                        SelfPreDormId = v.Id
                        break
                    end
                end
            end
        end
        DormManager.VisitDormitory(DisplaySetType.MySelf, SelfPreDormId)
        self:UpdateData(DisplaySetType.MySelf, SelfPreDormId)
        self.CurHostelNamesState = false
        self:SetDormListNameV(self.CurHostelNamesState)
    end

    XEventManager.DispatchEvent(XEventId.EVENT_DORM_HIDE_COMPONET)
end

function XUiDormSecond:OnBtnMenuClick()
    if self.HostSecondSkipGo then
        self.CurMenState = not self.CurMenState
        self:SetEnterState(self.CurMenState)
    end
end

function XUiDormSecond:SetEnterState(state)
    if self.HostSecondSkipGo then
        self.HostSecondSkipGo.gameObject:SetActiveEx(state)
        if state then
            self:PlayAnimation("CaiDanEnable")
        else
            self:PlayAnimation("CaiDanDisable")
        end
        if not state or self.InitEnter then
            return
        end
        self.InitEnter = true
        for k, v in pairs(self.EnterCfg) do
            local obj = Object.Instantiate(self.HostSecondSkipItem.gameObject)
            obj.transform:SetParent(self.HostSecondSkipList, false)
            obj.transform.localScale = V3O
            obj.gameObject:SetActiveEx(true)
            obj.gameObject.name = self.EnterCfg[k].Name
            local btn = obj:GetComponent("XUiButton")
            btn:SetName(self.EnterCfg[k].Name)
            btn:SetSprite(self.EnterCfg[k].IconPath)
            self:RegisterClickEvent(obj, self.EnterCfg[k].Skip)
            self.EnterBtns[k] = btn
        end
    end
end

function XUiDormSecond:OnPlayAnimation()
    local delay = 0
    if not self.IsStatic then
        self.IsStatic = true
        delay = XDormConfig.DormSecondAnimationDelayTime
    end

    if delay > 0 then
        self.DormWorkTimer = CS.XScheduleManager.ScheduleOnce(function()
            self.PanelBtn.gameObject:SetActiveEx(true)
            self:PlayAnimation("AnimStartEnable")
            CS.XScheduleManager.UnSchedule(self.DormWorkTimer)
        end, delay)
    else
        self:PlayAnimation("AnimStartEnable")
    end
end