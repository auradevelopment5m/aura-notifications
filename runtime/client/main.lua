local resourceName = GetCurrentResourceName()
local settings = {}
local notificationHistory = {}
local maxHistorySize = 100
local resourceStartTime = GetGameTimer() / 1000
local settingsLoaded = false

local function DebugPrint(...)
    if Config and Config.Debug then
        local args = {...}
        local message = ""
        for i, v in ipairs(args) do
            if type(v) == "table" then
                message = message .. json.encode(v) .. " "
            else
                message = message .. tostring(v) .. " "
            end
        end
        print("[Aura Notifications Debug] " .. message)
    end
end

local function LoadDefaultSettings()
    if not Config then
        DebugPrint("Config not loaded, using hardcoded defaults")
        settings = {
            position = 'top-right',
            enableSounds = true,
            size = "medium",
            colors = {
                info = "#818cf8",
                success = "#34d399",
                error = "#fb7185",
                warning = "#fbbf24",
                bank = "#38bdf8",
                wallet = "#60a5fa",
                police = "#60a5fa",
                ambulance = "#fb7185",
                mechanic = "#94a3b8",
                phone = "#a78bfa",
                message = "#c084fc",
                email = "#38bdf8",
                job = "#fbbf24",
                admin = "#e879f9",
                system = "#94a3b8"
            }
        }
        return
    end

    settings = {
        position = Config.DefaultSettings.position or 'top-right',
        enableSounds = Config.DefaultSettings.enableSounds or true,
        size = Config.DefaultSettings.size or "medium",
        colors = {}
    }

    for _, notifType in ipairs(Config.NotificationTypes or {}) do
        settings.colors[notifType] = Config.DefaultColors and Config.DefaultColors[notifType] or "#818cf8"
    end
end

local function ApplySettings()
    DebugPrint("Applying settings to UI:", settings)
    
    SendNUIMessage({
        type = 'updateSettings',
        settings = {
            position = settings.position,
            enableSounds = settings.enableSounds,
            size = settings.size,
            colors = settings.colors
        }
    })
    
    DebugPrint("Settings update message sent to NUI")
end

local function StoreNotificationInHistory(notificationType, title, message, duration)
    local timestamp = GetGameTimer() / 1000
    
    local historyEntry = {
        type = notificationType or "info",
        title = title or "",
        message = message or "",
        duration = duration or 5000,
        timestamp = timestamp,
        id = tostring(#notificationHistory + 1)
    }
    
    if #notificationHistory >= maxHistorySize then
        table.remove(notificationHistory, 1)
    end
    
    table.insert(notificationHistory, historyEntry)
end

local function ShowNotification(data)
    if not data or type(data) ~= 'table' then return end

    if not data.message then return end

    if not settingsLoaded then
        LoadDefaultSettings()
        settingsLoaded = true
    end

    data.type = data.type or 'info'
    data.duration = data.duration or 5000

    StoreNotificationInHistory(data.type, data.title, data.message, data.duration)

    SendNUIMessage({
        type = 'notification',
        notificationType = data.type,
        title = data.title,
        message = data.message,
        duration = data.duration
    })
end

local function ClearAllNotifications()
    SendNUIMessage({
        type = 'clearAll'
    })
end

local function OpenNotificationHistoryUI(count)
    DebugPrint("Opening notification history UI")
    
    count = count or #notificationHistory
    count = math.min(count, #notificationHistory)
    
    local historyToSend = {}
    local startIndex = math.max(1, #notificationHistory - count + 1)
    
    for i = startIndex, #notificationHistory do
        if notificationHistory[i] then
            table.insert(historyToSend, notificationHistory[i])
        end
    end
    
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = 'showNotificationHistory',
        history = historyToSend,
        resourceStartTime = resourceStartTime
    })
    
    DebugPrint("Notification history UI message sent with", #historyToSend, "items")
end

RegisterNUICallback('closeHistory', function(data, cb)
    DebugPrint("Received closeHistory callback")
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('clearHistory', function(data, cb)
    DebugPrint("Received clearHistory callback")
    notificationHistory = {}
    cb('ok')
end)

RegisterNUICallback('replayNotification', function(data, cb)
    DebugPrint("Received replayNotification callback")
    if data and data.type and data.message then
        ShowNotification({
            type = data.type,
            title = data.title or '',
            message = data.message,
            duration = data.duration or 5000
        })
    end
    cb('ok')
end)

RegisterNUICallback('uiReady', function(data, cb)
    DebugPrint("UI is ready, applying settings")
    ApplySettings()
    cb('ok')
end)

if Config and Config.Debug then
    RegisterCommand('notify', function(source, args, rawCommand)
        local notifType = args[1] or 'info'
        local title = args[2] or 'Notification'
        local message = args[3] or 'This is a test notification'
        local duration = tonumber(args[4]) or 5000

        ShowNotification({
            type = notifType,
            title = title,
            message = message,
            duration = duration
        })
    end, false)

    RegisterCommand('clearnotify', function()
        ClearAllNotifications()
    end, false)

    RegisterCommand('notifytest', function()
        local types = Config and Config.NotificationTypes or {
            'info', 'success', 'error', 'warning', 'bank', 'wallet',
            'police', 'ambulance', 'mechanic', 'phone', 'message', 'email',
            'job', 'admin', 'system'
        }

        local delay = 0
        for _, notifType in ipairs(types) do
            SetTimeout(delay, function()
                ShowNotification({
                    type = notifType,
                    title = 'Test: ' .. notifType,
                    message = 'This is a test notification of type: ' .. notifType,
                    duration = 5000
                })
            end)
            delay = delay + 1000
        end
    end, false)
end

RegisterCommand('notifyhistory', function(source, args, rawCommand)
    DebugPrint("notifyhistory command triggered")
    local count = tonumber(args[1])
    OpenNotificationHistoryUI(count)
end, false)

exports('ShowNotification', ShowNotification)
exports('ClearAllNotifications', ClearAllNotifications)
exports('OpenNotificationHistoryUI', OpenNotificationHistoryUI)

RegisterNetEvent(resourceName .. ':showNotification')
AddEventHandler(resourceName .. ':showNotification', function(data)
    ShowNotification(data)
end)

RegisterNetEvent(resourceName .. ':clearAllNotifications')
AddEventHandler(resourceName .. ':clearAllNotifications', function()
    ClearAllNotifications()
end)

RegisterNetEvent(resourceName .. ':openNotificationHistory')
AddEventHandler(resourceName .. ':openNotificationHistory', function(count)
    OpenNotificationHistoryUI(count)
end)

CreateThread(function()
    Wait(500)
    
    LoadDefaultSettings()
    settingsLoaded = true
    
    Wait(1000)
    
    ApplySettings()
    
    if Config and Config.Debug then
        TriggerEvent('chat:addSuggestion', '/notify', 'Show a notification', {
            { name = 'type', help = 'Notification type (info, success, error, etc.)' },
            { name = 'title', help = 'Notification title' },
            { name = 'message', help = 'Notification message' },
            { name = 'duration', help = 'Duration in ms (default: 5000)' }
        })
        
        TriggerEvent('chat:addSuggestion', '/clearnotify', 'Clear all notifications')
        TriggerEvent('chat:addSuggestion', '/notifytest', 'Show test notifications of all types')
    end
    
    TriggerEvent('chat:addSuggestion', '/notifyhistory', 'View notification history', {
        { name = 'count', help = 'Number of notifications to show (optional)' }
    })
end)