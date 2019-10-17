%function  [P,N,alpha,wc] = fdesignh(ATT,TW,wc)
%
%	FILE NAME       : F DESIGN H
%	DESCRIPTION 	: Finds optimal parameters for Escabi / Roark
%                     B-Spline Filter
%
%	N               : Filter Length
%	p               : Filter Smoothing Parameter
%	alpha           : Filter Shape Parameter
%	wc              : Cuttoff Frequency ( 0-pi )
%	ATT             : Attenuation ( dB )
%	TW              : Transition Width ( 0-pi )
%
% (C) Monty A. Escabi, Last Edit August 2006
%
function  [P,N,alpha,wc] = fdesign(ATT,TW,wc)

%Finding P
if ATT <= 21
	P=0;
end
if ATT > 21 & ATT < 120
	P = 13/(1+(126/ATT)^1.6) - .7;
end
if ATT >= 120
	P=0.5/( 1 + ( (ATT-120)/20 )^5 ) - 2.5 + 0.063*ATT;
end

%Finding N
if ATT <= 120 & ATT > 21
%	N=round(max([(24/(1+(149/ATT)^1.6) - 0.075 )/TW*pi  P*pi/wc/0.95]));
	N=round(max([(24.3/(1+(149/ATT)^1.6) - 0.085 )/TW*pi-1  P*pi/wc/0.95]));
end
if ATT > 120 & ATT <=147
	N=round(max([( - 7.5e-4*(ATT-200.3).^2 + 14.74)/TW*pi-1   P*pi/wc/0.95]));
end
if ATT > 147
	N=round(max([ ( 10.87e-5*(ATT + 245.6).^2 - 3.1)./TW*pi-1 P*pi/wc/0.95]));	
end

alpha=P*pi/(N+1)/wc;
