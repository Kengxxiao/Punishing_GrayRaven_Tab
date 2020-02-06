local XUiNewRoleShow = XLuaUiManager.Register(XLuaUi, "UiNewRoleShow")

function XUiNewRoleShow:OnAwake()
    self:InitAutoScript()
end

function XUiNewRoleShow:OnStart(RoleId, closecallback, openCallback)
    self.RoleConfig = nil
    self.CanClick = false
    self.CloseCallback = nil

    self.CanClick = false
    self.CloseCallback = closecallback
    self.RoleConfig = XNewRoleShowManager.GetNewRoleShowTemplate(RoleId)
    if openCallback then
        openCallback()
    end
    self:PlayAnimations()
end

function XUiNewRoleShow:OnDestroy()
    XUiHelper.StopAnimation()
    self.RoleConfig = nil
    if self.CloseCallback then
        self.CloseCallback()
    end
    self.CloseCallback = nil
end

function XUiNewRoleShow:PlayAnimations()
    self.PanelLoading.gameObject:SetActive(true)
    self.PanelRoleDetail.gameObject:SetActive(false)
    self.PanelEffect.gameObject:SetActive(false)
    self.PanelCenter.gameObject:SetActive(false)
    self.PanelLU.gameObject:SetActive(false)
    self.PanelRU.gameObject:SetActive(false)
    self.PanelLD.gameObject:SetActive(false)
    self.PanelRD.gameObject:SetActive(false)
    self:PlayBegan()
    self:PlayName()
    self:PlayDetail()
    self:PlayLu()
    self:PlayRd()
    self:PlayLd()
    self:PlayRu()
end

function XUiNewRoleShow:PlayBegan()
    local onStart = function()
        self.PanelLoading.gameObject:SetActive(false)
        self.PanelRoleDetail.gameObject:SetActive(true)
    end
    local onFinish = function()
        self.PanelEffect.gameObject:SetActive(true)
    end
    --XUiHelper.PlayAnimation(self, "Began", onStart, onFinish)
end

function XUiNewRoleShow:PlayDetail()
    local onStart = function()
        self.PanelLoading.gameObject:SetActive(false)
        self.PanelRoleDetail.gameObject:SetActive(true)
    end
    local onFinish = function()
        self.PanelEffect.gameObject:SetActive(true)
    end
    --XUiHelper.PlayAnimation(self, "Detail", onStart, onFinish)
end

function XUiNewRoleShow:PlayName()
    local onStart = function()
        self.PanelCenter.gameObject:SetActive(true)
        self.TxtRace.text = ""
    end
    local onFinish = function()
        XUiHelper.ShowCharByTypeAnimation(self.TxtRace, self.RoleConfig.Name, 100)
    end
    --XUiHelper.PlayAnimation(self, "Name", onStart, onFinish)
end

function XUiNewRoleShow:PlayLu()
    local onStart = function()
        self.PanelLU.gameObject:SetActive(true)
        self.TxtHeight.text = "0cm"
        self.TxtWeight.text = "0kg"
    end
    local onFinish = function()
        XUiHelper.Tween(0.5, function(f)
            if XTool.UObjIsNil(self.TxtHeight) then 
                return
            end

            if self.TxtHeight and self.RoleConfig then
                self.TxtHeight.text = math.floor(f * self.RoleConfig.Height) .. "cm"
                self.TxtWeight.text = math.floor(f * self.RoleConfig.Weight) .. "kg"
            else
                return true
            end
        end)
        --XUiHelper.ShowCharByTypeAnimation(self.TxtBWH,self.RoleConfig.BWH,100)
    end
    --XUiHelper.PlayAnimation(self, "Lu", onStart, onFinish)
end

function XUiNewRoleShow:PlayRu()
    local onStart = function()
        self.PanelRU.gameObject:SetActive(true)
        self.ImgIQ.fillAmount = 0
        self.ImgEQ.fillAmount = 0
        self.ImgPhysical.fillAmount = 0
        self.ImgTactics.fillAmount = 0
        self.ImgLeaderShip.fillAmount = 0
    end
    local onFinish = function()
        XUiHelper.Tween(
                0.5,
                function(f)
                    if self.RoleConfig then
                        local mul = f * 0.01
                        self.ImgIQ.fillAmount = self.RoleConfig.IQ * mul
                        self.ImgEQ.fillAmount = self.RoleConfig.EQ * mul
                        self.ImgPhysical.fillAmount = self.RoleConfig.Physical * mul
                        self.ImgTactics.fillAmount = self.RoleConfig.Tactics * mul
                        self.ImgLeaderShip.fillAmount = self.RoleConfig.LeaderShip * mul
                    else
                        return true
                    end
                end
        )
    end
    --XUiHelper.PlayAnimation(self, "Ru", onStart, onFinish)
end

function XUiNewRoleShow:PlayLd()
    local onStart = function()
        self.PanelLD.gameObject:SetActive(true)
        self.TxtAwareness.text = ""
        self.TxtActionStandard.text = ""
    end
    local onFinish = function()
        XUiHelper.ShowCharByTypeAnimation(self.TxtAwareness, self.RoleConfig.Awareness, 100)
        XUiHelper.ShowCharByTypeAnimation(self.TxtActionStandard, self.RoleConfig.ActionStandard, 100)
    end
    --XUiHelper.PlayAnimation(self, "Ld", onStart, onFinish)
end

function XUiNewRoleShow:PlayRd()
    local onStart = function()
        self.PanelRD.gameObject:SetActive(true)
        self.TxtCarryDevice.text = ""
    end
    local onFinish = function()
        XUiHelper.ShowCharByTypeAnimation(self.TxtCarryDevice, self.RoleConfig.CarrayDevice, 100, nil, function()
            self.CanClick = true
        end)
    end
    --XUiHelper.PlayAnimation(self, "Rd", onStart, onFinish)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiNewRoleShow:InitAutoScript()
    self:AutoInitUi()
    self.SpecialSoundMap = {}
    self:AutoAddListener()
end

function XUiNewRoleShow:AutoInitUi()
    self.PanelRoleDetail = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail")
    self.ImgRole = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/ImgRole"):GetComponent("Image")
    self.PanelEffect = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelEffect")
    self.PanelLU = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelLU")
    self.TxtHeight = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelLU/TxtHeight"):GetComponent("Text")
    self.TxtWeight = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelLU/TxtWeight"):GetComponent("Text")
    self.TxtBWH = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelLU/TxtBWH"):GetComponent("Text")
    self.PanelLD = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelLD")
    self.TxtAwareness = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelLD/TxtAwareness"):GetComponent("Text")
    self.TxtActionStandard = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelLD/TxtActionStandard"):GetComponent("Text")
    self.PanelRU = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelRU")
    self.ImgIQ = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelRU/ImgIQ"):GetComponent("Image")
    self.ImgEQ = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelRU/ImgEQ"):GetComponent("Image")
    self.ImgPhysical = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelRU/ImgPhysical"):GetComponent("Image")
    self.ImgTactics = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelRU/ImgTactics"):GetComponent("Image")
    self.ImgLeaderShip = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelRU/ImgLeaderShip"):GetComponent("Image")
    self.PanelRD = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelRD")
    self.TxtCarryDevice = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelRD/TxtCarryDevice"):GetComponent("Text")
    self.PanelCenter = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelCenter")
    self.TxtRace = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/PanelCenter/TxtRace"):GetComponent("Text")
    self.BtnClick = self.Transform:Find("SafeAreaContentPane/PanelRoleDetail/BtnClick"):GetComponent("Button")
    self.PanelLoading = self.Transform:Find("SafeAreaContentPane/PanelLoading")
end

function XUiNewRoleShow:GetAutoKey(uiNode, eventName)
    if not uiNode then
        return
    end
    return eventName .. uiNode:GetHashCode()
end

function XUiNewRoleShow:RegisterListener(uiNode, eventName, func)
    local key = self:GetAutoKey(uiNode, eventName)
    if not key then
        return
    end
    local listener = self.AutoCreateListeners[key]
    if listener ~= nil then
        uiNode[eventName]:RemoveListener(listener)
    end

    if func ~= nil then
        if type(func) ~= "function" then
            XLog.Error("XUiNewRoleShow:RegisterListener: func is not a function")
        end

        listener = function(...)
            XSoundManager.PlayBtnMusic(self.SpecialSoundMap[key], eventName)
            func(self, ...)
        end

        uiNode[eventName]:AddListener(listener)
        self.AutoCreateListeners[key] = listener
    end
end

function XUiNewRoleShow:AutoAddListener()
    self.AutoCreateListeners = {}
    self:RegisterClickEvent(self.BtnClick, self.OnBtnClickClick)
end
-- auto

function XUiNewRoleShow:OnBtnClickClick(...)
    if self.CanClick then
        --CS.XUiManager.ViewManager:Pop()
        self:Close()
    end
end
