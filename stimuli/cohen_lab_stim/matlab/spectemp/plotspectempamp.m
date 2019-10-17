%
%function []=plotspectempamp(filename)
%
%	FILE NAME 	: PLOT SPEC TEMP AMP
%	DESCRIPTION 	: Plots the Spectro-Temporal Modulation 
%			  Amplitude / Contrast Distribution of a Sound 
%
%	filename	: Input File Name
%
function []=plotspectempamp(filename)

MaxAmp=50;

%Loading Data
f=['load ' filename];
eval(f)

%Finding Time Varying Parameters for PDist
MeanAmp=PDist'*Amp;
for k=1:size(PDist,2)
	StdAmp(k)=sqrt( sum(PDist(:,k).*(Amp-MeanAmp(k)).^2) );
end
MeanAmp=MeanAmp';
%Finding Mean Distribution
MeanPDist=mean(PDist');

%Plotting Time Varying Contrast Dist
subplot(4,1.5,1)
imagesc(Time,Amp,PDist),shading flat,colormap jet
set(gca,'YDir','normal')
axis([0 max(Time) -MaxAmp MaxAmp])
title(filename)
ylabel('C( time )')

%Plotting Mean Contrast Distribution
subplot(4,5,5)
plot(MeanPDist,Amp)
axis([0 max(MeanPDist)*1.2 -MaxAmp MaxAmp])

%Plotting Mean Intensity Profile
subplot(4,1.5,2.5)
plot(Time,MeanAmp,'b')
axis([0 max(Time) -MaxAmp MaxAmp])
ylabel('I( time ) = E[ C( time ) ]')

%Plotting Contrast Std Profile
subplot(4,1.5,4)
plot(Time,StdAmp,'b')
axis([0 max(Time) min(StdAmp) max(StdAmp)])
corrcoef(StdAmp,MeanAmp)
ylabel('Std[ C( time ) ]')

%Plotting Scatter - Contrast vs. Intensity
subplot(4,5,15)
plot(MeanAmp,StdAmp,'r.')
axis([min(MeanAmp) max(MeanAmp) min(StdAmp) max(StdAmp)])

%Plotting StdAmp Histogram
subplot(4,6,17)
[N,X]=hist(StdAmp,30);
plot(N/sum(N),X)
axis([0 max(N/sum(N)) min(StdAmp) max(StdAmp)])

%Plotting MeanAmp Histogram
subplot(4,6,24)
[N,X]=hist(MeanAmp,30);
plot(X,N/sum(N))
axis([min(MeanAmp) max(MeanAmp) 0 max(N/sum(N))*1.1])

