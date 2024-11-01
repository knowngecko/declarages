/*
*   REMEMBER TO DO "cargo build --release" TO UPDATE THE BINARY FOR THE PACMAN CORE TO EXECUTE
*/
use std::{env, process::Command, thread::{self, JoinHandle}};

fn main() {
    // Parallel checking for updates
    let args: Vec<String> = env::args().collect();
    let current_directory = &args[1];
    let _res = env::set_current_dir(current_directory);
    let output = Command::new("ls").output().expect("Failed to exec command");
    let custom_packages = String::from_utf8(output.stdout).unwrap();
    let custom_packages_vec: Vec<String> = custom_packages.split('\n').map(|x| x.to_string()).filter(|x| x != "").collect();
    let mut handles: Vec<JoinHandle<String>> = vec![];
    print!("\x1b[1m");

    for package in custom_packages_vec {
        let handle = thread::spawn(move || {
            
            let current_version = String::from_utf8(Command::new("bash").arg("-c").arg("cd ".to_owned() + &package + "&& makepkg --printsrcinfo | awk -F ' = ' '/pkgver/ {print $2}'").output().expect("failedtoexec").stdout).unwrap();
            Command::new("bash").arg("-c").arg("cd ".to_owned() + &package + "&& git pull").output().expect("failedtoexec");
            Command::new("bash").arg("-c").arg("cd ".to_owned() + &package + "&& makepkg -o").output().expect("failedtoexec");
            let new_version = String::from_utf8(Command::new("bash").arg("-c").arg("cd ".to_owned() + &package + "&& makepkg --printsrcinfo | awk -F ' = ' '/pkgver/ {print $2}'").output().expect("failedtoexec").stdout).unwrap();
            if current_version != new_version {
                println!("\x1b[33m[LOG] Needs Update: {} \x1b[0m\x1b[1m", package);
                return package;
            } else {
                println!("[LOG] Already Up to Date: {} ", package);
                return "".to_string();
            }
        });
        handles.push(handle);
    }
    
    for handle in handles {
        let package = handle.join();
        match package {
            Ok(package) => {
                if package != "".to_string() {
                    println!("[LOG] Updating: {}", package);
                    Command::new("bash").arg("-c").arg("cd ".to_owned() + &package + "&& makepkg -si --noconfirm").output().expect("failedtoexec");
                    println!("[LOG] Completed: {}", package);
                }
            },
            Err(_) => (),
        }
    }
    print!("\x1b[0m");
}
