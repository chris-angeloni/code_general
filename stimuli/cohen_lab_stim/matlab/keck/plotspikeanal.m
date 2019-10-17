%
%function [fighandel]=plotspikeanal(SPKANALfile,Lag,invert)
%
%       FILE NAME       : PLOT SPIKE ANAL
%       DESCRIPTION     : Plots the data from an SpkA File
%	
%	SPKANALfile	: Spike Anal 'SpkA' Filename
%	Lag		: Temporal Lag for IETH, XCORR
%	invert		: Inverts the Spike Waveform
%			  'y' or 'n', Default='n'
%
function [fighandel]=plotspikeanal(SPKANALfile,Lag,invert)

%Input Arguments
if nargin<3
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

%Loading Data files
index=findstr(SPKANALfile,'_u');
Spikefile=SPKANALfile(1:index-1);
f=['load ' SPKANALfile];
eval(f);
f=['load ' Spikefile];
eval(f);

if exist('PSD')
	%Setting Print Area
	fighandel=figure;
%	set(fighandel,'position',[700,400,560,560],'paperposition',[.25 1.5  8 8.5]);

	%Renaming Variables as Generic Variables
	index1=findstr(SPKANALfile,'_u');
	index2=findstr(SPKANALfile,'_SpkA');
	Unit=str2num(SPKANALfile(index1+2:index2-1));
	f=['ModelWave=ModelWave' int2str(Unit) ';'];
	eval(f);
	f=['SpikeWave=SpikeWave' int2str(Unit) ';'];
	eval(f);

	%Ploting Data
	subplot(321)
	plot(Faxis,abs(PSD))
	hold on
	plot([min(Faxis) max(Faxis)],[PSDC(1) PSDC(1)],'r')
	plot([min(Faxis) max(Faxis)],[PSDC(2) PSDC(2)],'r')
	%plot([min(Faxis) max(Faxis)],[1+sigma 1+sigma],'g')
	%plot([min(Faxis) max(Faxis)],[1-sigma 1-sigma],'g')
	axis([0 max(Faxis)/2 0 1.25*max(abs(PSD))])
	hold off
	xlabel('Frequency ( Hz )')
	ylabel('Power Spectrum')
	index=find(SPKANALfile=='_');
	for k=1:length(index)
		SPKANALfile(index(k))='-';
	end
	title([SPKANALfile ' , Unit = ' int2str(Unit)]);

	subplot(322)
	N=(length(R)-1)/2;
	plot((-N:N)/Fsd,R)
	ylabel('Normalized X-Covariance ')
	xlabel('Lag ( sec )')
	axis([-Lag Lag 1.1*min(R) 1.1*max(R)])

	subplot(323)
	bar(TaxisC,CHist,'b')
	ch=get(gca,'children');
	if ~findstr(version,'4.2c')
		set(ch,'EdgeColor','b')
		set(ch,'FaceColor','b')
	end
	xlabel('Time After a Spike ( sec )')
	ylabel('Probability')
	axis([0 Lag 0 1.25*max(CHist)])

	subplot(324)
	bar(DT,IETH,'b')
	ch=get(gca,'children');
	if ~findstr(version,'4.2c')
		set(ch,'EdgeColor','b')
		set(ch,'FaceColor','b')
	end
	xlabel('Inter Spike Time ( sec )')
	ylabel('Probability')
	axis([0 Lag 0 1.25*max(IETH)])

	subplot(325)
	loglog(TT,FF,'b')
	xlabel('Averaging Window ( sec )')
	ylabel('Fano Facrtor')
	axis([min(TT)-.001 max(TT)+.001 min(min(FF),.1) max(max(FF),10)])
	set(gca,'XTick',[.0001 .001 .01 .1 1 10 100])

	subplot(326)
	N=size(SpikeWave);
	N=(N(1)-1)/2;
	plot((-N:N)/Fs*1000,invert*SpikeWave/1024/32,'b')
	hold on
	plot(Time,ModelWave/1024/32,'r','linewidth',2)
	axis([-N/Fs*1000 N/Fs*1000 -1 1])
	xlabel('Time ( sec )')
else
	disp('Not Enougth Spikes to Compute Data!!!')	
	fighandel=-9999;
end
