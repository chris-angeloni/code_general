%
%function [Y,spet]=haircell(X,f1,f2,Fs,Fc,Q,N,M)
%
%       FILE NAME       : HAIR CELL
%       DESCRIPTION     : Non linear hair cell simulation
%
%	fc		: Filter characteristic frequency
%			  If a two element array is entered, 
%			  its elements are taken as the lower
%			  and upper cutoff frequencies
%	dX		: Filter width in Octaves
%	Fs		: Sampling rate
%	ATT		: Filter Attenuation
%	Rate    : Mean Output Spike Rate
%
%RETURNED VARIABLES
%	Y		: Output 
%	S		: Output Spike Train
%	Vout	: Intracellular Voltage
%
function [Y,S,Vout]=haircell(X,fc,dX,Fs,ATT,Rate)

%Finding the lower and upper cutoff frequencies for Ha
if length(fc)==2
	f1=fc(1);
	f2=fc(2);
else
	f1=2*fc/(1+2^dX);
	f2=2*fc/(1+2^(-dX));
end

%System impulse response
TW=fc*2^(1/6)-fc;
Ha=bandpass(f1,f2,TW,Fs,ATT,'n');
Hb=lowpass(1000,200,Fs,ATT,'n');
Na=(length(Ha)-1)/2;
Nb=(length(Hb)-1)/2;

%Applying sandwich model
U=conv(X,Ha);
U=U/std(U);
V=hcnl(U,1,0,1,5);
Y=conv(V,Hb);

%Converting output to Spike Train
Iin=Y(2*Na+2*Nb+1:length(Y)-2*Na-2*Nb-1);
Tau=1;
Tref=1;
sigma=1;
nsigma=.2;
[S,Vout]=integratefire(Iin,Tau,Tref,Fs,sigma,nsigma);
