module BITMAP
#(parameter BITMAP_PATH="bitmap.mem", parameter WIDTH=256, parameter HEIGHT=128, parameter ADDR_WIDTH=8)
(
    input CLK, 
    input [(ADDR_WIDTH - 1):0] X,
    input [(ADDR_WIDTH - 1):0] Y,
    output reg PIXEL
);

    reg [7:0] ADDR;
    reg rom[(WIDTH * HEIGHT):0]; /* synthesis syn_romstyle = "select_rom" */;

    initial begin
        $readmemb({"../../src/", BITMAP_PATH}, rom);
    end

    assign ADDR = (Y * WIDTH) + X;

    always @ (posedge CLK) begin
        PIXEL <= rom[ADDR];
    end

endmodule
