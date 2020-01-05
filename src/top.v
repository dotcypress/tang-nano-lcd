module top
(
    input xtal,
    input btn_a,
    input btn_b,
    output led_g,
    output led_b,
    output led_r,
    output lcd_clk,
    output lcd_hsync,
    output lcd_vsync,
    output lcd_de,
    output [5:0] lcd_g,
    output [4:0] lcd_b,
    output [4:0] lcd_r
);
    localparam SCREEN_WIDTH  = 16'd800;
    localparam SCREEN_HEIGHT = 16'd480;
    localparam BITMAP_WIDTH  = 16'd256;
    localparam BITMAP_HEIGHT = 16'd128;
    localparam BITMAP_LEFT   = 9'd300;
    localparam BITMAP_TOP    = 9'd200;

    wire sys_clk;
    wire frame;
    wire pixel;
    wire logo_viewport;
    wire [9:0] x;
    wire [9:0] y;
    wire [9:0] x_viewport;
    wire [9:0] y_viewport;

    reg x_vel;
    reg y_vel;
    reg [9:0] x_pos = BITMAP_LEFT;
    reg [9:0] y_pos = BITMAP_TOP;
    reg [2:0] color = 3'b1;

    assign x_viewport = x - x_pos;
    assign y_viewport = y - y_pos;
    assign logo_viewport = x >= x_pos &
                           y >= y_pos &
                           x < (x_pos + BITMAP_WIDTH) &
                           y < (y_pos + BITMAP_HEIGHT);

    assign lcd_b = color == 4 && logo_viewport & pixel ? 5'b11111 : 0;
    assign lcd_r = color == 2 && logo_viewport & pixel ? 5'b11111 : 0;
    assign lcd_g = color == 1 && logo_viewport & pixel ? 6'b111111 : 0;

    assign led_b = color == 4 ? 0 : 1;
    assign led_r = color == 2 ? 0 : 1;
    assign led_g = color == 1 ? 0 : 1;

    RPLL rpll(
        .clkout(sys_clk),  // 200 MHz
        .clkoutd(lcd_clk), // 33.33 MHz
        .clkin(xtal)
    );

    LCD display (
        .clk(lcd_clk),
        .nrst(btn_a),
        .hsync(lcd_hsync),
        .vsync(lcd_vsync),
        .de(lcd_de),
        .frame(frame),
        .x(x),
        .y(y)
    );

    rom_bitmap dvd_logo (
        .clk(lcd_clk),
        .x(x_viewport),
        .y(y_viewport),
        .pixel(pixel)
    );

    always @ (posedge frame) begin
        if (x_pos == 0) begin
            color <= {color[1:0], color[2]};
            x_vel <= 1;
        end
        if (x_pos == (SCREEN_WIDTH - BITMAP_WIDTH)) begin
            color <= {color[1:0], color[2]};
            x_vel <= 0;
        end
        if (y_pos == 0) begin
            color <= {color[1:0], color[2]};
            y_vel <= 1;
        end
        if (y_pos == (SCREEN_HEIGHT - BITMAP_HEIGHT)) begin
            color <= {color[1:0], color[2]};
            y_vel <= 0;
        end
        x_pos <= x_vel == 1 ? (x_pos + 1) : (x_pos - 1);
        y_pos <= y_vel == 1 ? (y_pos + 1) : (y_pos - 1);
    end
endmodule