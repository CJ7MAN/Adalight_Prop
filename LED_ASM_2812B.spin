{{ AssemblyToggle.spin }}

CON
_clkmode = xtal1 + pll16x
_xinfreq = 5_000_000
LED_COUNT = 60
NS0H  =   278                                '270 250 0-bit high timing in nanoseconts 350
NS0L  =   664                                '700 675 0-bit low timing in nanoseconds 900
NS1H  =   645                                '670 650 1-bit high timing in nanoseconds 350
NS1L  =   296                                '300 275 1-bit low timing in nanoseconds 900

var
long ready                      
byte cog
long Dat_Pin
long Num_Leds
long RESETTICKS
long T0H
long T0L
long T1H
long T1L
byte RED[LED_COUNT]
byte GREEN[LED_COUNT]
byte BLUE[LED_COUNT]


PUB start(DAT_IN, Num_Leds_IN) | USTIX
    USTIX       :=  clkfreq / 1_000_000
    Dat_Pin     :=  |< DAT_IN
    Num_Leds    :=  Num_Leds_IN
    RESETTICKS  :=  USTIX * 60 
    T0H         :=  USTIX * NS0H / 1000
    T0L         :=  USTIX * NS0L / 1000
    T1H         :=  USTIX * NS1H / 1000
    T1L         :=  USTIX * NS1L / 1000
    stop
    cognew(@LED_DRIVER,@Dat_Pin)            'Launch new cog passing the address of the Driver and start of Global data address

PUB stop
    if cog
        cogstop(cog~ -1)
        
PUB Write_COLOR(RED_IN, GREEN_IN, BLUE_IN) |c
    repeat c from 0 to Num_Leds             'copy the RGB values into entire Buffer
        RED[c]      := RED_IN
        GREEN[c]    := GREEN_IN
        BLUE[c]     := BLUE_IN
    ready := true                           'Set ready flag so that the LED_DRIVER will paint frame
                       
PUB Write_LED(LED_NUM, RED_IN, GREEN_IN, BLUE_IN)
 '   ready := false
    RED[LED_NUM]    := RED_IN               'Set a specific LED RGB Values  
    GREEN[LED_NUM]  := GREEN_IN
    BLUE[LED_NUM]   := BLUE_IN
 '   RED[LED_NUM] := 255
 '   BLUE[LED_NUM] := 255
 '   GREEN[LED_NUM] := 255
 '   ready := true  
                                           
                       
DAT
            org     0                       'Begin at Cog RAM addr 0
LED_DRIVER  mov     Addr,       par
            rdlong  DATPIN,     Addr        'Read DATPIN
            add     Addr,       #4          'Move address counter one long
            rdlong  NUM_LED,    Addr        'Read LED_COUNT
            add     Addr,       #4          'Move Address Counter one long
            rdlong  LatchDelay, Addr       'Etc....
            add     Addr,       #4
            rdlong  bit0hi,     Addr
            add     Addr,       #4
            rdlong  bit0lo,     Addr
            add     Addr,       #4
            rdlong  bit1hi,     Addr
            add     Addr,       #4
            rdlong  bit1lo,     Addr
            add     Addr,       #4                                
            mov     LED_Addr,   Addr        'Move Address of LED Array to LED_Addr 
            or      dira,       DATPIN      'set DATPIN as output


            
main_loop   'rdlong  check,      _ready      'move ready status into check variable
            'tjz     check,      #main_loop  'if not ready check again until it is ready
            mov     Time,       LatchDelay  'Move Latch Delay into Time
            add     Time,       cnt         'Add the delay to the Time so we can ensure the latch happens
            waitcnt Time,       #0          'wait for the LatchDelay to happen then continue                                
            mov     LED_CNT,    #60 'NUM_LED    'restart LED counter
            mov     RED_PTR,    LED_Addr    'reset RED_PTR to start pushing out colors
            add     RED_PTR,    #2          'increment address to account for the 0 position in the arrays
            mov     GREEN_PTR,  RED_PTR     'set the green pointer the same as the red 
            add     GREEN_PTR,  NUM_LED     'add the number of bytes(leds) to point to start of Green array
            mov     BLUE_PTR,   GREEN_PTR   'set the blue pointer the same as the green
            add     BLUE_PTR,   NUM_LED     'add the number of bytes(leds) to point to the start of the Blue array     
                                                              
:strip_loop 
            rdbyte  colourbits, GREEN_PTR   'read byte at current position in LED buffer
            shl     colourbits, #8          'Shift Green Byte left
            rdbyte  Byte_Out,   RED_PTR
            or      colourbits, Byte_Out
            shl     colourbits, #8
            rdbyte  Byte_Out,   BLUE_PTR
            or      colourbits, Byte_Out
:shift_out
            shl     colourbits, #8          'Shift out the left most byte as it has no data
            mov     nbits,      #24
:led_loop
            rcl     colourbits, #1      wc
      if_c  mov     Time,       bit1hi
      if_nc mov     Time,       bit0hi
            or      outa,       DATPIN
            add     Time,       cnt
      if_c  waitcnt Time,       bit1lo
      if_nc waitcnt Time,       bit0lo
            andn    outa,       DATPIN
            waitcnt Time,       #0
            djnz    nbits,      #:led_loop
            add     GREEN_PTR,  #1
            add     RED_PTR,    #1
            add     BLUE_PTR,   #1
            djnz    LED_CNT,    #:strip_loop
            jmp     #main_loop
            
'--------------------------------------------------------------------------------------------------------------------- 

            _ready      res     1           'Stores location of the global ready variable
            LatchDelay  res     1           'Delay for latching
            Time        res     1           'System Counter Workspace
            Addr        res     1           'Address storage
            LED_Addr    res     1           'LED ARRAY ADDRESS
            RED_PTR     res     1           'Used to push the leds and count thought the mem spaces
            GREEN_PTR   res     1
            BLUE_PTR    res     1
            counter     res     1
            DATPIN      res     1 
            PIN_DATA    res     1
            Byte_Out    res     1
            Byte_CHK    res     1
            LED_CNT     res     1
            NUM_LED     res     1
            check       res     1
            bit0hi      res     1
            bit0lo      res     1
            bit1hi      res     1
            bit1lo      res     1
            colourbits  res     1
            nbits       res     1
            fit                 