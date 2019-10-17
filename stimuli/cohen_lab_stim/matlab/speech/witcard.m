%
%function [xc] = witcard(x,t,NZC,Ts,alpha,m,wc,N)
%	
%	FILE NAME 	: WIT CARD
%	DESCRIPTION 	: Witaker Cardinal Series
%
%	t		: Time to Evalueate
%	xs		: Sampled Signal - Length = 2N-1 
%	Ts		: Sampling Period 
%	alpha		: Filter Shape Parameter
%	m		: Filter ATT Parameter
%	wc		: Filter Cuttoff Frequency
%	N		: Filter Length
%	xc		: Returned Continuous Time Value
% 
function [xc] = witcard(xs,t,NZC,Ts,alpha,m,wc,N)

%Finding h(t-nT) 
naxis= ( t - (NZC-N:NZC+N-1)*Ts )/Ts;
H = h(naxis,wc,alpha,m);

%Finding Cardinal Sum
xc=sum( xs.*H );
