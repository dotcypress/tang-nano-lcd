module rom_bitmap
#(
    parameter ADDR_WIDTH  = 10,
    parameter WIDTH       = 256,
    parameter HEIGHT      = 128,
    parameter BITMAP_PATH = "bitmap.mem"
)
(
    input clk, 
    input [(ADDR_WIDTH - 1):0] x,
    input [(ADDR_WIDTH - 1):0] y,
    output reg pixel
);

    reg [7:0] addr;
    reg rom[(WIDTH * HEIGHT):0]; /* synthesis syn_romstyle = "select_rom" */;

    initial begin
        $readmemb({"../../src/", BITMAP_PATH}, rom);
    end

    assign addr = (y * WIDTH) + x;

    always @ (posedge clk) begin
        pixel <= rom[addr];
    end

endmodule
