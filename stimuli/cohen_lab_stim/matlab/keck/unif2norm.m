%
%function [Y]=unif2norm(X,a,b,meanX,stdX)
%
%	
%	FILE NAME 	: UNIF 2 NORM
%	DESCRIPTION 	: Transforms a Uniform distributed random variable 
%			  to a normal (gaussian) random variable
%
%	X		: Input uniform RV
%	a, b		: Min and Max range for normal variable
%	Mean		: Mean of Gaussian Variable
%	Std		: Standard Deviation of Gaussian Variable
%	Y		: Ouput normal distributed RV
%
function [Y]=unif2norm(X,a,b,meanX,stdX)

%Converting Uniform to Gaussian - This is an approximate solution!!!
i=find(X>=0);
j=find(X<0);
mu=0;
sig=.5;
Y(i)=sig*log(1./(1-X(i))-1)+mu;
Y(j)=sig*log(1./(1-X(j))-1)-mu;
