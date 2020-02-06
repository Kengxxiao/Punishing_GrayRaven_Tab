local XUiDormWorkGridItem = XClass()
local DormManager
local TextManager = CS.XTextManager
local WorkPosState

function XUiDormWorkGridItem:Ctor(ui,uiroot)
    DormManager = XDataCenter.DormManager
    WorkPosState = XDormConfig.WorkPosState
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.UiRoot = uiroot
    XTool.InitUiObject(self)
    self:InitFun()   
    self:InitText()
end

function XUiDormWorkGridItem:InitText()
    self.TextDormWorked = TextManager.GetText("DormWorked")
    self.TextDormWorking = TextManager.GetText("DormWorking")
    self.TextDormReward = TextManager.GetText("DormRewardText")
    self.TextDormNoRewardGet = TextManager.GetText("DormWorkNoRewardTips")
    self.TextDormNoMood = TextManager.GetText("DormWorkNoMoodTips")
end

function XUiDormWorkGridItem:InitFun()
    self.Btnclickcb = function() self:OnBtnClick() end
    self.TimerFunCb = function() self:UpdataTimer() end
    self.GetRewardCb = function() self.UiRoot:SetListData() end
    self.UiRoot:RegisterClickEvent(self.Transform,self.Btnclickcb)
end

function XUiDormWorkGridItem:OnBtnClick()
    if not self.ItemData then
        return
    end

    if self.CurState == WorkPosState.RewardEd then
        XUiManager.TipMsg(self.TextDormNoRewardGet)
        return
    end

    if self.CurState == WorkPosState.Empty then
        self.UiRoot:OpenMemeberList()
    elseif self.CurState == WorkPosState.Worked then
        self.UiRoot:OnBtnTotalGet()
    elseif self.CurState == WorkPosState.Working then
        if self.CurDaigonState == XUiButtonState.Disable then
            XUiManager.TipMsg(self.TextDormNoMood)
        else
            local d = {}
            d.DaiGongData = self.DaiGongData
            d.WorkPos = self.ItemData.WorkPos
            d.CurIconpath = XDormConfig.GetCharacterStyleConfigQIconById(self.ItemData.CharacterId)
            self.UiRoot:OpenOneChildUi("UiDormFoundryDetail",self.UiRoot,{d})
            if not self.FundryDetail then
                self.FundryDetail = self.UiRoot:FindChildUiObj("UiDormFoundryDetail")
            end
            self.FundryDetail:OnRefreshData({d})
            self.UiRoot.PanelWork.gameObject:SetActiveEx(false)
        end
    else
        XUiManager.TipText("DormWorkPosUnLockTips")
    end
end

-- 更新数据
function XUiDormWorkGridItem:OnRefresh(itemData,index)
    if not itemData then
        return
    end

    index = string.format( "%02d",index)
    self.CurIndex = index
    self.ItemData = itemData
    if itemData == WorkPosState.Empty then
       self.TxtEmptyCount.text = index
       self.CurState = WorkPosState.Empty
       self.ContainerEmpty.gameObject:SetActive(true)
       self.ContainerItem.gameObject:SetActive(false)
       self.ContainerFinish.gameObject:SetActive(false)
       self.ContainerFinishEd.gameObject:SetActive(false)
       self.ContainerLock.gameObject:SetActive(false)
       return
    elseif itemData == WorkPosState.Lock then
        self.TxtLockCount.text = index
        self.CurState = WorkPosState.Lock
        self.ContainerEmpty.gameObject:SetActive(false)
        self.ContainerItem.gameObject:SetActive(false)
        self.ContainerFinish.gameObject:SetActive(false)
        self.ContainerFinishEd.gameObject:SetActive(false)
        self.ContainerLock.gameObject:SetActive(true)
        return
    end

    self.ContainerEmpty.gameObject:SetActive(false)
    self.ContainerLock.gameObject:SetActive(false)
    
    local iconpath = XDormConfig.GetCharacterStyleConfigQSIconById(itemData.CharacterId)
    self.CurIconpath = iconpath
    if iconpath then
        self.UiRoot:SetUiSprite(self.ImgIcon,iconpath)
    end

    local workendtime = itemData.WorkEndTime
    if workendtime == 0 then
        self.TxtState.text = self.TextDormReward
        self.TxtTimer.text = ""
        self.TxtFinishedCount.text = index
        self.CurState = WorkPosState.RewardEd
        self.ContainerFinishEd.gameObject:SetActive(true)
        self.ContainerFinish.gameObject:SetActive(false)
        self.ContainerItem.gameObject:SetActive(false)
        return
    end
    
    self.RetimeSec = workendtime - XTime.GetServerNowTimestamp()
    if self.RetimeSec <= 0 then
        self.TxtState.text = self.TextDormWorked
        self.CurState = WorkPosState.Worked
        self.TxtTimer.text = ""
        self.TxtFinishCount.text = index
        self.ContainerFinish.gameObject:SetActive(true)
        self.ContainerFinishEd.gameObject:SetActive(false)
        self.ContainerItem.gameObject:SetActive(false)
        self.MoodFinsihTxtValues.text = DormManager.GetMoodById(itemData.CharacterId)
        local mood = DormManager.GetMoodById(itemData.CharacterId)
        local moodConfig = XDormConfig.GetMoodStateByMoodValue(mood)
        self.UiRoot:SetUiSprite(self.MoodFinishIcon, moodConfig.Icon)
    else
        self.TxtTimer.text = XUiHelper.GetTime(self.RetimeSec,XUiHelper.TimeFormatType.HOSTEL)
        self.TxtState.text = self.TextDormWorking
        self.CurState = WorkPosState.Working
        self.UiRoot:RegisterWorkTimer(self.TimerFunCb,itemData.WorkPos)
        self.TxtItemCount.text = index
        self.ContainerItem.gameObject:SetActive(true)
        self.ContainerFinish.gameObject:SetActive(false)
        self.ContainerFinishEd.gameObject:SetActive(false)
        local count = DormManager.GetDormitoryCount()
        self.DaiGongData = XDormConfig.GetDormCharacterWorkById(count)
        local mood = DormManager.GetMoodById(itemData.CharacterId)
        if self.DaiGongData and self.DaiGongData.Mood then
            local v = math.floor(self.DaiGongData.Mood / 100) 
            if v <= mood then
                self.CurDaigonState = XUiButtonState.Normal
                self.BtnDaigong:SetButtonState(XUiButtonState.Normal)
            else
                self.CurDaigonState = XUiButtonState.Disable
                self.BtnDaigong:SetButtonState(XUiButtonState.Disable)
            end
        end
        self.MoodTxtValues.text = mood
        local moodConfig = XDormConfig.GetMoodStateByMoodValue(mood)
        self.UiRoot:SetUiSprite(self.MoodIcon, moodConfig.Icon)
    end
end

-- 更新倒计时
function XUiDormWorkGridItem:UpdataTimer()
    if self.RetimeSec <= 0 then
        self.TxtState.text = self.TextDormWorked
        self.CurState = WorkPosState.Worked
        self.TxtTimer.text = ""
        self.ContainerFinish.gameObject:SetActive(true)
        self.ContainerFinishEd.gameObject:SetActive(false)
        self.ContainerItem.gameObject:SetActive(false)
        self.TxtFinishCount.text = self.CurIndex
        if self.ItemData and self.ItemData.WorkPos then
            self.UiRoot:RemoveWorkTimer(self.ItemData.WorkPos)
            local mood = DormManager.GetMoodById(self.ItemData.CharacterId)
            local moodConfig = XDormConfig.GetMoodStateByMoodValue(mood)
            self.UiRoot:SetUiSprite(self.MoodFinishIcon, moodConfig.Icon)        
        end
        return
    end
    
    self.RetimeSec = self.RetimeSec - 1
    self.TxtTimer.text = XUiHelper.GetTime(self.RetimeSec,XUiHelper.TimeFormatType.HOSTEL)
end

return XUiDormWorkGridItem
