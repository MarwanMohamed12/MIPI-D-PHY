module Serializer(Tx_rst,ser_en,Byte_clk,DDR_clk,TX_BYTE_DATA,Serial_B1,Serial_B2);

input ser_en,Byte_clk,DDR_clk;
input [7:0] TX_BYTE_DATA;
output reg Serial_B1,Serial_B2;

reg [7:0]Byte_data ;
reg [2:0]counter ;
// always used to capture data from TX
always @(posedge Byte_clk , posedge Tx_rst) begin
    
    if(Tx_rst)begin
        Byte_data <= 0;
    end
    else begin

        if(ser_en)begin
            Byte_data <= TX_BYTE_DATA;
        end
        else begin
            Byte_data <= 0;
        end

    end 
end
    
// always used to serialize data 
always @(posedge DDR_clk , posedge Tx_rst) begin
    
    if(Tx_rst)begin
        Serial_B1 <=0;
        Serial_B2 <=0;
        counter   <=0
    end
    else begin

        if(ser_en)begin
            Serial_B1 <= Byte_data[counter];
            Serial_B2 <= Byte_data[counter + 1];
            counter <= counter + 2 ;
        end
        else begin
            counter <= 0;
        end

    end 
end
    
endmodule
