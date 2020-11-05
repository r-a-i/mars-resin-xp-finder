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
- **Note:** I tried to add the gcode from "resin-calibration-setup.gcode" and "print-mode_restore.gcode" into the CHITUBOX start and end g-code fields (respectively) but it did not produce any observable change. I doubt that these fields get written to the cbddlp file because there dos not seem to be allocation for these data in the file structure.   

Slice and save one file per antialiasing level. 

Save them as <layer_height_>um_a<antialias_level_>_UvTest3_v2x.cbddlp

**Note:** This is a tedious and error prone process. Explore if CHITUBOX can be launched from the terminal and this can be automated into batch mode. 

**Critical:** Use the naming format (NNum_<filename>.cbddlp) because the post processing scripts matches this pattern to define the layer height and edit the files. 

## Post-process the cbddlp files to keep the build plate in place while varying the exposure
- Download 010 Editor and launch it
- Open cbddlp-hextemplate.bt and associate it to the file type (so it gets automatically applied. You can also apply it manually by right clicking on an open file and running it)
 - Menu:Preferences/Templates: Add cbddlp-hextemplate.bt and associate it with a mask of (.cbddlp). This will automatically apply the template to each file. 
- Open the .cbddlp file you want to edit
- Run the 'touch_cbddlp_file.1sc' script on the file (open the script and click the 'play' icon or use the 'play' icon in the tool bar.)
 - Bonus points if you can figure out how to apply the script automatically (and report it here)
 - The script automatically saves and closes the file
 
**Note**: I tried running 010 editor from command line (as a step towards batch mode), but it did not work on the 1st attempt. It makes sense to try to get this running to automate the tedious process of touching all cbddlp files. 

<path_to_010editor> 10um_a8_UVTest_v21.cbddlp -template:../../010editor-template/cbddlp-hextemplate.bt -script:../../010editor-template/touch_cbddlp_file.1sc -noui

 
![image](https://user-images.githubusercontent.com/11083514/40305607-1e75f01e-5cf3-11e8-9aad-a041dc8027ce.png) 

## Print and Read Result
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

# Things To Do 
- Figure out why, when in test mode, the printer go so high? Could this be because of my WhamBam buildplate?
 - Not sure the root cause, but setting the printer's max hight to 145 mm (by running 'setup-max-height-to-145mm.gcode') solves this.
- Include the 'resin-calibration-setup.gcode' start and 'print-mode_restore.gcode' end code within CHITUBOX
 - Tried, but the changes made into the CHITUBOX dialog did not have any effect
 - I'm doubtful that these fields get passed on to the cbddlp file, because the 010 template does not seem to have allocation for them.
  - Next step would be to empirically determine if they work by putting in there obviously observable commands (move up down, turn fan on-off, etc.) 

# Tested: 
- 50um_a0_UVTest_v19.cbddlp: Printed as expected. Best exposure for Siraya Fast Black at 21.7C = 18s. It was surprising that lower antialiasing levels required higher exposure. 
- 50um_a8_UVTest_v19.cbddlp: Printed as expected. Best exposure for Siraya Fast Black at 21.7C = 10.5s
- 20um_a8_UVTest_v21.cbddlp: Printed as expected. Best exposure for Siraya Fast Black at 21.7C = 10.5s. It was surprising that the ideal exposure was not less than for 50 µm.
- 10um_a8_UVTest_v21.cbddlp: Printed as expected. Best exposure for Siraya Fast Black at 21.7C = 10.5s. It was surprising that the ideal exposure was not less than for 50 µm.

---
Kudos to @Reonarudo for finding what makes .photon files tick. 

Kudos to toluse for creating the template for tweaking the .cbddlp files (here)[https://github.com/toluse/photon-resin-calibration]

