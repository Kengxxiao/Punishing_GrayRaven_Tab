local math = math
local string = string
local tonumber = tonumber
local mathFloor = math.floor
local mathCeil = math.ceil
local mathMin = math.min
local mathMax = math.max
local stringFormat = string.format
local stringSub = string.sub
local tableSort = table.sort
local tableInsert = table.insert
local tableRemove = table.remove

local STR_MONTH = CS.XTextManager.GetText("Mouth")
local STR_WEEK = CS.XTextManager.GetText("Week")
local STR_DAY = CS.XTextManager.GetText("Day")
local STR_HOUR = CS.XTextManager.GetText("Hour")
local STR_MINUTE = CS.XTextManager.GetText("Minute")
local STR_SECOND = CS.XTextManager.GetText("Second")

local S = 60
local H = 3600
local D = 3600 * 24
local W = 3600 * 24 * 7
local M = 3600 * 24 * 30

XUiHelper = XUiHelper or {}
XUiHelper.TimeFormatType = {
    DEFAULT = 1, -- 默认时间格式（大于一天显示天数，小于一天显示xx小时xx分）
    SHOP = 1, -- 商城时间格式
    TOWER = 2, -- 爬塔时间格式
    TOWER_RANK = 3, -- 爬塔排行消耗时间格式
    CHALLENGE = 4, -- 挑战的时间
    HOSTEL = 5, -- 宿舍倒计时
    DRAW = 6, -- 抽卡倒计时
    MAIN = 7, -- 主界面系统时间
    PURCHASELB = 8, -- 礼包时间
    ONLINE_BOSS = 9, -- 联机boss
    ACTIVITY = 10, -- 活动
    MAINBATTERY = 11, -- 主界面血清剩余时间
}

XUiHelper.TagBgPath = {
    Red = CS.XGame.ClientConfig:GetString("UiBagItemRed"),
    Yellow = CS.XGame.ClientConfig:GetString("UiBagItemYellow"),
    Blue = CS.XGame.ClientConfig:GetString("UiBagItemBlue"),
    Green = CS.XGame.ClientConfig:GetString("UiBagItemGreen"),
}

function XUiHelper.CreateTemplates(rootUi, pool, datas, ctor, template, parent, onCreate)
    for i = 1, #datas do
        local data = datas[i]
        local item = nil

        if i <= #pool then
            item = pool[i]
        else
            local go = CS.UnityEngine.Object.Instantiate(template)
            go.transform:SetParent(parent, false)
            item = ctor(rootUi, go)
            pool[i] = item
        end

        if onCreate then
            onCreate(item, data)
        end
    end

    for i = #datas + 1, #pool do
        local item = pool[i]
        item.GameObject:SetActive(false)
    end
end

function XUiHelper.CreateScrollItem(datas, template, parent, cb, scrollstyle)
    scrollstyle = scrollstyle or XGlobalVar.ScrollViewScrollDir.ScrollDown
    local x, y = 0, 0
    local width, height = template.gameObject:GetComponent("RectTransform").rect.width, template.gameObject:GetComponent("RectTransform").rect.height

    if scrollstyle == XGlobalVar.ScrollViewScrollDir.ScrollDown then
        parent:GetComponent("RectTransform").sizeDelta = CS.UnityEngine.Vector2(0, #datas * height)
    elseif scrollstyle == XGlobalVar.ScrollViewScrollDir.ScrollRight then
        parent:GetComponent("RectTransform").sizeDelta = CS.UnityEngine.Vector2(#datas * width, 0)
    end

    for i = 1, #datas do
        local obj = CS.UnityEngine.Object.Instantiate(template)
        obj.gameObject:SetActive(true)
        if scrollstyle == XGlobalVar.ScrollViewScrollDir.ScrollDown then
            obj.transform.localPosition = CS.UnityEngine.Vector3(width / 2, -height / 2 - height * (i - 1), 0)
        elseif scrollstyle == XGlobalVar.ScrollViewScrollDir.ScrollRight then
            obj.transform.localPosition = CS.UnityEngine.Vector3(width * (i - 1), 0, 0)
        end
        obj.transform.localScale = CS.UnityEngine.Vector3(1, 1, 1)
        obj.transform.localEulerAngles = CS.UnityEngine.Vector3(0, 0, 0)
        obj.transform:SetParent(parent, false)
        cb(obj, datas[i])
    end

end

function XUiHelper.TryGetComponent(transform, path, type)
    local temp = transform:Find(path)
    if temp then
        if type then
            return temp:GetComponent(type)
        else
            return temp
        end
    else
        return nil
    end
end

function XUiHelper.SetQualityIcon(rootUi, imgQuality, quality)
    local spriteName = CS.XGame.Config:GetString("QualityIconColor" .. quality)
    rootUi:SetUiSprite(imgQuality, spriteName)
end

function XUiHelper.GetPanelRoot(ui)
    while ui.Parent do
        ui = ui.Parent
    end
    return ui
end

------------时间相关begin------------
--==============================--
--desc: 固定的时间格式
--@second: 总秒数
--@return: 固定的时间格式
-- 时间大于1个月     则返回 X个月
-- 时间大于1周       则返回 X周
-- 时间大于1天       则返回 X天
-- 其余             则返回 XX:XX:XX
--==============================--
function XUiHelper.GetTime(second, timeFormatType)
    timeFormatType = timeFormatType and timeFormatType or XUiHelper.TimeFormatType.DEFAULT

    local month = mathFloor(second / M)
    local weeks = mathFloor((second % M) / W)
    local days = mathFloor((second % W) / D)
    local hours = mathFloor((second % D) / H)
    local minutes = mathFloor((second % H) / S)
    local seconds = mathFloor(second % S)

    if timeFormatType == XUiHelper.TimeFormatType.DEFAULT then
        if month >= 1 then
            return stringFormat("%d%s", month, STR_MONTH)
        end
        if weeks >= 1 then
            return stringFormat("%d%s", weeks, STR_WEEK)
        end
        if days >= 1 then
            return stringFormat("%d%s", days, STR_DAY)
        end
        return stringFormat("%02d:%02d:%02d", hours, minutes, seconds)
    end

    if timeFormatType == XUiHelper.TimeFormatType.MAINBATTERY then
        if month >= 1 then
            return stringFormat("%d%s", month, STR_MONTH)
        end
        if weeks >= 1 then
            return stringFormat("%d%s", weeks, STR_WEEK)
        end
        if days >= 1 then
            return stringFormat("%d%s", days, STR_DAY)
        end
        if hours >= 1 then
            return stringFormat("%d%s", hours, STR_HOUR)
        end
        local notZeroMin = minutes > 0 and minutes or 1
        return stringFormat("%d%s", notZeroMin, STR_MINUTE)
    end

    if timeFormatType == XUiHelper.TimeFormatType.ACTIVITY then
        local totalDays = mathFloor(second / D)
        if totalDays >= 1 then
            return stringFormat("%d%s", totalDays, STR_DAY)
        end
        if hours >= 1 then
            return stringFormat("%d%s", hours, STR_HOUR)
        end
        if minutes >= 1 then
            return stringFormat("%d%s", minutes, STR_MINUTE)
        end
        return stringFormat("%d%s", seconds, STR_SECOND)
    end

    if timeFormatType == XUiHelper.TimeFormatType.TOWER then
        return stringFormat("%d%s%02d%s%02d%s", days, STR_DAY, hours, STR_HOUR, minutes, STR_MINUTE)
    end

    if timeFormatType == XUiHelper.TimeFormatType.TOWER_RANK then
        return stringFormat("%02d%s%02d%s", minutes, STR_MINUTE, seconds, STR_SECOND)
    end

    if timeFormatType == XUiHelper.TimeFormatType.CHALLENGE or timeFormatType == XUiHelper.TimeFormatType.HOSTEL or timeFormatType == XUiHelper.TimeFormatType.PURCHASELB then
        if month >= 1 then
            return stringFormat("%d%s", month, STR_MONTH)
        end
        if weeks >= 1 then
            return stringFormat("%d%s", weeks, STR_WEEK)
        end
        if days >= 1 then
            return stringFormat("%d%s%d%s", days, STR_DAY, hours, STR_HOUR)
        end
        return stringFormat("%02d:%02d:%02d", hours, minutes, seconds)
    end

    if timeFormatType == XUiHelper.TimeFormatType.DRAW then
        local sumDas = mathFloor(second / D)
        if sumDas >= 1 then
            return stringFormat("%d%s", sumDas, STR_DAY)
        end
        if hours >= 1 then
            return stringFormat("%d%s", hours, STR_HOUR)
        end
        if minutes >= 1 then
            return stringFormat("%d%s", minutes, STR_MINUTE)
        end
        return stringFormat("%02d:%02d:%02d", hours, minutes, seconds)
    end

    if timeFormatType == XUiHelper.TimeFormatType.MAIN then
        return stringFormat("%02d:%02d", hours, minutes)
    end

    if timeFormatType == XUiHelper.TimeFormatType.ONLINE_BOSS then
        local sumDas = mathFloor(second / D)
        if sumDas >= 1 then
            return stringFormat("%d%s", sumDas, STR_DAY)
        end
        if hours >= 1 then
            return stringFormat("%d%s", hours, STR_HOUR)
        end
        return stringFormat("%02d:%02d", minutes, seconds)
    end
end

--背包限时道具时间样式
function XUiHelper.GetBagTimeLimitTimeStrAndBg(second)
    local timeStr, bgPath = "", ""

    local weeks = mathFloor((second % M) / W)
    local days = mathFloor((second % W) / D)
    local hours = mathFloor((second % D) / H)
    local minutes = mathFloor((second % H) / S)
    if weeks >= 1 then
        timeStr = stringFormat("%d%s", weeks, STR_WEEK)
        bgPath = XUiHelper.TagBgPath.Green
    elseif days >= 1 then
        timeStr = stringFormat("%d%s", days, STR_DAY)
        bgPath = XUiHelper.TagBgPath.Yellow
    elseif hours >= 1 then
        timeStr = stringFormat("%d%s", hours, STR_HOUR)
        bgPath = XUiHelper.TagBgPath.Red
    else
        local notZeroMin = minutes > 0 and minutes or 1
        timeStr = stringFormat("%d%s", notZeroMin, STR_MINUTE)
        bgPath = XUiHelper.TagBgPath.Red
    end

    return timeStr, bgPath
end

--  length为可选参数，为要显示的长度，例如3601,1为1小时，3601,2为1小时1秒,
function XUiHelper.GetTimeDesc(second, length)
    local M = 60
    local H = 3600
    local D = 3600 * 24

    local originLength = length
    if second <= 0 then
        return CS.XTextManager.GetText("IsExpire")
    end

    if not length then
        length = 1
    end

    local desc = ""
    while length > 0 do
        if second == 0 then
            return desc
        end

        if second < M then
            local s = mathFloor(second)
            desc = desc .. s .. CS.XTextManager.GetText("Second")
            second = 0
        else
            if second < H then
                local m = mathFloor(second / M)
                desc = desc .. m .. CS.XTextManager.GetText("Minute")
                second = second - m * M
            else
                if second < D then
                    local h = mathFloor(second / H)
                    desc = desc .. h .. CS.XTextManager.GetText("Hour")
                    second = second - h * H
                else
                    local d = mathFloor(second / D)
                    desc = desc .. d .. CS.XTextManager.GetText("Day")
                    second = second - d * D
                end
            end
        end

        length = length - 1
        if length > 0 then
            desc = desc .. " "
        end
    end

    return desc
end

--==============================--
--desc: 获取最后登录时间描述
--@time: 登录时间
--@return 最后登录时间对应描述
--==============================--
function XUiHelper.CalcLatelyLoginTime(time)
    local minute = mathFloor((XTime.Now() - time) / 60)
    local hourCount = mathFloor(minute / 60)
    local dayCount = mathFloor(hourCount / 24)
    local monthCount = mathFloor(dayCount / 30)

    if monthCount >= 1 then
        return monthCount .. CS.XTextManager.GetText("ToolMonthBefore")
    elseif dayCount >= 1 then
        return dayCount .. CS.XTextManager.GetText("ToolDayBrfore")
    elseif hourCount >= 1 then
        return hourCount .. CS.XTextManager.GetText("ToolHourBefore")
    else
        return minute .. CS.XTextManager.GetText("ToolMinuteBefore")
    end
end

function XUiHelper.GetRemindTime(time, now)
    now = now or XTime.Now()
    local remindTime = time - now
    if remindTime > 86400 then
        local day = mathFloor(remindTime / 86400) + 1
        return day .. CS.XTextManager.GetText("Day")
    else
        local h = mathFloor(remindTime / 3600)
        local m = mathFloor((remindTime - h * 3600) / 60)
        local s = mathFloor(remindTime % 60)
        return stringFormat("%02d:%02d:%02d", h, m, s)
    end
end
------------时间相关end------------
--==============================--
--desc: Hex Color 转成 color
--@hexColor: 如:B7C4FFFF
--@return: color(r, g, b, a)
--==============================--
function XUiHelper.Hexcolor2Color(hexColor)
    local str
    str = stringSub(hexColor, 1, 2)
    local r = tonumber(str, 16) / 255
    str = stringSub(hexColor, 3, 4)
    local g = tonumber(str, 16) / 255
    str = stringSub(hexColor, 5, 6)
    local b = tonumber(str, 16) / 255
    str = stringSub(hexColor, 7, 8)
    local a = tonumber(str, 16) / 255
    return CS.UnityEngine.Color(r, g, b, a)
end


------------动画相关begin------------
--==============================--
--desc: 打字机动画
--@txtobj: 文本对象
--@str: 打印的字符串
--@interval: 时间间隔
--@finishcallback: 结束回调
--@return 定时器对象
--==============================--
function XUiHelper.ShowCharByTypeAnimation(txtobj, str, interval, callback, finishcallback)
    local chartab = string.CharsConvertToCharTab(str)
    local index = 1
    local timer
    txtobj.text = ""
    timer = CS.XScheduleManager.Schedule(function(...)
        if index > #chartab then
            CS.XScheduleManager.UnSchedule(timer)
            if finishcallback then
                finishcallback()
            end
        else
            local char = chartab[index]
            if callback then
                callback(char)
            else
                txtobj.text = txtobj.text .. char
            end
            index = index + 1
        end
    end, interval, 0, 0)
    return timer
end

local AnimationPlayerMap = {}
-- 如果是子Ui，得先定义Parent才能获取到UiAnimation组件。
function XUiHelper.PlayAnimation(ui, name, onStart, onEnd)
    
    if onStart then
		onStart()
    end
    
	if ui.GetType and ui:GetType():ToString() == "UnityEngine.GameObject" then
		 ui:PlayLegacyAnimation(name,onEnd)
	else
        ui.GameObject:PlayLegacyAnimation(name,onEnd)
	end

end

function XUiHelper.StopAnimation(ui, name)
end

function XUiHelper.PlayCallback(onStart, onFinish)
    return CS.XUiAnimationManager.PlayCallback(onStart, onFinish)
end

--==============================--
--desc: 默认不会插入到全局播放列表。
--@duration: 动画时长
--@onRefresh: 刷新动作，返回值不为空或true时中断tween
--@onFinish:   结束回调
--@easeMethod: 自定义曲线函数
--@return 定时器
--==============================--
function XUiHelper.Tween(duration, onRefresh, onFinish, easeMethod)
    local startTicks = CS.XTimerManager.Ticks
    local refresh = function(timer)
        local t = (CS.XTimerManager.Ticks - startTicks) / duration / CS.System.TimeSpan.TicksPerSecond
        t = mathMin(1, t)
        t = mathMax(0, t)
        if easeMethod then
            t = easeMethod(t)
        end

        if onRefresh then
            local stop = onRefresh(t) or t == 1
            if stop then
                CS.XScheduleManager.UnSchedule(timer)
                if onFinish then
                    onFinish()
                end
                return
            end
        end

    end
    return CS.XScheduleManager.ScheduleForever(refresh, 0)
end

XUiHelper.EaseType = {
    Linear = 1,
    Sin = 2,
}

function XUiHelper.Evaluate(easeType, t)
    if easeType == XUiHelper.EaseType.Linear then
        return t
    elseif easeType == XUiHelper.EaseType.Sin then
        return math.sin(t * math.pi / 2)
    end
end

function XUiHelper.DoMove(rectTf, tarPos, duration, easeType, cb)
    local startPos = rectTf.localPosition
    easeType = easeType or XUiHelper.EaseType.Linear
    XUiHelper.Tween(duration, function(t)
        if not rectTf:Exist() then
            return true
        end
        rectTf.localPosition = CS.UnityEngine.Vector3.Lerp(startPos, tarPos, t)
    end, cb, function(t)
        return XUiHelper.Evaluate(easeType, t)
    end)
end

------------动画相关end------------
--==============================--
--desc: 计算文本所占宽
--@textObj: 文本对象
--@return 所占宽度
--==============================--
function XUiHelper.CalcTextWidth(textObj)
    local tg = textObj.cachedTextGeneratorForLayout
    local set = textObj:GetGenerationSettings(CS.UnityEngine.Vector2.zero)
    local text = textObj.text
    return mathCeil(tg:GetPreferredWidth(text, set) / textObj.pixelsPerUnit)
end

------------首次获得弹窗Begin------------
local FirstGetIdWaitToShowList = {}
local DELAY_POPUP_UI = false

local PopSortFunc = function(a, b)
    --角色 > 装备
    if a.Type ~= b.Type then
        return a.Type == XArrangeConfigs.Types.Weapon
    end

    if a.Type == XArrangeConfigs.Types.Character then
        local aCharacter = XDataCenter.CharacterManager.GetCharacter(a.Id)
        local bCharacter = XDataCenter.CharacterManager.GetCharacter(b.Id)
        if aCharacter and bCharacter then
            --品质
            if aCharacter.Quality ~= bCharacter.Quality then
                return aCharacter.Quality > bCharacter.Quality
            end

            --优先级
            local priorityA = XCharacterConfigs.GetCharacterPriority(a.Id)
            local priorityB = XCharacterConfigs.GetCharacterPriority(b.Id)
            if priorityA ~= priorityB then
                return priorityA < priorityB
            end
        end
    end

    if a.Type == XArrangeConfigs.Types.Weapon then
        --品质
        local aQuality = XDataCenter.EquipManager.GetEquipQuality(a.Id)
        local bQuality = XDataCenter.EquipManager.GetEquipQuality(b.Id)
        if aQuality ~= bQuality then
            return aQuality > bQuality
        end

        --优先级
        local priorityA = XDataCenter.EquipManager.GetEquipPriority(a.Id)
        local priorityB = XDataCenter.EquipManager.GetEquipPriority(b.Id)
        if priorityA ~= priorityB then
            return priorityA < priorityB
        end
    end
end

function XUiHelper.PushInFirstGetIdList(id, type)
    local beginPopUi = not next(FirstGetIdWaitToShowList)

    local data = { Id = id, Type = type }
    tableInsert(FirstGetIdWaitToShowList, data)
    tableSort(FirstGetIdWaitToShowList, PopSortFunc)

    if beginPopUi and not DELAY_POPUP_UI and not XLuaUiManager.IsUiShow("UiFirstGetPopUp") then
        XLuaUiManager.Open("UiFirstGetPopUp", FirstGetIdWaitToShowList)
    end
end

function XUiHelper.SetDelayPopupFirstGet(isDelay)
    DELAY_POPUP_UI = isDelay
end

function XUiHelper.PopupFirstGet()
    if next(FirstGetIdWaitToShowList) then
        XLuaUiManager.Open("UiFirstGetPopUp", FirstGetIdWaitToShowList)
    end
end

------------首次获得弹窗End------------
function XUiHelper.RegisterClickEvent(table, component, handle, clear)

    clear = clear and true or true

    local func = function(...)
        if handle then
            handle(table, ...)
        end
    end

    CsXUiHelper.RegisterClickEvent(component, func, clear)

end

function XUiHelper.RegisterSliderChangeEvent(table, component, handle, clear)

    clear = clear and true or true

    local func = function(...)
        if handle then
            handle(table, ...)
        end
    end

    CsXUiHelper.RegisterSliderChangeEvent(component, func, clear)

end

function XUiHelper.GetToggleVal(val)
    if val == XUiToggleState.Off then
        return false
    elseif val == XUiToggleState.On then
        return true
    end
end