`timescale 1ns/100ps

module UART_Trans #(
	parameter DATA_WIDTH = 8
)(
	input wire CLK100MHZ,
	input wire reset, 
	input wire isTX, 
	input wire [DATA_WIDTH-1:0] data,
	output reg TXD,
	output reg done
);

// Variable Declaration
wire en;
reg [4:0] i;
reg [DATA_WIDTH+1:0] dout;
reg [2:0] state;

//assign data = 8'b10101111;


localparam
	Qini 	= 3'b001,
	Qtrans	= 3'b010,
	Qend	= 3'b100;

//reg [9:0] counter;
//parameter baudCount = 868; // For 115200 baud rate: 100e6/115200 = 868   8.68us

/*
// Enable Pulse Generator	
always @ (posedge CLK100MHZ, posedge reset) 
begin
	if (reset)
		begin
			en <= 0;
			counter <= 0;
		end
	else if (isTX)	
		begin
			if (counter == baudCount)
				begin
					en <= 1;
					counter <= 0;
				end
			else
				begin
					en <= 0;
					counter <= counter + 1;
				end
		end
end
*/

pulse_generator Mp(.CLK100MHZ(CLK100MHZ), .reset(reset), .enable(isTX), .pulse(en));

// UART Transmitting
always @ (posedge CLK100MHZ, posedge reset)
begin
	if (reset)
		begin
			state <= Qini;
			TXD <= 1;
			done <= 0;
		end
	else if (isTX) 
		begin		
			case(state)
				Qini:
				begin
					state <= Qtrans;
					i <= 0;
					dout <= {1'b1, data, 1'b0}; //Preparing the data:{1 stop bit, data, 1 start bit}

				end
				
				Qtrans:
				begin
					if (en)
					begin
						if (i == DATA_WIDTH+1)
						begin
							i <= 0;
							state <= Qend;
							done <= 1'b1;
						end
						else
						begin
							TXD <= dout[i]; 
							i <= i + 1;
							

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