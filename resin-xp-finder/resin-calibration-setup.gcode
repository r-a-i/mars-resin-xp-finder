; File       : Elegoo Mars calibration test setup
; Author     : Delio Brignoli. Extended by Rodrigo Alvarez
; Created on : 2019-10-05

M8016 D0    ; The number of milliseconds to wait after z rises
M8015 P0    ; Z slow rise speed
M8016 P0    ; Z speed of rapid rise and fall
M8008 I5    ; Acceleration - higher acceleration = faster the overall print time. Too high will cause step loss
M8070 S0    ; Peel move SLOW MOVE in mm - 0 = Disabled > speed set by M8015 
M8070 Z0    ; Peel lift distance FAST MOVE in mm 0 = Disabled > speed set by M8016
M8026 I145  ; Z maximum stroke, the stroke is the movement stroke of Z. This is to avoid having the z-axis go too high after the print. 

M8510       ; Make the configuration effective immediately, but do not save the configuration
