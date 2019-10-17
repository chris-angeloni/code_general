%function  [P,N,alpha,wc] = fdesignerk(ATT,TW,wc)
%
%	FILE NAME 	: Fdesignerk
%	DESCRIPTION 	: Finds optimal parameters for Escabi / Roark filter
%			  when implemented as a Kaiser filter.
%	FUNCTION CALL	: fdesignerk(ATT,TW,wc)
%	N		: Filter Length
%	p		: Filter Parameter
%	wc		: Cuttoff Frequency
%	ATT		: Attenuation
%	TW		: Transition Width
%	Example		: [P,N,alpha,wc] = fdesignerk(200,.1,pi/4)
%
function  [P,N,alpha,wc] = fdesignerk(ATT,TW,wc)

%Finding P
if ATT <= 21
	P=0;
end
if ATT > 21 & ATT <= 120
	P = 13/(1+(126/ATT)^1.6) - .7;
end
if ATT >= 120
	P=0.5/( 1 + ( (ATT-120)/20 )^5 ) - 2.5 + 0.063*ATT;
end

%Finding N
if ATT <= 120 & ATT > 21
	N=round(max([( 0.071*ATT-.565 + 0.58/(1+exp((78-ATT)/3.5)) )/TW*pi  P*pi/wc/0.95]));
end
if ATT > 120 & ATT <=147
	N=round(max([( - 7.5e-4*(ATT-200.3).^2 + 14.74)/TW*.87*pi-1   P*pi/wc/0.95]));
end
if ATT > 147
	N=round(max([ ( 10.87e-5*(ATT + 245.6).^2 - 3.1)./TW*.87*pi-1 P*pi/wc/0.95]));	
end

alpha=P*pi/(N+1)/wc;


%ATT=1.02 * ATT

%TWE  =.86*TW

