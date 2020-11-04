# 010 Hex Editor Template

These instructions describe how to generate the test cbddlp files. They go from the Fusion360 models to the cbddlp files for printing. 

Edit In Fusion 360
In Fusion 360 edit the model files (UvTest3 vXX.f3d) as necessary and export as STLs (one file per body,0.010 mm precision).
- The files are set so that it is easy to edit the layer height and export new files. 
- There are many files with the goal of having the files directly annotate the layer_height, antialiasing level, etc. to avoid confusion later after printing. 

Slice in CHITUBOX
Note: CHITUBOX 1.6.5.1 did not work for generating test patterns. This version (maybe all >1.6.x) saves a cbddlp file version=3 that does not explicitly list liftingDistancemm.  It could be that the cbddlp-hextemplate.bt does not properly parse that section for v3. So instead I had to use CHITUBOX 1.5.0 (Included in this git for posterity)
Take the STL files from Fusion and import them into CHITUBOX 1.5.0 (z-rotate 90 degrees )
Update the Settings: 
- 1 mm per layer (yes, this looks weird but this will be changed later)
- 1 Second per layer (this will be the main exposure multiple)
- 3 Bottom layers exposed for 100 s (to ensure it sticks)
- 0 Lifting distance (this is critical)
- 5 mm Bottom Lifting distance (this is critical for building the base)
- [0,4,8] Antialiasing Level (one per file)
Slice and save one file per antialiasing level. 
Save them as <layer_height_>um_a<antialias_level_>_UvTest3_v2x.cbddlp
- The naming format (NNum_) because the post processing scripts use this to edit the files. 

Post-process the cbddlp files to keep the build plate in place while varying the exposure
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
- - struct layer_definition_t layer_definition[0]/layerPositionZmm = 0.05 (1st base layer = 0.05 * 1)
- - struct layer_definition_t layer_definition[1]/layerPositionZmm = 0.10 (2nd base layer = 0.05 * 2)
- - struct layer_definition_t layer_definition[2]/layerPositionZmm = 0.15 (3rd base layers = 0.05 * 3)
- - struct layer_definition_t layer_definition[3..N]/layerPositionZmm = 0.15 (0.05 * 3 + layer_height )
Save the file and it is ready for printing. See '(resin-xp-finder/Instructions.txt)[../resin-xp-finder/Instructions.txt]' 

T2D: 
X Kind of makes sense to redo the entire pipeline now that I have control. 
X - Just do it once, and do it right... For many settings. For myself. 
X Ideally, the base layer should be thicker to give the print structure. 
X - Fix this at the native model: Done. Now I have 2 layers
X It's not nice that files with exposures from 2-20 look identical to files 1-10. After printing this will get confusing. 
X - It would be nice to update the model to have the values: Done
X Label the files with the layer: Done
X Add Layer height to STL: Done
X STLs: 1-10, 11-20, 2-20; X 20µm, 50µm = 6.  If I do 20,30,40,50 = 12: Done
X Slice files with different levels of Antialiasing (0,4,8): Done
X cbddlp: Aliasing 0, 4, 8: Done
X Total = 18. Not terrible, but pretty big... Done
X Do I really need to put the printer into 'test-mode'? Yes. Otherwise the build plate lifts between test exposures
X Fix the 11-20 files. The 3rd layer did not show the correct exposure. 
X - Tweak file by setting 3rd layer as base layer but with 10s exposure. 
X - Alternatively: Tweak the base model so that print from 1-20 are in a single printout. 
X 2 base layers is pretty thin at 50 µm. 
X - I could use 3 base layers. I could also set all test to print the first 3 layers at 50 µm
X Compare if there is any difference between aliasing levels. 
X - If not: Delete the files. Yes there are.
X Do a validation print once a setpoint is found. Done. Printed the AmeraLabs Town and it looks pretty good.

- Figure out why, when in test mode, the printer go so high?
- - There is "End-g-code" I can use in CHitubox"
- Why does the printer go so high after the print. 


- I tested:
_50um_1-10s_UvTest2_v22_a0.cbddlp: Printed kind of as expected. Too little exposure overall. The text and labels failed.
_50um_11-20s_UvTest2_v22_a0.cbddlp: Did not print as expected. The 3rd layer did not show the 10s required exposure. 
- - I will try changing the 
_50um_2-20s_UvTest2_v22_a0.cbddlp: Printed kind of as expected. Found exposure level. 
_10um_1-10s_UvTest2-v22_a0.cbddlp

50um_a8_UVTest_v19.cbddlp: Printed as expected. Best exposure at 21.7C = 18s
50um_a0_UVTest_v19.cbddlp: Printed as expected. Best exposure at 21.7C = 10.5s
20um_a8_UVTest_v21.cbddlp: 


![image](https://user-images.githubusercontent.com/11083514/40305607-1e75f01e-5cf3-11e8-9aad-a041dc8027ce.png)

---
Kudos to @Reonarudo for finding what makes .photon files tick. 
Check his project to convert images into .photon files (here)[https://github.com/Reonarudo/pcb2photon]

Kudos to toluse for creating the template for tweaking the .cbddlp files (here)[https://github.com/toluse/photon-resin-calibration]

