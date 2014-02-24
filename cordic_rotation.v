module cordic_rotation (clock, angle, Xin, Yin, Xout, Yout) ;
	input clock ;
	input [0 : 15] angle, Xin, Yin ;
	output [0 : 15] Xout, Yout ;
	
//1 = 16.384 e para colocar o valor do angulo, pega-se o seu valor em rad e multiplica por 16.384 (2^14)
//          Exemplos de valores utilizados na simulação: ângulo = 30º, Xin = 1/16.384, Yin = 0;
//30º em rad equivale a 1,523598... que multiplicado por 16.384 é igual a 8.5786
//14.191/16.384 = 0.8661...
//8.187/16.384 = 0.4996...

wire [15 : 0] atan [11 : 0] ;
	assign atan[00] = 16'd12867; //atan de 2^-i, onde i {0, 1, 2, ..., 11} 
	assign atan[01] = 16'd7596 ;
	assign atan[02] = 16'd4013 ;
	assign atan[03] = 16'd2037 ;
	assign atan[04] = 16'd1022 ;
	assign atan[05] = 16'd511  ;
	assign atan[06] = 16'd255  ;
	assign atan[07] = 16'd127  ;
	assign atan[08] = 16'd63   ;
	assign atan[09] = 16'd31   ;
	assign atan[10] = 16'd15   ;
	assign atan[11] = 16'd7    ;
	
	reg [15 : 0] X [11 : 0];
	reg [15 : 0] Y [11 : 0];
	reg [15 : 0] Z [11 : 0];
	
	reg [29 : 0] XoutTemp;
	reg [29 : 0] YoutTemp;
	
genvar i;
generate
for(i = 0; i < 11; i = i+1)
	begin : cordic
//	wire z_sign;// Declara-se uma var como wire quando ela nao é nem valor de entrada nem de sai­da ou quando ela realizar a conexao entre dois blocos.
	always @(posedge clock)
      begin
			if(Z[i][15] == 0)
			begin
			  X[i+1] <= X[i] - (Y[i] >> i) ;
			  Y[i+1] <= Y[i] + (X[i] >> i) ;
			  Z[i+1] <= Z[i] - atan[i]     ;
			end
			else 
			begin
				X[i+1] <= X[i] + (Y[i] >> i) ;
				Y[i+1] <= Y[i] - (X[i] >> i) ;
				Z[i+1] <= Z[i] + atan[i]     ;
			end
      end
	end
endgenerate

always @ (posedge clock)
begin
	   X[0] <= Xin;
		Y[0] <= Yin;
		Z[0] <= angle;
		XoutTemp = X[i]; 
		YoutTemp = Y[i];
end

	assign Xout = (XoutTemp << 14)/16'd26980; //=k * 16.384, onde k = 1,6467
	assign Yout = (YoutTemp << 14)/16'd26980;	
	
endmodule