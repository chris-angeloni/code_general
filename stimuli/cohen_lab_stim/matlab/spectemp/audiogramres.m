%
%function []=audiogramres(f1,fN,dX,Fm)
%
%       FILE NAME       : AUDIOGRAM RES
%       DESCRIPTION     : Finds the filterbank spectro-temporal resolution
%			  for the audiogram analysis
%
%	f1		: Lower frequency
%	fN		: Upper frequency
%	dX		: Equivalent spectral resolution (octaves)
%	Fm		: Maximum modulation rate (Hz)
%
function []=audiogramres(f1,fN,dX,Fm)


%Chochlea Parameters
a=2.1;
K=0.88;
A=165.4;
x1=1/a*log10(f1/A+K);
xN=1/a*log10(fN/A+K);
dx=dX/a/log2(10);
L=ceil((xN-x1)/dx)+1;

%Chochlear distance
x=x1+dx*(0:L-1);
xc=x1+dx*(-.5:L);

%Chochlear cutoff (fc) and center frequencies
fc=A*(10.^(a*xc)-K);
f=A*(10.^(a*x)-K);

%Plotting Spectro-temporal resolutions
subplot(211)
plot(f,diff(fc),'r+')
xlabel('Center frequency (Hz)')
ylabel('Filter Bandwidth (Hz)')
subplot(212)
plot(f,diff(fc)/2,'r+')
hold on
plot(f,min(diff(fc)/2,Fm),'y')
xlabel('Center frequency (Hz)')
ylabel('Maximum modulation rate (Hz)')




