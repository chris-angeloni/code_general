%
%function [fighandle]=plotdbspl(filename,invert,PlotType)
%
%       FILE NAME       : PLOT dB SPL
%       DESCRIPTION     : Plots Spike Train Var, Mean and Var/Mean
%			  as a function of dB vs. SPL
%
%	filename	: dB vs. SPL File
%	invert		: Invert the Spike Waveform 'y' or 'n'
%			  Default: 'n'
%	PlotType	: Plot Type : 'pcolor' or 'surf'
%			  Default: 'pcolor'
%	fighandle	: Returned Figure Handle
%
function [fighandle]=plotdbspl(filename,invert,PlotType)

%Preliminaries
more off

%Input Arguments
if nargin<2
	invert='n';
end
if nargin<3
	PlotType='surf';
end

%Checking Invert Variable
if invert=='y'
	invert=-1;
else
	invert=1;
end

%Setting Print Area
fighandle=figure;
set(fighandle,'position',[0,325,560,400],'paperposition',[.25 1.5  8 8.5]);

%Loading Data files
f=['load ' filename];
eval(f);

%Loading Spike File
index1=findstr(filename,'_u');
index2=findstr(filename,'_dBSPL');
f=['load ' filename(1:index1-1)];
eval(f);
UnitNumber=filename(index1+2:index2-1);

%Plotting Mean
subplot(221)
dBA=min(dBAxis):3:max(dBAxis);
SPLA=flipud((min(SPLAxis):3:max(SPLAxis))');
M=interp2(dBAxis,SPLAxis,Mean,dBA,SPLA);
if strcmp(PlotType,'pcolor')
	pcolor(dBA,SPLA,M),colormap jet,colorbar
else
	surf(dBA,SPLA,M),colormap jet
	view(-20,40)
end
%imagesc(dBA,SPLA,flipud(M)),colormap jet,colorbar
title(['Mean Spike Count using ' int2str(round(1/Fsd*1000)) ' ms Window'])
xlabel('Modulation Depth ( dB )')
ylabel('SPL ( dB )')

%Plotting Var
subplot(222)
V=interp2(dBAxis,SPLAxis,Var,dBA,SPLA);
if strcmp(PlotType,'pcolor')
	pcolor(dBA,SPLA,V),colormap jet,colorbar
else
	surf(dBA,SPLA,V),colormap jet
	view(-20,40)
end
%imagesc(dBA,SPLA,flipud(V)),colormap jet,colorbar
title(['Var Spike Count using ' int2str(round(1/Fsd*1000)) ' ms Window'])
xlabel('Modulation Depth ( dB )')
ylabel('SPL ( dB )')
pause(0)

%Plotting Fano Factor
subplot(223)
[i,j]=find(Mean==0);
for k=1:length(i)
	Mean(i(k),j(k))=1;
	Var(i(k),j(k))=1;
end
FF=Var./Mean;
F=interp2(dBAxis,SPLAxis,FF,dBA,SPLA);
if strcmp(PlotType,'pcolor')
	pcolor(dBA,SPLA,F),colormap jet,colorbar
else
	surf(dBA,SPLA,F),colormap jet
	view(-20,40)
end
%imagesc(dBA,SPLA,flipud(F)),colormap jet,colorbar
title(['Var/Mean Spike Count using ' int2str(round(1/Fsd*1000)) ' ms Window'])
xlabel('Modulation Depth ( dB )')
ylabel('SPL ( dB )')
pause(0)

%Plotting Spike Data
f1=['SpikeWave=SpikeWave' UnitNumber ';'];
eval(f)
f2=['ModelWave=ModelWave' UnitNumber ';'];
eval(f)
if exist(['SpikeWave' UnitNumber])
        eval(f1);
        eval(f2);
end
if exist(['SpikeWave' UnitNumber])
	%Plotting Spike waveforms
	subplot(224)
	N=floor(length(SpikeWave)/2);
	plot((-N:N)/Fs*1000,invert*SpikeWave/1024/32,'b');
	hold on
	plot(Time,ModelWave/1024/32,'r','linewidth',1)
	T1=min([Time -N/Fs*100]);
	T2=max([Time N/Fs*100]);
	axis([T1 T2 -1 1])
	xlabel('Time (msec)')

	%Filename Title
	index=findstr(filename,'_');
	for k=1:length(index)
		filename(index(k))='-';
	end
	title(filename)
end

