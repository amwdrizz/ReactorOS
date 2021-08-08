# ReactorOS

A lua program / utility written for use in Minecraft to manage ExtremeReactor reactors using CC-Tweaked (Computer Craft)

## How to use
This tool assumes that you, the user has the following:

* Minecraft with the Following Mods:
    * ComputerCraft: Tweaked (CC:Tweaked)
    * ExtremeReactors
* Functional Reinforced Tier ExtremeReactor with a computer port
* The following CC:Tweaked items
    * 2x Wired Modems (one for your computer, one for the reactor)
    * Sufficent length of network cable to connect your two modems
    * Recommended: Disk Drive w/ Disk
    * Optional: Advanced Monitor

Assuming the above has been met, do the following from the computer that is connected to your reactor.

1) Download the files from this repository to your 'computer' in Minecraft
```
    wget https://raw.githubusercontent.com/amwdrizz/ReactorOS/main/app.lua
    wget https://raw.githubusercontent.com/amwdrizz/ReactorOS/main/config.lua
    wget https://raw.githubusercontent.com/amwdrizz/ReactorOS/main/Reactor.lua
```
2) Edit `config.lua` file to match your setup

3) Use either a or b
    a) Rename app.lua to startup and reboot the computer, it should auto run
    b) execute `./app.lua` from the terminal

If you are using a disk drive, and wish to keep the program on a disk instead.  Ensure you have changed directories into the disk drive 

``` cd /disk/ ```

Having the app on a disk allows you to 'reinstall' and reconnect quickly and easily.  Also, if you put it on the disk with a startup file instead, it will auto launch on boot as well.