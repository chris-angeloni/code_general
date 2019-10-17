%
%function [W,FF]=fano(x,N1,N2)
%
%       FILE NAME       : fano
%       DESCRIPTION     : Modified Fano Factor for Continuous 
%			  curves
%
%	x		: Input Signal
%       N1		: Smallest counting window
%	N2		: Maximum counting window 
%
%	FF		: Fano Factor
%	W		: Averaging window size
%			  in term of number of samples
%
function [W,FF]=fano(x,N1,N2)

N=length(x);

for n=N1:N2

	y=[];
	for j=1:n

		%Arranging data
		xj=x(j:n:N);
		if ~isempty(y)
			M=length(y(:,1));
		else
			M=[];
		end
	
		M=min([M length(xj)]);

		if ~isempty(y)
			y=[y(1:M,:) xj'];
		else
			y=[y xj'];
		end

	end
		%Finding FF
		FF(n-N1+1)=var(sum(y.^2))/mean(sum(y.^2));
end

%Averaging Window Array
W=N1:N2;
