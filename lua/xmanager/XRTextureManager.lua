XRTextureManager = XRTextureManager or {}


local RTextureCahe = nil


function XRTextureManager.SetTextureCahe(rtImg)
    --if not RTextureCahe then
    --    local screenWid = CS.XUiManager.RealScreenWidth
    --    local screenHei = CS.XUiManager.RealScreenHeight
    --    RTextureCahe = CS.UnityEngine.RenderTexture(screenWid,screenHei,24)
    --    RTextureCahe.antiAliasing = 2
    --end
    --XRTextureManager.SetCamerRT()
    --rtImg.texture = RTextureCahe
    --rtImg.gameObject:SetActive(true)
    
    rtImg.gameObject:SetActive(false)
end

function XRTextureManager.ClearCamerRT()
    --local cameraRest = CS.XUiManager.UiModelCamera
    --cameraRest.targetTexture = nil
end

function XRTextureManager.SetCamerRT()
    --local cameraRest = CS.XUiManager.UiModelCamera
    --cameraRest.targetTexture = RTextureCahe
end

function XRTextureManager.DeleteTextureCahe()
    if not RTextureCahe then return end
    RTextureCahe = nil
end