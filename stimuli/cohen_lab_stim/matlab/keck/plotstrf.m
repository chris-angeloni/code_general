%
%function [fighandle]=plotstrf(STRFfilename,invert,T)
%
%       FILE NAME       : PLOT STRF
%       DESCRIPTION     : Plots the data from an STRF file
%
%	STRFfilename	: STRF File Name
%	invert		: Inverts the Spike Waveform
%			  'y' or 'n', Default='n'
%	T		: Delay for plotting STRF ( sec )
%			  Optional 
%
function [fighandle]=plotstrf(STRFfilename,invert,T)

%Preliminaries
more off

%Loading Data files
index=find(STRFfilename=='u');
Spikefilename=STRFfilename(1:index-2);
f=['load ' STRFfilename];
eval(f);
f=['load ' Spikefilename];
eval(f);

%Searching for Double STRF presentation
if ~exist('STRF1','var')
   STRF1=STRF1A+STRF1B;
   STRF2=STRF2A+STRF2B;
end

%Input Arguments
if nargin<2
	invert='n';
end
if nargin<3
	T=max(taxis)-min(taxis);
end

%Invert Variable
if strcmp(invert,'y')
	invert=-1;
else
	invert=1;
end

%Setting Print Area
fighandle=figure;
set(fighandle,'position',[10,400,560,560],'paperposition',[.25 1.5  8 8.5]);

%Loading Rainbow Colormap 
load rainbow1

%Fixing the Filename for Print Output
index=find(STRFfilename=='_');
for l=1:length(index)
	STRFfilename(index(l))='-';
end

%Finding Unit Number and Renaming Spike Data to Generic Variable
if ~isempty(findstr(STRFfilename,'Lin'))
	index=findstr(STRFfilename,'Lin');
else
	index=findstr(STRFfilename,'dB');
end
UnitNumber=STRFfilename(index-2);
f1=['ModelWave=ModelWave' UnitNumber ';'];
f2=['SpikeWave=SpikeWave' UnitNumber ';'];
if exist(['SpikeWave' UnitNumber])
	eval(f1);
	eval(f2);
end

%Finding Max and Min
Max=max(max([STRF1 STRF2]))*sqrt(PP);
Min=min(min([STRF1 STRF2]))*sqrt(PP);

%Ploting Data
if exist('Min') & exist('Max') & ~(Min==0 & Max==0) & ~isnan(Max) & ~isnan(Min)
	if exist('STRF1s')

		%Ploting
		subplot(321)
		Max=max(abs([Max Min]));
		imagesc(taxis,log2(faxis/faxis(1)),STRF1*sqrt(PP),[-Max Max]),C1=colorbar;,colormap jet
		axis([min(taxis) min(taxis)+T 0 log2(max(faxis)/faxis(1))])
		set(C1,'Visible','off');
		C11=get(C1,'Children');
		set(C11,'Visible','off');
		set(gca,'Ydir','normal')
		title(STRFfilename)
		ylabel(['Octaves above ' int2str(faxis(1)) ' ( Hz )'])

		subplot(322)
		imagesc(taxis,log2(faxis/faxis(1)),STRF2*sqrt(PP),[-Max Max]), colorbar
		axis([min(taxis) min(taxis)+T 0 log2(max(faxis)/faxis(1))])
		title(['Wo=' num2str(Wo2,4) ' , SPL=' int2str(SPLN) ' (dB)'])
		set(gca,'Ydir','normal')

		subplot(323)
		imagesc(taxis,log2(faxis/faxis(1)),STRF1s*sqrt(PP),[-Max Max]),C2=colorbar;
		axis([min(taxis) min(taxis)+T 0 log2(max(faxis)/faxis(1))])
		set(C2,'Visible','off');
		C21=get(C2,'Children');
		set(C21,'Visible','off');
		set(gca,'Ydir','normal')
		xlabel('Time ( Sec )')
		ylabel(['Octaves above ' int2str(faxis(1)) ' ( Hz )'])
		%title(['Sound=' Sound ', MdB=' int2str(MdB) ', ModType=' SModType])

		subplot(324)
		imagesc(taxis,log2(faxis/faxis(1)),STRF2s*sqrt(PP),[-Max Max]),C3=colorbar;
		axis([min(taxis) min(taxis)+T 0 log2(max(faxis)/faxis(1))])
		set(C3,'Visible','off');
       		C31=get(C3,'Children');
       		set(C31,'Visible','off');
		set(gca,'Ydir','normal')
		xlabel('Time ( Sec )')
		pause(0)

		%Plotting Spike waveforms
		if exist('SpikeWave')
			subplot(325)
			N=floor(size(SpikeWave,1)/2);
         plot((-N:N)/Fs*1000,invert*SpikeWave/1024/32,'b');
			hold on
			plot(Time,ModelWave/1024/32,'r','linewidth',1)
			T1=min([Time -N/Fs*100]);
			T2=max([Time N/Fs*100]);
			axis([T1 T2 -1 1])
			xlabel('Time (msec)')
			hold off
			colorbar
			C1=colorbar;
			set(C1,'Visible','off');
			C11=get(C1,'Children');
			set(C11,'Visible','off');
		end
	else
      
      %Ploting
		subplot(221)
		imagesc(taxis,log2(faxis/faxis(1)),STRF1*sqrt(PP),[-Max Max]),shading flat,C1=colorbar;,colormap jet;
		set(C1,'Visible','off');
		C11=get(C1,'Children');
		set(C11,'Visible','off');
		set(gca,'Ydir','normal')
		title(STRFfilename)
		ylabel(['Octaves above ' int2str(faxis(1)) ' ( Hz )'])

		subplot(222)
		imagesc(taxis,log2(faxis/faxis(1)),STRF2*sqrt(PP),[-Max Max]),shading flat, colorbar
		title(['Wo=' num2str(Wo2,4) ' , SPL=' int2str(10*log10(PP/(2.2E-5)^2)) ' (dB)'])
		set(gca,'Ydir','normal')

		%Plotting Spike waveforms
		subplot(223)
      N=floor(size(SpikeWave,1)/2);
		plot((-N:N)/Fs*1000,SpikeWave/1024/32,'b');
		hold on
		plot(Time,ModelWave/1024/32,'r','linewidth',1)
		T1=min([Time -N/Fs*100]);
		T2=max([Time N/Fs*100]);
		axis([T1 T2 -1 1])
		xlabel('Time (msec)')
		%title(['Sound=' Sound ', MdB=' int2str(MdB) ', ModType=' SModType])
		hold off
		colorbar
		C1=colorbar;
		set(C1,'Visible','off');
		C11=get(C1,'Children');
		set(C11,'Visible','off');

	end
end

%Darkening the Colormap
brighten(.25)
