local XUiWaterMask = XLuaUiManager.Register(XLuaUi, "UiWaterMask")

function XUiWaterMask:OnAwake()
    self:InitUiObjects()
end

function XUiWaterMask:OnStart()
    
    self.TextId.text = XPlayer.Id

    if self.ObjectPool:Exist() then
        for i = 1, 50 do
            self.ObjectPool:Spawn()
        end
    end

end