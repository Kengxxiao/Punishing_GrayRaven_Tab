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
    Item        = 1,    --道具
    Character   = 2,    --成员
    Weapon      = 3,    --武器
    Wafer       = 4,    --意识
    Medal       = 5,    
    Part        = 6,
    Fashion     = 7,    --时装
    BaseEquip   = 8,    --基地装备
    Furniture   = 9,    --家具
    HeadPortrait = 10,  --头像
    DormCharacter = 11,  --宿舍构造体
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

