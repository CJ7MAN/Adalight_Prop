# Adalight_Prop
Adalight protocol for the Parallax Propeller v1 running 2812B LED strips via Serial

Currently 3 files are needed to compile the project:
AmbiLightVer1b_2812B.spin  <--Main program that is the main loop for serial and LED strip communications
LED_ASM_2812B.spin  <--Assembly language "library" that is called from the main program and started on a seperate cog, this one handles all communication with the LED strip
Full-Duplex_COMEngine.spin  <--Assembly language "library" that handles the bit banging serial communications with the host system
