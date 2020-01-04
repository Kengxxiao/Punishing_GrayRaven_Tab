local QualityBgPath = {
    CS.XGame.ClientConfig:GetString("CommonBagWhite"),
    CS.XGame.ClientConfig:GetString("CommonBagGreed"),
    CS.XGame.ClientConfig:GetString("CommonBagBlue"),
    CS.XGame.ClientConfig:GetString("CommonBagPurple"),
    CS.XGame.ClientConfig:GetString("CommonBagGold"),
    CS.XGame.ClientConfig:GetString("CommonBagRed"),
    CS.XGame.ClientConfig:GetString("CommonBagRed"),
}

XArrangeConfigs = XArrangeConfigs or {}

XArrangeConfigs.Types = {
    Error       = 0,
    Item        = 1,
    Character   = 2,
    Weapon      = 3,
    Wafer       = 4,
    Medal       = 5,
    Part        = 6,
    Fashion     = 7,
    BaseEquip   = 8,
    Furniture   = 9,
    HeadPortrait = 10,
}

function XArrangeConfigs.GetType(id)
    return math.floor(id / 1000000) + 1
end

function XArrangeConfigs.GeQualityBgPath(quality)
    if not quality then
        XLog.Error("XArrangeConfigs.GeQualityBgPath error: quality is nil")
        return
    end
    return QualityBgPath[quality]
end

