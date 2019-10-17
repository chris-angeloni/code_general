%
%function [T,R,RR]=strf2xcorr(taxis,faxis,STRF1,STRF2,PP,Display)
%
%   FILE NAME   : STRF 2 XCORR
%   DESCRIPTION : X-Correlation Function obtained from the STRF
%
%   taxis       : Time Axis for STRF
%   faxis       : Frequency Axis for STRF
%   STRF1       : STRF for unit 1
%   STRF2       : STRF for unit 2
%   PP          : Signal Power, i.e. the sound variance
%   Disp        : Display : 'y' or 'n' (Default : 'y')
%
%RETURNED VARIABLES
%
%   T           : Time Axis
%   R           : X-Correlation accounted by STRFs between unit 1 and 2 (spikes^2/sec^2)
%   Rcc         : X-correlation normalized as a correlation coefficient
%   RR          : X-Correlation for All Frequency Bands
%
% (C) Monty A. Escabi, Edited Nov 2009
%
function [T,R,Rcc,RR]=strf2xcorr(taxis,faxis,STRF1,STRF2,PP,Display)

%Preliminaries
if nargin<6
	Display='y';
end

%Computing X-Correlation 
Fst=inv(taxis(2)-taxis(1));
N1=length(STRF1(:,1));
N2=length(STRF1(1,:));
for k=1:N1
	RR(k,:)=xcorr(STRF1(k,:),STRF2(k,:))/Fst;
end
R=sum(RR)*PP;
Std1=strfstd(STRF1,zeros(size(STRF2)),PP,Fst);
Std2=strfstd(zeros(size(STRF1)),STRF2,PP,Fst);
Rcc=R/Std1/Std2;
T=(-N2+1:N2-1)*taxis(2);

%Displaying If Desired
if strcmp(Display,'y')
	subplot(211)
	pcolor(T,log2(faxis/500),RR),shading flat, colormap jet
	subplot(212)
	plot(T,R)
	ylabel('X-Correlation ( Spike / sec )^2')
	xlabel('Temporal Lag (sec)')
end