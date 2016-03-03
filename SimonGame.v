module main_module(OUTS, CLOCK_50, rand, KEY, SW);

	/*VCC = pin 12, GND = pin 11.*/	
	
	//Clock.
	input CLOCK_50;
	//Async. reset.
	input [0:0] KEY;
	//Seed
	input [2:0] SW;
	
	//InOut pins.
	output [4:0] OUTS;	
	output [2:0] rand;
	
	//Game module.
	simon_game SG0(OUTS[4], OUTS[3], OUTS[2], OUTS[1], OUTS[0], CLOCK_50, KEY[0], SW[2:0], rand);
	
endmodule


/*Main game module.*/
module simon_game(blue, yellow, red, green, orange, clk, rst, seed, rand_colour);
	
	//Clock and reset signals.
	input clk, rst; 	 
	//Connections to each LED light.
	output blue, yellow, red, green, orange; 	
	//Seed.
	input [2:0] seed;
	
	//Goal will become 1 everytime the counting is completed.
	wire goal;	
	count_for_clock CFC0(clk, rst, goal);
	
	//Genera will become 1 everytime we have to generate a new number.
	wire generate_new;
	
	//Generate a random number every clock cycle.
	output [2:0] rand_colour;	
	random_generator RO(clk, rst, seed, generate_new, rand_colour);	
	
	//Decoded colour for each random value generated.
	wire [4:0] decoded_color;
	mux_lights ML0(clk, rst, rand_colour, decoded_color);
	
	//Signals for illuminating the lights.
	wire [4:0] last_color;
	wire doneplaying;
	colours_player CP0(clk, rst, play, num_colours_generated, colours_generated, doneplaying, last_color);	
	
	assign blue = last_color[0];
	assign yellow = last_color[1];
	assign red = last_color[2];
	assign green = last_color[3];
	assign orange = last_color[4];			
	
	
endmodule

/*Plays the sequence stored in the register whenever the signal play is enabled.*/
module colours_player(clk, rst, play, num_colours_generated, colours_generated, doneplaying, last_color);	
	input clk, rst, play;
	input [3:0] num_colours_generated;
	input [49:0] colours_generated;
	
	//The last colour found in the generated data.
	output reg [4:0] last_color;
	
	//Signal to know if there is a sequence of colours being played.
	output reg doneplaying;	
	
	//Numbers of colours played.
	reg [3:0] played;
	
	//Time counters.
	reg [25:0] lights_on;
	reg [25:0] lights_off;
	//Signals to wait while playing.
	reg waitsig, lightsig;
	
	always@(posedge clk or negedge rst) begin
		if (~rst) begin
			played <= 'b0; 
			doneplaying <= 'b0;
			last_color <= 'b0;
			lights_on <= 'b0;
			lights_off <= 'b0;
			waitsig <= 0;
			lightsig <= 0;
		end
		else begin
			if(play && ~doneplaying) begin	
				if ((played < num_colours_generated)) begin					
					//Play all the sequence but wait for the respective delay.
					if(~waitsig) begin
						case(played)
							0: last_color = colours_generated[4:0];
							1: last_color = colours_generated[9:5];
							2:	last_color = colours_generated[14:10];
							3: last_color = colours_generated[19:15];
							4: last_color = colours_generated[24:20];
							5: last_color = colours_generated[29:25];
							6: last_color = colours_generated[34:30];
							7: last_color = colours_generated[39:35];
							8: last_color = colours_generated[44:40];
							9: last_color = colours_generated[49:45];
						endcase
						waitsig = 1;
						lightsig = 1;
					end
					else if(lights_on < 3 && lightsig) begin					
						lights_on <= lights_on + 1;							
					end 			
					else if(lights_on == 3) begin
						last_color <= 'b0;
						lights_on <= 'b0;	
						//Turn off the lights now for another amount of time.
						lightsig <= 'b0;
					end
					else if(lights_off < 3 && ~lightsig) begin
						lights_off <= lights_off + 1;
					end
					else if(lights_off == 3) begin
						played <= played + 1;
						lights_off <= 'b0;
						waitsig = 0;
					end					
				end				
				else begin
					doneplaying <= 'b1;
					played <= 'b0;
					last_color <= 'b0;
				end
			end
			else if(~play) begin
				doneplaying <= 'b0;
			end		
		end
	end
	
endmodule

/*Stores the generated sequence.*/
module data_storage(clk, rst, data);

	input clk, data, rst;
	
	//Numbers generated so far.
	reg [3:0] num_colours_generated;	
	//Score.
	reg [3:0] score;	
	//User input accumulator.
	reg [49:0] user_input;
	//Random numbers accumulator.	
	reg [49:0] colours_generated;
	
endmodule

/*Produces a new action based on some input.*/
module move_validator(numbers_generated, user_input, numbers_generated, action);
	input [49:0] numbers_generated, user_input;
	output action;
	
endmodule

/*Decode the lights.*/
module mux_lights(clk, rst, rand_colour, decoded_color);

	input [2:0] rand_colour;
	input clk, rst;
	output reg [4:0] decoded_color;	
 
	always@(posedge clk or negedge rst) begin		
		if (~rst) begin
			decoded_color = 'b00000; //Clear lights.
		end
		else begin
			case(rand_colour)
				'b000 : decoded_color = 'b00001;
				'b001 : decoded_color = 'b00010;
				'b010 : decoded_color = 'b00100;
				'b011 : decoded_color = 'b01000;
				'b100 : decoded_color = 'b10000;
				'b101 : decoded_color = 'b01000;
				'b110 : decoded_color = 'b00100;
				'b111 : decoded_color = 'b00010; 
			endcase
		end		
	end
	
endmodule

/*Generate a random number per clock cycle and each time generate_new is set.*/
module random_generator(clk, rst, seed, generate_new, b);

	input clk, rst, generate_new;
	output reg [2:0] b;

	//Seed.
	input [2:0] seed;
	
	//LFSR feedback bit.
	wire feedback; 
	assign feedback = b[0] ^ b[2];
 
	always@(posedge clk or negedge rst) begin
		if (~rst) begin
			//Reset the values to something empty.
			b[2:0] <= seed;
		end 
		//Reset the values to something empty.
		else if(generate_new) begin
			if (b == 'b0) begin
				if(seed == 'b0) begin
					b[2:0] <= 'b111;
				end
				else begin				
					b[2:0] <= seed;
				end
			end			
			else begin
				b[0] <= feedback;
				b[1] <= b[0];
				b[2] <= b[1];				
			end
		end
	end
	
endmodule


/*Wait for some clk cycles.*/
module count_for_clock(clk, rst, goal);

	input clk, rst;
	
	//Cycles to wait before changing a light, goal = delay passed.
	reg [25:0] delay_counter;
	output reg goal;
	
	always @ (posedge clk or negedge rst) begin  
		if (~rst) begin	
			goal <= 'b0;
			delay_counter <= 'b0;				
		end
		else if (delay_counter == 4) begin
			//Goal reached.
			goal <= 'b1;	
			delay_counter <= 'b0;	
		end
		else begin
			goal <= 'b0;
			delay_counter <= delay_counter + 1;					
		end		
	end
 
endmodule
