%
%function [I]=tocomplex(I)
%
%       FILE NAME       : TO COMPLEX
%       DESCRIPTION     : Converts a 2 Element Array to a Complex
%			  Number
%
%	I		: Input Array
%
function [I]=tocomplex(I)

if length(I)>1
	I=I(1)+i*I(2);
end
