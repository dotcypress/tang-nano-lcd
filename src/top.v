module top
(
    input XTAL,
    input BTN_A,
    input BTN_B,
    output LED_G,
    output LED_B,
    output LED_R,
    output LCD_CLK,
    output LCD_HSYNC,
    output LCD_VSYNC,
    output LCD_DE,
    output [5:0] LCD_G,
    output [4:0] LCD_B,
    output [4:0] LCD_R
);
    localparam SCREEN_WIDTH  = 16'd800;
    localparam SCREEN_HEIGHT = 16'd480;
    localparam BITMAP_WIDTH  = 16'd256;
    localparam BITMAP_HEIGHT = 16'd128;
    localparam BITMAP_LEFT = 9'd270;
    localparam BITMAP_TOP = 9'd160;

    wire sys_clk;
    wire frame_end;

    reg pixel;
    reg viewport;
    reg x_vel;
    reg y_vel;
    reg [2:0] color = 3'b001;
    reg [9:0] x_logo;
    reg [9:0] y_logo;
    reg [9:0] x;
    reg [9:0] y;
    reg [9:0] x_pos = BITMAP_LEFT;
    reg [9:0] y_pos = BITMAP_TOP;

    assign x_logo = x - x_pos;
    assign y_logo = y - y_pos;
    assign viewport = x >= x_pos &
                      x < (x_pos + BITMAP_WIDTH) &
                      y >= y_pos &
                      y < (y_pos + BITMAP_HEIGHT);

    assign LCD_G = color == 2 && viewport & pixel ? 5'b111111 : 5'b000000;
    assign LCD_B = color == 4 && viewport & pixel ? 5'b111111 : 5'b000000;
    assign LCD_R = color == 1 && viewport & pixel ? 6'b111111 : 6'b000000;

    assign LED_G = color == 2 ? 0 : 1;
    assign LED_B = color == 4 ? 0 : 1;
    assign LED_R = color == 1 ? 0 : 1;

    RPLL rpll(
        .clkout(sys_clk),  // 200 MHz
        .clkoutd(LCD_CLK), // 33.33 MHz
        .clkin(XTAL)
    );

    LCD display (
        .CLK(LCD_CLK),
        .nRST(BTN_A),
        .HSYNC(LCD_HSYNC),
        .VSYNC(LCD_VSYNC),
        .DE(LCD_DE),
        .FRAME_END(frame_end),
        .X(x),
        .Y(y)
    );

    BITMAP dvd_logo (
        .CLK(LCD_CLK),
        .X(x_logo),
        .Y(y_logo),
        .PIXEL(pixel)
    );

    always @ (negedge frame_end) begin
        if (x_pos == 0) begin
            x_vel <= 1;
            color <= {color[1:0], color[2]};
        end
        if (x_pos == (SCREEN_WIDTH - BITMAP_WIDTH)) begin
            x_vel <= 0;
            color <= {color[1:0], color[2]};
        end
        if (y_pos == 0) begin
            y_vel <= 1;
            color <= {color[1:0], color[2]};
        end
        if (y_pos == (SCREEN_HEIGHT - BITMAP_HEIGHT)) begin
            y_vel <= 0;
            color <= {color[1:0], color[2]};
        end
        x_pos <= x_vel == 1 ? (x_pos + 1) : (x_pos - 1);
        y_pos <= y_vel == 1 ? (y_pos + 1) : (y_pos - 1);
    end
endmodule