%
%function [Y]=interp10(X,L)
%
%       FILE NAME       : INTERP 10
%       DESCRIPTION     : Interpolates a signal by a factor of 10^L
%			  where L is an integer
%			  Data must be a row vector of length N
%			  Returned vector has lenght (N-1)*10^L
%
%	X		: Input Signal 
%	L		: Integer - interpolates by factor of 10^L
%	Y		: Output Signal
%
function [Y]=interp10(X,L)

%Interpolating
Y=X';
for k=1:L
	N=length(Y);
	Y=interp1(0:N-1,Y,(0:N*10-1)/(N*10-1)*(N-1),'cubic');
end

%Transposing if necessary
LY=size(Y);
LX=size(X);
if ~( LX(1)==LY(1) | LX(2)==LY(2) )
	Y=Y';
end
