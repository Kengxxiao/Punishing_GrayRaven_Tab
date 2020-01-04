-- 家具建造子界面
XUiPanelCreate = XClass()

local EnoughColor = CS.XGame.ClientConfig:GetString("FurnitureCostEnough")
local NotEnoughColor = CS.XGame.ClientConfig:GetString("FurnitureCostNotEnough")

function XUiPanelCreate:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    XTool.InitUiObject(self)

    self.GridCreatePool = {}
    self.GridInvestmentPool = {}
    self.SelectTypeId = nil

    self.BtnTanchuangClose.CallBack = function() self:OnBtnCancelClick() end
    self.BtnStart.CallBack = function() self:OnBtnStartClick() end
    self.BtnSelect.CallBack = function() self:OnBtnSelectClick() end
end

function XUiPanelCreate:OnBtnCancelClick()
    self.RootUi:PlayAnimCreationDetailDisable(function()
        self.PanelCreationDetail.gameObject:SetActive(false)
    end)
end

function XUiPanelCreate:OnBtnStartClick()
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
        self.RootUi:PlayAnimCreationDetailDisable(function()
            self.PanelCreationDetail.gameObject:SetActive(false)
            self:UpdateCreateGridByPos(self.SelectPos)
        end)
    end)
end


function XUiPanelCreate:Init(cfg)
    self.CreateGridDatas = cfg
    self.GridCreate.gameObject:SetActive(false)

    if not self.CreateGridDatas then
        XLog.Warning("XUiPanelCreate:Init error: cfg is nil")
    end

    if not self.DynamicTableCreate then
        self.DynamicTableCreate = XDynamicTableNormal.New(self.ScrCreate.gameObject)
        self.DynamicTableCreate:SetProxy(XUiGridCreate)
        self.DynamicTableCreate:SetDelegate(self)
    end
    
    self.DynamicTableCreate:SetDataSource(self.CreateGridDatas)
    self.DynamicTableCreate:ReloadDataASync()
end

-- [列表事件]
function XUiPanelCreate:OnDynamicTableEvent(event, index, grid)
    if event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_INIT then
        grid:Rename(index)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_ATINDEX then
        self:OnRefreshCreate(index, grid)
    elseif event == DYNAMIC_DELEGATE_EVENT.DYNAMIC_GRID_RECYCLE then
        grid:OnClose()
    end
end

function XUiPanelCreate:OnRefreshCreate(index, grid)
    local data = self.CreateGridDatas[index]
    if not data then return end
    grid:Init(data, self)
end

function XUiPanelCreate:UpdateCreateGridByPos(pos)
    if not self.CreateGridDatas then return end
    
    local index = 1
    for k, v in pairs(self.CreateGridDatas) do
        if v.Pos == pos then
            index = k
            break
        end
    end

    if not self.DynamicTableCreate then return end
    local grid = self.DynamicTableCreate:GetGridByIndex(index)
    if grid then
        grid:Init(self.CreateGridDatas[index], self)
    end
end

function XUiPanelCreate:SetPanelActive(value)
    self.GameObject:SetActive(value)
end

--显示制造家具详情UI
function XUiPanelCreate:ShowPanelCreationDetail(pos)
    self.SelectPos = pos or 0
    --清除上一个状态
    self.SelectTypeId = nil
    
    self.PanelCreationDetail.gameObject:SetActive(true)
    self.ImgAdd.gameObject:SetActive(true)
    self.RootUi:PlayAnimCreationDetailEnable()
    self:UpdateCreationDetail()

    local icon = XDataCenter.ItemManager.GetItemIcon(XDataCenter.ItemManager.ItemId.FurnitureCoin)
    self.RImgFurnitureCoinIcon:SetRawImage(icon)

    self.BtnSelect:SetNameByGroup(0, CS.XTextManager.GetText("FurnitureAddType"))
end

-- 制造家具详情ui界面设置
function XUiPanelCreate:UpdateCreationDetail(isIgnoreUpdateInvesment)
    if not isIgnoreUpdateInvesment then
        self.InvestmentCfg = XFurnitureConfigs.GetFurnitureAttrType()
        local onCreate = function(grid, data)
            grid:Init(data, self)
        end
        XUiHelper.CreateTemplates(self.RootUi, self.GridInvestmentPool, self.InvestmentCfg, XUiGridInvestment.New, self.GridInvestment, self.PanelInvestment, onCreate)
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

function XUiPanelCreate:SetInvestBtnsState(state)
    for k, v in pairs(self.GridInvestmentPool) do
        if v then
            v:SetBtnState(state)
        end
    end
end

-- 获得所有家具币-建造加多少币有么有限制
function XUiPanelCreate:GetTotalFurnitureCoin()
    local minConsume, maxConsume = XFurnitureConfigs.GetFurnitureCreateMinAndMax()

    local currentOwn = XDataCenter.ItemManager.GetCount(XDataCenter.ItemManager.ItemId.FurnitureCoin)

    return (currentOwn >= maxConsume) and maxConsume or currentOwn
end

-- 检查是否可以投入
function XUiPanelCreate:CheckCanAddSum()
    local totalNum = self:GetTotalFurnitureCoin()
    local currentSum = 0
    for k, v in pairs(self.GridInvestmentPool) do
        currentSum = currentSum + v:GetCurrentSum()
    end
    local incresment = CS.XGame.ClientConfig:GetInt("FurnitureInvestmentIncreaseStep")
    return totalNum >= currentSum + incresment
end

-- 可以投入的最大数量
function XUiPanelCreate:GetPassableSum()
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

function XUiPanelCreate:UpdateTotalNum()
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
function XUiPanelCreate:OnBtnSelectClick(eventData)
    local func = function(typeId)
        self.SelectTypeId = typeId
        self.RootUi:PlayAnimInvestmentEnable()
        self.BtnSelect:SetNameByGroup(0, "")
        self.ImgAdd.gameObject:SetActive(false)
        self:UpdateCreationDetail(true)
    end
    XLuaUiManager.Open("UiFurnitureTypeSelect",nil, nil, func)
end

function XUiPanelCreate:HasSelectType()
    return self.SelectTypeId ~= nil
end

return XUiPanelCreate
