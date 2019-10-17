%
%function [fighandel]=plotstrfs(STRFFile,T,SoundCh)
%
%       FILE NAME       : PLOT STRFs
%       DESCRIPTION     : Plots all the STRFs from a given spike file
%			  sequence
%
%	STRFFile	: STRF Filename
%	T		: Maximum delay to plot STRFs ( msec )
%			  Default: 50 ms
%	SoundCh		: Sound Channel Number ( 1 or 2 )
%			  If both channels desired - [1 2]
%			  Default: SoundCh = 1
%
function [fighandel]=plotstrfs(STRFFile,T,SoundCh)

%Input Arguments
if nargin<2
	T=50;
end
if nargin<3
	SoundCh=1;
end

%Preliminaries
more off

%Loading Data files
index=findstr(STRFFile,'_u');
SpikeFile=STRFFile(1:index-1);
f=['load ' SpikeFile];
eval(f);

%Finding All Non-Outlier Spet Variables
count=-1;
while exist(['spet' int2str(count+1)])
	count=count+1;
end
Nspet=(count+1)/2;

%Number of Subplots
if Nspet<=4
	N1=2;
	N2=2;
	Height=.35;
elseif Nspet<=6
	N1=3;
	N2=2;
	Height=.18;
else
	N1=3;
	N2=3;
	Height=.18;
end

if length(SoundCh)==1

	%Setting Figure and PaperPosition
	fighandle=figure('Name',...
		['STRFs for ' SpikeFile ', Sound Channel ' int2str(SoundCh)],...
		'NumberTitle','off');
	set(fighandle,'position',[400,200,600,500],'paperposition',...
		[.25 1.5  8 8.5]);

	%Plotting STRFs
	for k=0:Nspet-1

			%Loading STRF Files
			f=['load ' STRFFile];
			f(5+index+2)=int2str(k);
			eval(f)	

			if SoundCh==2
				%Plotting STRF - Sound Channel 2
				s=subplot(N1,N2,k+1);
				Pos=get(s,'Position');,Pos(4)=Height;
				set(s,'Position',Pos);
				X=log2(faxis/faxis(1));
				imagesc(taxis*1E3,X,STRF2s*sqrt(PP)),...
				colormap jet, colorbar
				set(gca,'Ydir','normal')
				axis([min(taxis)*1000 (min(taxis))*1000+T,...
				0 max(X)])
				title(['U=' int2str(k) , ...
				', Wo1=' num2str(Wo1) ', No=' int2str(No1)])
			else
				%Plotting STRF - Sound Channel 1
				s=subplot(N1,N2,k+1);
				Pos=get(s,'Position');,Pos(4)=Height;
				set(s,'Position',Pos);
				X=log2(faxis/faxis(1));
				imagesc(taxis*1E3,X,STRF1s*sqrt(PP)),...
				colormap jet,colorbar
				set(gca,'Ydir','normal')
				axis([min(taxis)*1000 (min(taxis))*1000+T,...
				0 max(X)])
				title(['U=' int2str(k) , ...
				', Wo1=' num2str(Wo1) ', No=' int2str(No1)])
			end

	end
	hold off

elseif length(SoundCh)==2

	%Plotting STRFs for both channels
	[fighandel1]=plotstrfs(STRFFile,T,SoundCh(1));
	[fighandel2]=plotstrfs(STRFFile,T,SoundCh(2));
	fighandel=[fighandel1 fighandel2];	
end

