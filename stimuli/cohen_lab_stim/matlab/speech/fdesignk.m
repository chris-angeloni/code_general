%function  [Beta,N,wc] = fdesignk(ATT,TW,wc)
%
%	FILE NAME 	: Fdesigner - Kaiser
%	DESCRIPTION 	: Finds optimal parameters for kaiser filter.
%	FUNCTION CALL	: Fdesignk(ATT,TW,wc)
%	N		: Filter Length
%	Beta		: Filter Parameter
%	wc		: Cuttoff Frequency (0,pi)
%	ATT		: Attenuation
%	TW		: Transition Width
%	Example		: [Beta,N,wc] = fdesignk(200,.1,pi/4)
%
function  [Beta,N,wc] = fdesignk(ATT,TW,wc)

N=ceil((ATT-7.95)/14.36/TW*pi);

if ATT >= 50
	Beta=.1102*(ATT-8.7);
end

if ATT < 21
	Beta=0;
end

if ATT > 21 & ATT < 50
	Beta=.5842*(ATT-21)^.4+.07886*(ATT-21);
end


