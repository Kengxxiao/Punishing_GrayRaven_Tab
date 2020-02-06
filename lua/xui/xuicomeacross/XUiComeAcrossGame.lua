local XUiComeAcrossGame = XLuaUiManager.Register(XLuaUi, "UiComeAcrossGame")
local XUiPanelGame = require("XUi/XUiComeAcross/XUiPanelGame")
local XUiPanelEliminateGame = require("XUi/XUiComeAcross/XUiPanelEliminateGame")
local XUiPanelComeAcrossReward = require("XUi/XUiComeAcross/XUiPanelComeAcrossReward")
local XUiPanelStart = require("XUi/XUiComeAcross/XUiPanelStart")

function XUiComeAcrossGame:OnAwake()
    self:InitAutoScript()
    self:Init()
end

function XUiComeAcrossGame:Init()
    self.ComeAcrossClickGame = XUiPanelGame.New(self.PanelGame,self)
    self.ComeAcrossEliminateGame = XUiPanelEliminateGame.New(self.PanelEliminateGame,self)
    self.ComeAcrossRewardPanel = XUiPanelComeAcrossReward.New(self.PanelComeAcrossReward,self)
    self.StartPanel = XUiPanelStart.New(self.PanelStart,self)

    self.CurGame = nil
    self.PanelStart.gameObject:SetActive(true)
    self.PanelComeAcrossReward.gameObject:SetActive(false)
    self.PanelGame.gameObject:SetActive(false)
    self.PanelEliminateGame.gameObject:SetActive(false)

    self.PanelMask.gameObject:SetActive(false)

    self.Timer = CS.XScheduleManager.ScheduleForever(function()
        self:Update()
    end, 0)
end


function XUiComeAcrossGame:OnStart(gameData)
    self.GameData = gameData
    local gameType = gameData.GameConfig.Type
    if gameType == ComeAcrossGameType.GAME_CLICK then
        self.CurGame = self.ComeAcrossClickGame
    else
        self.CurGame = self.ComeAcrossEliminateGame
    end

    local position = self.GameData.Position

    self.StartPanel:SetupContent(self.GameData)
    self:SetUiSprite(self.ImgBg,position.BgIcon)
    self.Transform:PlayLegacyAnimation("UiComeAcrossGameStartBegin")


end

function XUiComeAcrossGame:OnFinish(result)

    if not self.GameData then
        return
    end

    local finitshNum = 0
    for k,v in ipairs(result) do
        if v == 1 then
            finitshNum = finitshNum + 1
        end
    end

    XDataCenter.ComeAcrossManager.ReqTrustGameResultRequest(self.GameData.Character.Id,self.GameData.GameConfig.Id,finitshNum,function(res)
        self.PanelStart.gameObject:SetActive(true)
        self.PanelMask.gameObject:SetActive(false)
        self.CurGame.GameObject:SetActive(false)

        self.StartPanel:SetupResult()
    end)
end


function XUiComeAcrossGame:SetupReward()
    local result = XDataCenter.ComeAcrossManager.GetLastResult()
    if result then
        self.PanelComeAcrossReward.gameObject:SetActive(true)
        --XUiHelper.PlayAnimation(self, "UiComeAcrossGameRewardBegin")
        self.ComeAcrossRewardPanel:SetupReward(self.GameData,result)
    end
end

function XUiComeAcrossGame:OnEnable()
end


function XUiComeAcrossGame:OnDisable()
end


function XUiComeAcrossGame:OnDestroy()
    if self.Timer ~= nil then
        CS.XScheduleManager.UnSchedule(self.Timer)
        self.Timer = nil
    end
end


function XUiComeAcrossGame:OnNotify(evt,...)
end


function XUiComeAcrossGame:Update()
    local dt = CS.UnityEngine.Time.deltaTime
    if self.CurGame then
        self.CurGame:Update(dt)
    end
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiComeAcrossGame:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiComeAcrossGame:AutoInitUi()
    self.PanelStart = self.Transform:Find("Animator/FullScreenBackground/PanelStart")
    self.PanelGame = self.Transform:Find("Animator/FullScreenBackground/PanelGame")
    self.PanelComeAcrossReward = self.Transform:Find("Animator/FullScreenBackground/PanelComeAcrossReward")
    self.PanelMask = self.Transform:Find("Animator/FullScreenBackground/PanelMask")
    self.PanelEliminateGame = self.Transform:Find("Animator/FullScreenBackground/PanelEliminateGame")
    self.ImgBg = self.Transform:Find("Animator/FullScreenBackground/ImgBg"):GetComponent("Image")
end

function XUiComeAcrossGame:AutoAddListener()
end
-- auto

function XUiComeAcrossGame:OnBtnSelectClick(eventData)
    if not self.CurGame then
        return
    end

    self.PanelStart.gameObject:SetActive(false)
    self.PanelMask.gameObject:SetActive(true)
    self.CurGame.GameObject:SetActive(true)

    self.CurGame:SetupGameData(self.GameData)
    self.CurGame:Play()
  
end

function XUiComeAcrossGame:OnSliderFavorClick(eventData)

end