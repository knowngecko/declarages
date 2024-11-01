package.path = package.path .. ";" ..  debug.getinfo(1, "S").source:sub(2):match("(.*/)") .. "?.lua";
local Common = require("common");

--> Decipher argument path
local FileName = "packages";
if arg[1] ~= nil then
    FileName = arg[1]:match("([^/]+)$"):gsub("%.lua$", "")
    local Directory = arg[1]:match("^(.*)/").. "/"
    print(Directory, FileName)
    package.path = package.path .. ";" .. Directory .. "/?.lua"
else
    --package = package.path.. ";" 
end

local Configuration = require(FileName);
local Colours = require("colours")

if Configuration.Settings.SuperuserCommand ~= "" then Configuration.Settings.SuperuserCommand = Configuration.Settings.SuperuserCommand.. " "; end

print(Colours.Blue.. "[ENTER] Beginning".. Colours.Reset);
for Index, Value in pairs(Configuration["Settings"]["Cores"]) do
    Value = string.lower(Value);
    local Core = require("cores/"..Value.."/"..Value);
    Value = Value:gsub("^%l", string.upper)
    print(Colours.Magenta.. Colours.Bold.. "[LOG] Executing: ".. Value.. " Core".. Colours.Reset)
    Core.execute(Configuration);
    print(Colours.Magenta.. Colours.Bold.. "[LOG] Completed: ".. Value.. " Core".. Colours.Reset)
end
print(Colours.Blue.. "[EXIT] Finished".. Colours.Reset);
