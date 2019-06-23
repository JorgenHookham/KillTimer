local version = "0.0.1"

local DEBUG = true

start_time = 0
multi_mob_combat = false
in_party = false

local Events = {
    CHAT_MSG_COMBAT_SELF_HITS = MobHitHandler,
    -- CHAT_MSG_COMBAT_SELF_MISSES = DefaultEventHandler,
    CHAT_MSG_SPELL_SELF_DAMAGE = MobHitHandler,
    CHAT_MSG_COMBAT_HOSTILE_DEATH = MobKilledHandler,
    -- PLAYER_REGEN_DISABLED = DefaultEventHandler,
    PLAYER_REGEN_ENABLED = CombatEndedHandler,
    -- UNIT_COMBAT = DefaultEventHandler,
    -- UNIT_HEALTH = DefaultEventHandler,
    PARTY_MEMBERS_CHANGED = SetPartyStatus,
}

function print(msg)
    ChatFrame2:AddMessage(msg, 1, 1, 0.5)
end

function DefaultEventHandler()
    if DEBUG then LogEvent() end
end

function SetPartyStatus()
    old_status = in_party
    if GetNumPartyMembers() > 0 then in_party = true else in_party = false end
    if not (in_party == old_status) then
        if in_party then print("KillTimer is not available while in a party.")
        else print("KillTimer is now available.") end
    end
end

function LogEvent()
    log_string = event
    if arg1 then
        log_string = log_string .. " (" .. arg1 .. ")"
    end
    if arg2 then
        log_string = log_string .. " (" .. arg2 .. ")"
    end
    if arg3 then
        log_string = log_string .. " (" .. arg3 .. ")"
    end
    if arg4 then
        log_string = log_string .. " (" .. arg4 .. ")"
    end
    if arg5 then
        log_string = log_string .. " (" .. arg5 .. ")"
    end
    print(log_string)
end

function PrintTargetHP()
    print("Target HP: " .. UnitHealth("target"))
    if DEBUG then LogEvent() end
end

function KillTimer_OnLoad()
    SetPartyStatus()
    for event, handler in Events do
        this:RegisterEvent(event)
    end
    print("KillTimer was loaded :)")
end

function KillTimer_OnEvent()
    Events[event]()
end

function TimerStart()
    start_time = time()
end

function TimerReset()
    start_time = 0
    stop_time = 0
end

function CanRun()
    if multi_mob_combat then return false end
    if in_party then return false end
    return true
end

function MobHitHandler()
    if not CanRun() then return end
    target_hp_before_hit = UnitHealth("target")
    if start_time > 0 then
        if not target_hp_before_hit == 100 then multi_mob_combat = true end
    else
        TimerStart()
    end
end

function MobKilledHandler()
    if not CanRun() then return end
    stop_time = time()
    time_to_kill = stop_time - start_time
    print("You killed the target in " .. time_to_kill .. " seconds")
end

function CombatEndedHandler()
    multi_mob_combat = false
    TimerReset()
end
