module LCD
(
    input clk,
    input nrst,
    output [9:0] x,
    output [9:0] y,
    output vsync,
    output hsync,
    output de,
    output frame
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

    reg [15:0] x_offset;
    reg [15:0] y_offset;

    always @(posedge clk or negedge nrst) begin
        if (!nrst ) begin
            y_offset <= 16'b0;
            x_offset <= 16'b0;
        end
        else if (x_offset == FRAME_WIDTH) begin
            x_offset <= 16'b0;
            y_offset <= y_offset + 1'b1;
        end
        else if (y_offset == FRAME_HEIGHT) begin
            y_offset <= 16'b0;
            x_offset <= 16'b0;
        end
        else begin
            x_offset <= x_offset + 1'b1;
        end
    end

    assign x = x_offset - H_BACKPORCH;
    assign y = y_offset - V_BACKPORCH;

    assign vsync = ((y_offset >= V_SYNC ) && (y_offset <= FRAME_HEIGHT)) ? 1'b0 : 1'b1;
    assign hsync = ((x_offset >= H_SYNC) && (x_offset <= (FRAME_WIDTH - H_FRONTPORCH))) ? 1'b0 : 1'b1;

    assign de = ((x_offset > H_BACKPORCH) &&
                (x_offset <= FRAME_WIDTH - H_FRONTPORCH) &&
                (y_offset >= V_BACKPORCH) &&
                (y_offset <= FRAME_HEIGHT - V_FRONTPORCH - 1)) ? 1'b1 : 1'b0;

    assign frame = (x_offset == FRAME_WIDTH - 1) & (y_offset == FRAME_HEIGHT - 1);

endmodule