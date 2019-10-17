%function [Y]=dynripam(f1,f2,fRP1,fRP2,fRD1,fRD2,fAM1,fAM2,beta,gamma,App,RDL,RDU,RPhase,M,Fs,dt)
%
%	
%	FILE NAME 	: dynripam
%	DESCRIPTION 	: Dynamic Ripple Spectrum Noise with 
%			  bandlimited AM Modulations
%
%       f1              : Lower Ripple Frequency
%       f2              : Upper Ripple Frequency
%	fRP1		: Lower Ripple Phase Frequency
%	fRP2		: Upper Ripple Phase Frequency
%	fRD1		: Lower Ripple Density Frequency
%	fRD2		: Upper Ripple Density Frequency
%	fAM1		: Lower AM Frequency
%	fAm2		: Upper AM Frequency
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
function [Y]=dynripam(f1,f2,fRP1,fRP2,fRD1,fRD2,fAM1,fAM2,beta,gamma,App,RDL,RDU,RPhase,M,Fs,dt)

%Dynamic Ripple Noise Carrier
[Y]=dynrip(f1,f2,fRP1,fRP2,fRD1,fRD2,beta,gamma,App,RDL,RDU,RPhase,M,Fs,dt);
N=length(Y);

%Modulation Signal
AM=noiseblh(fAM1,fAM2,Fs,N);
index=find(AM<0);
AM(index)=zeros(size(index));
AM=norm1d(AM);

%Modulated sound
Y=Y.*AM;
