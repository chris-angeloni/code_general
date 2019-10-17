%
%function [Time,StddB,MeandB,KurtdB,p]=ampstdmean(Time,Amp,PDist,N)
%
%	FILE NAME 	: AMP STD MEAN
%	DESCRIPTION 	: Computes the Std and Mean decibel trajectories for 
%			  the decibel contrast distribution. Also computes the 
%			  correlation coefficient between the trajectories.
%
%	Time		: Time Axis 
%	Amp		: Amplitude Axis (Contrast,dB)
%	PDist		: Contrast Prob. Distribution
%	N		: Rescaling factor - Distribution is averaged
%			  over N temporal points. In this way
%			  distributions are estimated at distinct scales
%			  Default==1 -> no averaging
%
%RETUERNED VARIABLES
%
%	Time		: Time axis for trajectories
%	StddB		: dB amplitude STD trajectory
%	MeandB		: dB amplitude MEAN trajectory
%	KurtdB		: dB amplitude Kurtosis trajectory
%	p		: Correlation Coefficient Between
%			  StddB and MeandB
%
function [Time,StddB,MeandB,KurtdB,p]=ampstdmean(Time,Amp,PDist,N)

%Prelimninaries
if nargin < 4
	N=1;
end

%Rescaling Distribution, i.e. averaging temporal axis by factor of N
[Time,Amp,PDist]=ampdrescale(Time,Amp,PDist,N);

%Finding Mean and Std
MeandB=(PDist'*Amp)';
for k=1:size(PDist,2)
	StddB(k)=sqrt(PDist(:,k)'*(Amp-MeandB(k)).^2);
	KurtdB(k)=PDist(:,k)'*(Amp-MeandB(k)).^4 / StddB(k)^4 - 3;
end

%Find Correlation Coefficient Between MeandB and StddB
p=corrcoef(StddB,MeandB);
p=p(2,1);
