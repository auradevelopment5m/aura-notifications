Config = {}

Config.DefaultSettings = {
    defaultType = 'info',
    defaultDuration = 5000,
    position = 'top-right' -- top-right, top-left, bottom-right, bottom-left, top-center, bottom-center
}

Config.NotificationTypes = {
    'info',
    'success',
    'error',
    'warning',
    'bank',
    'wallet',
    'police',
    'ambulance',
    'mechanic',
    'phone',
    'message',
    'email',
    'job',
    'admin',
    'system'
}

Config.DefaultColors = {
    info = "#818cf8",      -- indigo-400
    success = "#34d399",   -- emerald-400
    error = "#fb7185",     -- rose-400
    warning = "#fbbf24",   -- amber-400
    bank = "#38bdf8",      -- sky-400
    wallet = "#60a5fa",    -- blue-400
    police = "#60a5fa",    -- blue-400
    ambulance = "#fb7185", -- rose-400
    mechanic = "#94a3b8",  -- slate-400
    phone = "#a78bfa",     -- violet-400
    message = "#c084fc",   -- purple-400
    email = "#38bdf8",     -- sky-400
    job = "#fbbf24",       -- amber-400
    admin = "#e879f9",     -- fuchsia-400
    system = "#94a3b8"     -- slate-400
}

Config.Debug = false