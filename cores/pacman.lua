local Common = require("../common")
local Colours = require("../colours")
local Run = {};

local function get_real_packages(input)
    if type(input) == "table" then
        return input.Sub
    else
        return input
    end
end

function Run.execute(Configuration)
    --> Get installed pacakges
    local InstalledPackagesRaw = Common.execute_command("pacman -Qeq");
    local InstalledPackages = {}

    for Line in InstalledPackagesRaw:gmatch("([^\n]+)") do
        if Line ~= "" then
            table.insert(InstalledPackages, Line);
        end
    end

    --> Remove installed packages that are no longer required
    local CombinedNameOnlyPackages = {}
    for Index, Value in ipairs(Common.merge_arrays(Configuration.Pacman.Official, Configuration.Pacman.Custom)) do
        local RealPackage = get_real_packages(Value);
        if type(RealPackage) == "table" then
            CombinedNameOnlyPackages = Common.merge_arrays(CombinedNameOnlyPackages, RealPackage);
        else
            table.insert(CombinedNameOnlyPackages, RealPackage);
        end
    end

    local PackagesToRemove = Common.subtract_arrays(InstalledPackages, CombinedNameOnlyPackages);

    local Confirmation = true;
    if #PackagesToRemove > Configuration.Settings.WarnOnPackageRemovalAbove then
        print(Colours.Bold.. Colours.Yellow.. "[WARNING]".. Colours.Reset .. Colours.Bold.." Are you sure you would like to remove these ".. #PackagesToRemove .." packages?".. Colours.Reset);
        for Index, Value in ipairs(PackagesToRemove) do
            io.write(Value..", ");
        end
        print("");
        io.write("(Y/n) ");
        Confirmation = Common.ensure_confirmation();
        print("");
    end

    if Confirmation == true and #PackagesToRemove > 0 then
        --> Need to check if the packages are dependencies of other packages before attempting removal
        for Index, Value in ipairs(PackagesToRemove) do
            local DependenciesRaw = Common.execute_command("pactree -r --optional=0 --depth=1 -l ".. Value);

            local CanBeRemoved = true;
            for Package in DependenciesRaw:gmatch("([^\n]+)") do
                if Package ~= "" then
                    --> Check if the package that depends on this package is part of the packages we are removing
                    local Hit = false;
                    for Index2, Value2 in ipairs(PackagesToRemove) do
                        if Package == Value2 then
                            Hit = true;
                        end
                    end
                   if Hit == false then
                        CanBeRemoved = false;
                        break;
                   end 
                end
            end

            if CanBeRemoved == false then
                    table.remove(PackagesToRemove, Index);
                    print(Colours.Bold.. Colours.Yellow.. "[WARNING]".. Colours.Reset .. Colours.Bold.." Unable to remove ".. Value .." as the following depend upon it:" .. Colours.Reset);
                    io.write(DependenciesRaw);
                    print(Colours.Bold.. "[LOG] Marking ".. Value .." install reason as dependency".. Colours.Reset);
                print("");
            end
        end

        if #PackagesToRemove > 0 then
            local RemovalString = "pacman -Rns";
            io.write(Colours.Bold.. "[LOG] Removing: ".. Colours.Reset)
            for Index, Value in ipairs(PackagesToRemove) do
                io.write(Value.. ", ");
                RemovalString = RemovalString.. " " ..Value;
            end
            print("");
            Common.execute_command(RemovalString, Configuration.Settings.SuperuserCommand);
        end

    end
end

return Run