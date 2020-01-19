local XUiMain = XLuaUiManager.Register(XLuaUi, "UiMain")

local CameraIndex = {
    Main = 1,
    MainEnter = 2,
    MainChatEnter = 3,
}

function XUiMain:OnAwake(...)
    --BDC
    CS.XHeroBdcAgent.BdcIntoGame(CS.UnityEngine.Time.time)

    self.RightTop =     XUiMainRightTop.New(self)           --右上角组件（资源、电量、时间、设置、邮件……）
    self.RightMid =     XUiMainRightMid.New(self)           --右中角组件（各种功能……）
    self.RightBottom =  XUiMainRightBottom.New(self)        --右下角组件（各个大功能入口……）
    self.LeftTop =      XUiMainLeftTop.New(self)            --左上角组件（玩家信息……）
    self.LeftMid =      XUiMainLeftMid.New(self)            --左中角组件（自动战斗、过期提醒……）
    self.LeftBottom =   XUiMainLeftBottom.New(self)         --左下角组件（公告、好友、福利、AD、聊天……）
    self.Other =        XUiMainOther.New(self)              --其他组件（角色触摸、截图……）
end

function XUiMain:OnStart(...)
    self:InitSceneRoot() --设置摄像机
end

function XUiMain:OnEnable()
    if XLoginManager.IsFirstOpenMainUi() then
        self:SetBtnWelfareTagActive(false)
        self:UpdateCamera(CameraIndex.MainEnter)
    else
        self:UpdateCamera(CameraIndex.Main)
    end

    self:PlayEnterAnim()
    XRedPointManager.AutoReleseRedPointEvent()
    self.LeftTop:OnEnable()
    self.LeftMid:OnEnable()
    self.LeftBottom:OnEnable()
    self.RightMid:OnEnable()
    self.RightTop:OnEnable()
    self.RightBottom:OnEnable()
    self.Other:OnEnable()
    self:SetCacheFight()
    self:SetScreenAdaptorCache()
end

function XUiMain:OnDisable()
    self.LeftTop:OnDisable()
    self.LeftMid:OnDisable()
    self.LeftBottom:OnDisable()
    self.RightMid:OnDisable()
    self.Other:OnDisable()
end

function XUiMain:OnDestroy(delete)
    self.LeftBottom:OnDestroy()
    self.Other:OnDestroy()
    self.RightTop:OnDestroy()
end

function XUiMain:OnNotify(evt, ...)
    if evt == XEventId.EVENT_CHAT_OPEN then
        --打开聊天界面
        self:PlayMainChatIn()
    elseif evt == XEventId.EVENT_CHAT_CLOSE then
        --聊天界面关闭
        self:PlayMainChatOut()
    end
    self.LeftBottom:OnNotify(evt)
    self.RightMid:OnNotify(evt)
end

function XUiMain:OnGetEvents()
    return { 
        XEventId.EVENT_CHAT_OPEN,
        XEventId.EVENT_CHAT_CLOSE,
        XEventId.EVENT_NOTICE_PIC_CHANGE,
        XEventId.EVENT_NOTICE_STATUS_CHANGE,
        XEventId.EVENT_TASKFORCE_INFO_NOTIFY,
        XEventId.EVENT_ACTIVITY_MAINLINE_STATE_CHANGE}
end

--初始化摄像机
function XUiMain:InitSceneRoot()
    local root = self:GetSceneRoot().transform

    self.CameraFar = {
        [CameraIndex.Main] = root:FindTransform("CamFarMain"),
        [CameraIndex.MainEnter] = root:FindTransform("CamFarMainEnter"),
        [CameraIndex.MainChatEnter] = root:FindTransform("CamFarMainChatEnter"),
    }
    self.CameraNear = {
        [CameraIndex.Main] = root:FindTransform("CamNearMain"),
        [CameraIndex.MainEnter] = root:FindTransform("CamNearMainEnter"),
        [CameraIndex.MainChatEnter] = root:FindTransform("CamNearMainChatEnter"),
    }
end

function XUiMain:UpdateCamera(camera)
    for _, cameraIndex in pairs(CameraIndex) do
        self.CameraNear[cameraIndex].gameObject:SetActive(cameraIndex == camera)
        self.CameraFar[cameraIndex].gameObject:SetActive(cameraIndex == camera)
    end
end

--播放主界面打开动画
function XUiMain:PlayEnterAnim()
    local anim, endCb
    if XLoginManager.IsFirstOpenMainUi() then
        anim = "AnimEnter"
    else
        anim = "AnimReenter"
    end
    XLuaUiManager.SetMask(true)
    endCb = function()
        if XLoginManager.IsFirstOpenMainUi() then
            anim = "AnimEnter2"
            self:PlayAnimation(anim, endCb)
            self:UpdateCamera(CameraIndex.Main)
            XLoginManager.SetFirstOpenMainUi(false)
        else
            XLoginManager.SetStartGuide(true)
            XEventManager.DispatchEvent(XEventId.EVENT_CARD_REFRESH_WELFARE_BTN)
            XEventManager.DispatchEvent(XEventId.EVENT_MAINUI_ENABLE)
            XLuaUiManager.SetMask(false)
        end
    end
    self:PlayAnimation(anim, endCb)
end

--播放关闭聊天动画
function XUiMain:PlayMainChatOut()
    self:UpdateCamera(CameraIndex.Main)
    self:PlayAnimation("AnimChatIn")
end

--播放打开聊天动画
function XUiMain:PlayMainChatIn()
    self:UpdateCamera(CameraIndex.MainChatEnter)
    self:PlayAnimation("AnimChatOut")
end

function XUiMain:SetCacheFight()
    if not self.IsFirstSetFight then
        self.IsFirstSetFight = true
        XDataCenter.SetManager.SetAllyDamageByCache()
        XDataCenter.SetManager.SetAllyEffectByCache()
        XDataCenter.SetManager.SetOwnFontSizeByCache()
        XDataCenter.SetManager.SetDefaultFontSize()
        XDataCenter.SetManager.SetScreenOff()
    end
end

function XUiMain:SetScreenAdaptorCache()
    if XDataCenter.SetManager.IsAdaptorScreen() and not XTool.UObjIsNil(self.SafeAreaContentPane) then
        self.SafeAreaContentPane:UpdateSpecialScreenOff()
    end
end

-- 设置福利按钮特效可见性
function XUiMain:SetBtnWelfareTagActive(active)
    self.LeftBottom:SetBtnWelfareTagActive(active)
end