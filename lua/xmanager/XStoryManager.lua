XStoryManagerCreator = function()

    local XStoryManager = {}

    function XStoryManager.Init()

        CsXGameEventManager.Instance:RegisterEvent(CS.XEventId.EVENT_STOP_MOVIE, function(evt,args,...)
            local storyId = args[0]
            XStoryManager.FinishStory(storyId)
        end)

        CsXGameEventManager.Instance:RegisterEvent(CS.XEventId.EVENT_PLAY_MOVIE, function(evt,args, ...)
            local storyId = args[0]
            XStoryManager.StartStory(storyId)
        end)
    end


    function XStoryManager.StartStory(storyId)
        XNetwork.Send("StartStoryRequest", { StoryId = storyId })
    end



    function XStoryManager.FinishStory(storyId, cb)
        XNetwork.Send("FinishStoryRequest", { StoryId = storyId })    
    end


    XStoryManager.Init()

    return XStoryManager
end