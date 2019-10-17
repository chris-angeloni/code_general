%
%function [R]=circularcorrcoef(X,Y)
%
%       FILE NAME       : CIRCULAR CORR COEF
%       DESCRIPTION     : Correlation coeficient for circular data
%	
%	X		: Variable 1 column vector
%	Y		: Variable 2 column vector
%
%RETURNED VARIABLES
%	R		: Correlation Coefficient
%
%	For details see Zar Eq. 27.43, Pg. 649
%
function [R]=circularcorrcoef(X,Y)


%Computing Correlation Coefficient (Zar, Eq. 27.43, Pg. 649)
N=length(X);
A=0;
for i=1:N-1
	for j=i+1:N
		A=A+sin(X(i)-X(j))*sin(Y(i)-Y(j));
	end
end

B=0;
for i=1:N-1
	for j=i+1:N
		B=B+sin(X(i)-X(j))^2;
	end
end

C=0;
for i=1:N-1
	for j=i+1:N
		C=C+sin(Y(i)-Y(j))^2;
	end
end

R=A/sqrt(B*C);
