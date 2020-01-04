local camTrf
local camera
local bloom
local Type = {
    Default = 1,
    Draw = 2
}

local Init = function(transform)
    --camTrf = transform.root:Find("UiModelCamera")
    --camera = camTrf:GetComponent("Camera")
    --local ppb = camTrf:GetComponent("PostProcessingBehaviour")
    --local profile = ppb.profile
    --bloom = profile.bloomModel
end

local LoadSettings = function(type)
    -- local data = XDataCenter.DrawManager.GetDrawCamera(type)
    -- if not data then
    --     return
    -- end
    -- camera.allowHDR = data.AllowHDR
    -- local settings = bloom.settings
    -- local bloomSettings = settings.bloom
    -- bloomSettings.intensity = data.Intensity
    -- bloomSettings.threshold = data.Threshold
    -- bloomSettings.saturation = data.Saturation
    -- bloomSettings.softKnee = data.SoftKnee
    -- bloomSettings.radius = data.Radius
    -- bloomSettings.iterations = data.Iterations
    -- settings.bloom = bloomSettings
    -- bloom.settings = settings
end

local GetCameraTransform = function()
    return camTrf
end

local DrawCamera = {}

DrawCamera.Type = Type
DrawCamera.Init = Init
DrawCamera.LoadSettings = LoadSettings
DrawCamera.GetCameraTransform = GetCameraTransform

return DrawCamera