module VrSMex(CLOCK, RESET, Data_RDY, interpolate_count, loaded, shift_done, interpolate_count_ENP, CIC_en, pulse_slow, pulse_fast, data_select, sample_rdy, load_result_slow, load_result_fast);
  input CLOCK, RESET, Data_RDY, interpolate_count, shift_done, loaded;
  output interpolate_count_ENP, CIC_en, pulse_slow, pulse_fast, data_select, sample_rdy, load_result_slow, load_result_fast;
  reg interpolate_count_ENP, CIC_en, pulse_slow, pulse_fast, data_select, sample_rdy, load_result_slow, load_result_fast;
  reg [3:0] Sreg, Snext;          // State register and next state
  parameter [3:0] INIT            = 4'b0000,  // Define the states
                  LOAD_SLOW1      = 4'b0001,
                  LOAD_SLOW2      = 4'b0010,
                  WAIT            = 4'b0011,
                  LOAD_FAST1      = 4'b0100,
                  LOAD_FAST2      = 4'b0101,
                  SEND            = 4'b0110,
                  LOAD_FAST_INIT1 = 4'b0111,
                  LOAD_FAST_INIT2 = 4'b1000;               
                   
  always @ (posedge CLOCK)	 // Create the state memory
  if (RESET==1) Sreg <= INIT;
  else Sreg <= Snext;

  always @ (Data_RDY, interpolate_count, shift_done, Sreg, loaded) begin  // Next-state logic
    case (Sreg)
      INIT:         if (Data_RDY==1) Snext = LOAD_SLOW1;
                    else Snext = INIT;
      LOAD_SLOW1:   Snext = LOAD_SLOW2;
      LOAD_SLOW2:   Snext = LOAD_FAST_INIT1;
      LOAD_FAST1:   Snext = LOAD_FAST2;
      LOAD_FAST2:   Snext = SEND;
      WAIT:         if (interpolate_count==1)  Snext = INIT;
                    else if (shift_done==1) Snext = LOAD_FAST1;
                    else Snext = WAIT;
      SEND:         Snext = WAIT;
      LOAD_FAST_INIT1:    Snext = LOAD_FAST_INIT2;
      LOAD_FAST_INIT2:    Snext = SEND;           
      default:      Snext = INIT;
    endcase
  end

  always @ (Sreg) // Output logic
  begin
    interpolate_count_ENP = 1'b0;
    CIC_en = 1'b1;
    pulse_slow = 1'b0;
    pulse_fast = 1'b0;
    data_select = 1'b0;
    sample_rdy = 1'b0;
    load_result_slow = 1'b0;
    load_result_fast = 1'b0;
    case (Sreg)
      LOAD_SLOW1:   begin
                    load_result_slow = 1'b1;
                    pulse_slow = 1'b1;                    
                    end                                  
      LOAD_SLOW2:   begin
                    end
      LOAD_FAST1:    begin
                     load_result_fast = 1'b1;
                     pulse_fast = 1'b1;                     
                     end
      LOAD_FAST2:    begin
                     end                     
      SEND:         begin
                    sample_rdy = 1'b1;
                    interpolate_count_ENP = 1'b1;                    
                    end
      LOAD_FAST_INIT1:    begin
                          load_result_fast = 1'b1;
                          data_select = 1'b1;
                          pulse_fast = 1'b1;                          
                          end
      LOAD_FAST_INIT2:    begin
                          end                                                  
                                           
      default:      begin 
                    interpolate_count_ENP = 1'b0;
                    CIC_en = 1'b1;
                    pulse_slow = 1'b0;
                    pulse_fast = 1'b0;
                    data_select = 1'b0;                    
                    sample_rdy = 1'b0;
                    load_result_slow = 1'b0;
                    load_result_fast = 1'b0;    
                    end
    endcase
  end
endmodule