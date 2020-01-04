XFriend = XClass()

local Default = {
    FriendId = 0,
    NickName = "",
    Icon = 0,
    Level = 0,
    Sign = "",
    IsOnline = false,
    LastLoginTime = 0,
    FriendExp = 0,
}

function XFriend:Ctor(friendId, createTime)
    for key in pairs(Default) do
        self[key] = Default[key]
    end

    self.FriendId = friendId
    self.CreateTime = createTime
end

function XFriend:Update(playerInfo)
    self.FriendId = playerInfo.Id
    self.NickName = playerInfo.Name
    self.Icon = playerInfo.CurrHeadPortraitId
    self.Level = playerInfo.Level
    self.Sign = playerInfo.Sign
    self.IsOnline = playerInfo.IsOnline
    self.LastLoginTime = playerInfo.LastLoginTime
    self.FriendExp = playerInfo.FriendExp
    self.CurrMedalId = playerInfo.CurrMedalId
end