%
%function [Fs,dTomax,PE]=titzetheo(Fo,Fs,NdB)
%	
%	FILE NAME 	: TITZE THEO
%	DESCRIPTION 	: Finds the theoretical maximum period measurement
%			  perturbation and measuremnet error
%
%	Fo		: Fundamental Frequency
%	Fs		: Desired Sampling Frequencies Array
%	NdB		: Signal to Noise Ration in dB 
%
%Output
%	dTomax		: Maximum dT vs Fs curve
%	PE		: Percent Fo Error
%
function [Fs,dTomax,PE]=titzetheo(Fo,Fs,NdB)


%Generating Theoretical Results
Ts=1./Fs;
Nmax=10^(-NdB/20);
dTomax=2*abs(-.2*Ts + Ts.*sin(.4*pi*Ts*Fo)./(sin(.4*pi*Ts*Fo)+sin(1.6*pi*Ts*Fo)) ) + Nmax/pi/Fo;
PE=Fo*dTomax./(1+dTomax*Fo)*100;
