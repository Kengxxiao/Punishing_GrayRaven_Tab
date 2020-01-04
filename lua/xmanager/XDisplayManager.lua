XDisplayManagerCreator = function()

    local XDisplayManager = {}

    local DisplayTable = nil
    local ContentTable = nil
    local Groups = {}
    local CharDict = {}
    local CurDisplayChar
    local LoadStates = {}

    function XDisplayManager.Init()
        DisplayTable = XDisplayConfigs.GetDisplayTable()
        ContentTable = XDisplayConfigs.GetContentTable()
        Groups = XDisplayConfigs.GetGroups()
    end

    function XDisplayManager.InitDisplayCharId(id)
        XDisplayManager.GetCharDict()
        CurDisplayChar = CharDict[id]
    end

    function XDisplayManager.GetDisplayTable(id)
        local tab = DisplayTable[id]
        if not tab then
            XLog.Error("XDisplayManager.GetDisplayTable : can not find display table, id = " .. id)
        end
        return tab
    end

    function XDisplayManager.GetDisplayContentTable(id)
        local tab = ContentTable[id]
        if not tab then
            XLog.Error("XDisplayManager.GetDisplayTable : can not find display content table, id =" .. id)
        end
        return tab
    end

    function XDisplayManager.RandBehavior(modelName)
        local group = Groups[modelName]
        if not group then
            if not modelName then
                XLog.Error("XDisplayManager.RandContent : model name is nil.")
            else
                XLog.Error("XDisplayManager.RandContent : can not find display tables of [" .. modelName .. "].")
            end
            return
        end
        local index = XMath.RandByWeights(group.Weights)
        local id = group.Ids[index]
        if not id then
            XLog.Error("id is nil, model name = " .. modelName .. "index is " .. index)
            return
        end
        local displayTable = XDisplayManager.GetDisplayTable(id)
        local contentTable = XDisplayManager.GetDisplayContentTable(displayTable.ContentId)
        local result = {
            Action = displayTable.Action,
            Sound = contentTable.Sound,
            Text = contentTable.Text,
            Duration = contentTable.Duration,
        }
        return result
    end

    function XDisplayManager.SetDisplayCharById(id, callback)
        if id == XPlayer.DisplayCharId then
            return
        end

        local newChar = XDataCenter.CharacterManager.GetCharacter(id)
        if not newChar then
            return
        end

        XNetwork.Call("ChangePlayerDisplayCharIdRequest", { CharId = id }, function(res)
            if res.Code ~= XCode.Success then
                XUiManager.TipCode(res.Code)
                return
            end

            XDataCenter.SignBoardManager.ChangeDisplayCharacter(id)

            CurDisplayChar = newChar
            XPlayer.SetDisplayCharId(id)
            callback(id)
        end)
    end

    function XDisplayManager.GetCharDict()
        CharDict = {}
        local list = XDataCenter.CharacterManager.GetOwnCharacterList()
        for _, char in ipairs(list) do
            CharDict[char.Id] = char
        end
        return CharDict
    end

    function XDisplayManager.GetDisplayChar()
        if not CurDisplayChar then
            local charId = XPlayer.DisplayCharId
            CurDisplayChar = XDataCenter.CharacterManager.GetCharacter(charId)
        end
        return CurDisplayChar
    end

    function XDisplayManager.GetModelName(id)
        local character = XDataCenter.CharacterManager.GetCharacter(id)
        local quality
        if character then
            quality = character.Quality
        else
            quality = XCharacterConfigs.GetCharMinQuality(id)
        end
        return XDataCenter.CharacterManager.GetCharModel(id, quality)
    end

    -- 更换模型和加载展示状态机，完成后调用回调。
    function XDisplayManager.UpdateRoleModel(panelRoleModel, id, cb, fashionId)

        local state = {}

        -- 初始化信息
        LoadStates[panelRoleModel] = state
        state.Panel = panelRoleModel
        state.Id = id
        state.Callback = cb
        state.IsLoading = true
        state.ModelName = XDisplayManager.GetModelName(id)

        state.RerollData = function()
            state.RollData = XDisplayManager.RandBehavior(state.ModelName)
        end

        --获取时装ModelName
        local resourcesId
        if fashionId then
            resourcesId = XDataCenter.FashionManager.GetResourcesId(fashionId)
        else
            resourcesId = XDataCenter.FashionManager.GetFashionResouceIdByCharId(id)
        end

        local fashionModelName = nil

        if resourcesId then
            fashionModelName = XDataCenter.CharacterManager.GetCharResModel(resourcesId)
        else
            fashionModelName = self:GetModelName(id)
        end
        
        --获取Controller名字
        local modelConfig = XModelManager.GetModelTemplates(fashionModelName)
        if not modelConfig.DisplayControllerPath then
            XLog.Error("XDisplayManager.UpdateRoleModel() error: modelConfig.DisplayControllerPath = nil, modelName:" .. tostring(state.ModelName))
            return
        end
        state.RuntimeControllerName = modelConfig.DisplayControllerPath

        -- 更换模型
        local callback = function(model)
            state.Model = model
            state.Animator = state.Model:GetComponent("Animator")
            XDisplayManager.OnAssetLoaded(state)
        end
        panelRoleModel:UpdateCharacterModel(id, nil, XModelManager.MODEL_UINAME.XUiMain, callback, nil, fashionId)

        -- 加载animationController
        local runtimeController = CS.LoadHelper.LoadUiController(state.RuntimeControllerName, panelRoleModel.RefName)

        if runtimeController == nil or not runtimeController:Exist() then
            XLog.Error("XUiPanelDisplay RefreshSelf error: LoadUiAnimation name: " .. state.RuntimeControllerName)
            return
        end
        state.RunTimeController = runtimeController
        if not state.Model then
            return
        end
        XDisplayManager.OnAssetLoaded(state)

        -- 两个都OK的时候触发回调
        return state
    end

    function XDisplayManager.OnAssetLoaded(state)
        if XTool.UObjIsNil(state.Model) or XTool.UObjIsNil(state.RunTimeController) then
            return
        end
        state.Animator.runtimeAnimatorController = state.RunTimeController
        state.IsLoading = false
        if not state.Model.activeSelf then
            return
        end
        if state.Callback then
            state.Callback(state.Model)
        end
    end

    function XDisplayManager.PlayAnimation(panelRoleModel, animation)
        local state = LoadStates[panelRoleModel]
        if state.IsLoading or not state.Animator or not state.Model.activeSelf then
            return
        end
        state.Animator:SetTrigger(animation)
    end

    XDisplayManager.Init()
    return XDisplayManager
end