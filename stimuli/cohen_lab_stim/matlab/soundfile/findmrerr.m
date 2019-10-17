%
%function [StdERD,StdEFM,MaxERD,MaxEFM,ERD,EFM]=findmrerr(MaxRD,MaxFM,MaxX,T,fRD,fFM,M)
%
%       FILE NAME     	: FIND MR ERR
%       DESCRIPTION     : Finds the error in the RTFH estimate obtained
%			  as a result of moving ripple parameters
%
%	MaxRD		: Maximum Ripple Density  (Cycles/Octave)
%	MaxFM		: Maximum Modulation Rate (Hz)
%	MaxX		: Maximum Octave Frequency
%       T               : Receptive Field Length ( sec )
%	fRD		: Bandlimit frequency of ripple density parameter
%	fFM		: Bandlimit frequency of temporal modulation
%			  rate parameter
%	M		: Number of samples used for error estimates
%			  ( Optional ) Default == 1024*16
%
%RETURNED VARIABLES
%	StdERD		: std of error obtained from RD parameters
%	StdEFM		: std of error obtained fromr FM parameters
%	MaxERD		: Max error obtained from RD parameters
%	MaxEFM		: Max error obtained from FM parameters
%	ERD		: RD Error Array 
%	EFM		: FM Error Array
%
function [StdERD,StdEFM,MaxERD,MaxEFM,ERD,EFM]=findmrerr(MaxRD,MaxFM,MaxX,T,fRD,fFM,M)

%Input Arguments
if nargin<7
	M=1024*16;
end

%Setting Plot Area
fighandle=figure;
set(fighandle,'position',[10,300,500,500],'paperposition',[.25 1.5  8 8.5]);

%RD Errors
subplot(221)
Fs=20*fRD;
RD=MaxRD*noiseunif(fRD,Fs,M);
ERD=diff(RD)*Fs*MaxX/2;
[N,X]=hist(ERD,30);
bar(X,N/sum(N),'b')
xlabel('Error ( Hz )')
ylabel('Probability')
text(.05,.8,['stdERD=' num2str(std(ERD))],'units','normalized')
text(.05,.6,['MaxERD=' num2str(max(abs(ERD)))],'units','normalized')

%FM Errors
subplot(222)
Fs=1/T;
FM=2*MaxFM*(noiseunif(fFM,Fs,M)-.5);
EFM=diff(FM);
[N,X]=hist(EFM,30);
bar(X,N/sum(N),'b')
xlabel('Error ( Hz )')
ylabel('Probability')
text(.05,.8,['stdEFM=' num2str(std(EFM))],'units','normalized')
text(.05,.6,['MaxEFM=' num2str(max(abs(EFM)))],'units','normalized')

%Cumulative Errors : ERD+EFM
subplot(223)
[N,X]=hist(EFM+ERD,30);
bar(X,N/sum(N),'b')
xlabel('Cumulative Error ( Hz )')
ylabel('Probability')
text(.05,.8,['std(EFM+ERD)=' num2str(std(EFM+ERD))],'units','normalized')
text(.05,.6,['Max(EFM+ERD)=' num2str(max(abs(EFM+ERD)))],'units','normalized')

%Computing Error Max and Standard Deviation
MaxERD=max(ERD);
MaxEFM=max(EFM);
StdERD=std(ERD);
StdEFM=std(EFM);

%Writtting Parameters
subplot(224)
set(gca,'visible','off')
text(0,1,['fRD= ' num2str(fRD)],'units','normalized')
text(0,.8,['fFM= ' num2str(fFM)],'units','normalized')
text(0,.6,['MaxRD= ' num2str(MaxRD)],'units','normalized')
text(0,.4,['MaxFM= ' num2str(MaxFM)],'units','normalized')
text(0,.2,['MaxX= ' num2str(MaxX)],'units','normalized')
text(0,0,['T= ' num2str(T)],'units','normalized')


