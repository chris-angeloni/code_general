%function [S]=int2strconvert(X,D)
%
%       FILE NAME       : INT 2 STR CONVERT
%       DESCRIPTION     : Converts an integer to a D element string with
%			  zeros appended
%
%	X		: Input integer
%	D		: Number of Digits, appends zeros if length of X 
%			  is shorter than D
%
%RETURNED VARIABLES
%
%	S		: Converted String
%
function [S]=int2strconvert(X,D)


k=1;
while k<D & X>=10^k
	k=k+1;
end

S=num2str(X);
for l=1:D-k
	S=['0' S];
end
