`timescale 1ns/100ps

module UART_Trans(
	input wire CLK100MHZ,
	input wire SW0, 
	input wire SW1, 
	output reg UART_RXD_OUT,
	output reg done
);

// Variable Declaration
reg enable;
reg [4:0] i;
reg [9:0] counter;
reg [2:0] state;
reg done;
reg [9:0] dout;

wire [7:0] data;
wire reset;
wire start;

assign reset = SW0;
assign start = SW1;


assign data = 8'b10101111;


localparam
	Qini 	= 3'b001,
	Qtrans	= 3'b010,
	Qend	= 3'b100;
	
parameter baudCount = 868; // For 115200 baud rate: 100e6/115200 = 868

// Enable Pulse Generator	
always @ (posedge CLK100MHZ, posedge reset) 
begin
	if (reset)
		begin
			enable <= 0;
			counter <= 0;
		end
	else if (start)	
		begin
			if (counter == baudCount)
				begin
					enable <= 1;
					counter <= 0;
				end
			else
				begin
					enable <= 0;
					counter <= counter + 1;
				end
		end
end

// UART Transmitting
always @ (posedge CLK100MHZ, posedge reset)
begin
	if (reset)
		begin
			state <= Qini;
			UART_RXD_OUT <= 1;
		end
	else if (start) 
		begin		
			case(state)
				Qini:
				begin
					state <= Qtrans;
					i <= 0;
					dout <= {1'b1, data, 1'b0}; //Preparing the data：{1 stop bit, data, 1 start bit}

				end
				
				Qtrans:
				begin
					if (enable)
					begin
						if (i == 9)
						begin
							i <= 0;
							state <= Qend;
						end
						else
						begin
							UART_RXD_OUT <= dout[i]; 
							i <= i + 1;
							done <= 1'b1;

						end
					end
				end
				
				Qend:
				begin
					done <= 1'b0;
					state <= Qini;
				end
			endcase	
		end
end

endmodule