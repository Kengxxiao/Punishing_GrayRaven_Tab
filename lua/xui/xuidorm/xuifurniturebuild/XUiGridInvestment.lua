-- 建造家具，家具币选择
XUiGridInvestment = XClass()

local incresment = CS.XGame.ClientConfig:GetInt("FurnitureInvestmentIncreaseStep")

function XUiGridInvestment:Ctor(rootUi, ui)
    self.RootUi = rootUi
    self.GameObject = ui.gameObject
    self.Transform = ui.transform
    self.CurrentSum = 0
    XTool.InitUiObject(self)

    self:AddBtnsListeners()
end

function XUiGridInvestment:AddBtnsListeners()
    self.AutoCreateListeners = {}
    self:RegisterListener(self.BtnReduce, "onClick", self.OnBtnReduceClick)
    self:RegisterListener(self.BtnAdd, "onClick", self.OnBtnAddClick)
    self:RegisterListener(self.BtnMax, "onClick", self.OnBtnMaxClick)
end

function XUiGridInvestment:OnBtnReduceClick(eventData)
    if not self.Parent then return end
    if not self.Parent:HasSelectType() then
        XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureSelectAType"))
        return
    end

    if self.CurrentSum - incresment <= 0 then
        self.CurrentSum = 0
    else
        self.CurrentSum = self.CurrentSum - incresment
    end
    
    self:SetSumText(self.CurrentSum)
    self.Parent:UpdateTotalNum()
end

function XUiGridInvestment:OnBtnAddClick(eventData)
    if not self.Parent then return end
    if not self.Parent:HasSelectType() then
        XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureSelectAType"))
        return
    end

    if self.Parent:CheckCanAddSum() then
        self.CurrentSum = self.CurrentSum + incresment
        self:SetSumText(self.CurrentSum)
        self.Parent:UpdateTotalNum()
    else
        if self.CurrentSum <= 0 then
            XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureZeroCoin"))
        else
            XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureMaxCoin"))
        end
    end
end

function XUiGridInvestment:OnBtnMaxClick(eventData)
    if not self.Parent then return end
    if not self.Parent:HasSelectType() then
        XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureSelectAType"))
        return
    end

    if self.Parent:CheckCanAddSum() then
        local extraNum = self.Parent:GetPassableSum()
        self.CurrentSum = self.CurrentSum + extraNum
        self:SetSumText(self.CurrentSum)
        self.Parent:UpdateTotalNum()
    else
        if self.CurrentSum <= 0 then
            XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureZeroCoin"))
        else
            XUiManager.TipMsg(CS.XTextManager.GetText("FurnitureMaxCoin"))
        end
    end
end

function XUiGridInvestment:RegisterListener(uiNode, eventName, func)
    if not uiNode then return end
    local key = eventName .. uiNode:GetHashCode()
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end
    
    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiBtnTab:RegisterListener: func is not a function")
        end
        
        listener = function(...)
            func(self, ...)
        end
        
        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiGridInvestment:GetCurrentSum()
    return self.CurrentSum or 0
end

function XUiGridInvestment:Init(cfg, parent)
    self.Parent = parent
    self.Cfg = cfg
    
    self.CurrentSum = 0
    self:SetSumText(self.CurrentSum)
    self.RootUi:SetUiSprite(self.ImgAttributeIcon, self.Cfg.TypeIcon)
    self.TxtAttributeName.text = self.Cfg.TypeName
    
    self:UpdateInfos()
    
end

function XUiGridInvestment:UpdateInfos()
    if not self.Parent then return end

    self.BtnReduce.interactable = not (self.CurrentSum <= 0)
end

function XUiGridInvestment:SetBtnState(state)
    self.BtnAdd.interactable = state
    self.BtnMax.interactable = state
end

function XUiGridInvestment:GetCostDatas()
    return self.Cfg, self.CurrentSum
end

function XUiGridInvestment:SetSumText(num)

    if self.Parent:HasSelectType() and num > 0 then
        self.TxtSum.text = ""
        self.TxtSumOn.text = num
        self.TxtAttributeName.text = ""
        self.TxtAttributeNameOn.text = self.Cfg and self.Cfg.TypeName or ""
    else
        self.TxtSum.text = num
        self.TxtSumOn.text = ""
        self.TxtAttributeName.text = self.Cfg and self.Cfg.TypeName or ""
        self.TxtAttributeNameOn.text = ""
    end
    
end

return XUiGridInvestment