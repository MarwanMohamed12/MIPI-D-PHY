
`timescale 1ns/1ps

module CLKHSTX_tb;

  // Inputs
  reg HS_BYTE_CLK;
  reg enable;
  reg TxRst;
  reg TxDDR_CLK;
  reg TxRequestHS;
  reg TX_ULPS_Exit;
  reg TX_ULPS_CLK;
  reg DATA_LANE_STP_S;

  // Outputs
  wire STOP_STATE;
  wire ULPS_ACTIVE_NOT;
  wire DATA_LANE_START;
  wire CLK_DP;
  wire CLK_DN;

  // Instantiate the DUT
  CLKHSTX dut (
    .HS_BYTE_CLK(HS_BYTE_CLK),
    .enable(enable),
    .TxRst(TxRst),
    .TxDDR_CLK(TxDDR_CLK),
    .TxRequestHS(TxRequestHS),
    .TX_ULPS_Exit(TX_ULPS_Exit),
    .TX_ULPS_CLK(TX_ULPS_CLK),
    .DATA_LANE_STP_S(DATA_LANE_STP_S),
    .STOP_STATE(STOP_STATE),
    .ULPS_ACTIVE_NOT(ULPS_ACTIVE_NOT),
    .DATA_LANE_START(DATA_LANE_START),
    .CLK_DP(CLK_DP),
    .CLK_DN(CLK_DN)
  );

  // Clock generation: HS_BYTE_CLK
  initial HS_BYTE_CLK = 0;
  always #5 HS_BYTE_CLK = ~HS_BYTE_CLK;  // 100 MHz byte clock

  // DDR Clock for HS_CLK toggling
  initial TxDDR_CLK = 0;
  always #2 TxDDR_CLK = ~TxDDR_CLK; // 250 MHz HS toggling clock

  // Test sequence
  initial begin
    // Initialize
    TxRst = 1;
    enable = 0;
    TxRequestHS = 0;
    TX_ULPS_CLK = 0;
    TX_ULPS_Exit = 0;
    DATA_LANE_STP_S = 0;

    #20;
    TxRst = 0;
    enable = 1;

    // --- TEST HS TRANSMISSION ---
    $display("Starting HS transmission");
    TxRequestHS = 1;
    #200; // Wait long enough to go through PREPARE, GO, PRE, CLK

    TxRequestHS = 0; // stop HS CLK, should go to POST/TRAIL/EXIT
    
    wait(STOP_STATE);
    
    // --- TEST ULPS MODE ---
    $display("Starting ULPS entry");
    TX_ULPS_CLK = 1;
    #20;
    TX_ULPS_CLK = 0;
    #100;

    TX_ULPS_Exit = 1;
    #20;
    TX_ULPS_Exit = 0;
    #50;

    $display("Test complete");
    $stop;
  end

  // Optional monitor: print outputs at every HS_BYTE_CLK posedge
  always @(posedge HS_BYTE_CLK) begin
    $display("Time=%0t | PS=%0d | CLK_DP=%b CLK_DN=%b DATA_LANE=%b STOP=%b ULPS=%b",
             $time, dut.ps, CLK_DP, CLK_DN, DATA_LANE_START, STOP_STATE, ULPS_ACTIVE_NOT);
  end

endmodule
