/*
    3D = "="
    01 = "SOH"

    FIX message typical format
    8=FIX.4.2SOH --> 00 00 38 (3D) 46 49 58 2E 34 2E 32 (01)

    Assumption is data_in already serialize bit by bit else
    we can run parallel serialization to improve throughput 
*/

module fix_parser
    #(
        parameter   DATA_WIDTH              = 8,
        parameter   TAG_WIDTH               = 24,
        parameter   VALUE_WIDTH             = 21*8,
        parameter   CHECKSUM_WIDTH          = 24,
        parameter   MODULO_WIDTH            = 12,
        parameter   ASCII_WIDTH             = 24
    )(
        // input module
        input                               clk,
        input                               rst,

        input       [DATA_WIDTH-1:0]        data_in,

        // output module
        output reg  [TAG_WIDTH-1:0]         tag,
        output reg                          tag_valid,
        output reg  [VALUE_WIDTH-1:0]       value,
        output reg                          value_valid,
        output reg  [CHECKSUM_WIDTH-1:0]    checksum,
        output reg                          checksum_valid,
        output reg  [1:0]                   state,
        output reg                          parser_valid,
        output reg                          parser_not_valid,
        // fix_checksum
        output reg  [2:0]                   internal_checksum_state
    );

    // internal state machine
    localparam S_IDLE     = 2'b00;
    localparam S_TAG      = 2'b01;
    localparam S_VALUE    = 2'b10;
    localparam S_CHECKSUM = 2'b11;

    // internal signals
    reg [DATA_WIDTH-1:0]    temp_data;
    reg [TAG_WIDTH-1:0]     temp_tag;
    reg [VALUE_WIDTH-1:0]   temp_value;

    // counter
    reg [15:0]  i;

    // fix_checksum
    wire [CHECKSUM_WIDTH-1:0]   internal_checksum;
    wire                        internal_checksum_valid;
    wire [MODULO_WIDTH-1:0]     internal_modulo;
    wire                        internal_modulo_valid;
    wire [ASCII_WIDTH-1:0]      internal_ascii;
    wire                        internal_ascii_valid;

    // comparator of fix parser checksum vs actual data checksum
    reg [CHECKSUM_WIDTH-1:0]   compare_a;
    reg [ASCII_WIDTH-1:0]      compare_b;
    reg [2:0] comparator_state;

    assign temp_data = data_in;

    // Control Path
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // initialize 
            tag             <= 24'h0;
            value           <= 80'h0;
            checksum        <= 24'h0;
            state           <= S_IDLE;
            {tag_valid,value_valid,checksum_valid} <= 3'b000;
        end
        else begin
            // Control Path
            case(state)
                S_IDLE: begin // S0
                    if (temp_data == 8'h00) begin
                        state <= S_TAG;
                    end

                    else begin
                        state <= S_IDLE;
                        {tag_valid,value_valid,checksum_valid} <= 3'b000;
                    end

                end

                S_TAG: begin // S1
                    if (temp_data == 8'h3D) begin
                        state <= S_VALUE;
                        {tag_valid,value_valid,checksum_valid} <= 3'b100;
                    end

                    else begin
                        state <= S_TAG;
                        {tag_valid,value_valid,checksum_valid} <= 3'b000;
                    end
                end

                S_VALUE: begin // S2
                    //if ((temp_data == 8'h01)&&(tag == 24'h003130)) begin
                    if (tag == 24'h003130) begin
                        state <= S_CHECKSUM;
                        {tag_valid,value_valid,checksum_valid} <= 3'b000; 
                    end
                    //else if ((temp_data == 8'h01)&&(tag != 24'h003130)) begin
                    else if (temp_data == 8'h01) begin
                        state <= S_TAG;
                        {tag_valid,value_valid,checksum_valid} <= 3'b010;            
                    end
                    else begin
                        state <= S_VALUE;
                        {tag_valid,value_valid,checksum_valid} <= 3'b000;
                    end
                end

                S_CHECKSUM: begin // S3
                    if (temp_data == 8'h01) begin
                        state <= S_IDLE;
                        {tag_valid,value_valid,checksum_valid} <= 3'b001;
                    end
                    else begin
                        state <= S_CHECKSUM;
                        {tag_valid,value_valid,checksum_valid} <= 3'b000;
                    end
                end
                
                default: state <= S_IDLE;
            endcase
        end
    end

    // Data Path
    always @(posedge clk) begin
        // Data path
        case(state)
            S_IDLE: begin
                {temp_tag, temp_value} <= 0;
                tag             <= 24'h0;
                value           <= 80'h0;
                checksum        <= 24'h0;
                //temp_value   <= 0;
            end

            S_TAG: begin
                // shift register takes 3 clock cycle                
                // tag [7:0]   <= temp_data;
                // tag [15:8]  <= tag [7:0];
                // tag [23:16] <= tag [15:8];

                //temp_value <= 0;
                {temp_tag, temp_value} <= 0;
                tag             <= 24'h0;
                value           <= 80'h0;
                checksum        <= 24'h0;

                temp_tag [TAG_WIDTH-1:0] <= {16'h0, temp_data};

                for (i=1; i<4; i=i+1) begin
                    temp_tag[i*8 +: 8] <= temp_tag[(i-1)*8 +: 8];
                end

                tag <= temp_tag;

            end

            S_VALUE: begin
                // shift register takes maximum of 21 clock cycle

                //temp_tag <= 0;
                {temp_tag, temp_value} <= 0;
                tag             <= 24'h0;
                value           <= 80'h0;
                checksum        <= 24'h0;

                temp_value [VALUE_WIDTH:0] <= {72'h0, temp_data};

                //for (i=1; i<11; i=i+1) begin
                for (i=1; i<(VALUE_WIDTH+1); i=i+1) begin
                    temp_value [i*8 +: 8] <= temp_value [(i-1)*8 +: 8];
                end
                value <= temp_value;
            end

            S_CHECKSUM: begin
                // shift register takes 3 clock cycle

                //temp_tag <= 0;
                {temp_tag, temp_value} <= 0;
                tag             <= 24'h0;
                value           <= 80'h0;
                checksum        <= 24'h0;

                temp_value [VALUE_WIDTH:0] <= {72'h0, temp_data};

                for (i=1; i<4; i=i+1) begin
                    temp_value [i*8 +: 8] <= temp_value [(i-1)*8 +: 8];
                end
                checksum <= temp_value;
            end

            default: begin
                state <= S_IDLE;
            end
        endcase
    end

    // comparator
    // When checksum_valid = 1, x <= checksum
    // When internal_ascii_valid = 1, y <= internal_ascii

    localparam S_COMP_A     = 0;
    localparam S_COMP_B     = 1;
    localparam S_COMP_AeqB  = 2;

    always @(posedge clk or posedge rst) begin
        if (rst==1) begin
            compare_a <= 1'b0;
            compare_b <= 1'b0;
            parser_valid <= 1'b0;
            parser_not_valid <= 1'b0;
            comparator_state <= S_COMP_A;
        end
        else begin
            case (comparator_state) 
                S_COMP_A: begin
                    if (internal_ascii_valid==1'b1) begin
                        compare_a <= internal_ascii;
                        comparator_state <= S_COMP_B;
                    end
                    else begin
                        compare_a <= 1'b0;
                        compare_b <= 1'b0;
                        parser_valid <= 1'b0;
                        parser_not_valid <= 1'b0;
                        comparator_state <= S_COMP_A;
                    end
                end

                S_COMP_B: begin
                    if (checksum_valid==1'b1) begin
                        compare_b <= checksum;
                        comparator_state <= S_COMP_AeqB;
                    end
                    else begin
                        compare_b <= 1'b0;
                        parser_valid <= 1'b0;
                        parser_not_valid <= 1'b0;
                        comparator_state <= S_COMP_B;
                    end
                end

                S_COMP_AeqB: begin
                    if (compare_a==compare_b) begin
                        parser_valid <= 1'b1;
                        parser_not_valid <= 1'b0;
                        comparator_state <= S_COMP_A;
                    end
                    else begin
                        parser_valid <= 1'b0;
                        parser_not_valid <= 1'b1;
                        comparator_state <= S_COMP_A;
                    end
                end
            endcase
        end
/*
        else if (internal_ascii_valid==1'b1) begin
            compare_a <= internal_ascii;

            if (checksum_valid==1'b1) begin
                compare_b <= checksum;
                
                if (compare_a==compare_b) begin
                    parser_valid <= 1'b1;
                    compare_a <= 24'b0;
                    compare_b <= 24'b0;
                end
                else begin
                    parser_valid <= 1'b0;
                    compare_a <= 24'b0;
                    compare_b <= 24'b0;
                end
            end  
        end
        */

    end

    // assign parser_valid = (internal_ascii_valid == 1) ? ((checksum == internal_ascii) ? 1'b1 : 1'b0) : 1'b0;

    fix_checksum #(
        // PARAMETER
        .DATA_WIDTH(8),
        .CHECKSUM_WIDTH(24),
        .MODULO_WIDTH(12),
        .ASCII_WIDTH(24)
    ) u1_fix_checksum (
        // INPUT
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        // OUTPUT
        .checksum(internal_checksum),
        .checksum_valid(internal_checksum_valid),
        .modulo(internal_modulo),
        .modulo_valid(internal_modulo_valid),
        .ascii(internal_ascii),
        .ascii_valid(internal_ascii_valid),
        .state(internal_checksum_state)
    );

endmodule
