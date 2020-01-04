XSceneResourceManager = XSceneResourceManager or {}

local ScenePoolRoot = nil
local ResourceMap = nil

-- 初始化
function XSceneResourceManager.InitPool()
    if XTool.UObjIsNil(ScenePoolRoot) then
        ScenePoolRoot = CS.UnityEngine.GameObject("ScenePoolRoot")
        ScenePoolRoot:SetActive(false)
        CS.UnityEngine.Object.DontDestroyOnLoad(ScenePoolRoot)
    end

    XSceneResourceManager.ClearPool()
    ResourceMap = {}
end

-- 出池
function XSceneResourceManager.GetGoFromPool(path)
    if not ResourceMap then
        ResourceMap = {}
    end

    local temp = ResourceMap[path]
    if not temp then
        temp = {}
        temp.Gos = {}
        ResourceMap[path] = temp
    end

    if not temp.Resource then
        temp.Resource = CS.XResourceManager.Load(path)
    end

    local go

    while (#temp.Gos > 0) do
        go = table.remove(temp.Gos, #temp.Gos)
        if not XTool.UObjIsNil(go) then
            go:SetActive(true)
            break
        end
    end

    if XTool.UObjIsNil(go) then
        go = CS.UnityEngine.Object.Instantiate(temp.Resource.Asset)
    end

    return go
end

-- 回池
function XSceneResourceManager.ReturnGoToPool(path, go)
    if XTool.UObjIsNil(go) then
        return
    end

    if not ResourceMap then
        ResourceMap = {}
    end

    local temp = ResourceMap[path]
    if not temp then
        temp = {}
        temp.Gos = {}
        ResourceMap[path] = temp
    end

    if not temp.Resource then
        CS.UnityEngine.GameObject.Destroy(go)
        return
    end

    go.transform:SetParent(ScenePoolRoot.transform, false)
    table.insert(temp.Gos, go)
end

-- 清池
function XSceneResourceManager.ClearPool()
    if ResourceMap then
        for _, v in pairs(ResourceMap) do
            -- 销毁GameObject
            if v.Gos then
                for _, go in ipairs(v.Gos) do
                    if not XTool.UObjIsNil(go) then
                        CS.UnityEngine.GameObject.Destroy(go)
                    end
                end
            end
            v.Gos = nil

            -- 释放资源
            if v.Resource then
                v.Resource:Release()
            end
        end
    end

    ResourceMap = nil
end