%
%function [fc]=greenwoodfc(f1,fN,dX,Fm)
%
%   FILE NAME       : GREENWOOD FC
%   DESCRIPTION     : Finds the cochlear center frequencies (fc) using the
%                     Greenwood cochlear possition versus frequency
%                     function.
%
%	f1		: Lower frequency
%	fN		: Upper frequency
%	dX		: Equivalent spectral resolution (octaves)
%	Fm		: Maximum modulation rate (Hz)
%
function [fc]=greenwoodfc(f1,fN,dX)


%Chochlea Parameters
a=2.1;
K=0.88;
A=165.4;
x1=1/a*log10(f1/A+K);
xN=1/a*log10(fN/A+K);
dx=dX/a/log2(10);
L=ceil((xN-x1)/dx)+1;

%Chochlear distance
xc=x1+dx*(0:L-1);

%Chochlear center frequencies (fc)
fc=A*(10.^(a*xc)-K);