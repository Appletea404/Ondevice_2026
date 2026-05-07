`timescale 1ns / 1ps


module tb_dht11_cntr();

    reg clk, reset_p;
    tri1 dht11_data;        // 풀업 달려있는 변수, 시뮬레이션 상이라서 가능한거임 
    wire [7:0] humidity, temperature;
    
    reg dout, wr_e;
    assign dht11_data = wr_e ? dout : 'bz;
    // 'bz는 고임피던스 z상태를 의미함

    dht11_cntr DUT(
    .clk(clk), .reset_p(reset_p),
    .dht11_data(dht11_data),
    .humidity(humidity), .temperature(temperature)
    );
    
    initial begin
        clk = 0;
        reset_p = 1;
        wr_e = 0;
        dout = 0;
        
    end

    always #5 clk = ~clk;       // #5는 5ns delay test_bench에서만 사용가능
    
    localparam [7:0] humi_value = 8'd10;
    localparam [7:0] temp_value = 8'd25;
    localparam [7:0] check_sum = humi_value + temp_value;
    localparam [39:0] data = {humi_value, 8'd0, temp_value, 8'd0, check_sum};
    
    integer i;
    
    
    
    initial begin
        #10; reset_p = 0;
        #10;
        wait(!dht11_data);
        wait(dht11_data);
        #20_000;
        dout = 0; wr_e = 1; #80_000;
        wr_e = 0; #80_000;
        wr_e = 1;
        
        for(i = 0; i < 40; i = i + 1) begin
            dout = 0; wr_e = 1; #50_000;
            dout = 1;
            if(data[39-i]) #70_000;
            else #28_000;
        end
        
        dout = 0; #10;
        wr_e = 0; #100_000;
        $stop;
        
        
        
    end
endmodule
