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