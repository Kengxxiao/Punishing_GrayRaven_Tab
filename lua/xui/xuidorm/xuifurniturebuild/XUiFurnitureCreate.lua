-- 家具建造子界面
local XUiFurnitureCreate = XLuaUiManager.Register(XLuaUi, "UiFurnitureCreate")

local EnoughColor = CS.XGame.ClientConfig:GetString("FurnitureCostEnough")
local NotEnoughColor = CS.XGame.ClientConfig:GetString("FurnitureCostNotEnough")

function XUiFurnitureCreate:OnAwake()
    self.GridInvestmentPool = {}
    self.SelectTypeId = nil


end

function XUiFurnitureCreate:OnBtnCancelClick()
    self:Close()
end

function XUiFurnitureCreate:OnBtnStartClick()
    if not self.SelectTypeId then
        XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureChooseAType"))
        return
    end
    
    local costA = 0
    local costB = 0
    local costC = 0
    for i=1, #self.InvestmentCfg do
        local investmentItem = self.GridInvestmentPool[i]
        local cfg, sum = investmentItem:GetCostDatas()
        if cfg.Id == XFurnitureConfigs.AttrType.AttrA then
            costA = sum
        elseif cfg.Id == XFurnitureConfigs.AttrType.AttrB then
            costB = sum
        elseif cfg.Id == XFurnitureConfigs.AttrType.AttrC then
            costC = sum
        end
    end
    -- update界面，关闭界面
    XDataCenter.FurnitureManager.CreateFurniture(self.SelectPos, self.SelectTypeId, costA, costB, costC, function()
        XUiManager.TipText("FurnitureBuildStart")
        self:Close()
    end)
end


function XUiFurnitureCreate:OnStart(typeId)
    self.BtnTanchuangClose.CallBack = function() self:OnBtnCancelClick() end
    self.BtnStart.CallBack = function() self:OnBtnStartClick() end
    self.BtnSelect.CallBack = function() self:OnBtnSelectClick() end

        self:ShowPanelCreationDetail()
    self:SetSelectType(typeId)
end

function XUiFurnitureCreate:SetPanelActive(value)
    self.GameObject:SetActive(value)
end

--显示制造家具详情UI
function XUiFurnitureCreate:ShowPanelCreationDetail(pos)
    self.SelectPos = pos or 0

    local maxCreateNum = CS.XGame.Config:GetInt("DormFurnitureCreateNum")
    for i = 0,maxCreateNum,1 do
        local furnitureCreateData = XDataCenter.FurnitureManager.GetFurnitureCreateItemByPos(i)
        if not furnitureCreateData then
            self.SelectPos = i
            break
        end
    end 

    --清除上一个状态
    self.SelectTypeId = nil
    
    self.PanelCreationDetail.gameObject:SetActive(true)
    self.ImgAdd.gameObject:SetActive(true)
    --self.RootUi:PlayAnimCreationDetailEnable()
    self:UpdateCreationDetail()

    local icon = XDataCenter.ItemManager.GetItemIcon(XDataCenter.ItemManager.ItemId.FurnitureCoin)
    self.RImgFurnitureCoinIcon:SetRawImage(icon)

    self.BtnSelect:SetNameByGroup(0, CS.XTextManager.GetText("FurnitureAddType"))
end

-- 制造家具详情ui界面设置
function XUiFurnitureCreate:UpdateCreationDetail(isIgnoreUpdateInvesment)
    if not isIgnoreUpdateInvesment then
        self.InvestmentCfg = XFurnitureConfigs.GetFurnitureAttrType()
        local onCreate = function(grid, data)
            grid:Init(data, self)
        end
        XUiHelper.CreateTemplates(self, self.GridInvestmentPool, self.InvestmentCfg, XUiGridInvestment.New, self.GridInvestment, self.PanelInvestment, onCreate)
        self.GridInvestment.gameObject:SetActive(false)
    end

    self.TxtFurnitureCoinCount.text = self:GetTotalFurnitureCoin()
    local canvasGroup = (self.SelectTypeId==nil) and 1 or 0
    local typeName = ""
    self.HeadIcon.gameObject:SetActive(self.SelectTypeId~=nil)
    self.ImgItemIcon.gameObject:SetActive(self.SelectTypeId~=nil)
    if self.SelectTypeId then
        local furnitureTypeTemplate = XFurnitureConfigs.GetFurnitureTypeById(self.SelectTypeId)
        typeName = furnitureTypeTemplate.CategoryName
        self.ImgItemIcon:SetRawImage(furnitureTypeTemplate.TypeIcon)
        self:SetInvestBtnsState(true)
    else
        self:SetInvestBtnsState(false)
    end
    self.TxtTypeName.text = typeName
    self:UpdateTotalNum()
end

function XUiFurnitureCreate:SetInvestBtnsState(state)
    for k, v in pairs(self.GridInvestmentPool) do
        if v then
            v:SetBtnState(state)
        end
    end
end

-- 获得所有家具币-建造加多少币有么有限制
function XUiFurnitureCreate:GetTotalFurnitureCoin()
    local minConsume, maxConsume = XFurnitureConfigs.GetFurnitureCreateMinAndMax()

    local currentOwn = XDataCenter.ItemManager.GetCount(XDataCenter.ItemManager.ItemId.FurnitureCoin)

    return (currentOwn >= maxConsume) and maxConsume or currentOwn
end

-- 检查是否可以投入
function XUiFurnitureCreate:CheckCanAddSum()
    local totalNum = self:GetTotalFurnitureCoin()
    local currentSum = 0
    for k, v in pairs(self.GridInvestmentPool) do
        currentSum = currentSum + v:GetCurrentSum()
    end
    local incresment = CS.XGame.ClientConfig:GetInt("FurnitureInvestmentIncreaseStep")
    return totalNum >= currentSum + incresment
end

-- 可以投入的最大数量
function XUiFurnitureCreate:GetPassableSum()
    local totalNum = self:GetTotalFurnitureCoin()
    local currentSum = 0
    for k, v in pairs(self.GridInvestmentPool) do
        currentSum = currentSum + v:GetCurrentSum()
    end
    if totalNum > currentSum then
        return  totalNum - currentSum
    end
    return 0
end

function XUiFurnitureCreate:UpdateTotalNum()
    local totalNum = self:GetTotalFurnitureCoin()
    local currentSum = 0
    for k, v in pairs(self.GridInvestmentPool) do
        currentSum = currentSum + v:GetCurrentSum()
        v:UpdateInfos()
    end
    if totalNum >= currentSum then
        self.TxtFurnitureCoinCount.text = totalNum - currentSum
    else
        self.TxtFurnitureCoinCount.text = totalNum
    end

    local minConsume, maxConsume = XFurnitureConfigs.GetFurnitureCreateMinAndMax()
    local notEnought = minConsume > currentSum
    self.TxtNotPass.gameObject:SetActive(notEnought)
    self.BtnStart:SetDisable(notEnought, not notEnought)
end

-- 选择TypeId
function XUiFurnitureCreate:OnBtnSelectClick(eventData)
    XLuaUiManager.Open("UiFurnitureTypeSelect",nil, nil, handler(self,self.SetSelectType))
end

function XUiFurnitureCreate:SetSelectType(typeId)
    self.SelectTypeId = typeId
    self.BtnSelect:SetNameByGroup(0, "")
    self.ImgAdd.gameObject:SetActive(false)
    self:UpdateCreationDetail(true)
end

function XUiFurnitureCreate:HasSelectType()
    return self.SelectTypeId ~= nil
end

return XUiFurnitureCreate
