module LCD
(
    input wire CLK,
    input wire nRST,
    output wire [9:0] X,
    output wire [9:0] Y,
    output wire VSYNC,
    output wire HSYNC,
    output wire DE,
    output wire FRAME_END
);

    localparam SCREEN_WIDTH  = 16'd800;
    localparam SCREEN_HEIGHT = 16'd480;

    localparam V_SYNC       = 16'd5;
    localparam V_FRONTPORCH = 16'd62;
    localparam V_BACKPORCH  = 16'd6;

    localparam H_SYNC       = 16'd1;
    localparam H_FRONTPORCH = 16'd210;
    localparam H_BACKPORCH  = 16'd182;

    localparam FRAME_WIDTH  = H_BACKPORCH + H_FRONTPORCH + SCREEN_WIDTH;
    localparam FRAME_HEIGHT = V_BACKPORCH + V_FRONTPORCH + SCREEN_HEIGHT;

    reg [15:0] X_POS;
    reg [15:0] Y_POS;

    always @(posedge CLK or negedge nRST) begin
        if (!nRST ) begin
            Y_POS <= 16'b0;
            X_POS <= 16'b0;
        end
        else if (X_POS == FRAME_WIDTH) begin
            X_POS <= 16'b0;
            Y_POS <= Y_POS + 1'b1;
        end
        else if (Y_POS == FRAME_HEIGHT) begin
            Y_POS <= 16'b0;
            X_POS <= 16'b0;
        end
        else begin
            X_POS <= X_POS + 1'b1;
        end
    end

    assign X = X_POS - H_BACKPORCH;
    assign Y = Y_POS - V_BACKPORCH;

    assign VSYNC = ((Y_POS >= V_SYNC ) && (Y_POS <= FRAME_HEIGHT)) ? 1'b0 : 1'b1;
    assign HSYNC = ((X_POS >= H_SYNC) && (X_POS <= (FRAME_WIDTH - H_FRONTPORCH))) ? 1'b0 : 1'b1;

    assign DE = ((X_POS > H_BACKPORCH) &&
                (X_POS <= FRAME_WIDTH - H_FRONTPORCH) &&
                (Y_POS >= V_BACKPORCH) &&
                (Y_POS <= FRAME_HEIGHT - V_FRONTPORCH - 1)) ? 1'b1 : 1'b0;

    assign FRAME_END = ((X == SCREEN_WIDTH - 1) & (Y == SCREEN_HEIGHT));

endmodule