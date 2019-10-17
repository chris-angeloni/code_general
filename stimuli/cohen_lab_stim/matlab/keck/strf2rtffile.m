%
%function []=strf2rtffile(filename,MaxFm,MaxRD,Tresh,Display)
%
%       FILE NAME       : STRF 2 RTF FILE
%       DESCRIPTION     : Converts an STRF File to a Ripple Transfer Function
%			  File	
%	filename	: Spectro Temporal Receptive Field File
%	MaxFm		: Maximum Modulation Rate for Experiment
%	MaxRD		: Maximum Ripple Density for Experiment
%	Tresh		: Fraction of Maximum for second response peak
%			  Two Best RD and FM are choosen if the second
%			  maximum achieves the value Tresh*max(max(RTF))
%			  where Tresh E [0 1]    
%	Display		: Display : 'y' or 'n'
%			  Default : 'n'
%
function []=strf2rtffile(filename,MaxFm,MaxRD,Tresh,Display)

%Checking Input arguments
if nargin<2
	Display='n';
end

%Loading File
f=['load ' filename];
eval(f);

%Computing RTF for Contra and Ipsi
[Fm,RD,RTF1]=strf2rtf(taxis,faxis,STRF1,MaxFm,MaxRD);
[Fm,RD,RTF2]=strf2rtf(taxis,faxis,STRF2,MaxFm,MaxRD);
[Fm,RD,RTF1s]=strf2rtf(taxis,faxis,STRF1s,MaxFm,MaxRD);
[Fm,RD,RTF2s]=strf2rtf(taxis,faxis,STRF2s,MaxFm,MaxRD);

%Finding Maximum
Max =max(max(max(RTF1)),max(max(RTF2)));
Maxs=max(max(max(RTF1s)),max(max(RTF2s)));

%Computing Best Temporal Modulation and Ripple Density Parameters
[BestFm1,BestRD1]=rtfparam(Fm,RD,RTF1,Tresh,'n');
[BestFm2,BestRD2]=rtfparam(Fm,RD,RTF2,Tresh,'n');
[BestFm1s,BestRD1s]=rtfparam(Fm,RD,RTF1s,Tresh,'n');
[BestFm2s,BestRD2s]=rtfparam(Fm,RD,RTF2s,Tresh,'n');

%Saving To File
if findstr(filename,'dB')
	index=findstr(filename,'_dB');
else
	index=findstr(filename,'_Lin');
end
f=['save ' filename(1:index-1) '_RTF Fm RD RTF1 RTF2 RTF1s RTF2s ', ...
   'BestRD1 BestFm1 BestRD2 BestFm2 BestRD1s BestFm1s BestRD2s BestFm2s'];
if ~strcmp(version,'4.2c')
	f=[f ' -v4'];
end
eval(f);

%Plotting if Desired
if strcmp(Display,'y')

	%Fixing File Name for Display
	index=findstr(filename,'_');
	for k=1:length(index)
		filename(index(k))='-';
	end

	%Maximum and Minimum Axis
	MaxFm=max(Fm);
	MaxRD=max(RD);
	MinFm=min(Fm);
	MinRD=0;

	subplot(221)
	imagesc(Fm,RD,RTF1,[0 Max]),shading flat,colormap jet
	set(gca,'Ydir','normal')	
	axis([MinFm MaxFm MinRD MaxRD])
	title('Ripple Transfer Function')
	ylabel('RD ( Cycles / Octave)')
	hold on
	plot(BestFm1,BestRD1,'ko','linewidth',5)
	hold off

	subplot(222)
	imagesc(Fm,RD,RTF2,[0 Max]),shading flat,colormap jet
	set(gca,'Ydir','normal')	
	axis([MinFm MaxFm MinRD MaxRD])
	title(filename)
	ylabel('RD ( Cycles / Octave)')
	hold on
	plot(BestFm2,BestRD2,'ko','linewidth',5)
	hold off

	subplot(223)
	imagesc(Fm,RD,RTF1s,[0 Maxs]),shading flat,colormap jet
	set(gca,'Ydir','normal')	
	axis([MinFm MaxFm MinRD MaxRD])
	ylabel('RD ( Cycles / Octave)')
	xlabel('Fm ( Hz )')
	hold on
	plot(BestFm1s,BestRD1s,'ko','linewidth',5)
	hold off

	subplot(224)
	imagesc(Fm,RD,RTF2s,[0 Maxs]),shading flat,colormap jet
	set(gca,'Ydir','normal')	
	axis([MinFm MaxFm MinRD MaxRD])
	xlabel('Fm ( Hz )')
	hold on
	plot(BestFm2s,BestRD2s,'ko','linewidth',4)
	hold off

	pause(0)
end
