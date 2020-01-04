XSetConfigs = XSetConfigs or {}
XSetConfigs.SelfNumKeyConfig = {
    SelfNumSmall = "SelfNumSmall",
    SelfNumMiddle = "SelfNumMiddle",
    SelfNumBig = "SelfNumBig",
}
XSetConfigs.SelfNumKeyIndexConfig = {
    [1] = 0,
    [2] = XSetConfigs.SelfNumKeyConfig.SelfNumSmall,
    [3] = XSetConfigs.SelfNumKeyConfig.SelfNumMiddle,
    [4] = XSetConfigs.SelfNumKeyConfig.SelfNumBig,
}

XSetConfigs.SelfNumEnum = {
    Close = 1,
    Small = 2,
    Middle = 3,
    Big = 4,
}

XSetConfigs.FriendNumEnum = {
    Close = 1,
    Open = 2,
}

XSetConfigs.FriendEffectEnum = {
    Close = 1,
    Open = 2,
}
XSetConfigs.SelfNum = "SelfNum"---自身伤害数字
XSetConfigs.FriendNum = "FriendNum"--队友伤害数字
XSetConfigs.FriendEffect = "FriendEffect"--队友特效
XSetConfigs.ScreenOff = "ScreenOff"
XSetConfigs.SelfNumSizes = {}

function XSetConfigs.Init()
    local key1 = XSetConfigs.SelfNumKeyConfig.SelfNumSmall
    local key2 = XSetConfigs.SelfNumKeyConfig.SelfNumMiddle
    local key3 = XSetConfigs.SelfNumKeyConfig.SelfNumBig
    XSetConfigs.SelfNumSizes[key1] = CS.XGame.ClientConfig:GetInt(key1) or 0
    XSetConfigs.SelfNumSizes[key2] = CS.XGame.ClientConfig:GetInt(key2) or 0
    XSetConfigs.SelfNumSizes[key3] = CS.XGame.ClientConfig:GetInt(key3) or 0
end