module VrSMex(CLOCK, RESET, Data_RDY, interpolate_count, shift_done, loaded, interpolate_count_ENP, sinc_en, pre_load, sample_rdy);
  input CLOCK, RESET, Data_RDY, interpolate_count, shift_done, loaded;
  output interpolate_count_ENP, sinc_en, pre_load, sample_rdy;
  reg interpolate_count_ENP, sinc_en, pre_load, sample_rdy;
  reg [3:0] Sreg, Snext;          
  parameter [3:0] INIT            = 4'd0,
                  PER_LOAD_1      = 4'd1,
                  PER_LOAD_1_WAIT = 4'd2,
                  PER_LOAD_2      = 4'd3,                  
                  LOAD_REG_1      = 4'd4,
                  LOAD_REG_2      = 4'd5,
                  LOAD_MULT_REG   = 4'd6,                  
                  LOAD_ADD_1      = 4'd7,
                  LOAD_ADD_2      = 4'd8,
                  LOAD_ADD_3      = 4'd9,
                  LOAD_ADD_4      = 4'd10,
                  LOAD_ADD_5      = 4'd11,
                  INC_COUNTER     = 4'd12,                  
                  SHIFT_WAIT      = 4'd13,
                  PRE_LOAD_GEN    = 4'd14,
                  LOADED_WAIT     = 4'd15;
                  
                  
  always @ (posedge CLOCK)	 // Create the state memory
  if (RESET==1) Sreg <= PER_LOAD_1_WAIT;
  else Sreg <= Snext;

  always @ (Data_RDY, interpolate_count, shift_done, loaded, Sreg) begin  // Next-state logic
    case (Sreg)
      PER_LOAD_1_WAIT:  if (Data_RDY) Snext = PER_LOAD_2;
                        else Snext = PER_LOAD_1_WAIT;
      PER_LOAD_2:       Snext = LOAD_REG_1;    
      LOAD_REG_1:       Snext = LOAD_REG_2; 
      LOAD_REG_2:       Snext = LOAD_MULT_REG;
      LOAD_MULT_REG:    Snext = LOAD_ADD_1; 
      LOAD_ADD_1:       Snext = LOAD_ADD_2;
      LOAD_ADD_2:       Snext = LOAD_ADD_3;
      LOAD_ADD_3:       Snext = LOAD_ADD_4;
      LOAD_ADD_4:       Snext = LOAD_ADD_5;
      LOAD_ADD_5:       Snext = LOADED_WAIT;
      LOADED_WAIT:      if (loaded) Snext = INC_COUNTER;
                        else Snext = LOADED_WAIT;
      INC_COUNTER:      Snext = SHIFT_WAIT;
      SHIFT_WAIT:       if (interpolate_count) Snext = PER_LOAD_1_WAIT;
                        else if (Data_RDY) Snext = PRE_LOAD_GEN;
                        else if (shift_done) Snext = LOAD_MULT_REG;
                        else Snext = SHIFT_WAIT;
      PRE_LOAD_GEN:     Snext = SHIFT_WAIT;                  
      default:          Snext = PER_LOAD_1_WAIT;
    endcase
  end

  always @ (Sreg) // Output logic
  begin
    interpolate_count_ENP = 1'b0;
    sinc_en = 1'b0;
    pre_load = 1'b0;
    sample_rdy = 1'b0;
    case (Sreg)
        PER_LOAD_2: pre_load = 1'b1;      
        LOAD_REG_1: begin
                    pre_load = 1'b1;
                    sinc_en = 1'b1;
                    end      
        LOAD_REG_2: begin
                    pre_load = 1'b1;
                    sinc_en = 1'b1;
                    end   
        LOAD_ADD_5:   sample_rdy = 1'b1;       
        INC_COUNTER:  interpolate_count_ENP = 1'b1;
        PRE_LOAD_GEN: pre_load = 1'b1;                                                                
      default:      begin 
                      interpolate_count_ENP = 1'b0;
                      sinc_en = 1'b0;
                      pre_load = 1'b0;
                      sample_rdy = 1'b0;
                    end
    endcase
  end
endmodule