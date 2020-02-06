
XFunctionalSkipManagerCreator = function()
    local XFunctionalSkipManager = {}
    local DormDrawGroudId = CS.XGame.ClientConfig:GetInt("DormDrawGroudId")

    -- 跳转打开界面选择标签页类型6
    function XFunctionalSkipManager.SkipSystemWidthArgs(skipDatas)
        if not skipDatas then return end
        local param1 = (skipDatas.CustomParams[1] ~= 0) and skipDatas.CustomParams[1] or nil
        local param2 = (skipDatas.CustomParams[2] ~= 0) and skipDatas.CustomParams[2] or nil
        local param3 = (skipDatas.CustomParams[3] ~= 0) and skipDatas.CustomParams[3] or nil

        if skipDatas.UiName == "UiTask" and XLuaUiManager.IsUiShow("UiTask") then
            XEventManager.DispatchEvent(XEventId.EVENT_TASK_TAB_CHANGE, param1)
        elseif skipDatas.UiName == "UiActivityBriefBase" and  XLuaUiManager.IsUiShow("UiActivityBriefBase") then
            XEventManager.DispatchEvent(XEventId.EVENT_BRIEF_CHANGE_TAB, param1)
        else
            XLuaUiManager.Open(skipDatas.UiName, param1, param2, param3)
        end
    end

    -- 跳转副本类型7
    function XFunctionalSkipManager.SkipCustom(skipDatas)
        if not skipDatas then return end

        if XFunctionalSkipManager[skipDatas.UiName] then
            XFunctionalSkipManager[skipDatas.UiName](skipDatas)
        end
    end

    -- 跳转宿舍类型8
    function XFunctionalSkipManager.SkipDormitory(skipDatas)
        if not skipDatas or not XPlayer.Id then return end

        if XFunctionalSkipManager[skipDatas.UiName] then
            XFunctionalSkipManager[skipDatas.UiName](skipDatas)
        end
    end
    
    -- 前往宿舍房间
    function  XFunctionalSkipManager.SkipDormRoom(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or nil
        -- 该房间未激活
        if (param1 == nil) or (not XDataCenter.DormManager.IsDormitoryActive(param1)) then
            if not XHomeDormManager.InDormScene() then
                XHomeDormManager.EnterDorm(XPlayer.Id, nil, false)
            end
            return
        end

        -- 房间已激活
        if XHomeDormManager.InDormScene() then

            if not XHomeDormManager.IsInRoom(param1) then

                if not XLuaUiManager.IsUiShow("UiDormSecond") then
                    XLuaUiManager.Open("UiDormSecond", XDormConfig.VisitDisplaySetType.MySelf, param1)
                else
                    XEventManager.DispatchEvent(XEventId.EVENT_DORM_SKIP, param1)
                end
                
                XHomeDormManager.SetSelectedRoom(param1, true)
            else
                if XLuaUiManager.IsUiShow("UiDormTask") then
                    XLuaUiManager.Close("UiDormTask")
                end
            end
        else
            XHomeDormManager.EnterDorm(XPlayer.Id, nil, false, function()

                if not XLuaUiManager.IsUiShow("UiDormSecond") then
                    XLuaUiManager.Open("UiDormSecond", XDormConfig.VisitDisplaySetType.MySelf, param1)
                else
                    XEventManager.DispatchEvent(XEventId.EVENT_DORM_SKIP, param1)
                end

                XHomeDormManager.SetSelectedRoom(param1, true)

            end)
        end
    end

    -- 前往宿舍主界面
    function XFunctionalSkipManager.SkipDormMain(list)

        if XLuaUiManager.IsUiLoad("UiDormTask") then
            XLuaUiManager.Remove("UiDormTask")
        end

        if not XHomeDormManager.InDormScene() then
            XHomeDormManager.EnterDorm(XPlayer.Id, nil, false)
        elseif XHomeDormManager.InAnyRoom() then
            local roomId = XHomeDormManager.GetCurrentRoomId()
            if roomId then
                XHomeDormManager.SetSelectedRoom(roomId, false)

                if XLuaUiManager.IsUiLoad("UiDormSecond") then
                    XLuaUiManager.Remove("UiDormSecond")
                end

            end
        end
        XLuaUiManager:ShowTopUi()
    end

    -- 前往宿舍访问
    function XFunctionalSkipManager.SkipDormVisit(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or 1
        if XHomeDormManager.InDormScene() then
            XLuaUiManager.Open("UiDormVisit", nil, param1)
        else
            XHomeDormManager.EnterDorm(XPlayer.Id, nil, false, function()
                XLuaUiManager.Open("UiDormVisit", nil, param1)
            end)
        end
    end

    -- 前往宿舍任务
    function XFunctionalSkipManager.SkipDormTask(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or 1
        if XHomeDormManager.InDormScene() then
            XLuaUiManager.Open("UiDormTask", param1)
        else
            XHomeDormManager.EnterDorm(XPlayer.Id, nil, false, function()
                XLuaUiManager.Open("UiDormTask", param1)
            end)
        end
    end

    -- 前往宿舍仓库界面
    function XFunctionalSkipManager.SkipDormWarehouse(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or 1
        if XHomeDormManager.InDormScene() then
            XLuaUiManager.Open("UiDormBag", param1)
        else
            XHomeDormManager.EnterDorm(XPlayer.Id, nil, false, function()
                XLuaUiManager.Open("UiDormBag", param1)
            end)
        end
    end

    -- 前往宿舍成员界面
    function XFunctionalSkipManager.SkipDormMember(list)
        if XHomeDormManager.InDormScene() then
            XLuaUiManager.Open("UiDormPerson")
        else
            XHomeDormManager.EnterDorm(XPlayer.Id, nil, false, function()
                XLuaUiManager.Open("UiDormPerson")
            end)
        end
    end

    -- 前往宿舍打工界面
    function XFunctionalSkipManager.SkipDormWork(list)
        if XHomeDormManager.InDormScene() then
            XLuaUiManager.Open("UiDormWork")
        else
            XHomeDormManager.EnterDorm(XPlayer.Id, nil, false, function()
                XLuaUiManager.Open("UiDormWork")
            end)
        end
    end

    -- 前往宿舍商店界面
    function XFunctionalSkipManager.SkipDormShop(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1]
        if XHomeDormManager.InDormScene() then
            XLuaUiManager.Open("UiShop", XShopManager.ShopType.Dorm, nil, param1)
        else
            XHomeDormManager.EnterDorm(XPlayer.Id, nil, false, function()
                XLuaUiManager.Open("UiShop", XShopManager.ShopType.Dorm, nil, param1)
            end)
        end
    end
    
    -- 前往宿舍研发界面
    function XFunctionalSkipManager.SkipDormDraw(list)
        if XHomeDormManager.InDormScene() then
            XDataCenter.DrawManager.GetDrawGroupList(
                function()
                    local info = XDataCenter.DrawManager.GetDrawGroupInfoByGroupId(DormDrawGroudId)
                    if not info then return end
                    XDataCenter.DrawManager.GetDrawInfoList(DormDrawGroudId, function()
                        XLuaUiManager.Open("UiDraw", DormDrawGroudId, function()
                            XHomeSceneManager.ResetToCurrentGlobalIllumination()
                        end, info.UiBackGround)
                    end)
                end
            )
        else
            XHomeDormManager.EnterDorm(XPlayer.Id, nil, false, function()
                XDataCenter.DrawManager.GetDrawGroupList(
                    function()
                        local info = XDataCenter.DrawManager.GetDrawGroupInfoByGroupId(DormDrawGroudId)
                        if not info then return end
                        XDataCenter.DrawManager.GetDrawInfoList(DormDrawGroudId, function()
                            XLuaUiManager.Open("UiDraw", DormDrawGroudId, function()
                                XHomeSceneManager.ResetToCurrentGlobalIllumination()
                            end, info.UiBackGround)
                        end)
                    end
                )
            end)
        end
    end

    -- 前往宿舍建造界面
    function XFunctionalSkipManager.SkipDormFurnitureBuild(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or 1
        if XHomeDormManager.InDormScene() then
            XLuaUiManager.Open("UiFurnitureBuild", param1)
        else
            XHomeDormManager.EnterDorm(XPlayer.Id, nil, false, function()
                XLuaUiManager.Open("UiFurnitureBuild", param1)
            end)
        end
    end

    -- 前往巴别塔
    function XFunctionalSkipManager.OnOpenBabelTower(list)
        if not XFunctionManager.DetectionFunction(XFunctionManager.FunctionName.BabelTower) then
            return
        end
        
        local currentActivityNo = XDataCenter.FubenBabelTowerManager.GetCurrentActivityNo()
        if not currentActivityNo or not XDataCenter.FubenBabelTowerManager.IsInActivityTime(currentActivityNo) then
            XUiManager.TipMsg(CS.XTextManager.GetText("BabelTowerNoneOpen"))
            return
        end

        XLuaUiManager.Open("UiBabelTowerMainNew")
    end

    -- 前往赏金任务
    function XFunctionalSkipManager.OnOpenUiMoneyReward(list)
       -- XDataCenter.BountyTaskManager.SetBountyTaskLastLoginTime()
        XDataCenter.BountyTaskManager.SetBountyTaskLastRefreshTime()
        XLuaUiManager.Open("UiMoneyReward")
    end

    -- 前往协同作战
    function XFunctionalSkipManager.OnOpenUiOnlineBoss(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or 1
        XDataCenter.FubenBossOnlineManager.OpenBossOnlineUi(param1)
    end

    -- 被感染的守林人
    function XFunctionalSkipManager.OnOpenUiActivityBranch(list)

        -- 开启时间限制
        if not XDataCenter.FubenActivityBranchManager.IsOpen() then
            XUiManager.TipText("ActivityBranchNotOpen")
            return
        end

        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or 1
        local param2 = (list.CustomParams[2] ~= 0) and list.CustomParams[2] or nil

        if param1 == XDataCenter.FubenActivityBranchManager.BranchType.Difficult then
            if not XDataCenter.FubenActivityBranchManager.IsStatusEqualChallengeBegin() then
                XUiManager.TipText("ActivityBranchNotOpen")
                return 
            end
        end
        
        if XFunctionalSkipManager.IsStageLock(param2) then return end
        
        local sectionId = XDataCenter.FubenActivityBranchManager.GetCurSectionId()
        XLuaUiManager.Open("UiActivityBranch", sectionId, param1, param2)
    end
    
    -- 前往格式塔
    function XFunctionalSkipManager.OnOpenUiActivityBossSingle(list)

        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or nil
        local sectionId = XDataCenter.FubenActivityBossSingleManager.GetCurSectionId() or 1
        -- 活动时间限制
        if not XDataCenter.FubenActivityBossSingleManager.IsOpen() then
            XUiManager.TipText("ActivityBossSingleNotOpen")
            return
        end

        if (not param1) or (not XDataCenter.FubenActivityBossSingleManager.IsChallengeUnlock(param1)) then
            XLuaUiManager.Open("UiActivityBossSingle", sectionId)
        else
            XLuaUiManager.Open("UiActivityBossSingleDetail", param1)
        end
    end
    
    -- 前往纷争战区
    function XFunctionalSkipManager.OnOpenUiArena(list)
        local arenaChapters = XFubenConfigs.GetChapterBannerByType(XDataCenter.FubenManager.ChapterType.ARENA)
        XDataCenter.ArenaManager.RequestSignUpArena(function()
            XLuaUiManager.Open("UiArena", arenaChapters)
        end)
    end
    
    -- 前往幻痛囚笼
    function XFunctionalSkipManager.OnOpenUiFubenBossSingle(list)
        local bossSingleChapters = XFubenConfigs.GetChapterBannerByType(XDataCenter.FubenManager.ChapterType.BOSSSINGLE)
        XDataCenter.FubenBossSingleManager.OpenBossSingleView(bossSingleChapters)
    end

    -- 前往资源副本
    function XFunctionalSkipManager.OnOpenUiFubenDaily(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1]
        local param2 = (list.CustomParams[2] ~= 0) and list.CustomParams[2]
        if param1 == nil or param1 == 0 then
            XLuaUiManager.Open("UiFuben", XDataCenter.FubenManager.StageType.Resource)
            return
        end
        
        XLuaUiManager.OpenWithCallback("UiFubenDaily", function()
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_RESOURCE_AUTOSELECT, param2)
        end, XDataCenter.FubenDailyManager.GetDailyDungeonRulesById(param1))
    end

    -- 前往前传
    function XFunctionalSkipManager.OnOpenUiPrequel(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1]
        local param2 = (list.CustomParams[2] ~= 0) and list.CustomParams[2]
        local covers = XDataCenter.PrequelManager.GetListCovers()
        if covers then
            local index = 0
            for k, v in pairs(covers) do
                if v.CoverId == param1 then
                    index = k
                    break
                end
            end
            if covers[index] then
                if covers[index].IsAllChapterLock and (not covers[index].IsActivity) then 
                    XUiManager.TipMsg(XDataCenter.PrequelManager.GetChapterUnlockDescription(covers[index].ShowChapter))
                    return 
                end
                XLuaUiManager.Open("UiPrequel", covers[index], nil, param2)
            end
        end
        -- XLuaUiManager.OpenWithCallback("UiFuben", function()
        --     CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_PREQUEL_AUTOSELECT, param1, param2)
        -- end, 1)
    end

    -- 前往剧情简章主界面-- 前往据点战主界面
    function XFunctionalSkipManager.OnOpenMainlineSubtab(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or 1
        XLuaUiManager.Open("UiFuben", 1, nil, param1)
    end
    
    -- 前往隐藏关卡主界面
    function XFunctionalSkipManager.OnOpenMainlineWithDifficuty(list)
        XLuaUiManager.OpenWithCallback("UiFuben", function()
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_FUBEN_MAINLINE_DIFFICUTY_SELECT)
        end, 1)
    end

    -- 前往展示厅,有参数时打开某个角色
    function XFunctionalSkipManager.OnOpenExhibition(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or nil
        XDataCenter.ExhibitionManager.SetCharacterInfo(XDataCenter.ExhibitionManager.GetSelfGatherRewards())
        XLuaUiManager.OpenWithCallback("UiExhibition", function()
            CsXGameEventManager.Instance:Notify(XEventId.EVENT_CHARACTER_EXHIBITION_AUTOSELECT, param1)
        end, true)
    end

    -- 前往具体的抽卡
    function XFunctionalSkipManager.OnOpenDrawDetail(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or nil
        XDataCenter.DrawManager.GetDrawGroupList(function()
            local drawGroupInfos = XDataCenter.DrawManager.GetDrawGroupInfos()
            for k, info in pairs(drawGroupInfos or {}) do
                if param1 and info.Id == param1 then
                    XDataCenter.DrawManager.GetDrawInfoList(info.Id, function()
                        XLuaUiManager.Open(info.UiPrefab, info.Id, nil, info.UiBackGround)
                    end)
                    break
                end
            end
        end)
    end

    -- 跳转节日活动
    function XFunctionalSkipManager.OnOpenFestivalActivity(list)
        local param1 = (list.CustomParams[1] ~= 0) and list.CustomParams[1] or nil
        local param2 = (list.CustomParams[2] ~= 0) and list.CustomParams[2] or nil
        if not XDataCenter.FubenFestivalActivityManager.IsFestivalInActivity(param1) then
            XUiManager.TipText("FestivalNotInActivity")
            return 
        end
        
        if param2 then
            if XFunctionalSkipManager.IsStageLock(param2) then return end
            XLuaUiManager.Open("UiFubenChristmasMainLineChapter", param1, param2)
        else
            XLuaUiManager.Open("UiFubenChristmasMainLineChapter", param1)
        end
    end

    -- 检查stageId是否开启
    function XFunctionalSkipManager.IsStageLock(stageId)
        if not stageId then return false end
        local stageInfo = XDataCenter.FubenManager.GetStageInfo(stageId)
        if not stageInfo then
            return false
        end
        if not stageInfo.Unlock then
            XUiManager.TipMsg(XDataCenter.FubenManager.GetFubenOpenTips(stageId))
            return true
        end
        return false
    end

    return XFunctionalSkipManager
end