# 010 Hex Editor Template

These instructions describe how to go from the Fusion360 models to the cbddlp files for printing. 

Edit In Fusion 360
In Fusion 360 edit the model files (UvTest2 vXX.f3d) as necessary and export as STLs (one file per body,0.010 mm precision).
- The files are set so that it is easy to edit the layer height and export new files. 
- If you need to create files with longer exposures it makes sense to copy the main body more times.

Slice in CHITUBOX
Note: CHITUBOX 1.6.5.1 did not work for generating test patterns. This version (maybe all 1.6.x) saves a cbddlp file version=3 that does not explicitly list liftingDistancemm.  It could be that the cbddlp-hextemplate.bt does not properly parse that section for v3. So instead I had to use CHITUBOX 1.5.0 (Included in this git for posterity)
Take the STL files from Fusion and import them into CHITUBOX 1.5.0 (z-rotate 90 degrees )
Update the Setting: 
- 1 mm per layer (yes, this looks weird but this will be changed later)
- 1 Second per layer (this will be the multiple)
- 1 Bottom layer exposed for 60 s (to ensure it sticks)
- 0 Lifting distance (this is critical)
- [0,4,8] Antialiasing Level
Slice and save one file per antialiasing level. 
I saved _<layer_height_>um_[1-10s,11-20s,2-20s]_UvTest2-v22_a[0,4,8].cbddlp

Edit the cbddlp files to keep the build plate in place while varying the exposure
Download 010 Editor
Open cbddlp-hextemplate.bt and associate it to the file type (so it gets automatically applied. You can also apply it manually by right clicking on an open file and running it)
- Menu:Preferences/Templates: Add cbddlp-hextemplate.bt and associate it with a mask of (.cbddlp). This will automatically apply the template to each file. 
Open the .cbddlp file you want to edit
Run the 'touch_cbddlp_file.1sc' script on the file (open the script and click the 'play' icon or use the 'play' icon in the tool bar.)
- Bonus points if you can figure out how to apply the script automatically (and report it here)
- The script automatically saves and closes the file

Background
Check the short intro video on how to hack the files
https://www.youtube.com/watch?v=s_NIeiNoKi0&t=24s

The touch_cbddlp_file.1sc script modifies the following fields for each file:
- struct header_t header
- - layerHeightmm = 0.05 (for the 50 µm layer heigh)
- - exposureTimeSeconds = 1 (This is the exposure time for all the test layers. It overwrites a downstream exposure set in each layer. Set it to 1 for 1-10s and 2 for 2-20s files)
- struct print_parameters_t printParameters: 
- - liftingDistancemm = 0 (Confirm this is set to 0. Otherwise the build plate will lift between exposures, recirculate the resin, and fail the test)
- struct layer_definition_t layer_definition[12] (This is where we hack the printer to expose the test layers at the same height)
- - struct layer_definition_t layer_definition[0]/layerPositionZmm = 0.05 (1st base layer = layer_height * 1)
- - struct layer_definition_t layer_definition[1]/layerPositionZmm = 0.10 (2nd base layer = layer_height * 2)
- - struct layer_definition_t layer_definition[2..12]/layerPositionZmm = 0.15 (All patern layers = layer_height * 3)
- - struct layer_definition_t layer_definition[2]/layerExposureSeconds (for files with (11-20s) set layerExposureSeconds = 10)
Save the file and it is ready for printing. See '(resin-xp-finder/Instructions.txt)[../resin-xp-finder/Instructions.txt]' 

T2D: 
- Kind of makes sense to redo the entire pipeline now that I have control. 
- - Just do it once, and do it right... For many settings. For myself. 
- Ideally, the base layer should be thicker to give the print structure. 
- - Fix this at the native model: Done. Now I have 2 layers
- It's not nice that files with exposures from 2-20 look identical to files 1-10. After printing this will get confusing. 
- - It would be nice to update the model to have the values: Done
- Label the files with the layer: Done
- Add Layer height to STL: Done
- STLs: 1-10, 11-20, 2-20; X 20µm, 50µm = 6.  If I do 20,30,40,50 = 12: Done
- Slice files with different levels of Antialiasing (0,4,8): Done
- cbddlp: Aliasing 0, 4, 8: Done
- Total = 18. Not terrible, but pretty big... Done


- Do I really need to put the printer into 'test-mode'?
- - If I do. The printer moves way too high at the end. Why? 
- - There is "End-g-code I can use in CHitubox"




![image](https://user-images.githubusercontent.com/11083514/40305607-1e75f01e-5cf3-11e8-9aad-a041dc8027ce.png)

---
Kudos to @Reonarudo for finding what makes .photon files tick. 
Check his project to convert images into .photon files (here)[https://github.com/Reonarudo/pcb2photon]

Kudos to toluse for creating the template for tweaking the .cbddlp files (here)[https://github.com/toluse/photon-resin-calibration]

