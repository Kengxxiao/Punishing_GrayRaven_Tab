XUiFubenExploreBuff = XClass()
function XUiFubenExploreBuff:Ctor(ui, buffInfo)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.BuffInfo = buffInfo
    self.IsUnlock = XDataCenter.FubenExploreManager.IsBuffUnlock(buffInfo)
    self:InitUiObjects()
    self:Update(self.BuffInfo, true)
end

function XUiFubenExploreBuff:InitUiObjects()
    XTool.InitUiObject(self)
end

function XUiFubenExploreBuff:Update(buffInfo, isInit)
    local isUnlock = XDataCenter.FubenExploreManager.IsBuffUnlock(buffInfo)
    local unLockProgress = XDataCenter.FubenExploreManager.GetBuffUnlockProgress(buffInfo)
    if isUnlock then
        if isInit == nil and isUnlock ~= self.IsUnlock then
            self.IsUnlock = isUnlock
            self.FxUiTanSuoUnlock.gameObject:SetActive(true)
        else
            self.FxUiTanSuoUnlock.gameObject:SetActive(false)
        end
        self.Ico:SetRawImage(buffInfo.Icon)
        self.Ico.gameObject:SetActive(true)
        self.Lock.gameObject:SetActive(false)
    else
        self.Ico.gameObject:SetActive(false)
        self.Lock.gameObject:SetActive(true)
        self.ImgProgress.fillAmount = unLockProgress
    end
end