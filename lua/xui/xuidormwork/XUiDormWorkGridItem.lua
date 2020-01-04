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

    if self.CurState == WorkPosState.Working or self.CurState == WorkPosState.RewardEd then
        XUiManager.TipMsg(self.TextDormNoRewardGet)
        return
    end

    if self.CurState == WorkPosState.Empty then
        self.UiRoot:OpenMemeberList()
    elseif self.CurState == WorkPosState.Worked then
        self.UiRoot:OnBtnTotalGet()
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
    
    self.RetimeSec = workendtime - XTime.Now()
    if self.RetimeSec <= 0 then
        self.TxtState.text = self.TextDormWorked
        self.CurState = WorkPosState.Worked
        self.TxtTimer.text = ""
        self.TxtFinishCount.text = index
        self.ContainerFinish.gameObject:SetActive(true)
        self.ContainerFinishEd.gameObject:SetActive(false)
        self.ContainerItem.gameObject:SetActive(false)
    else
        self.TxtTimer.text = XUiHelper.GetTime(self.RetimeSec,XUiHelper.TimeFormatType.HOSTEL)
        self.TxtState.text = self.TextDormWorking
        self.CurState = WorkPosState.Working
        self.UiRoot:RegisterWorkTimer(self.TimerFunCb,itemData.WorkPos)
        self.TxtItemCount.text = index--itemData.WorkPos
        self.ContainerItem.gameObject:SetActive(true)
        self.ContainerFinish.gameObject:SetActive(false)
        self.ContainerFinishEd.gameObject:SetActive(false)
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
        self.UiRoot:RemoveWorkTimer(self.ItemData.WorkPos)
        self.TxtFinishCount.text = self.CurIndex
        return
    end
    
    self.RetimeSec = self.RetimeSec - 1
    self.TxtTimer.text = XUiHelper.GetTime(self.RetimeSec,XUiHelper.TimeFormatType.HOSTEL)
end

return XUiDormWorkGridItem
