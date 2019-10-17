%
%function [Time,StddB,MeandB,p]=ampstdmean(Time,Amp,PDist,N)
%
%	FILE NAME 	: AMP D RESCALE
%	DESCRIPTION 	: Temporally rescales the contrast distribution
%			  Distribution is rescaled by averaging contrast
%			  distribution, p(Amp|t) , over N time segments
%
%	Time		: Time Axis 
%	Amp		: Amplitude Axis (Contrast,dB)
%	PDist		: Contrast Prob. Distribution (time dependent)
%	N		: Rescaling factor. Averages N temporal segments.
%
%RETUERNED VARIABLES
%
%	T		: Rescaled Time axis for trajectories
%	A		: dB Amplitude Axis (should be identical to Amp) 
%	P		: Temporally Rescaled Amp Distribution
%
function [T,A,P]=ampdrescale(Time,Amp,PDist,N)

%Rescaling Distribution, i.e. averaging temporal axis by factor of N
if N>1
	NT=N*floor(size(PDist,2)/N);
	P=zeros(size(PDist,1),NT/N);
	T=zeros(1,NT/N);
	for k=1:N
		P=P+PDist(:,k:N:NT)/N;
		T=T+Time(k:N:NT)/N;
	end
	A=Amp;
elseif N==1	%No Rescaling
	A=Amp;
	P=PDist;
	T=Time;
end
