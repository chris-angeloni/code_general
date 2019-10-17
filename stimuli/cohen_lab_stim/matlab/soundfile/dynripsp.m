%
%function [Y,RD,RP,AM,fphase,alpha,T,dT]=dynripsp(f1,f2,fRP1,fRP2,fRD1,fRD2,MaxA,MinA,MaxT,MinT,MaxdT,beta,gamma,App,RDL,RDU,Rphase,M,Fs,dt)
%	
%	FILE NAME 	: dynripsp
%	DESCRIPTION 	: Dynamic Ripple Spectrum Noise with 
%			  Spline Window Modulations
%
%       f1              : Lower Ripple Frequency
%       f2              : Upper Ripple Frequency
%	fRP1		: Lower Ripple Phase Frequency
%	fRP2		: Upper Ripple Phase Frequency
%	fRD1		: Lower Ripple Density Frequency
%	fRD2		: Upper Ripple Density Frequency
%
%	MaxA		: Max Alpha
%	MinA		: Min Alpha 
%	MaxT		: Max Window Width 
%	MinT		: Min Window Width
%	MaxdT		: Max Inter Window Width
%
%	beta		: 1 : dB Amplitude Ripple Spectrum
%			  2 : Liner Amplitude Ripple Spectrum
%
%       gamma           : 1 : Random Ripple Phase  
%			  2 : Random Ripple Density 
%			  3 : Random Ripple Phase and Density
%
%       App             : Peak to Peak Riple Amplitude 
%			  if beta ==
%			  1 : App is in dB 
%			  2 : App E [0,1]
%	RDU		: Upper Ripple Density
%	RDL		: Lower Ripple Density
%	RPhase		: Maximum Ripple Phase if gamma==1 or 3
%			  OtherWise Constant Ripple Phase
%       M               : Number of Samples
%       Fs              : Sampling Rate
%	dt		: Temporal window size used for reconstruction
%
%	Y		: Returned Noise
%	RD		: Ripple Density Signal
%	RP		: Ripple Phase Signal
%	AM		: Amplitude Modulation Signal
%
function [Y,RD,RP,AM,fphase,alpha,T,dT]=dynripsp(f1,f2,fRP1,fRP2,fRD1,fRD2,MaxA,MinA,MaxT,MinT,MaxdT,beta,gamma,App,RDL,RDU,RPhase,M,Fs,dt)

%Dynamic Ripple Noise Carrier
[Y,RD,RP,fphase]=dynrip(f1,f2,fRP1,fRP2,fRD1,fRD2,beta,gamma,App,RDL,RDU,RPhase,M,Fs,dt);
N=length(Y);

%Amplitude Modulation Signal
AM=[];
Wold=[];
W=[];
k=1;
while length(AM)<N
	Wold=W;
	alpha(k)=rand*(MaxA-MinA)+MinA;
	T(k)=rand*(MaxT-MinT)+MinT;
	dT(k)=rand*MaxdT;
	dTI=zeros(1,round(dT(k)*Fs));
	[Taxis,W] = splinewin(4,alpha(k),T(k),Fs);
	AM=[AM dTI W];
	k=k+1;
end

%Modulating With Noise Carrier
N=length(AM)-length(Wold)-length([W])-length(dTI);
AM=AM(1:N);
Y=Y(1:N).*AM(1:N);

