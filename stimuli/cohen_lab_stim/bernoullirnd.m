%function [X]=bernoulli(P,N1,N2)
%
%       FILE NAME       : BERNOULLI
%       DESCRIPTION     : Bernoulli Random Number Generator
%
%	P		: Probability of Getting a 1 (0<P<1)
%			  1-P = Probability of 0
%			  If P is an array of dimmensions N1xN2
%			  the bernoulli random variable is determined
%			  independently for each matrix element 
%	N1,N2		: Number of Elements for Array
%			  N1xN2 Elements
%
%Optional
%	N		: Bernoulli Random Number Array
%
function [X]=bernoulli(P,N1,N2)

X=rand(N1,N2);
i=find(X>1-P);
X(i)=ones(size(i));
i=find(X<=1-P);
X(i)=zeros(size(i));

