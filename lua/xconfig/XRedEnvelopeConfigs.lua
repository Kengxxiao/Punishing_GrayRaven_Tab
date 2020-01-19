XRedEnvelopeConfigs = XRedEnvelopeConfigs or {}

local TABLE_REDENVELOPE_NPC_PATH = "Share/RedEnvelope/RedEnvelopeNpc.tab"

local RedEnvelopeNpcTemplates = {}

function XRedEnvelopeConfigs.Init()
    RedEnvelopeNpcTemplates = XTableManager.ReadByIntKey(TABLE_REDENVELOPE_NPC_PATH, XTable.XTableRedEnvelopeNpc, "Id")
end

function XRedEnvelopeConfigs.GetNpcConfig(id)
    local template = RedEnvelopeNpcTemplates[id]
    if not template then
        XLog.Error("XRedEnvelopeConfigs.GetNpcConfig error: can not found template, id is " .. id)
        return
    end
    return template
end