local XUiMedalUnlock = XLuaUiManager.Register(XLuaUi, "UiMedalUnlock")
local CLOSE_TIME = 2
local IsInClose
function XUiMedalUnlock:OnStart()
    
    if XPlayer.NewMedalInfo then
        self.TxtMedalName.text = XMedalConfigs.GetMeadalConfigById(XPlayer.NewMedalInfo.Id).Name
        self.TxtUid.text = XPlayer.Id
        self.TxtName.text = XPlayer.Name
        self.BtnSkip.CallBack = function() 
            self:OnBtnSkip()
        end
        self:AddBtnUnlockCallBack()
        IsInClose = false
    else
        local function action()
            self:OnOpenMedalDetail(
                self:CreatePlayerMedal(XDataCenter.MedalManager.InType.GetMedal,nil,XPlayer.UnlockedMedalInfos)
            )
        end
        CS.XScheduleManager.Schedule(action, 0, 1, 0)
    end
end

function XUiMedalUnlock:OnDestroy()
    
end

function XUiMedalUnlock:AddBtnUnlockCallBack()
    self.BtnUnlock.CallBack = function() 
        self:OnBtnUnlock()
    end
end

function XUiMedalUnlock:OnBtnSkip()
    self:OnOpenMedalDetail(
        self:CreatePlayerMedal(XDataCenter.MedalManager.InType.GetMedal,XPlayer.NewMedalInfo.Id,XPlayer.UnlockedMedalInfos)
        )
end

function XUiMedalUnlock:OnBtnUnlock()
    if not IsInClose then
        self:AddCloseTimer()
        self:PlayAnimation("AnimEnableTwo")
    end
end

function XUiMedalUnlock:AddCloseTimer()
    IsInClose = true
    local time = 0
    local function action()
        time = time + 1
        if time == CLOSE_TIME then
            self:OnOpenMedalDetail(
                self:CreatePlayerMedal(XDataCenter.MedalManager.InType.GetMedal,XPlayer.NewMedalInfo.Id,XPlayer.UnlockedMedalInfos)
                )
        end
    end
    CS.XScheduleManager.Schedule(action, CS.XScheduleManager.SECOND, CLOSE_TIME, 0)
end

function XUiMedalUnlock:CreatePlayerMedal(inType,skipMedalId,detailInfos)
    local playerMedal = {}
    playerMedal.InType = inType
    playerMedal.SkipMedalId = skipMedalId
    playerMedal.DetailInfos = detailInfos
    return playerMedal
end

function XUiMedalUnlock:OnOpenMedalDetail(playerMedal)
    local selectBtnId = 4
    XLuaUiManager.Open("UiPlayer",nil,selectBtnId,nil,playerMedal)
    XLuaUiManager.Remove( "UiMedalUnlock")
end