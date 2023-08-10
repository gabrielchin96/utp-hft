module fix_checksum
    #(
        parameter   DATA_WIDTH              = 8,
        parameter   CHECKSUM_WIDTH          = 24,
        parameter   MODULO_WIDTH            = 8,
        parameter   ASCII_WIDTH             = 24
    )(
        // input module
        input                               clk,
        input                               rst,
        input       [DATA_WIDTH-1:0]        data_in,
        output reg  [CHECKSUM_WIDTH-1:0]    checksum,
        output reg                          checksum_valid,
        output reg  [MODULO_WIDTH-1:0]      modulo,
        output reg                          modulo_valid,
        output reg  [ASCII_WIDTH-1:0]       ascii,
        output reg                          ascii_valid,
        output reg  [2:0]                   state
    );

    // internal state machine
    localparam S_IDLE           = 3'h0;
    localparam S_IDLE_1         = 3'h1;
    localparam S_IDLE_2         = 3'h2;
    localparam S_CHECKSUM       = 3'h3;
    localparam S_CHECKSUM_1     = 3'h4;
    localparam S_CHECKSUM_2     = 3'h5;
    localparam S_MODULO         = 3'h6;
    localparam S_ASCII          = 3'h7;

    // internal signals
    reg [DATA_WIDTH-1:0]        temp_data;
    reg [CHECKSUM_WIDTH-1:0]    temp_checksum;
    reg [MODULO_WIDTH-1:0]      temp_modulo;
    
    wire [11:0] temp_bcd;
    wire [23:0] temp_ascii;

    assign temp_data = data_in;

    // implements a modulo function
    // modulo here is synthesizable as it is 2**8
    // This operation can be implemented purely combinatorially 
    // Therefore we only consider combinatorial delay
    // Essentially we are just taking the 8-bit LSB of original value
    assign temp_modulo = checksum_valid? checksum % 256 : 0; 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // initialize
            {checksum, checksum_valid}  <= {24'h0, 1'b0};
            {modulo, modulo_valid}      <= {8'h0, 1'b0};
            {ascii, ascii_valid}        <= {24'h0, 1'b0};
            state                       <= S_IDLE;                     
            temp_checksum               <= 24'h0;

        end else begin
            case (state)
                S_IDLE: begin 
                    if (temp_data == 8'h00) begin
                        temp_checksum <= data_in;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_IDLE_1;
                    end
                    else begin
                        temp_checksum <= 24'h0;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_IDLE;
                    end
                end

                S_IDLE_1: begin 
                    if (temp_data == 8'h00) begin
                        temp_checksum <= temp_checksum + data_in;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_IDLE_1;
                    end
                    else if (temp_data == 8'h38) begin
                        temp_checksum <= temp_checksum + data_in;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_IDLE_2;
                    end
                    else begin
                        temp_checksum <= 24'h0;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_IDLE;
                    end
                end

                S_IDLE_2: begin 
                    if (temp_data == 8'h3D) begin
                        temp_checksum <= temp_checksum + data_in;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_CHECKSUM;
                    end
                    else begin
                        temp_checksum <= 24'h0;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_IDLE;
                    end
                end

                S_CHECKSUM: begin
                    if (temp_data == 8'h31) begin
                        temp_checksum <= temp_checksum + data_in;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_CHECKSUM_1;
                    end
                    else begin
                        temp_checksum <= temp_checksum + data_in;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_CHECKSUM;
                    end
                end

                S_CHECKSUM_1: begin
                    if (temp_data == 8'h30) begin
                        temp_checksum <= temp_checksum + data_in;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_CHECKSUM_2;
                    end
                    else begin
                        temp_checksum <= temp_checksum + data_in;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_CHECKSUM;
                    end
                end

                S_CHECKSUM_2: begin
                    if (temp_data == 8'h3D) begin
                        checksum <= temp_checksum - 8'h61;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b1, 1'b0, 1'b0};
                        state <= S_MODULO;
                    end
                    else begin
                        temp_checksum <= temp_checksum + data_in;
                        {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b0};
                        state <= S_CHECKSUM;
                    end
                end

                S_MODULO: begin
                    modulo <= temp_modulo;
                    {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b1, 1'b0};
                    state <= S_ASCII;
                end

                S_ASCII: begin
                    ascii <= temp_ascii;
                    {checksum_valid, modulo_valid, ascii_valid} <= {1'b0, 1'b0, 1'b1};
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase 
        end
    end

    bin2bcd u1_bin2bcd (
        .bin(modulo),
        .bcd(temp_bcd)
    );

    bcd2ascii u1_bcd2ascii (
        .hex(temp_bcd[11:8]),
        .ascii(temp_ascii[23:16])
    );

    bcd2ascii u2_bcd2ascii (
        .hex(temp_bcd[7:4]),
        .ascii(temp_ascii[15:8])
    );

    bcd2ascii u3_bcd2ascii (
        .hex(temp_bcd[3:0]),
        .ascii(temp_ascii[7:0])
    );

endmodule

/*
module bcd2ascii
    (
        input wire [3:0] hex, // Input: 4-bit hex number
        output reg [7:0] ascii // Output: 8-bit ASCII character
    );

    always @ (*)
    begin
        case (hex)
            4'h0: ascii = 8'h30; // ASCII code for "0"
            4'h1: ascii = 8'h31; // ASCII code for "1"
            4'h2: ascii = 8'h32; // ASCII code for "2"
            4'h3: ascii = 8'h33; // ASCII code for "3"
            4'h4: ascii = 8'h34; // ASCII code for "4"
            4'h5: ascii = 8'h35; // ASCII code for "5"
            4'h6: ascii = 8'h36; // ASCII code for "6"
            4'h7: ascii = 8'h37; // ASCII code for "7"
            4'h8: ascii = 8'h38; // ASCII code for "8"
            4'h9: ascii = 8'h39; // ASCII code for "9"
            default: ascii = 8'h3F; // ASCII code for "?"
        endcase
    end
endmodule 
*/

/*
module bin2bcd(
        // input
        input      [7:0]    bin,
        // output
        output reg [11:0]   bcd
    );

    //Internal variables
    reg [3:0] i;   
     
    //Always block - implement the Double Dabble algorithm
    always @(*)
        begin
            bcd = 0; //initialize bcd to zero.
            for (i = 0; i < 8; i = i+1) //run for 8 iterations
            begin
                bcd = {bcd[10:0],bin[7-i]}; //concatenation

                //if a hex digit of 'bcd' is more than 4, add 3 to it.  
                if(i < 7 && bcd[3:0] > 4) 
                    bcd[3:0] = bcd[3:0] + 3;
                if(i < 7 && bcd[7:4] > 4)
                    bcd[7:4] = bcd[7:4] + 3;
                if(i < 7 && bcd[11:8] > 4)
                    bcd[11:8] = bcd[11:8] + 3;  
            end
        end                    
endmodule
*/