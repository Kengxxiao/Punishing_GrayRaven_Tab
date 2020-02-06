local XUiComeAcross = XLuaUiManager.Register(XLuaUi, "UiComeAcross")
local XUiGridLevel = require("XUi/XUiComeAcross/XUiGridLevel")

function XUiComeAcross:OnAwake()
    self:InitAutoScript()
    self:Init()
end

function XUiComeAcross:Init()
    self.GridLevel = {}
    for i = 1, 5, 1 do
        self.GridLevel[i] = XUiGridLevel.New(self["GridLevel_" .. i], self, i)
    end
end

function XUiComeAcross:OnStart(...)
    self:SetupContent()

    --XUiHelper.PlayAnimation(self, "AniComeAcrossBegin")
end

function XUiComeAcross:SetupContent()
    local games = XDataCenter.ComeAcrossManager.GetComeAcrossGames()
    for i = 1, 5, 1 do
        if games[i] then
            self.GridLevel[i]:SetGridLevelContent(games[i])
            self.GridLevel[i].GameObject:SetActive(true)
        else
            self.GridLevel[i].GameObject:SetActive(false)
        end
    end

    self:SetPlayTimes()
end



function XUiComeAcross:SetPlayTimes()
    local playTimes = XDataCenter.ComeAcrossManager.GetPlayCount()
    local totalTimes = CS.XGame.Config:GetInt("TrustGameCount")
    self.TxtTime.text = string.format("%s/%s", totalTimes - playTimes, totalTimes)
end


function XUiComeAcross:OnEnable()
    self:SetPlayTimes()
end

function XUiComeAcross:OnDisable()
end
  

function XUiComeAcross:OnDestroy()
end


function XUiComeAcross:OnGetEvents()
    return {
        XEventId.EVENT_COMEACROSS_PLAY,
        XEventId.EVENT_COMEACROSS_PLAYRESULT,
    }
end


function XUiComeAcross:OnNotify(evt, ...)
    self:SetupContent()
end

-- auto
-- Automatic generation of code, forbid to edit
function XUiComeAcross:InitAutoScript()
    self:AutoInitUi()
    self:AutoAddListener()
end

function XUiComeAcross:AutoInitUi()
    self.TxtTime = self.Transform:Find("Animator/SafeAreaContentPane/Text/TxtTime"):GetComponent("Text")
    self.BtnHelp = self.Transform:Find("Animator/SafeAreaContentPane/BtnHelp"):GetComponent("Button")
    self.PanelLevel = self.Transform:Find("Animator/SafeAreaContentPane/PanelLevel")
    self.GridLevel_1 = self.Transform:Find("Animator/SafeAreaContentPane/PanelLevel/GridLevel_1")
    self.GridLevel_2 = self.Transform:Find("Animator/SafeAreaContentPane/PanelLevel/GridLevel_2")
    self.GridLevel_3 = self.Transform:Find("Animator/SafeAreaContentPane/PanelLevel/GridLevel_3")
    self.GridLevel_4 = self.Transform:Find("Animator/SafeAreaContentPane/PanelLevel/GridLevel_4")
    self.GridLevel_5 = self.Transform:Find("Animator/SafeAreaContentPane/PanelLevel/GridLevel_5")
    self.BtnMainUi = self.Transform:Find("Animator/SafeAreaContentPane/Top/BtnMainUi"):GetComponent("Button")
    self.BtnBack = self.Transform:Find("Animator/SafeAreaContentPane/Top/BtnBack"):GetComponent("Button")
end

function XUiComeAcross:AutoAddListener()
    self:RegisterClickEvent(self.BtnHelp, self.OnBtnHelpClick)
    self:RegisterClickEvent(self.BtnMainUi, self.OnBtnMainUiClick)
    self:RegisterClickEvent(self.BtnBack, self.OnBtnBackClick)
end
-- auto
function XUiComeAcross:OnBtnHelpClick(eventData)
    XUiManager.DialogTip("", CS.XTextManager.GetText("ComeAcrossTips"), XUiManager.DialogType.OnlyClose);
end

function XUiComeAcross:OnBtnMainUiClick(eventData)
    XLuaUiManager.RunMain()
end

function XUiComeAcross:OnBtnBackClick(eventData)
    self:Close()
end