%
%function [fighandle]=plotrtfhist(filename,RDMax,FMMax,invert)
%
%       FILE NAME       : PLOT RTF HIST
%       DESCRIPTION     : Plots the data from an RTF Hist file
%
%	filename	: Input RTFHist file name
%	RDMax		: Maximum Ripple Density
%			  Default = 4 Cycles / Octave
%	FMMax		: Maximum Modulation Rate 
%			  Default = 350 Hz
%	invert		: Inverts the Spike Waveform
%			  'y' or 'n', Default='n'
%
function [fighandle]=plotrtfhist(filename,RDMax,FMMax,invert)

%Input Arguments
if nargin < 2
	RDMax=4;
	FMMax=350;
	invert='n';
elseif nargin < 3
	FMMax=350;
	invert='n';
elseif nargin<4
	invert='n';
end

%Invert Variable
if strcmp(invert,'y')
	invert=-1;
else
	invert=1;
end

%Preliminaries
more off

%Setting Print Area
fighandle=figure;
set(fighandle,'position',[700,400,560,560],'paperposition',[.25 1.5  8 8.5]);
pause(0)

%Loading Data files
index=findstr(filename,'_u');
Spikefilename=filename(1:index-1);
f=['load ' filename];
eval(f);
f=['load ' Spikefilename];
eval(f);

%Fixing the Filename for Print Output
index=find(filename=='_');
for l=1:length(index)
	filename(index(l))='-';
end

%Ploting Data
MFM=2*FMMax/20*(-10:9)+2*FMMax/20/2;
MRD=RDMax/20*(0:19)+RDMax/20/2;

subplot(321)
[FM,RD,N]=hist2(FM1,RD1,MFM,MRD);
pcolor(-FM,RD,N)
C1=colorbar;
set(C1,'Visible','off');
C11=get(C1,'Children');
set(C11,'Visible','off');
ylabel(['RD ( Cycle/Oct )'])
xlabel(['FM ( Hz )'])
colormap jet
title('Ripple Transfer Function Histogram')
pause(0)

subplot(322)
[FM,RD,N]=hist2(FM2,RD2,MFM,MRD);
pcolor(-FM,RD,N)
colorbar;
ylabel(['RD ( Cycle/Oct )'])
xlabel(['FM ( Hz )'])
colormap jet
title(filename)
pause(0)

subplot(323)
[RDC,RDI,N]=hist2(RD1,RD2,MRD,MRD);
pcolor(RDC,RDI,N)
C1=colorbar;
set(C1,'Visible','off');
C11=get(C1,'Children');
set(C11,'Visible','off');
ylabel(['Ipsi - RD'])
xlabel(['Contra - RD'])
colormap jet
pause(0)

subplot(324)
[FMC,FMI,N]=hist2(FM1,FM2,MFM,MFM);
pcolor(FMC,FMI,N)
colorbar;
xlabel(['Contra - FM'])
ylabel(['Ipsi - FM'])
colormap jet
pause(0)

%Finding Unit Number
index1=findstr(filename,'-u');
index2=findstr(filename,'-RTF');
Unit=str2num(filename(index1+2:index2-1));

%Plotting Spikes if Available
if exist(['SpikeWave' int2str(Unit)]) & exist(['ModelWave' int2str(Unit)])
	%Renaming Spike Data to Generic Variable
	f=['SpikeWave=SpikeWave' int2str(Unit) ';'];
	eval(f);
	f=['ModelWave=ModelWave' int2str(Unit) ';'];
	eval(f);

	%Plotting Spike waveforms
	subplot(325)
	N=floor(length(SpikeWave)/2);
	plot((-N:N)/Fs*1000,invert*SpikeWave/1024/32,'b');
	hold on
	plot(Time,ModelWave/1024/32,'r','linewidth',2)
	T1=min([Time -N/Fs*100]);
	T2=max([Time N/Fs*100]);
	axis([T1 T2 -1 1])
	xlabel('Time (msec)')
	hold off
end
