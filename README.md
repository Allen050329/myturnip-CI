In this repository, you will find a shell script to build freedreno/turnip driver for android as a magisk module.


### Notes;
- Apps and games in magisk hidelist/denylist will not able to access turnip driver, other workarround in progress
- Make sure you are not using SkiaVK.

### How to build locally?
- Pick up the [turnip_builder.sh](https://github.com/Allen050329/myturnip-CI/raw/main/turnip_builder.sh)
- You must be in a linux environment;
- Open terminal and navigate to the directory of script and run this command ```sh turnip_builder.sh```
- You can edit **turnip_builder.sh** to add a break or skip some steps, this is also a good way when you want to try something that is not merged in to mesa repository.


###Allen050329 Changelog
-Change auto build time to the 1st, 8th, 15th and 22nd of each month
-Add drm stuff back in

Notes
use command 
bash turnip_builder.sh (For some system instead sh command)

### References

- https://forum.xda-developers.com/t/getting-freedreno-turnip-mesa-vulkan-driver-on-a-poco-f3.4323871/

- https://gitlab.freedesktop.org/mesa/mesa/-/issues/6802
- https://gitlab.freedesktop.org/mesa/mesa/-/issues/7033#note_1621646
