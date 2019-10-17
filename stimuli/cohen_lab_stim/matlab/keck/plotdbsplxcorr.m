%
%function [fighandle]=plotdbsplxcorr(filename)
%
%       FILE NAME       : PLOT dB VS SPL XCORR
%       DESCRIPTION     : Plots X-Correlation vs dB and SPL
%
function [fighandle]=plotdbsplxcorr(filename)

%Preliminaries
more off

%Setting Print Area
fighandle=figure;
set(fighandle,'position',[700,400,560,560],'paperposition',[.25 1.5  8 8.5]);


%Loading Data files
f=['load ' filename];
eval(f);

%Plotting dB vs SPL X-Corr
%Finding Amplitude and Temporal Ranges
Max=1.2*max(max(Xcorr));
Min=min(min(Xcorr));
N=floor(size(Xcorr,2)/2);
taxis=(-N:N)/Fsd;

N3=5
for k=1:5*N3
	subplot(N3,5,k)
	plot(taxis,Xcorr(k,:),'r')
	axis([ min(taxis) max(taxis) Min Max])
end

