module UART_echo(
	input wire CLK100MHZ,
	input wire SW0, SW1, SW2, 
	input wire RXD,
	output wire TXD
);

wire empty, full;
wire [3:0] depth;
wire isRX, isTX, reset;
assign reset = SW0;
assign isRX = SW1;
assign isTX = SW2;

wire [7:0] tx_data, rx_data;
wire done1, done2;

UART_Receiver U1 (.CLK100MHZ(CLK100MHZ), .reset(reset), .isRx(isRX), .RXD(RXD), .data(rx_data), .done(done1));
fifo_reg_array_sc U2 (.clk(CLK100MHZ), .reset(reset), .data_in(rx_data), .wen(done1), .ren(done2), .data_out(tx_data), .depth(depth), .empty(empty), .full(full));
UART_Trans #(8) M1 (.CLK100MHZ(CLK100MHZ), .reset(reset), .isTX(isTX&!empty), .data(tx_data), .TXD(TXD), .done(done2));

//UART_Control U1 (.CLK100MHZ(CLK100MHZ),.reset(reset), .isTX(isTX), .TXD(out));




endmodule

module pulse_generator (
	input CLK100MHZ,
	input reset,
	input enable,
	output reg pulse
);

reg [9:0] counter;
parameter baudCount = 868; // For 115200 baud rate: 100e6/115200 = 868   8.68us

always @ (posedge CLK100MHZ, posedge reset) 
begin
	if (reset)
		begin
			pulse <= 0;
			counter <= 0;
		end
	else if (enable)	
		begin
			if (counter == baudCount - 1)
				begin
					pulse <= 1;
					counter <= 0;
				end
			else
				begin
					pulse <= 0;
					counter <= counter + 1;
				end
		end
end
endmodule