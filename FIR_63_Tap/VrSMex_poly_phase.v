module VrSMex_poly_phase(CLOCK, RESET, Data_RDY, interpolate_count, shift_done, interpolate_count_ENP, FIR_en, sample_rdy);
  input CLOCK, RESET, Data_RDY, interpolate_count, shift_done;
  output interpolate_count_ENP, FIR_en, sample_rdy;
  reg interpolate_count_ENP, FIR_en, sample_rdy;
  reg [3:0] Sreg, Snext;          // State register and next state
  parameter [3:0] INIT             = 4'b0000, 
                  LOAD_DELAY       = 4'b0001,                  
                  LOAD_MULT        = 4'b0010,
                  LOAD_SUM0        = 4'b0011,                  
                  LOAD_SUM1        = 4'b0100,
                  LOAD_SUM2        = 4'b0101,
                  DATA_RDY         = 4'b0110,
                  SHIFT_WAIT       = 4'b0111,
                  COUNT            = 4'b1000,
                  COUNT_CHK        = 4'b1001;     
                  
  always @ (posedge CLOCK)	 // Create the state memory
  if (RESET==1) Sreg <= INIT;
  else Sreg <= Snext;

  always @ (Data_RDY, interpolate_count, shift_done, Sreg) begin  // Next-state logic
    case (Sreg)
        INIT:         if (Data_RDY==1) Snext = LOAD_DELAY;
                      else Snext = INIT;
        LOAD_DELAY:   Snext = LOAD_MULT;      
        LOAD_MULT:    Snext = LOAD_SUM0;
        LOAD_SUM0:    Snext = LOAD_SUM1;                     
        LOAD_SUM1:    Snext = LOAD_SUM2;   
        LOAD_SUM2:    Snext = DATA_RDY;   
        DATA_RDY:     Snext = SHIFT_WAIT;   
        SHIFT_WAIT:   if (shift_done==1) Snext = COUNT;
                      else Snext = SHIFT_WAIT;       
        COUNT:        Snext = COUNT_CHK;
        COUNT_CHK:    if (interpolate_count==1) Snext = INIT;
                      else Snext = LOAD_MULT; 
        default:      Snext = INIT;
    endcase
  end

  always @ (Sreg) // Output logic
  begin
    interpolate_count_ENP = 1'b0;
    FIR_en = 1'b0;
    sample_rdy = 1'b0;
    case (Sreg)
      LOAD_DELAY:   FIR_en = 1'b1;                           
      DATA_RDY:     sample_rdy = 1'b1;
      COUNT:        interpolate_count_ENP = 1'b1;                                                                                                  
      default:      begin 
                    interpolate_count_ENP = 1'b0;
                    FIR_en = 1'b0;
                    sample_rdy = 1'b0;
                    end
    endcase
  end
endmodule