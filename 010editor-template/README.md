# 010 Hex Editor Template

Download 010 Editor
Drop cbddlp-hextemplate.bt into the template folder
Open the .photon or .cbddlp file you want to edit
apply the template to reveal the meaning of the blocks

Check the short intro video on how to hack the files
https://www.youtube.com/watch?v=s_NIeiNoKi0&t=24s

The cbddlp files from this project were generated using UvTest2.stl with CHITUBOX 1.6.5.1 using:
- 1 Second per layer (this will be the multiple)
- 1 Bottom layer exposed for 120 s (to ensure it sticks)
- 0 Lifting distance
- Level 8 Antialiasing 
* I could not make this happen on CHITUBOX 1.6.5.1 because it saves cbddlp file version 3 which does not have an obvious lift-distance definition.
* Instead I'm trying to solve this in CHITUBOX 1.5 which I could only download for windows. 
- In Windows with CB 1.5 I made resin-test-50u.B60.1-10_ctb1.5_base.cbddlp


Editing the cbddlp file
- struct header_t header
- - layerHeightmm = 0.05

- struct layer_definition_t layer_definition[12]
- - struct layer_definition_t layer_definition[0]/layerPositionZmm = 0
- - struct layer_definition_t layer_definition[1..12]/layerPositionZmm = 0.05


- In 010 I'm editing resin-test-50u.B60.2-20_ctb1.5_0.cbddlp
Editing the cbddlp file
- struct header_t header
- - layerHeightmm = 0.05
- - exposureTimeSeconds = 2 (For this first file test)
- struct print_parameters_t printParameters: Confirm float liftingDistancemm = 0
- struct layer_definition_t layer_definition[12]
- - struct layer_definition_t layer_definition[0]/layerPositionZmm = 0.05
- - struct layer_definition_t layer_definition[1..12]/layerPositionZmm = 0.1

Success!!! This printed as expected


![image](https://user-images.githubusercontent.com/11083514/40305607-1e75f01e-5cf3-11e8-9aad-a041dc8027ce.png)

---
Kudos to @Reonarudo for finding what makes .photon files tick. 
Check his project to convert images into .photon files (here)[https://github.com/Reonarudo/pcb2photon]
