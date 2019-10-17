%function [mv]=playmv2(N,file1,file2,dB)
%
%	FILE NAME 	: PLAY MV 
%	DESCRIPTION 	: Generates a PSTH Movie for two PSTH DATA sets
%
%	N		: Number of Frames
%	file1		: File used for movie on screren 1.  Must include path.
%	file2		: File used for movie on screren 2.  Must include path.
%	mv		: Returned Movie. Can be played with the matlab
%			  command -> MOVIE
%	dB		: Display Maginitude in dBs: 'y' or 'n'
%	
function [mv]=playmv2(N,file1,file2,dB)

Max1=-9999;
Min1=9999;
Max2=-9999;
Min2=9999;

%Loading Movie Files
for n=1:N
	f=['load ',file1,'.',num2str(n),'.mat'];
	eval(f);
	f=['Loading: ',file1,'.',num2str(n),'.mat'];
	disp(f);
	f=['MV1',num2str(n),'=I;'];
	eval(f);

	f=['load ',file2,'.',num2str(n),'.mat'];
	eval(f);
	f=['Loading: ',file2,'.',num2str(n),'.mat'];
	disp(f);
	f=['MV2',num2str(n),'=I;'];
	eval(f);
end

%Finding Ranges
for n=1:N
	f=['Min1=min([min(min(MV1',num2str(n),')) Min1]);'];
	eval(f);
	f=['Max1=max([max(max(MV1',num2str(n),')) Max1]);'];
	eval(f);

	f=['Min2=min([min(min(MV2',num2str(n),')) Min2]);'];
	eval(f);
	f=['Max2=max([max(max(MV2',num2str(n),')) Max2]);'];
	eval(f);
end

%Setting Magnitude to dB
if dB=='y'
	Min=min([Min1 Min2]);
	Max=max([Max1 Max2]);

	Min=20*log10(1);
	Max=20*log10(Max-Min+1);

	for n=1:N
		f=['MV1',num2str(n),'=20*log10(abs(MV1',num2str(n),'-Min+1));'];
		eval(f);
		f=['MV2',num2str(n),'=20*log10(abs(MV2',num2str(n),'-Min+1));'];
		eval(f);
	end
end
if dB~='y'
	Min=min([Min1 Min2]);
	Max=max([Max1 Max2]);
end

%Generating Movie
mv=moviein(N);
L=length(MV11);
for n=1:N
	%Displaying the nth frame 
	f=['MV=[MV1',num2str(n),' MV2',num2str(n),'];'];
	eval(f);
	f=['pcolor(MV);'];
	eval(f);

	%Normalizing ranges
	shading interp;
	colormap jet;
	caxis([Min Max])
	hold on

	%Setting Borders
	plot([L+.5 L+.5],[0 L],'Color',[.45 .45 .45],'linewidth',3.5)
	set(gca,'LineWidth',3.5,'XColor',[.45 .45 .45],'Ycolor',[.45 .45 .45],'Box','on')
	set(gca,'XTick',[])
	set(gca,'YTick',[])
	text(10,60,['frame=' num2str(n)],'Color','black')

	%Getting nth the Movie Frame 
	mv(:,n)=getframe;
	hold off
end


