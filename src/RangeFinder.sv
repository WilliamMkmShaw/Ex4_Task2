`default_nettype none
module RangeFinder
  #(parameter WIDTH=16)
  (input logic [WIDTH-1:0] data_in,
   input logic clock, reset,
   input logic go, finish,
   output logic [WIDTH-1:0] range,
   output logic debug_error);

  // Reg values for high_q and low_q
  logic [WIDTH-1:0] high_q, low_q;

  // States:
  // FSM 
  enum logic [1:0] {DONE, RUN, ERROR} currState, nextState;

  // State assignment Logic
  always_comb begin
    case (currState)
      DONE : begin
        if (finish) nextState = ERROR;   // Error, go and finish, or just finish before go
        else if (go) nextState = RUN;
        else nextState = DONE;
      end
      RUN : begin
        if (go && finish) nextState = ERROR;
        else if (finish) nextState = DONE;
        else nextState = RUN;
      end
      ERROR : begin
        if (go) nextState = RUN;
        else nextState = ERROR;
      end
      default: begin
        if (finish) nextState = ERROR;   // Error, go and finish, or just finish before go
        else if (go) nextState = RUN;
        else nextState = DONE;
      end
    endcase
  end

  // Output logic:
  always_comb begin
    debug_error = (currState == ERROR) ? 1 : 0;
    range = high_q - low_q;
  end

  // Register logic
  always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
      currState <= DONE;
      high_q <= {WIDTH{1'b0}};
      low_q <= {WIDTH{1'b1}};
    end
    else begin
      currState <= nextState;

      if (currState == RUN) begin
        if (data_in > high_q)
          high_q <= data_in;
        if (data_in < low_q)
          low_q <= data_in;
      end
      else begin
        if (go) begin
          high_q <= data_in;
          low_q <= data_in;
        end
      end
    end
  end
endmodule : RangeFinder