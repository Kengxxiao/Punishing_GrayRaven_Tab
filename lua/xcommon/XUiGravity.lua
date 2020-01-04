XUiGravity = XClass(XLuaBehaviour)
-- 范围（防止画面抖动）
local range = 0.01

function XUiGravity:Ctor(rootUi, ui, minX, maxX, minY, maxY)
    self.minX = minX
    self.maxX = maxX
    self.minY = minY
    self.maxY = maxY
    self.lastAttitude = CS.UnityEngine.Vector3.zero
    self.testV = 0
    self.testSpeed = 0.01
end

function XUiGravity:Start()
    CS.UnityEngine.Input.gyro.enabled = true
end

function XUiGravity:Update()
    self.testV = self.testV + self.testSpeed
    if self.testV > 1 then
        self.testSpeed = -0.01
    elseif self.testV < -1 then
        self.testSpeed = 0.01
    end
    local transform = self.Transform
    -- local attitude = CS.UnityEngine.Vector3(CS.UnityEngine.Input.gyro.attitude.x, CS.UnityEngine.Input.gyro.attitude.y, 0)
    local attitude = CS.UnityEngine.Vector3(self.testV, 0, 0)
    --使安全范围内 - 1之1
    attitude.x = XMath.Clamp(attitude.x, -1, 1);
    attitude.y = XMath.Clamp(attitude.y, -1, 1);

    local x = transform.localPosition.x
    local y = transform.localPosition.y

    local isDirty = false
    if math.abs(self.lastAttitude.x - attitude.x) >= range then
        isDirty = true
        local direction = attitude.x - self.lastAttitude.x
        local position = direction * (self.maxX - self.minX) / 2
        x = XMath.Clamp(transform.localPosition.x - position, self.minX, self.maxX);
        self.lastAttitude = attitude
    end
    if math.abs(self.lastAttitude.y - attitude.y) >= range then
        isDirty = true
        local direction = attitude.y - self.lastAttitude.y
        local position = direction * (self.maxY - self.minY) / 2
        y = XMath.Clamp(transform.localPosition.y - position, self.minY, self.maxY);
        self.lastAttitude = attitude
    end
    if isDirty then
        transform.localPosition = CS.UnityEngine.Vector3(x, y, transform.localPosition.z);
    end
end

return XUiGravity