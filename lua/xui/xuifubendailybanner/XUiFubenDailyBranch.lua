local XUiFubenDailyBranch = XLuaUiManager.Register(XLuaUi, "UiFubenDaily")
local stringGsub = string.gsub
local STAGE_COUNT_MAX = 4
local DROP_VIEW_MAX = 4
function XUiFubenDailyBranch:OnAwake()
    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    self:AutoAddListener()
end

function XUiFubenDailyBranch:OnEnable()
    self:StageRefresh()
    self:StageIconMove(0,false)
end

function XUiFubenDailyBranch:OnStart(Rule)
    self.Rule = Rule
    self.DungeonId=self.Rule.DungeonOfWeek[XDataCenter.FubenDailyManager.GetNowDayOfWeekByRefreshTime()]
    self.ChapterList = {}
    self.Stage = {}
    self.StageObjs = {}
    self.Drop = {}
    self.DropObjs = {}
end

function XUiFubenDailyBranch:StageRefresh()
    if not self.StageObjs then
        return
    end
    
    local dungeoData = XDataCenter.FubenDailyManager.GetDailyDungeonData(self.DungeonId)
    local IsStart = true
    local exValue = 0
    self.TxtTitle.text = dungeoData.Name
    self.BgCommonBai:SetRawImage(dungeoData.BgImg)
    
    for i = 1, STAGE_COUNT_MAX do
        if not self.StageObjs[i] then
            local temp
            temp = CS.UnityEngine.Object.Instantiate(self.FubenDailyStageObj)
            temp.transform:SetParent(self.PanelStageContent.transform, false)
            table.insert(self.StageObjs, temp)
        end
        self.StageObjs[i].gameObject:SetActive(false)
    end
    
    for k, v in pairs(dungeoData.StageId) do
        if v ~= 0 then
            if not self.Stage[k] then
                self.Stage[k] = XUiFubenDailyStage.New(self,self.StageObjs[k], v, exValue, dungeoData, k)
            else
                self.Stage[k]:ReSetStageCfg()
            end
            self.Stage[k]:SetCallBack(function(num,IsOpen)
                self:StageIconMove(num,IsOpen)
            end)
            self.StageObjs[k].gameObject:SetActive(true)
        else
            self.StageObjs[k].gameObject:SetActive(false)
        end
        exValue = v
    end
end

function XUiFubenDailyBranch:StageIconMove(num,IsOpen)
    if IsOpen then
        XUiHelper.DoMove(self.PaneStageList,self["TagPos"..num].transform.localPosition,0.5,XUiHelper.EaseType.Sin)
    else
        local zeroPos = {0,0,0}
        XUiHelper.DoMove(self.PaneStageList,zeroPos,0.3,XUiHelper.EaseType.Sin)
    end
end

function XUiFubenDailyBranch:AutoAddListener()
    self.BtnBack.CallBack = function(eventData)
        self:OnBtnBackClick(eventData)
    end
    self.BtnMainUi.CallBack = function(eventData)
        self:OnBtnMainUiClick(eventData)
    end
    self.BtnActDesc.CallBack = function(eventData)
        self:OnBtnActDescClick(eventData)
    end
end

function XUiFubenDailyBranch:OnBtnBackClick(eventData)
    self:Close()
end

function XUiFubenDailyBranch:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiFubenDailyBranch:OnBtnActDescClick(eventData)
    local dungeoData = XDataCenter.FubenDailyManager.GetDailyDungeonData(self.DungeonId)
    local description = stringGsub(dungeoData.Description, "\\n", "\n")
    XUiManager.UiFubenDialogTip("", description)
end

function XUiFubenDailyBranch:OnGetEvents()
    return {XEventId.EVENT_FUBEN_CLOSE_FUBENSTAGEDETAIL, XEventId.EVENT_FUBEN_ENTERFIGHT, XEventId.EVENT_FUBEN_RESOURCE_AUTOSELECT}
end

--事件监听
function XUiFubenDailyBranch:OnNotify(evt, ...)
    local args = {...}
    if evt == XEventId.EVENT_FUBEN_ENTERFIGHT then
        self:EnterFight(args[1])
    elseif evt == XEventId.EVENT_FUBEN_RESOURCE_AUTOSELECT then
        
        if not self.DungeonId then return end
        local stageId = args[1]
        local dungeoData = XDataCenter.FubenDailyManager.GetDailyDungeonData(self.DungeonId)
        if not dungeoData then return end

        for k, v in pairs(dungeoData.StageId) do
            if stageId and v == stageId and self.Stage[k] then
                self.Stage[k]:OnBtnEnter()
                break
            end
        end

    end
end

function XUiFubenDailyBranch:EnterFight(stage)
    if XDataCenter.FubenManager.OpenRoomSingle(stage, nil, nil) then
        XLuaUiManager.Remove("UiFubenStageDetail")
    end
end

function XUiFubenDailyBranch:ShowPanelAsset(IsShow)
    self.PanelAsset.gameObject:SetActiveEx(IsShow)
end