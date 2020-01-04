--local XUiMail = XUiManager.Register("UiMail")
local XUiMail = XLuaUiManager.Register(XLuaUi, "UiMail")
local MailMaxCount = CS.XGame.Config:GetInt("MailCountLimit")
local CSGetText = CS.XTextManager.GetText
function XUiMail:OnAwake()
    self:InitAutoScript()

    self.DynamicTable = XDynamicTableNormal.New(self.PanelTitleList)
    self.DynamicTable:SetProxy(XUiGridTitle)
    self.DynamicTable:SetDelegate(self)
    self.GridTitle.gameObject:SetActive(false)
end

function XUiMail:OnStart()
    
    self.CurMailInfo = nil
    self.SelectTitle = nil
    self.RewardGrids = {}

    self.HtmlText = self.GridContent:GetComponent("XHtmlText")
    self.HtmlText.HrefListener = function(link, content)
        self:ClickLink(link)
    end

    self:Reset()

    self.AssetPanel = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.FreeGem, XDataCenter.ItemManager.ItemId.ActionPoint, XDataCenter.ItemManager.ItemId.Coin)
    -- local musicKey = self:GetAutoKey(self.BtnBack, "onClick")
    -- self.SpecialSoundMap[musicKey] = XSoundManager.UiBasicsMusic.Return    
end

function XUiMail:OnEnable()
    self:ReLoadMailData()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiMail:InitAutoScript()
    self:AutoAddListener()
end

--动态列表事件
function XUiMail:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        grid:UpdateMailGrid(self,self.PageDatas[index])
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_TOUCHED then
        
    end
end

--设置动态列表
function XUiMail:SetupDynamicTable()
    self.PageDatas = XDataCenter.MailManager.GetMailList()
    self.CurMailInfo = self.PageDatas[1]
    self.DynamicTable:SetDataSource(self.PageDatas)
    self.DynamicTable:ReloadDataSync(1) 
end

function XUiMail:AutoAddListener()
    self.BtnDelete.CallBack = function() 
        self:OnBtnDeleteClick()
    end
    self.BtnGet.CallBack = function() 
        self:OnBtnGetClick()
    end
    self.BtnGetReward.CallBack = function() 
        self:OnBtnGetRewardClick()
    end
    self.BtnMainUi.CallBack = function() 
        self:OnBtnMainUiClick()
    end
    self.BtnBack.CallBack = function() 
        self:OnBtnBackClick()
    end
    
end
-- auto

function XUiMail:Reset()
    self.PanelMailContent.gameObject:SetActive(false)
    --self.ImgBgUn.gameObject:SetActive(true)
    self.BtnGetReward.gameObject:SetActive(false)
    self.ImgGetReward.gameObject:SetActive(false)
    self.PanelItemContent.gameObject:SetActive(false)
end

function XUiMail:ReLoadMailData()
    self:SetupDynamicTable()
    self:UpdateMailList()
end

function XUiMail:ResetReward()
    if self.CurMailInfo and self.CurMailInfo.Id then
        self:Reset()
        self:SetRewardBtnStatus(self.CurMailInfo.Id)
        self:InitRewardList(self.CurMailInfo.Id) 
    end
end

function XUiMail:UpdateMailList()

    self.PanelUnGet.gameObject:SetActive(false)
    self.TxtMailCount.text = CSGetText("MailCountText", #self.PageDatas, MailMaxCount)
    if #self.PageDatas == 0 then
        self.PanelUnGet.gameObject:SetActive(true)
        return
    end
end

function XUiMail:ShowMailInfo(mailInfo)
    self.TxtContentTitle.text = mailInfo.Title
    local content = mailInfo.Content or ""
    local sendName = mailInfo.SendName or ""
    self.HtmlText.text = content .. "\n\n" .. CSGetText("ComeFrom") .. ": " .. sendName .. "\n"
    self.PanelMailContent.gameObject:SetActive(true)
    self:RemoveTimer()

    if not mailInfo.ExpireTime then
        self.TxtContentDateNum.gameObject:SetActive(false)
        return
    end

    local refreshFunc
    local restTime = mailInfo.ExpireTime - XTime.Now()
    if restTime and restTime > 0 then
        refreshFunc = function ()
            local dataTime = XUiHelper.GetTime(restTime)
            if XTool.UObjIsNil(self.TxtContentDateNum) then
                return
            end
            self.TxtContentDateNum.text = CSGetText("EmailExpireTime",dataTime)
            restTime = restTime - 1

            if restTime < 0 then
                refreshFunc = nil
            end
        end
    else
        if mailInfo.ExpireTime == 0 then
            self.TxtContentDateNum.text = CSGetText("EmailForever")
        else
            self.TxtContentDateNum.text = CSGetText("EmailExpireTime",XUiHelper.GetTime(0))
        end
        
    end

    if refreshFunc then
        refreshFunc()
    else
        return
    end

    self.Timer = CS.XScheduleManager.Schedule(function()
        if not refreshFunc then
            self:RemoveTimer()
            return
        end

        if refreshFunc then
            refreshFunc()
        end
    end, 1000, 0, 0)
end

function XUiMail:RemoveTimer()
    if self.Timer then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end

function XUiMail:ClickMailGrid(mailInfo,IsPlayAnim)
    --self.ImgBgUn.gameObject:SetActive(false)
    XDataCenter.MailManager.ReadMail(mailInfo.Id)
    self:ShowMailInfo(mailInfo)
    self:SetRewardBtnStatus(mailInfo.Id)
    self:InitRewardList(mailInfo.Id)
    if IsPlayAnim then
        self:PlayAnimation("AnimYouJianEnable")  
    end
end

function XUiMail:InitRewardList(mailId)
    local baseItem = self.GridItem
    baseItem.gameObject:SetActive(false)
    self.PanelItemContent.gameObject:SetActive(false)

    if not XDataCenter.MailManager.HasMailReward(mailId) then
        return
    end

    for _, grid in pairs(self.RewardGrids) do
        grid:Refresh()
    end

    local mail = XDataCenter.MailManager.GetMailCache(mailId)
    local isGetReward = XDataCenter.MailManager.IsGetReward(mail.Status)
    local index = 1
    local function refreshReward(value)
        if not self.RewardGrids[index] then
            local item = CS.UnityEngine.Object.Instantiate(baseItem)
            local grid = XUiGridCommon.New(self, item)
            grid.Transform:SetParent(self.PanelItemContent, false)
            self.RewardGrids[index] = grid
        end

        self.RewardGrids[index]:Refresh(value, { ["ShowReceived"] = isGetReward })
        index = index + 1
    end

    local rewards = XRewardManager.MergeAndSortRewardGoodsList(mail.RewardGoodsList)

    for i = 1, #rewards do
        refreshReward(rewards[i])
    end

    self.PanelItemContent.gameObject:SetActive(true)
end

function XUiMail:OnBtnDeleteClick(...)
    XDataCenter.MailManager.DeleteMail(function(...)
            self:ResetReward()
            self:ReLoadMailData()
    end)
end

function XUiMail:OnBtnGetClick(...)
    XDataCenter.MailManager.GetAllMailReward(function(...)
            self:ResetReward()
            self:ReLoadMailData()
    end)
end

function XUiMail:OnBtnGetRewardClick(...)
    if self.CurMailInfo then
        XDataCenter.MailManager.GetMailReward(self.CurMailInfo.Id, function(mailId)
                self:ResetReward()
                if self.GetItemCallBack then
                    self.GetItemCallBack()
                end
                self:ClickMailGrid(self.CurMailInfo,true)
            end) 
    end
end

function XUiMail:OnBtnBackClick(...)
    self:RemoveTimer()
    self:Close()  
    XDataCenter.MailManager.SyncMailEvent()
end

function XUiMail:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiMail:SetRewardBtnStatus(mailId)
    mailId = mailId and mailId or self.CurMailInfo.Id
    self.BtnGetReward.gameObject:SetActive(false)
    self.ImgGetReward.gameObject:SetActive(false)

    if not mailId then
        return
    end

    local mail = XDataCenter.MailManager.GetMailCache(mailId)
    if mail and XDataCenter.MailManager.HasMailReward(mailId) then
        if not XDataCenter.MailManager.IsGetReward(mail.Status) then
            self.BtnGetReward.gameObject:SetActive(true)
        else
            self.ImgGetReward.gameObject:SetActive(true)
        end
    end
end

function XUiMail:SetRewardStatus(mailId)
    mailId = mailId and mailId or self.CurMailInfo.Id

    if not mailId then
        return
    end

    if XDataCenter.MailManager.HasMailReward(mailId) then
        self.PanelItemContent.gameObject:SetActive(true)
        local isGetReward = XDataCenter.MailManager.IsMailGetReward(mailId)
        for _, grid in pairs(self.RewardGrids) do
            grid:SetReceived(isGetReward)
        end
    end
end

function XUiMail:ClickLink(url)
    CS.UnityEngine.Application.OpenURL(url)
end