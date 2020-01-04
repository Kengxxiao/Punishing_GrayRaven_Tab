local XUiBagItemInfoPanel = XLuaUiManager.Register(XLuaUi, "UiBagItemInfoPanel")

local MIN_SELET_COUNT = 1
local IsLockBtnAdd = false
local IsLockBtnUse = false
function XUiBagItemInfoPanel:OnAwake()
    XTool.InitUiObject(self)
    self:InitAutoScript()
end

function XUiBagItemInfoPanel:OnStart(itemData)

    self.SelectCount = 0
    self.DefaultMinSelectCount = 0

    self.WgtBtnAddSelect = self.BtnAddSelect.gameObject:GetComponent("XUiPointer")
    self.WgtBtnMinusSelect = self.BtnMinusSelect.gameObject:GetComponent("XUiPointer")

    XUiButtonLongClick.New(self.WgtBtnMinusSelect, 100, self, nil, self.BtnMinusSelectLongClickCallback, nil, true)
    XUiButtonLongClick.New(self.WgtBtnAddSelect, 100, self, nil, self.BtnAddSelectLongClickCallback, nil, true)

    self.ItemData = itemData.Data
    self.GridIndex = itemData.GridIndex
    self.RecycleBatch = itemData.RecycleBatch

    local id = self.ItemData.TemplateId and self.ItemData.TemplateId or self.ItemData.Id
    if not id then
        XLog.Error("XUiBagItem:RefreshSelf error: id is nil")
        return
    end
    self.IsUseable = XDataCenter.ItemManager.IsUseable(id)

    self:SetupContent()
    self:SetBtnShowOfActionPointOverLimit()
end

function XUiBagItemInfoPanel:SetupContent()
    if not self.ItemData then
        return
    end

    self:SetupOperation()
    self:SetupBaseInfo()
end

function XUiBagItemInfoPanel:OnEnable()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiBagItemInfoPanel:InitAutoScript()
    self:AutoAddListener()
end

function XUiBagItemInfoPanel:AutoAddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
    self:RegisterClickEvent(self.BtnGet, self.OnBtnGetClick)
    self:RegisterClickEvent(self.BtnAddSelect, self.OnBtnAddSelectClick)
    self:RegisterClickEvent(self.BtnMinusSelect, self.OnBtnMinusSelectClick)
    self:RegisterClickEvent(self.BtnUse, self.OnBtnUseClick)
    self:RegisterClickEvent(self.BtnMax, self.OnBtnMaxClick)
end
-- auto
function XUiBagItemInfoPanel:OnBtnAddSelectClick(...)
    if self.SelectCount <= 0 or self.SelectCount >= self:GetGridCount() then
        return
    end
    if IsLockBtnAdd then
        XUiManager.TipMsg(CS.XTextManager.GetText("OverLimitCanNotUse"))
        return
    end
    self:SetSelectCount(self.SelectCount + 1)
    self:SetBtnShowOfActionPointOverLimit()
end

function XUiBagItemInfoPanel:OnBtnMinusSelectClick(...)
    if self.SelectCount <= 0 then
        return
    end

    self:SetSelectCount(self.SelectCount - 1)
    self:SetBtnShowOfActionPointOverLimit()
end

function XUiBagItemInfoPanel:OnBtnCloseClick(...)
    self:Close()
end

function XUiBagItemInfoPanel:OnBtnGetClick(...)
    XLuaUiManager.Open("UiSkip", self.ItemData.Template.Id)
end

function XUiBagItemInfoPanel:BtnMinusSelectLongClickCallback(time)
    if self.SelectCount == 0 then
        return
    end

    local delta = math.max(0, math.floor(time / 150))
    local count = self.SelectCount - delta
    if count <= 0 then
        count = 0
    end
    self:SetSelectCount(count)
    self:SetBtnShowOfActionPointOverLimit()
end

function XUiBagItemInfoPanel:BtnAddSelectLongClickCallback(time)
    local maxCount = self:GetGridCount()
    if maxCount and self.SelectCount >= maxCount then
        return
    end
    if IsLockBtnAdd then
        XUiManager.TipMsg(CS.XTextManager.GetText("OverLimitCanNotUse"))
        return
    end
    local delta = math.max(0, math.floor(time / 150))
    local count = self.SelectCount + delta
    if maxCount and count >= maxCount then
        count = maxCount
    end

    self:SetSelectCount(count)
    self:SetBtnShowOfActionPointOverLimit()
end

function XUiBagItemInfoPanel:SetSelectCount(newCount)
    self.SelectCount = math.max(newCount, self.DefaultMinSelectCount)
    if self.BtnUse then
        self.BtnUse.interactable = newCount > 0
    end

    self.TxtSelect.text = tostring(self.SelectCount)
end

--设置操作
function XUiBagItemInfoPanel:SetupOperation()
    local isUseable = self.IsUseable
    if isUseable then
        self.DefaultMinSelectCount = MIN_SELET_COUNT
        self.SelectCount = self.DefaultMinSelectCount
        self.TxtSelect.text = tostring(MIN_SELET_COUNT)
    end
    self.BtnMax.gameObject:SetActive(isUseable)
    self.BtnMinusSelect.gameObject:SetActive(isUseable)
    self.BtnAddSelect.gameObject:SetActive(isUseable)
    self.TxtSelect.gameObject:SetActive(isUseable)
end

--获取当前道具的数量包括堆叠显示
function XUiBagItemInfoPanel:GetGridCount()
    if self.RecycleBatch then
        return self.RecycleBatch.RecycleCount
    end

    if self.ItemData.Template.GridCount <= 0 then
        return self.Data.Count
    else
        if self.GridIndex then
            return math.min(self.ItemData.Count - (self.GridIndex - 1) * self.ItemData.Template.GridCount, self.ItemData.Template.GridCount)
        end
    end
end

function XUiBagItemInfoPanel:OnBtnUseClick()
    if self.SelectCount <= 0 then
        return
    end
    if IsLockBtnUse then
        XUiManager.TipMsg(CS.XTextManager.GetText("OverLimitCanNotUse"))
        return
    end
    local callback = function(rewardGoodsList)
        XUiManager.OpenUiObtain(rewardGoodsList, CS.XTextManager.GetText("CongratulationsToObtain"))
    end

    XDataCenter.ItemManager.Use(self.ItemData.Id, self.RecycleBatch and self.RecycleBatch.RecycleTime, self.SelectCount, callback)

    self:OnBtnCloseClick()
    self:SetBtnShowOfActionPointOverLimit()
end

function XUiBagItemInfoPanel:SetBtnShowOfActionPointOverLimit()
    IsLockBtnUse = false
    IsLockBtnAdd = false
    local GoodsNum = 1
    local RewardIndex = 2
    local ActionPoint = XDataCenter.ItemManager.GetItem(XDataCenter.ItemManager.ItemId.ActionPoint)
    for k, v in pairs(XDataCenter.ItemManager.GetCurBatterys()) do
        if self.ItemData.Id == v.Data.Id then
            local goodsList = XRewardManager.GetRewardList(v.Data.Template.SubTypeParams[RewardIndex])
            if goodsList[GoodsNum].Count * self.SelectCount + ActionPoint:GetCount() > ActionPoint.Template.MaxCount then
                IsLockBtnUse = true
            end
            if goodsList[GoodsNum].Count * (self.SelectCount + 1) + ActionPoint:GetCount() > ActionPoint.Template.MaxCount then
                IsLockBtnAdd = true
            end
        end
    end
end

function XUiBagItemInfoPanel:GetMaxCount()
    local maxCount = self:GetGridCount() or 0
    if maxCount == 0 then
        return maxCount
    end
    local tmpMaxCount = 1
    local GoodsNum = 1
    local RewardIndex = 2
    local ActionPoint = XDataCenter.ItemManager.GetItem(XDataCenter.ItemManager.ItemId.ActionPoint)
    for k, v in pairs(XDataCenter.ItemManager.GetCurBatterys()) do
        if self.ItemData.Id == v.Data.Id then
            while (true) do
                local goodsList = XRewardManager.GetRewardList(v.Data.Template.SubTypeParams[RewardIndex])
                if tmpMaxCount == maxCount then
                    break
                end
                if goodsList[GoodsNum].Count * (tmpMaxCount + 1) + ActionPoint:GetCount() <= ActionPoint.Template.MaxCount then
                    tmpMaxCount = tmpMaxCount + 1
                else
                    maxCount = tmpMaxCount
                    break
                end
            end
        end
    end
    return maxCount
end

function XUiBagItemInfoPanel:OnBtnMaxClick()
    local maxCount = self:GetMaxCount()
    if maxCount and self.SelectCount >= maxCount then
        return
    end

    self:SetSelectCount(maxCount)
    self:SetBtnShowOfActionPointOverLimit()
end

function XUiBagItemInfoPanel:SetupBaseInfo()
    self.BtnUse.gameObject:SetActive(self.IsUseable)
    self.BtnUse.interactable = self.SelectCount > 0

    local template = self.ItemData.Template
    self.TxtName.text = template.Name
    self.TxtDescription.text = template.Description
    self.TxtWorldDesc.text = template.WorldDesc
    local count = self:GetGridCount()
    self.TxtCount.text = tostring(count)
    self.RImgIcon:SetRawImage(template.BigIcon)
    if XDataCenter.ItemManager.IsTimeLimit(self.ItemData.Id) then
        local leftTime = 0
        if self.RecycleBatch then
            leftTime = self.RecycleBatch.RecycleTime - XTime.Now()
        else
            leftTime = XDataCenter.ItemManager.GetRecycleLeftTime(self.ItemData.Id)
        end
        local deadlineStr = XUiHelper.GetTimeDesc(leftTime, 2)
        self.TxtDeadLine.text = leftTime <= 0 and "(" .. deadlineStr .. ")" or CS.XTextManager.GetText("ItemDeadLine", deadlineStr)
        self.TxtDeadLine.gameObject:SetActive(true)
    else
        self.TxtDeadLine.gameObject:SetActive(false)
    end

    --获取途径按钮
    local skipIdParams = XGoodsCommonManager.GetGoodsSkipIdParams(self.ItemData.Id)
    if skipIdParams and #skipIdParams > 0 then
        self.BtnGet.gameObject:SetActive(true)
    else
        self.BtnGet.gameObject:SetActive(false)
    end

    self:SetUiSprite(self.ImgIconBg, XArrangeConfigs.GeQualityBgPath(template.Quality))
end