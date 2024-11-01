if arg[1] ~= nil then
    print("Arg1 not nil", arg[1])
    package.path = package.path .. ";" .. arg[1] .. "/?.lua"
end
local Configuration = require("config");
local Colours = require("colours")

if Configuration.Settings.SuperuserCommand ~= "" then Configuration.Settings.SuperuserCommand = Configuration.Settings.SuperuserCommand.. " "; end

for Index, Value in pairs(Configuration["Settings"]["Cores"]) do
    print(Colours.Magenta.. Colours.Bold.. "[LOG] Executing: ".. Value.. " Core".. Colours.Reset)
    local Core = require("cores/"..Value.."/"..Value);
    Core.execute(Configuration);
    print(Colours.Magenta.. Colours.Bold.. "[LOG] Completed: ".. Value.. " Core".. Colours.Reset)
end