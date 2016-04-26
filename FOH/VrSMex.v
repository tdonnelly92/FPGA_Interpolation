module VrSMex(CLOCK, RESET, Data_RDY, interpolate_count, shift_done, RegA, RegB, RegC, interpolate_count_ENP, init_C, sample_rdy);
  input CLOCK, RESET, Data_RDY, interpolate_count, shift_done;
  output [2:0] RegA, RegB, RegC;
  output init_C, interpolate_count_ENP, sample_rdy;
  reg [2:0] RegA, RegB, RegC;
  reg init_C, interpolate_count_ENP, sample_rdy;
  reg [3:0] Sreg, Snext;          // State register and next state
  parameter [3:0] INIT            = 4'b0000,  // Define the states
                  LOADA           = 4'b0001,                  
                  LOADB           = 4'b0010,                  
                  LOADC_INIT      = 4'b0011,
                  SAMPLE_RDY      = 4'b0100,
                  WAIT            = 4'b0101,                  
                  LOADC           = 4'b0110,
                  LOADB_DELAY     = 4'b1001,
                  LOADB_DELAY_2   = 4'b1010;
                  
  always @ (posedge CLOCK)	 // Create the state memory
  if (RESET==1) Sreg <= INIT;
  else Sreg <= Snext;

  always @ (Data_RDY, interpolate_count, shift_done, Sreg) begin  // Next-state logic
    case (Sreg)
      INIT:         if (Data_RDY==1) Snext = LOADA;
                    else Snext = INIT;
      LOADA:        Snext = LOADB;      
      LOADB:        Snext = LOADB_DELAY;
      LOADB_DELAY:  Snext = LOADB_DELAY_2;
      LOADB_DELAY_2: Snext = LOADC_INIT;
      LOADC_INIT:   Snext = SAMPLE_RDY;
      SAMPLE_RDY:   if (interpolate_count==1)  Snext = INIT;
                    else Snext = WAIT;
      WAIT:         if (interpolate_count==1)  Snext = INIT;
                    else if (shift_done==1) Snext = LOADC;
                    else Snext = WAIT;   
      LOADC:        Snext = SAMPLE_RDY;              
      default:      Snext = INIT;
    endcase
  end

  always @ (Sreg) // Output logic
  begin
    RegA = 3'b000;
    RegB = 3'b000;
    RegC = 3'b000;
    init_C = 1'b0;
    interpolate_count_ENP = 1'b0;
    sample_rdy = 1'b0;
    case (Sreg)
      LOADA:        RegA = 3'b001;                           
      LOADB:        begin
                    RegB = 3'b001;
                    init_C = 1'b1;
                    end
      /*
      LOADB_DELAY:  init_C = 1'b1;
      LOADB_DELAY_2:  init_C = 1'b1;
      */
      LOADC_INIT:   begin
                    RegC = 3'b001;
                    init_C = 1'b1;
                    end
      SAMPLE_RDY:   sample_rdy = 1'b1;
      WAIT:         begin
                    end
      LOADC:        begin
                    RegC = 3'b001;
                    interpolate_count_ENP = 1'b1;
                    end                                                                          
      default:      begin 
                    RegA = 3'b000;
                    RegB = 3'b000;
                    RegC = 3'b000;
                    init_C = 1'b0;
                    interpolate_count_ENP = 1'b0;
                    sample_rdy = 1'b0;
                    end
    endcase
  end
endmodule
