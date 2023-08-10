`timescale 1ns / 1ps

module fix_checksum_tb();

    reg             clk;
    reg             rst;
    reg     [7:0]   data_in;
    wire    [23:0]  checksum;
    wire            checksum_valid;
    wire    [11:0]  modulo;
    wire            modulo_valid;
    wire    [23:0]  ascii;
    wire            ascii_valid;
    wire    [2:0]   state;

    fix_checksum uut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .checksum(checksum),
        .checksum_valid(checksum_valid),
        .modulo(modulo),
        .modulo_valid(modulo_valid),
        .ascii(ascii),
        .ascii_valid(ascii_valid),
        .state(state)
    );

    always begin
        // clock generator
        #5 clk = ~clk;
    end

    initial begin
        clk     = 1'b0;
        data_in = 8'hFF;
        rst     = 1'b1;

        #10 rst = 0;

        // JUNK
        #10 data_in = 8'h00;
        #10 data_in = 8'h04;
        #10 data_in = 8'h4B;
        #10 data_in = 8'h02;

        #10 data_in = 8'hF6;
        #10 data_in = 8'h23;
        #10 data_in = 8'h00;
        #10 data_in = 8'h1E;

        #10 data_in = 8'h65;
        #10 data_in = 8'hD6;
        #10 data_in = 8'hA4;
        #10 data_in = 8'hD0;

        #10 data_in = 8'h08;
        #10 data_in = 8'h00;
        #10 data_in = 8'h45;
        #10 data_in = 8'h00;

        #10 data_in = 8'h00;
        #10 data_in = 8'hCF;
        #10 data_in = 8'h4E;
        #10 data_in = 8'hC6;

        #10 data_in = 8'h40;
        #10 data_in = 8'h00;
        #10 data_in = 8'h80;
        #10 data_in = 8'h06;

        #10 data_in = 8'h94;
        #10 data_in = 8'h76;
        #10 data_in = 8'h0A;
        #10 data_in = 8'h00;

        #10 data_in = 8'h01;
        #10 data_in = 8'h6D;
        #10 data_in = 8'h0A;
        #10 data_in = 8'h00;

        #10 data_in = 8'h01;
        #10 data_in = 8'h80;
        #10 data_in = 8'hC3;
        #10 data_in = 8'h07;

        #10 data_in = 8'h13;
        #10 data_in = 8'h8A;
        #10 data_in = 8'h7F;
        #10 data_in = 8'h60;

        #10 data_in = 8'h31;
        #10 data_in = 8'hDD;
        #10 data_in = 8'hF3;
        #10 data_in = 8'h05;

        #10 data_in = 8'h92;
        #10 data_in = 8'hF4;
        #10 data_in = 8'h50;
        #10 data_in = 8'h18;

        #10 data_in = 8'h44;
        #10 data_in = 8'h12;
        #10 data_in = 8'h22;
        #10 data_in = 8'h74;

        #10 data_in = 8'h00;
        #10 data_in = 8'h00;
        #10 data_in = 8'h00;
        #10 data_in = 8'h00;

        // 1ST FIELD IN MESSAGE
        // sending 8=FIX.4.2
        // TAG "8" BeginString
        #10 data_in = 8'h00; // 0
        #10 data_in = 8'h00; // 0
        #10 data_in = 8'h38; // 8
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE
        #10 data_in = 8'h46; // F
        #10 data_in = 8'h49; // I
        #10 data_in = 8'h58; // X
        #10 data_in = 8'h2E; // .
        #10 data_in = 8'h34; // 4
        #10 data_in = 8'h2E; // .
        #10 data_in = 8'h32; // 2
        // "SOH"
        #10 data_in = 8'h01; // SOH

        // 2ND FIELD IN MESSAGE
        // sending 9=144 (bytes)
        // TAG "9" BodyLength
        #10 data_in = 8'h39; // 9
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE
        #10 data_in = 8'h31; // 1
        #10 data_in = 8'h34; // 4
        #10 data_in = 8'h34; // 4
        // "SOH"
        #10 data_in = 8'h01; // SOH

        // 3RD FIELD IN MESSAGE
        // sending 35=D (order)
        // TAG "35" MsgType
        #10 data_in = 8'h33; // 3
        #10 data_in = 8'h35; // 5
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE
        #10 data_in = 8'h44; // D (order)
        // "SOH"
        #10 data_in = 8'h01; // SOH

// Edit the comments
        // sending 
        // TAG "34" MsgSeqNum
        #10 data_in = 8'h33; // 3
        #10 data_in = 8'h34; // 4
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE
        #10 data_in = 8'h32; // 2
        // "SOH"
        #10 data_in = 8'h01; // SOH

        // sending 
        // TAG "49" SenderCompID
        #10 data_in = 8'h34; // 4
        #10 data_in = 8'h39; // 9
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE 
        #10 data_in = 8'h43; // C
        #10 data_in = 8'h4C; // L
        #10 data_in = 8'h49; // I
        #10 data_in = 8'h45; // E
        #10 data_in = 8'h4E; // N
        #10 data_in = 8'h54; // T
        #10 data_in = 8'h31; // 1  
        // "SOH"
        #10 data_in = 8'h01; // SOH  

        // sending 
        // TAG "52" SendingTime
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h32; // 2
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE 
        #10 data_in = 8'h32; // 2
        #10 data_in = 8'h30; // 0
        #10 data_in = 8'h31; // 1
        #10 data_in = 8'h30; // 0
        #10 data_in = 8'h30; // 0
        #10 data_in = 8'h36; // 6
        #10 data_in = 8'h30; // 0
        #10 data_in = 8'h34; // 4
        #10 data_in = 8'h2D; // -
        #10 data_in = 8'h32; // 2
        #10 data_in = 8'h33; // 3
        #10 data_in = 8'h3A; // :
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h38; // 8
        #10 data_in = 8'h3A; // :
        #10 data_in = 8'h34; // 4
        #10 data_in = 8'h38; // 8
        #10 data_in = 8'h2E; // :
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h36; // 6      
        // "SOH"
        #10 data_in = 8'h01; // SOH  

        // sending 
        // TAG "56" TargetCompID
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h36; // 6
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE 
        #10 data_in = 8'h4F; // O
        #10 data_in = 8'h52; // R
        #10 data_in = 8'h44; // D
        #10 data_in = 8'h45; // E
        #10 data_in = 8'h52; // R
        #10 data_in = 8'h4D; // M
        #10 data_in = 8'h41; // A
        #10 data_in = 8'h54; // T
        #10 data_in = 8'h43; // C
        #10 data_in = 8'h48; // H      
        // "SOH"
        #10 data_in = 8'h01; // SOH       

        // sending 
        // TAG "11" ClOrdID
        #10 data_in = 8'h31; // 1 
        #10 data_in = 8'h31; // 1
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE 
        #10 data_in = 8'h31; // 1
        #10 data_in = 8'h32; // 2
        #10 data_in = 8'h37; // 7
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h36; // 6
        #10 data_in = 8'h39; // 9
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h39; // 9
        #10 data_in = 8'h32; // 2
        #10 data_in = 8'h38; // 8
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h31; // 1
        #10 data_in = 8'h31; // 1
        // "SOH"
        #10 data_in = 8'h01; // SOH     

        // sending 
        // TAG "21" HandlInst
        #10 data_in = 8'h32; // 2
        #10 data_in = 8'h31; // 1
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE
        #10 data_in = 8'h31; // 1
        // "SOH"
        #10 data_in = 8'h01; // SOH

        // sending 
        // TAG "38" OrderQty
        #10 data_in = 8'h33; // 3
        #10 data_in = 8'h38; // 8
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE
        #10 data_in = 8'h39; // 9
        #10 data_in = 8'h38; // 8
        // "SOH"
        #10 data_in = 8'h01; // SOH

        // sending 
        // TAG "40" OrdType
        #10 data_in = 8'h34; // 4
        #10 data_in = 8'h30; // 0
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE
        #10 data_in = 8'h32; // 2
        // "SOH"
        #10 data_in = 8'h01; // SOH

        // sending 
        // TAG "44" Price
        #10 data_in = 8'h34; // 4
        #10 data_in = 8'h34; // 4
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE 
        #10 data_in = 8'h31; // 1
        #10 data_in = 8'h30; // 0
        #10 data_in = 8'h32; // 2
        #10 data_in = 8'h2E; // .
        #10 data_in = 8'h37; // 7
        // "SOH"
        #10 data_in = 8'h01; // SOH    

        // sending 
        // TAG "54" Side
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h34; // 4
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE 
        #10 data_in = 8'h31; // 1
        // "SOH"
        #10 data_in = 8'h01; // SOH

        // sending 
        // TAG "55" Symbol
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h35; // 5
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE 
        #10 data_in = 8'h49; // I
        #10 data_in = 8'h42; // B
        #10 data_in = 8'h4D; // M   
        // "SOH"
        #10 data_in = 8'h01; // SOH  

        // sending 
        // TAG "59" TimeInForce
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h39; // 9
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE 
        #10 data_in = 8'h30; // 0
        // "SOH"
        #10 data_in = 8'h01; // SOH

        // sending 
        // TAG "60" TransactTime
        #10 data_in = 8'h36; // 6
        #10 data_in = 8'h30; // 0
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE 
        #10 data_in = 8'h32; // 2
        #10 data_in = 8'h30; // 0
        #10 data_in = 8'h31; // 1
        #10 data_in = 8'h30; // 0
        #10 data_in = 8'h30; // 0
        #10 data_in = 8'h36; // 6
        #10 data_in = 8'h30; // 0
        #10 data_in = 8'h34; // 4
        #10 data_in = 8'h2D; // -
        #10 data_in = 8'h32; // 2
        #10 data_in = 8'h33; // 3
        #10 data_in = 8'h3A; // :
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h38; // 8
        #10 data_in = 8'h3A; // :
        #10 data_in = 8'h34; // 4
        #10 data_in = 8'h38; // 8
        #10 data_in = 8'h2E; // .
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h35; // 5
        #10 data_in = 8'h31; // 1
        // "SOH"
        #10 data_in = 8'h01; // SOH

        // LAST FIELD IN MESSAGE
        // sending 10=180
        // TAG "10" CheckSum
        #10 data_in = 8'h31; // 5
        #10 data_in = 8'h30; // 6
        // "="
        #10 data_in = 8'h3D; // =
        // VALUE 
        #10 data_in = 8'h31; // 1
        #10 data_in = 8'h38; // 8
        #10 data_in = 8'h30; // 0   
        // "SOH"
        #10 data_in = 8'h01; // SOH    

        #10000
        $finish;
    end

endmodule