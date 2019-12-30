module top(
    input XTAL,
    input BTN_A,
    input BTN_B,
    output LED_R,
    output LED_G,
    output LED_B,
    output LCD_CLK,
    output LCD_HSYNC,
    output LCD_VSYNC,
    output LCD_DE,
    output [4:0] LCD_R,
    output [5:0] LCD_G,
    output [4:0] LCD_B
    );

    wire SYS_CLK;

    RPLL rpll(
        .clkout(SYS_CLK),  // 200 MHz
        .clkoutd(LCD_CLK), // 33.33 MHz
        .clkin(XTAL)
    );

    wire [9:0] x;
    wire [9:0] y;

    LCD display (
        .CLK(LCD_CLK),
        .nRST(BTN_A),
        .HSYNC(LCD_HSYNC),
        .VSYNC(LCD_VSYNC),
        .DE(LCD_DE),
        .X(x),
        .Y(y)
    );

    assign LCD_R = BTN_B & (x > 10) & (y > 10) & (x < 790) & (y < 470) ? 5'b00000 : 5'b11111;
    assign LCD_G = BTN_B & (x > 10) & (y > 10) & (x < 790) & (y < 470) ? 6'b000000 : 6'b111111;
    assign LCD_B = BTN_B & (x > 10) & (y > 10) & (x < 790) & (y < 470) ? 5'b00000 : 5'b11111;

    reg [32:0] counter;
    assign LED_R = counter > 32'd8_000_000;
    assign LED_G = counter < 32'd8_000_000 | counter > 32'd16_000_000;
    assign LED_B = counter < 32'd16_000_000;

    always @(posedge LCD_CLK or negedge BTN_A) begin
        if (!BTN_A) 
            counter <= 32'd0;
        else if (counter < 32'd24_000_000) begin
            if (BTN_B)
                counter <= counter + 1;
        end
        else begin
            counter <= 32'd0;
        end
    end

endmodule