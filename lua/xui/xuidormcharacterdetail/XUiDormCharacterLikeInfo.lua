local XUiGridLikeInfo = require("XUi/XUiDormCharacterDetail/XUiGridLikeInfo")

local XUiDormCharacterLikeInfo = XLuaUiManager.Register(XLuaUi, "UiDormCharacterLikeInfo")

function XUiDormCharacterLikeInfo:OnAwake()
    self:AutoAddListener()
end

function XUiDormCharacterLikeInfo:OnStart(characterId)
    self.CharacterId = characterId
    self:Init()
end

function XUiDormCharacterLikeInfo:OnEnable()
    self:PlayAnimation("LikeInfoEnable")
end

function XUiDormCharacterLikeInfo:OnDisable()
    self:PlayAnimation("LikeInfoDisable")
end

function XUiDormCharacterLikeInfo:AutoAddListener()
    self:RegisterClickEvent(self.BtnClose, self.OnBtnCloseClick)
end

function XUiDormCharacterLikeInfo:OnBtnCloseClick(...)
    self:Close()
end

function XUiDormCharacterLikeInfo:Init()
    local recoveryConfigs = XDormConfig.GetCharRecoveryConfig(self.CharacterId)
    self.GridLikeInfo.gameObject:SetActive(false)

    for i = 1, #recoveryConfigs do
        local grid = CS.UnityEngine.Object.Instantiate(self.GridLikeInfo)
        local gridLikeInfo = XUiGridLikeInfo.New(grid, self)
        gridLikeInfo:Refresh(recoveryConfigs[i])
        grid.transform:SetParent(self.PanelRecycle, false)
        gridLikeInfo.GameObject:SetActive(true)
    end
end