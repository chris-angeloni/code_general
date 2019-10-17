%
%function [Rb]=bootstrapcorrcoef(X,Y,N)
%
%       FILE NAME       : BOOT STRAP CORR COEF
%       DESCRIPTION     : Bootstrap algorythm used to compute significance
%			  of CORRCOEF performed on the arrays X and Y
%
%       X		: Data Array 1
%	Y		: Data Array 2
%	N		: Number of itterations for bootstrap
%
%Returned Variables
%	Rb		: Bootstraped correlation coefficient array
%
function [Rb]=bootstrapcorrcoef(X,Y,N)

%Bootstraping for N itterations
for k=1:N
	%Displaying Output
	if k/100==round(k/100)
	clc
	disp(['Bootstrap Iteration: ' int2str(k) ' of ' int2str(N)])
	end

	%Bootstraping CorrCoef
	index=round((length(X)-1)*rand(size(X)))+1;
	RR=corrcoef(X(index),Y(index));
	Rb(k)=RR(1,2);
end

