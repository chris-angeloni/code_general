%
%function [BreakPoints]=ampdistbreak(Time,Amp,PDist)
%
%	FILE NAME 	: AMP DIST BREAK
%	DESCRIPTION 	: Manually find the edges (break) points of the 
%			  relevant segments of an amplitude distribution
%			  Segments are choosen sequentially
%
%	Time		: Time Axis 
%	Amp		: Amplitude Axis (Contrast,dB)
%	PDist		: Contrast Prob. Distribution
%
%RETUERNED VARIABLES
%
%	BreakPoints	: Edge sample (in sample number) break points array
%			  Sample locations are interleaved with 
%			  start and endpoints
%			  e.g., BreakPoints=[s1 e1 s2 e2 s3 e3]
%
function [BreakPoints]=ampdistbreak(Time,Amp,PDist)

%Plotting AmpDist
imagesc(Time,Amp,PDist),colormap jet
set(gca,'YDir','normal')

%Finding Number of Sound Segments
N=input('How Many Sound Segments: ');

%Finding Edge Points 
[time,amp]=ginput(2*N);

%Convering Edge Points to Samples
BreakPoints=round(time/Time(2))';
if BreakPoints(1)<0
	BreakPoints(1)=1;
end
if BreakPoints(length(BreakPoints))>length(Time)
	BreakPoints(length(BreakPoints))=length(Time);
end

