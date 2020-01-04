XUiGridTitle = XClass()

function XUiGridTitle:Ctor(ui)
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)
    self:InitAutoScript()
    self:SetTitleBg(false)
    self.RepointId = XRedPointManager.AddRedPointEvent(self.ImgRedDot,self.CheckUnReadOrHasReward,self,{XRedPointConditions.Types.CONDITION_MAIL_PERSONAL},nil)

end

function XUiGridTitle:CheckUnReadOrHasReward(count)
    self.ImgRedDot.gameObject:SetActiveEx(count >= 0)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiGridTitle:InitAutoScript()
    self:AutoAddListener()
end

function XUiGridTitle:AutoAddListener()
    self.BtnTitle.CallBack = function()
        self:OnBtnTitleClick()
    end
end
-- auto

function XUiGridTitle:OnBtnTitleClick(...)
    self.Base.CurMailInfo = self.MailInfo
    self:OpenMail(true)
end

function XUiGridTitle:OpenMail(IsPlayAnim)
    if self.Base.CurMailInfo.Id == self.MailInfo.Id then
        self.Base.GetItemCallBack = function()
            self:SetMailStatus(true)
        end
        self.Base:ClickMailGrid(self.MailInfo,IsPlayAnim)
        if self.Base.OldTitle then
            self.Base.OldTitle:SetTitleBg(false)
        end
        self.Base.OldTitle = self
        self:SetMailStatus(true)
        self:SetTitleBg(true)
        self:SetUnread(false)
    else
        self:SetTitleBg(false)
    end
end

function XUiGridTitle:SetUnread(IsUnread)
    self.TxtUnread.gameObject:SetActiveEx(IsUnread)
    self.ImgBgUnread.gameObject:SetActiveEx(IsUnread)
end

function XUiGridTitle:UpdateMailGrid(base,mailInfo)
    self.Base = base
    self.MailInfo = mailInfo
    local mailId = mailInfo.Id
    self.TxtTitleRead.text = mailInfo.Title
    self.TxtDateRead.text = CS.XDate.FormatTime(mailInfo.CreateTime)
    self.TxtDateRead.gameObject:SetActiveEx(false)
    self.TxtTitleUnread.text = mailInfo.Title
    self.TxtDateUnread.text = CS.XDate.FormatTime(mailInfo.CreateTime)
    self.TxtDateUnread.gameObject:SetActiveEx(false)
    self:SetMailStatusByStatu()
    self:OpenMail(false)
    XRedPointManager.Check(self.RepointId,mailId)
end

function XUiGridTitle:SetMailStatusByStatu()
    local isRead = XDataCenter.MailManager.IsRead(self.MailInfo.Status)
    self:SetMailStatus(isRead)
    self:SetUnread(not isRead)
end

function XUiGridTitle:SetMailStatus(isRead)
    self.ImgIconRead.gameObject:SetActiveEx(false)
    self.ImgIconUnRead.gameObject:SetActiveEx(false)
    self.ImgIconReadgift.gameObject:SetActiveEx(false)
    self.ImgIconUnReadgift.gameObject:SetActiveEx(false)
    --self.ImgRedDot.gameObject:SetActive(not isRead)
    local isHasReward = XDataCenter.MailManager.HasMailReward(self.MailInfo.Id)
    local isGetReward = XDataCenter.MailManager.IsMailGetReward(self.MailInfo.Id)
    

    if isHasReward and not isGetReward then
        
        self.ImgIconUnReadgift.gameObject:SetActiveEx(not isRead)
        self.ImgIconReadgift.gameObject:SetActiveEx(isRead)

    else
        self.ImgIconUnRead.gameObject:SetActiveEx(not isRead)
        self.ImgIconRead.gameObject:SetActiveEx(isRead)

    end
end

function XUiGridTitle:SetTitleBg(flag)
    self.ImgTitleBg.gameObject:SetActiveEx(flag)
end
