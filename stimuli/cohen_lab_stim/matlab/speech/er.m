%function [To,L]=er(x,Fs,epsilon,ATT,TW)
%	
%	FILE NAME 	: ER
%	DESCRIPTION 	: Finds To using ER (Escabi / Roark ) ZC extraction
%			  Method.  
%
%	x		: Input Signal
%	Fs		: Sampling Frequency
%
%	To		: Measured Fundamental Period Array 
%	L		: Number of Periods Removed to avoid truncation 
%			  effects at extremities
%Optional
%
%	epsilon		: Zero Finding Precission - For Gradient Method
%	ATT		: Filter Attenuation ( Default=120dB )
%	TW		: Transition width ( Default=.1*pi=.1*wc )
%
function [To,L]=er(x,Fs,epsilon,ATT,TW)

%Checking Arguments
if nargin<3
        epsilon=1E-10;
	ATT=120;
	TW=.1*pi;
elseif nargin<4
	ATT=120;
	TW=.1*pi;
elseif nargin<5
	TW=.1*pi;
end

%Filter Design
wc=pi;
[m,N,alpha,wc] = fdesignh(ATT,TW,wc);

%Finding ZC
nz=findzc(x);

%Determining the number of periods to remove - depends on N
index=find(nz>N+1 & nz<length(x)-N-1);
nz=nz(index);

%Interpolating - Removes First and Last L Periods
Ts=1/Fs;
for k=1:length(nz)

%	clc	
%	disp(['Finding Period: ',num2str(k)])
	NZC=nz(k);
	xs=x(NZC-N:NZC+N-1);
	t1=NZC*Ts;
	t2=(NZC+1)*Ts;
	tzc(k) = gzero(t1,t2,xs,Ts,NZC,alpha,m,wc,N);

end

%Finding Periods
To=diff(tzc);
