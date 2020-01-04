-- 家具建造主界面
local XUiFurnitureBuild = XLuaUiManager.Register(XLuaUi, "UiFurnitureBuild")

local TAB_TYPE_CREATE = 1--创造
local TAB_TYPE_REFORM = 2--改装


function XUiFurnitureBuild:OnAwake()
    self.FurnitureCreateList = {}
    local createNum = CS.XGame.Config:GetInt("DormFurnitureCreateNum")
    for i=1, createNum do
        table.insert(self.FurnitureCreateList, i, {
            Id = i,
            Pos = i - 1
        })
    end
    self:AddBtnsListeners()
    self.BtnHelp.CallBack = function() self:OnBtnHelpClick() end
end

function XUiFurnitureBuild:AddBtnsListeners()
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
end

function XUiFurnitureBuild:OnBtnHelpClick()
    XUiManager.ShowHelpTip("Dorm")
end

function XUiFurnitureBuild:OnStart(tabType)
    self.PanelAsset = XUiPanelAsset.New(self, self.PanelAsset, XDataCenter.ItemManager.ItemId.DormCoin, XDataCenter.ItemManager.ItemId.FurnitureCoin)
    self.PanelCreate = XUiPanelCreate.New(self, self.PanelCreate)
    self.PanelRefit = XUiPanelRefit.New(self, self.PanelRefit)
    self.BtnTabList = {}
    table.insert(self.BtnTabList, self.BtnCreate)
    table.insert(self.BtnTabList, self.BtnRefit)
    self.BtnGroup:Init(self.BtnTabList, function(index) self:SelectPanel(index) end)

    self.BtnCreate:SetNameByGroup(0, CS.XTextManager.GetText("FurntiureBuildCreateCH"))
    self.BtnCreate:SetNameByGroup(1, CS.XTextManager.GetText("FurntiureBuildCreateEN"))
    self.BtnRefit:SetNameByGroup(0, CS.XTextManager.GetText("FurnitureBuildRefitCH"))
    self.BtnRefit:SetNameByGroup(1, CS.XTextManager.GetText("FurnitureBuildRefitEN"))
    
    self:Init(tabType or TAB_TYPE_CREATE)

    self.AnimBuildEnable:PlayTimelineAnimation()
    self.BuildPointId = XRedPointManager.AddRedPointEvent(self.FurnitureBuildRedPoint, self.OnCheckBuildFurniture, self, { XRedPointConditions.Types.CONDITION_FURNITURE_CREATE })
end

function XUiFurnitureBuild:OnCheckBuildFurniture(count)
    self.FurnitureBuildRedPoint.gameObject:SetActive(count >= 0)
end

function XUiFurnitureBuild:OnDestroy()
end

function XUiFurnitureBuild:Init(tabType)
    self.PanelCreate:Init(self.FurnitureCreateList)
    self.PanelRefit:Init()
    self.BtnGroup:SelectIndex(tabType)
end

function XUiFurnitureBuild:OnBtnBackClick(...)
    self:Close()
end

function XUiFurnitureBuild:OnBtnMainUiClick(...)
    XLuaUiManager.RunMain()
end

function XUiFurnitureBuild:SelectPanel(index)
    self.PanelCreate:SetPanelActive(index == TAB_TYPE_CREATE)
    self.PanelRefit:SetPanelActive(index == TAB_TYPE_REFORM)
end

function XUiFurnitureBuild:PlayAnimRefitEnable()
    self.AnimRefitEnable:PlayTimelineAnimation()
end

function XUiFurnitureBuild:PlayAnimInvestmentEnable()
    self.AnimInvestmentEnable:PlayTimelineAnimation()
end

function XUiFurnitureBuild:PlayAnimCreationDetailEnable()
    self.AnimCreationDetailEnable:PlayTimelineAnimation()
end

function XUiFurnitureBuild:PlayAnimCreationDetailDisable(callback)
    self.AnimCreationDetailDisable:PlayTimelineAnimation(function()
        if callback then callback() end
    end)
end

function XUiFurnitureBuild:OnEnable()
    XDataCenter.DormManager.StartDormRedTimer()
end

function XUiFurnitureBuild:OnDisable()
    XDataCenter.DormManager.StopDormRedTimer()
end
