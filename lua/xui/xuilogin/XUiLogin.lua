local XUiLogin = XLuaUiManager.Register(XLuaUi, "UiLogin")

local HasRequestNotice = false

function XUiLogin:OnAwake()
    self:InitAutoScript()
    self.GridServer.gameObject:SetActive(false)

    self.PanelLogin.gameObject:SetActive(true)
    self.PanelServerList.gameObject:SetActive(false)
    self.ServerList = {}
    self.SyncServer = false

    self.VerificationWaitInterval = CS.XGame.ClientConfig:GetInt("VerificationWaitInterval")
    self.SyncServerListInterval = CS.XGame.ClientConfig:GetInt("SyncServerListInterval")
    self.TxtNewVersion.text = CS.XRemoteConfig.DocumentVersion .. " (DocumentVersion)"
    self.TxtOldVersion.text = CS.XRemoteConfig.ApplicationVersion .. " (ApplicationVersion)"

    self:InitServerList()

    self.TxtUser.text = XUserManager.UserName

    XEventManager.BindEvent(self.TxtUser, XEventId.EVENT_USERNAME_CHANGE, function(userName)
        self.TxtUser.text = userName
    end)

end

function XUiLogin:OnStart(...)
    if self.BlackMask then
        self.BlackMask.color = CS.UnityEngine.Color(0.0, 0.0, 0.0, 0.0)
        self.BlackMask.gameObject:SetActive(false)
    end
    self.BtnLoginNotice.gameObject:SetActive(false)

    self:RequestLoginNotice()

    CS.XAudioManager.PlayMusic(CS.XAudioManager.LOGIN_BGM)

    self:ShowLoginPanel()
    
    self.GameObject:ScheduleOnce(function()
        --释放启动界面的资源
        CS.UnityEngine.Resources.UnloadUnusedAssets()
    end,100)
end

function XUiLogin:ShowLoginPanel()
    self.PanelLogin.gameObject:SetActive(true)
    self.PanelServerList.gameObject:SetActive(false)
end

function XUiLogin:ShowActivatePanel()
    self.PanelActivate.gameObject:SetActive(true)
end

function XUiLogin:HideActivatePanel()
    self.PanelActivate.gameObject:SetActive(false)
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiLogin:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiLogin:AutoInitUi()
    self.PanelLogin = self.Transform:Find("SafeAreaContentPane/PanelLogin")
    self.TogPlayOp = self.Transform:Find("SafeAreaContentPane/PanelLogin/TogPlayOp"):GetComponent("Toggle")
    self.BtnStart = self.Transform:Find("SafeAreaContentPane/PanelLogin/BtnStart"):GetComponent("Button")
    self.ImgStart = self.Transform:Find("SafeAreaContentPane/PanelLogin/BtnStart/ImgStart"):GetComponent("Image")
    self.PanelLoginServer = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelLoginServer")
    self.BtnServer = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelLoginServer/BtnServer"):GetComponent("Button")
    self.PanelMaintain = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelLoginServer/BtnServer/PanelMaintain")
    self.TxtName = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelLoginServer/BtnServer/PanelMaintain/TxtName"):GetComponent("Text")
    self.PanelLow = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelLoginServer/BtnServer/PanelLow")
    self.TxtNameA = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelLoginServer/BtnServer/PanelLow/TxtName"):GetComponent("Text")
    self.PanelHigh = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelLoginServer/BtnServer/PanelHigh")
    self.TxtNameB = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelLoginServer/BtnServer/PanelHigh/TxtName"):GetComponent("Text")
    self.PanelUser = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelUser")
    self.BtnUser = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelUser/BtnUser"):GetComponent("Button")
    self.TxtUser = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelUser/BtnUser/TxtUser"):GetComponent("Text")
    self.TxtNewVersion = self.Transform:Find("SafeAreaContentPane/PanelLogin/TxtNewVersion"):GetComponent("Text")
    self.ImgStart1 = self.Transform:Find("SafeAreaContentPane/PanelLogin/ImgStart1"):GetComponent("Image")
    self.PanelServerList = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelServerList")
    self.PanelServer = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelServerList/PanelServer")
    self.SViewServer = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelServerList/PanelServer/SViewServer"):GetComponent("ScrollRect")
    self.PanelServerContent = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelServerList/PanelServer/SViewServer/Viewport/PanelServerContent")
    self.GridServer = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelServerList/PanelServer/SViewServer/Viewport/PanelServerContent/GridServer")
    self.BtnHideServerList = self.Transform:Find("SafeAreaContentPane/PanelLogin/PanelServerList/PanelServer/BtnHideServerList"):GetComponent("Button")
    self.TxtOldVersion = self.Transform:Find("SafeAreaContentPane/PanelLogin/TxtOldVersion"):GetComponent("Text")
    self.ImgLogo = self.Transform:Find("SafeAreaContentPane/ImgLogo"):GetComponent("Image")
    self.BtnLoginNotice = self.Transform:Find("SafeAreaContentPane/BtnLoginNotice"):GetComponent("Button")
end

function XUiLogin:AutoAddListener()
    self:RegisterClickEvent(self.TogPlayOp, self.OnTogPlayOpClick)
    self:RegisterClickEvent(self.BtnStart, self.OnBtnStartClick)
    self:RegisterClickEvent(self.BtnServer, self.OnBtnServerClick)
    self:RegisterClickEvent(self.BtnUser, self.OnBtnUserClick)
    self:RegisterClickEvent(self.BtnHideServerList, self.OnBtnHideServerListClick)
    self:RegisterClickEvent(self.BtnLoginNotice, self.OnBtnLoginNoticeClick)
end
-- auto
function XUiLogin:OnBtnLoginNoticeClick(eventData)
    XDataCenter.NoticeManager.OpenLoginNotice()
end

function XUiLogin:OnTogPlayOpClick(eventData)

end

function XUiLogin:OnTogPlayOpValueChanged(...)

end

function XUiLogin:OnBtnHideServerListClick(...)
    self.PanelServerList.gameObject:SetActive(false)
end

function XUiLogin:DoLogin(...)
    if self.IsLoginingGameServer then
        return
    end
    self.IsLoginingGameServer = true

    XLuaUiManager.SetAnimationMask(true)
    XLog.Debug("login ui: do login open mask.")
    local loginProfiler = CS.XProfiler.Create("login")
    loginProfiler:Start()
    XLoginManager.Login(function(code)
        XLog.Debug("login ui: do login close mask.")
        XLuaUiManager.SetAnimationMask(false)
        if code and code ~= XCode.Success then
            if code == XCode.LoginServiceInvalidToken then
                XUserManager.ClearLoginData()
                XUserManager.ShowLogin()
            end

            self.IsLoginingGameServer = false
            return
        end

        CS.XAudioManager.PlayMusic(CS.XAudioManager.MAIN_BGM)

        local runMainProfiler = loginProfiler:CreateChild("RunMain")
        runMainProfiler:Start()

        --BDC
        CS.XHeroBdcAgent.BdcAfterSdkLoginPage()

        XDataCenter.PurchaseManager.YKInfoDataReq(function()
            if self.BlackMask then
                self.BlackMask.color = CS.UnityEngine.Color(0.0, 0.0, 0.0, 0.0)
                self.BlackMask.gameObject:SetActive(true)
                self.BlackMask:DOFade(1.1, 0.3):OnComplete(function()
                    local guideFight = XDataCenter.GuideManager.GetNextGuideFight()
                    if guideFight then
                        self:Close()

                        local movieId = CS.XGame.ClientConfig:GetInt("NewUserMovieId")

                        CS.Movie.XMovieManager.Instance:PlayById(movieId, function()
                            XDataCenter.FubenManager.EnterGuideFight(guideFight.Id, guideFight.StageId, guideFight.NpcId, guideFight.Weapon)
                        end)
                    else
                        XLoginManager.SetFirstOpenMainUi(true)
                        XLuaUiManager.RunMain()
                    end
                end)
            else
                local guideFight = XDataCenter.GuideManager.GetNextGuideFight()
                if guideFight then
                    self:Close()
                    local movieId = CS.XGame.ClientConfig:GetInt("NewUserMovieId")
                    CS.Movie.XMovieManager.Instance:PlayById(movieId, function()
                        XDataCenter.FubenManager.EnterGuideFight(guideFight.Id, guideFight.StageId, guideFight.NpcId, guideFight.Weapon)
                    end)
                else
                    XLoginManager.SetFirstOpenMainUi(true)
                    XLuaUiManager.RunMain()
                end
            end
        end)

        runMainProfiler:Stop()

        loginProfiler:Stop()
        XLog.Debug(loginProfiler)
    end)
end

function XUiLogin:OnBtnServerClick(...)
    self.PanelServerList.gameObject:SetActive(true)
end

function XUiLogin:OnBtnUserClick(...)
    if self.IsLoginingGameServer then
        return
    end

    if self.IsLogoutingAccount then
        return
    end

    self.IsLogoutingAccount = true
    XUserManager.Logout(function()
        self.IsLogoutingAccount = false
    end)
end

function XUiLogin:OnBtnStartClick(...)
    if not self.IsRequestNotice then
        return
    end

    if XLuaUiManager.IsUiShow("UiLoginNotice") then
        return
    end

    if self.IsLogoutingAccount then
        return
    end

    if XUserManager.IsNeedLogin() then
        XUserManager.ShowLogin()
        return
    end

    self:DoLogin()
end

function XUiLogin:UpdateSelectServer(server)
    self.PanelMaintain.gameObject:SetActive(false)
    self.PanelLow.gameObject:SetActive(false)
    self.PanelHigh.gameObject:SetActive(false)

    self.PanelMaintain:Find("TxtName"):GetComponent("Text").text = server.Name
    self.PanelLow:Find("TxtName"):GetComponent("Text").text = server.Name
    self.PanelHigh:Find("TxtName"):GetComponent("Text").text = server.Name

    if server.State == XServerManager.SERVER_STATE.MAINTAIN then
        self.PanelMaintain.gameObject:SetActive(true)
    elseif server.State == XServerManager.SERVER_STATE.LOW then
        self.PanelLow.gameObject:SetActive(true)
    elseif server.State == XServerManager.SERVER_STATE.GIGH then
        self.PanelHigh.gameObject:SetActive(true)
    else
        XLog.Error("XUiGridServer:UpdateServerState error: unknown state ui, server id is " .. server.Id .. ", state is " .. server.State)
    end
    --self.PanelLow.gameObject:SetActive(true)
end

function XUiLogin:StopSyncServerList()
    if self.SyncServerTimer then
        CS.XScheduleManager.UnSchedule(self.SyncServerTimer)
        self.SyncServer = false
        self.SyncServerTimer = null
    end
end

function XUiLogin:UpdateServerListSelect()
    for _, server in pairs(self.ServerList) do
        server:UpdateServerSelect()
    end
end

function XUiLogin:SyncServerList(cb)
    if not self.SyncServer then
        self.SyncServer = true
        self.SyncServerTimer = CS.XScheduleManager.ScheduleForever(function(...)
            self:SyncServerList()
        end, self.SyncServerListInterval, 0)
    end

    local baseGrid = self.GridServer
    XServerManager.GetServerData(function(serverData)
        XTool.LoopMap(serverData.ServerTable, function(key, value)
            if value.Id == XServerManager.Id then
                self:UpdateSelectServer(value)
            end

            if self.ServerList[value.Id] then
                self.ServerList[value.Id]:UpdateServer(value)
            else
                local serverGrid = XUiGridServer.New(CS.UnityEngine.Object.Instantiate(baseGrid), value, function()
                    XServerManager.Select(value)
                    self:UpdateSelectServer(value)
                    self:UpdateServerListSelect()
                    self.PanelServerList.gameObject:SetActive(false)
                end)

                serverGrid.Transform:SetParent(self.PanelServerContent, false)
                serverGrid.GameObject:SetActive(true)
                self.ServerList[value.Id] = serverGrid
            end
        end)

        if cb then
            cb()
        end
    end)
end

function XUiLogin:InitServerList()
    local list = XServerManager.GetServerList()

    if list then
        self.BtnServer.gameObject:SetActiveEx(#list > 1)
    end

    for _, server in pairs(list) do
        local serverGrid = XUiGridServer.New(CS.UnityEngine.Object.Instantiate(self.GridServer), server, function()
            XServerManager.Select(server)
            self:UpdateSelectServer(server)
            self:UpdateServerListSelect()
            self.PanelServerList.gameObject:SetActive(false)
        end)

        serverGrid.Transform:SetParent(self.PanelServerContent, false)
        serverGrid.GameObject:SetActive(true)
        self.ServerList[server.Id] = serverGrid
    end

    self:UpdateSelectServer(list[XServerManager.Id])
end

function XUiLogin:RequestLoginNotice()
    CS.XUiManager.Instance:SetAnimationMask(true)
    XLog.Debug("login ui: request notice to open mask.")
    XDataCenter.NoticeManager.RequestLoginNotice(function(invalid)
        self.IsRequestNotice = true
        CS.XUiManager.Instance:SetAnimationMask(false)
        XLog.Debug("login ui: request notice to close mask.")
        if not XTool.UObjIsNil(self.BtnLoginNotice) then 
            self.BtnLoginNotice.gameObject:SetActive(invalid)
        end
    end)
end