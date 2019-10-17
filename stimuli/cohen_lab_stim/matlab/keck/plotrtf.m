%
%function [fighandle]=plotrtf(filename)
%
%       FILE NAME       : PLOT RTF 
%       DESCRIPTION     : Plots data from an RTF File
%
%	
%	filename	: Ripple Transfer Function File
%
function [fighandle]=plotrtf(filename)

%Loading RTF File
f=['load ' filename];
eval(f);

%Setting Print Area
fighandle=figure;
set(fighandle,'position',[700,400,560,560],'paperposition',[.25 1.5  8 8.5]);

%Fixing File Name for Display
index=findstr(filename,'_');
for k=1:length(index)
	filename(index(k))='-';
end

%Finding Maximum
Max =max(max(max(RTF1)),max(max(RTF2)));
Maxs=max(max(max(RTF1s)),max(max(RTF2s)));

%Maximum and Minimum Axis
MaxFm=max(Fm);
MaxRD=max(RD);
MinFm=min(Fm);
MinRD=0;

if Max>0
	subplot(221)
	imagesc(Fm,RD,RTF1,[0 Max]),shading flat,colormap jet
	set(gca,'Ydir','normal')	
	axis([MinFm MaxFm MinRD MaxRD])
	title('Ripple Transfer Function')
	ylabel('RD ( Cycles / Octave)')
	hold on
	plot(BestFm1,BestRD1,'ko','linewidth',3)
	hold off

	subplot(222)
	imagesc(Fm,RD,RTF2,[0 Max]),shading flat,colormap jet
	set(gca,'Ydir','normal')	
	axis([MinFm MaxFm MinRD MaxRD])
	title(filename)
	ylabel('RD ( Cycles / Octave)')
	hold on
	plot(BestFm2,BestRD2,'ko','linewidth',3)
	hold off
end

if Maxs>0
	subplot(223)
	imagesc(Fm,RD,RTF1s,[0 Maxs]),shading flat,colormap jet
	set(gca,'Ydir','normal')	
	axis([MinFm MaxFm MinRD MaxRD])
	ylabel('RD ( Cycles / Octave)')
	xlabel('Fm ( Hz )')
	hold on
	plot(BestFm1s,BestRD1s,'ko','linewidth',3)
	hold off

	subplot(224)
	imagesc(Fm,RD,RTF2s,[0 Maxs]),shading flat,colormap jet
	set(gca,'Ydir','normal')	
	axis([MinFm MaxFm MinRD MaxRD])
	xlabel('Fm ( Hz )')
	hold on
	plot(BestFm2s,BestRD2s,'ko','linewidth',3)
	hold off
end
pause(0)
