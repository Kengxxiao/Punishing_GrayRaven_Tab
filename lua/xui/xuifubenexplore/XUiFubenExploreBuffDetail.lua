XUiFubenExploreBuffDetail = XClass()
function XUiFubenExploreBuffDetail:Ctor(ui, buffInfo)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.BuffInfo = buffInfo
    self:InitUiObjects()
    self.UnlockColor = self.TxtLock.color
    self:Update(self.BuffInfo)
end

function XUiFubenExploreBuffDetail:InitUiObjects()
    XTool.InitUiObject(self)
end

function XUiFubenExploreBuffDetail:Update(buffInfo)
    local isUnlock = true
    local unLockText = ""
    local unLockTextSeparate = CS.XTextManager.GetText("ExploreBuffUnlockSeparate")
    for i = 1, #buffInfo.UnlockEvent do
        if i == 1 then
            if not XDataCenter.FubenExploreManager.IsBuffUnlockEvent(buffInfo, buffInfo.UnlockEvent[i]) then
                isUnlock = false
                self.TxtLock.color = CS.UnityEngine.Color.white
            else
                self.TxtLock.color = self.UnlockColor
            end
        elseif i == 2 then
            if not XDataCenter.FubenExploreManager.IsBuffUnlockEvent(buffInfo, buffInfo.UnlockEvent[i]) then
                isUnlock = false
                self.TxtLock2.color = CS.UnityEngine.Color.white
            else
                self.TxtLock2.color = self.UnlockColor
            end
        end
    end

    if isUnlock then
        self.Normal.gameObject:SetActive(true)
        self.Lock.gameObject:SetActive(false)
    else
        self.Normal.gameObject:SetActive(false)
        self.Lock.gameObject:SetActive(true)
    end
    self.ImgIco:SetRawImage(buffInfo.Icon)
    self.TxtName.text = buffInfo.BuffName
    self.TxtDis.text = buffInfo.Explain
    self.TxtLock.text = buffInfo.GainDesc[1]
    self.TxtLock2.text = buffInfo.GainDesc[2]
end