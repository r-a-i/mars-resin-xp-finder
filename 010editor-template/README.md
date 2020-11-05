# 010 Hex Editor Template

These instructions describe how to generate the test cbddlp files. They go from the Fusion360 models to the cbddlp files for printing. 

## Edit In Fusion 360
In Fusion 360 edit the model files (UvTest3 vXX.f3d) as necessary and export as STLs (one file per body,0.010 mm precision).
- The files are set so that it is easy to edit the layer height and export new files. 
- There are many STL files with the goal of having the files directly annotate the layer_height, antialiasing level, etc. to avoid confusion later after printing. 

## Slice in CHITUBOX
**Note:** CHITUBOX 1.6.5.1 did not work for generating test patterns. This version (maybe all >1.6.x) saves a cbddlp file version=3 that do not explicitly have a liftingDistancemm field.  It could be that the cbddlp-hextemplate.bt does not properly parse that section for v3. So instead I had to use CHITUBOX 1.5.0 (Included in this git for posterity).

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

**Critical:** Use the naming format (NNum_<filename>.cbddlp) because the post processing scripts matches this pattern to define the layer height and edit the files. 

## Post-process the cbddlp files to keep the build plate in place while varying the exposure
- Download 010 Editor
- Open cbddlp-hextemplate.bt and associate it to the file type (so it gets automatically applied. You can also apply it manually by right clicking on an open file and running it)
 - Menu:Preferences/Templates: Add cbddlp-hextemplate.bt and associate it with a mask of (.cbddlp). This will automatically apply the template to each file. 
- Open the .cbddlp file you want to edit
- Run the 'touch_cbddlp_file.1sc' script on the file (open the script and click the 'play' icon or use the 'play' icon in the tool bar.)
 - Bonus points if you can figure out how to apply the script automatically (and report it here)
 - The script automatically saves and closes the file
 
![image](https://user-images.githubusercontent.com/11083514/40305607-1e75f01e-5cf3-11e8-9aad-a041dc8027ce.png) 

## Print
See '[resin-xp-finder/Instructions.txt](../resin-xp-finder/Instructions.txt)' for details on how to print the cbddlp file. 

# Background
Check the [short intro video](https://www.youtube.com/watch?v=s_NIeiNoKi0&t=24s) on how to hack the files. It is a little outdated but still has the main principles. 

The touch_cbddlp_file.1sc script modifies the following fields for each file:
- struct header_t header
 - layerHeightmm = 0.05 (for the 50 µm layer heigh)
 - exposureTimeSeconds = 1 (This is the exposure time for all the test layers. It overwrites a downstream exposure set in each layer. Set it to 1 for 1-10s and 2 for 2-20s files)
- struct print_parameters_t printParameters: 
 - liftingDistancemm = 0 (Confirm this is set to 0. Otherwise the build plate will lift between exposures, recirculate the resin, and fail the test)
- struct layer_definition_t layer_definition[12] (This is where we hack the printer to expose the test layers at the same height)
 - struct layer_definition_t layer_definition[0]/layerPositionZmm = 0.05 (1st base layer = 0.05 * 1)
 - struct layer_definition_t layer_definition[1]/layerPositionZmm = 0.10 (2nd base layer = 0.05 * 2)
 - struct layer_definition_t layer_definition[2]/layerPositionZmm = 0.15 (3rd base layers = 0.05 * 3)
 - struct layer_definition_t layer_definition[3..N]/layerPositionZmm = 0.15 (0.05 * 3 + layer_height )
Save the file and it is ready for printing. 

# T2D: 
- Figure out why, when in test mode, the printer go so high? Could this be because of my WhamBam buildplate?

# Tested: 
- 50um_a0_UVTest_v19.cbddlp: Printed as expected. Best exposure at 21.7C = 18s. It was surprising that lower antialiasing levels required higher exposure. 
- 50um_a8_UVTest_v19.cbddlp: Printed as expected. Best exposure at 21.7C = 10.5s
- 20um_a8_UVTest_v21.cbddlp: Printed as expected. Best exposure at 21.7C = 10.5s. This was surprising.


---
Kudos to @Reonarudo for finding what makes .photon files tick. 

Kudos to toluse for creating the template for tweaking the .cbddlp files (here)[https://github.com/toluse/photon-resin-calibration]

