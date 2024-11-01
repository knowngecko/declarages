local Common = require("common")
local Colours = require("colours")
local Luv = require("luv")
local Run = {};

local function get_sub_packages(input)
    if type(input) == "table" then
        return input.Sub
    else
        return input
    end
end

local function get_base_packages(input)
    if type(input) == "table" then
        return input.Base
    else
        return input
    end
end

local function convert_to_base_package_names(Array)
    local NamedPackages = {}
    for Index, Value in ipairs(Array) do
        local RealPackage = get_base_packages(Value);
        table.insert(NamedPackages, RealPackage);
    end
    return NamedPackages;
end

local function convert_to_sub_package_names(Array)
    local NamedPackages = {}
    for Index, Value in ipairs(Array) do
        local RealPackage = get_sub_packages(Value);
        if type(RealPackage) == "table" then
            NamedPackages = Common.merge_arrays(NamedPackages, RealPackage);
        else
            table.insert(NamedPackages, RealPackage);
        end
    end
    return NamedPackages;
end

local function update_custom_packages(Value, Location)
    local Task = function(Value, Location)
        local Colours = { Reset = "\27[0m", Bold = "\27[1m", Green = "\27[32m", }
        
        local function execute_command(Command, Prefix)
            if Prefix then Command = Prefix..Command; end local Handle = io.popen(Command); local Result = Handle:read("a"); Handle:close(); return Result;
        end

        local CurrentVersion = execute_command("cd ".. Location.."/"..Value.."/".."&& makepkg --printsrcinfo | awk -F ' = ' '/pkgver/ {print $2}'", nil);
        execute_command("cd ".. Location.."/"..Value.."/".."&& git pull");
        local NewVersion = execute_command("cd ".. Location.."/"..Value.."/".."&& makepkg --printsrcinfo | awk -F ' = ' '/pkgver/ {print $2}'", nil);
        if NewVersion ~= CurrentVersion then
            print(Colours.Bold.. "[LOG] Updating: ".. Value.. Colours.Reset);
            os.execute("cd ".. Location.."/"..Value.."/".."&& makepkg -si --noconfirm ");
            print(Colours.Green.. Colours.Bold.. "[LOG] Completed: ".. Value.. Colours.Reset);
        else
            print(Colours.Bold.. "[LOG] Already Up to Date: ".. Value.. Colours.Reset);
        end
    end
    local Thread = Luv.new_thread(Task, Value, Location);
end

function Run.execute(Configuration)
    --> Get installed pacakges
    local InstalledPackages = Common.raw_list_to_table(Common.execute_command("pacman -Qeq"));

    --> Remove installed packages that are no longer required
    local CombinedNameOnlyPackages = convert_to_sub_package_names(Common.merge_arrays(Configuration.Pacman.Official, Configuration.Pacman.Custom))
    local PackagesToRemove = Common.subtract_arrays(InstalledPackages, CombinedNameOnlyPackages);

    local Confirmation = true;
    if #PackagesToRemove > Configuration.Settings.WarnOnPackageRemovalAbove then
        print(Colours.Bold.. Colours.Yellow.. "[WARNING]".." Are you sure you would like to remove these ".. #PackagesToRemove .." packages?".. Colours.Reset);
        for Index, Value in ipairs(PackagesToRemove) do
            io.write(Value.." ");
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
                Common.execute_command("pacman -D --asexplicit".. Value, Configuration.Settings.SuperuserCommand);
                print("");
            end
        end

        if #PackagesToRemove > 0 then
            local RemovalString = "pacman -Rns --noconfirm";
            io.write(Colours.Bold.. "[LOG] Removing: ".. Colours.Reset)
            for Index, Value in ipairs(PackagesToRemove) do
                io.write(Value.. " ");
                RemovalString = RemovalString.. " " ..Value;
            end
            print("");
            Common.execute_command(RemovalString, Configuration.Settings.SuperuserCommand);
            io.write(Colours.Green.. Colours.Bold.. "[LOG] Removed Packages: ");
            for Index, Value in ipairs(PackagesToRemove) do
                io.write(Value.. " ");
            end
            io.write(Colours.Reset.. "\n");
        end
    end

    --> Delete Old Custom Package directories
    local InstalledCustomPackages = Common.raw_list_to_table(Common.execute_command("ls ".. Configuration.Pacman.CustomLocation, Configuration.Settings.SuperuserCommand));
    local UnrequiredCustom = Common.subtract_arrays(InstalledCustomPackages, convert_to_base_package_names(Configuration.Pacman.Custom))
    for Index, Value in ipairs(UnrequiredCustom) do
        Common.remove_path(Configuration.Pacman.CustomLocation.."/"..Value, Configuration.Settings.SuperuserCommand, Configuration.Settings.AddPathConfirmation);
    end

    --> Install packages we don't have
    local OfficialNameOnlyPackages = convert_to_base_package_names(Configuration.Pacman.Official);
    local PackagesToInstallOfficial = Common.subtract_arrays(OfficialNameOnlyPackages, InstalledPackages);

    local InstallString = "pacman -Syu --noconfirm";
    if #PackagesToInstallOfficial > 0 then
        io.write(Colours.Bold.. "[LOG] Upgrading System & Attempting to install: ".. Colours.Reset);
        for Index, Value in ipairs(PackagesToInstallOfficial) do
            io.write(Value.. " ");
            InstallString = InstallString .." ".. Value;
        end
        print(""); 
    else
        print(Colours.Bold .."[LOG] Upgrading System".. Colours.Reset);
    end

    os.execute(Configuration.Settings.SuperuserCommand.. InstallString);
    print(Colours.Bold.. Colours.Green.. "[LOG] Completed Installations".. Colours.Reset);

    Common.create_path(Configuration.Pacman.CustomLocation, "", Configuration.Settings.AddPathConfirmation);
    local InstalledCustomPackages = Common.raw_list_to_table(Common.execute_command("ls ".. Configuration.Pacman.CustomLocation, Configuration.Settings.SuperuserCommand));

    --> Update Installed Custom packages 
    --[[ NON-MULTI-THREADED WAY
    for Index, Value in ipairs(InstalledCustomPackages) do
        local CurrentVersion = Common.execute_command("cd ".. Configuration.Pacman.CustomLocation.."/"..Value.."/".."&& makepkg --printsrcinfo | awk -F ' = ' '/pkgver/ {print $2}'", nil);
        Common.execute_command("cd ".. Configuration.Pacman.CustomLocation.."/"..Value.."/".."&& git pull");
        local NewVersion = Common.execute_command("cd ".. Configuration.Pacman.CustomLocation.."/"..Value.."/".."&& makepkg --printsrcinfo | awk -F ' = ' '/pkgver/ {print $2}'", nil);
        if NewVersion ~= CurrentVersion then
           print(Colours.Bold.. "[LOG] Updating: ".. Value.. Colours.Reset);
            os.execute("cd ".. Configuration.Pacman.CustomLocation.."/"..Value.."/".."&& makepkg -si --noconfirm ");
            print(Colours.Green.. Colours.Bold.. "[LOG] Completed: ".. Value.. Colours.Reset);
        else
            print(Colours.Bold.. "[LOG] Already Up to Date: ".. Value.. Colours.Reset);
        end
    end ]]

    --> MULTI-THREADED WAY
    for Index, Value in ipairs(InstalledCustomPackages) do
        update_custom_packages(Value, Configuration.Pacman.CustomLocation)
    end
    Luv.run()

    local CustomPackagesToInstall = Common.subtract_arrays(convert_to_base_package_names(Configuration.Pacman.Custom), InstalledCustomPackages);

    for Index, Value in ipairs(CustomPackagesToInstall) do
        print(Colours.Green.. Colours.Bold.. "[LOG] Installing: ".. Value.. Colours.Reset);
        local Url = "https://aur.archlinux.org./"..Value..".git";
        for Index2, Value2 in ipairs(Configuration.Pacman.Custom) do
            if type(Value2) == "table" then
                if Value2.Base == Value then
                    Url = Value2.Url;
                end
            end
        end

        Common.execute_command("cd ".. Configuration.Pacman.CustomLocation.."&& git clone ".. Url, nil);
        Common.execute_command("cd ".. Configuration.Pacman.CustomLocation.."/"..Value.."/".."&& makepkg -si --noconfirm", nil);
        print(Colours.Green.. Colours.Bold.. "[LOG] Completed: ".. Value.. Colours.Reset);
    end
end

return Run