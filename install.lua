local owner = "SubhanAfz"
local repo = "uber_system"
local branch = "main"
local rawBaseUrl = "https://raw.githubusercontent.com/" .. owner .. "/" .. repo .. "/" .. branch .. "/"
local apiBaseUrl = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents"

local function shouldSkip(path)
    for part in string.gmatch(path, "[^/]+") do
        if string.sub(part, 1, 1) == "." then
            return true
        end
    end
    return false
end

local function fetchJson(url)
    local response = http.get(url, {
        ["User-Agent"] = "CC-Tweaked Installer"
    })

    if not response then
        error("Failed to fetch " .. url)
    end

    local body = response.readAll()
    response.close()

    local data = textutils.unserializeJSON(body)
    if not data then
        error("Failed to parse GitHub response for " .. url)
    end

    return data
end

local function ensureParent(path)
    local dir = fs.getDir(path)
    if dir ~= "" and not fs.exists(dir) then
        fs.makeDir(dir)
    end
end

local function downloadFile(path)
    if shouldSkip(path) then
        return
    end

    ensureParent(path)

    if fs.exists(path) then
        fs.delete(path)
    end

    print("Downloading " .. path .. "...")

    local ok = shell.run("wget", rawBaseUrl .. path, path)
    if not ok then
        error("Failed to download " .. path)
    end
end

local function downloadTree(path)
    local suffix = path ~= "" and ("/" .. path) or ""
    local entries = fetchJson(apiBaseUrl .. suffix .. "?ref=" .. branch)

    for _, entry in ipairs(entries) do
        if not shouldSkip(entry.path) then
            if entry.type == "file" then
                downloadFile(entry.path)
            elseif entry.type == "dir" then
                downloadTree(entry.path)
            end
        end
    end
end

downloadTree("")

local startupFile = fs.open("startup", "w")
startupFile.writeLine("shell.run(\"main\")")
startupFile.close()

print("Install complete.")
print("Run 'main' now, or reboot to launch from startup.")
