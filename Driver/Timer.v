module Timer(reset,start,time_to_move,clk,done);

input  [4:0]time_to_move;
input  reset,clk ,start;
output done;

reg [4:0]counter ;

assign done = (counter == time_to_move ) ? 1 : 0 ;

always@(posedge clk or posedge reset)begin

    if(reset)begin
        counter <= 0;
    end
    else begin
       if(start)begin
            
            if(counter == time_to_move)
                    counter <= 0;
                else 
                    counter <= counter ;


            counter <= counter + 1 ;
       end
       else begin
            counter <= 0;
       end 


    end

end

endmodule