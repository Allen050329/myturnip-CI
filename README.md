In this repository, you will find a shell script to build freedreno/turnip driver for android as a magisk module.


### Notes;
- Apps and games in magisk hidelist/denylist will not able to access turnip driver, other workarround in progress
- Make sure you are not using SkiaVK.

### How to build locally?
- Clone this repo;
- You must be in a linux environment;
- Edit .pc files to match path
- Open terminal and navigate to the directory of script and run this command ```bash turnip_builder.sh```
- You can edit **turnip_builder.sh** to add a break or skip some steps, this is also a good way when you want to try something that is not merged in to mesa repository.


###Allen050329 Changelog
-Change auto build time to the 1st, 8th, 15th and 22nd of each month
-Add drm stuff back in for Open GL drivers
-Merge actions to build all together (2023/2/2)

Notes
use command (for vk on Adreno):
bash turnip_builder.sh (For some system instead sh command)

use command (for vk on Adreno):
bash mali_turnip.sh (For some system instead sh command)

use command (for openGL):
bash turnip_builder_gl.sh (For some system instead sh command)

### References

- https://forum.xda-developers.com/t/getting-freedreno-turnip-mesa-vulkan-driver-on-a-poco-f3.4323871/

- https://gitlab.freedesktop.org/mesa/mesa/-/issues/6802
- https://gitlab.freedesktop.org/mesa/mesa/-/issues/7033#note_1621646
