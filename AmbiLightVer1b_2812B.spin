con

  _clkmode = xtal1 + pll16x                                     ' run @ 80MHz in XTAL mode
  _xinfreq = 5_000_000                                          ' use 5MHz crystal                                                                                                        
  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  leds = 60
  CLK_PIN = 25
  DAT_PIN = 27


OBJ
  pst1  : "Full-Duplex_COMEngine"
  RGB   : "LED_ASM_2812B"
 
var
  byte incoming
  byte R_IN[leds]
  byte G_IN[leds]
  byte B_IN[leds]
  byte position_counter
  byte LED_Counter
  byte HI_Byte
  byte LO_Byte
  byte CHK_Byte
  byte xor_result
  
pub main
  dira[0] :=1
  dira[1] :=1
  pst1.COMEngineStart(17,16,115_200)
  pst1.receiverFlush
  RGB.start(DAT_PIN, leds)
  
  position_counter := 1
  LED_Counter := 1
  repeat
    incoming := -1
    incoming := pst1.readByte
    if(incoming > -1)
        case position_counter
            1:
                if incoming == "A"      
                    position_counter := 2
            2:
                if incoming == "d"      
                    position_counter := 3
                else 
                    position_counter := 1
            3:
                if incoming == "a"      
                   position_counter :=4
                else 
                    position_counter := 1
            4:
                HI_Byte := incoming
                position_counter := 5
            5:
                LO_Byte := incoming
                position_counter := 6
            6:
                CHK_Byte := incoming
                xor_result := (HI_BYTE ^ LO_Byte ^ $55)
                if CHK_Byte == xor_result
                   position_counter :=7
                   LED_Counter := 1
                else                  
                   position_counter := 1
            7:
                R_IN[LED_Counter] := incoming
                position_counter := 8
            8:
                G_IN[LED_Counter] := incoming
                position_counter := 9
            9:
                B_IN[LED_Counter] := incoming
                RGB.WRITE_LED(LED_COUNTER, R_IN[LED_COUNTER], G_IN[LED_COUNTER], B_IN[LED_COUNTER])
                if LED_Counter == leds
                        !outa[1]
                        position_counter := 1
                        LED_Counter := 1
                        pst1.receiverFlush  
                else
                  LED_Counter++ 
                  position_counter := 7
                              
    
    