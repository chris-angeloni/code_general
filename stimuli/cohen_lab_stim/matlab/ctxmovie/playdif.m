%function [mv]=playmv2(N,file1,file2)
%
%	FILE NAME 	: PSTH MV 
%	DESCRIPTION 	: Generates difference PSTH Movie for two data sets
%
%	N		: Number of Frames
%	file1		: File used for movie on screren 1.  Must include path.
%	file2		: File used for movie on screren 2.  Must include path.
%	mv		: Returned Movie. Can be played with the matlab
%			  command -> MOVIE
%	
function [mv]=playdif(N,file1,file2)

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
%	f=['MV1',num2str(n),'=','MV1',num2str(n),'-min(min(MV1',num2str(n),'));'];
%	eval(f);
	f=['Min1=min([min(min(MV1',num2str(n),')) Min1]);'];
	eval(f);
	f=['Max1=max([max(max(MV1',num2str(n),')) Max1]);'];
	eval(f);

%	f=['MV2',num2str(n),'=','MV2',num2str(n),'-min(min(MV2',num2str(n),'));'];
%	eval(f);
	f=['Min2=min([min(min(MV2',num2str(n),')) Min2]);'];
	eval(f);
	f=['Max2=max([max(max(MV2',num2str(n),')) Max2]);'];
	eval(f);
end


%Generating Movie
mv=moviein(N);
for n=1:N
	%Displaying the nth frame 
	f=['MV=abs(MV1',num2str(n),'-MV2',num2str(n),');'];
	eval(f);
	f=['pcolor(MV);'];
	eval(f);

	%Normalixing ranges
	shading interp;
	colormap jet;
	Min=min([Min1 Min2]);
	Max=max([Max1 Max2]);
	caxis([Min Max])
	hold on

	%Setting Borders
	L=length(MV(1,:));
	W=length(MV(:,1));
	set(gca,'LineWidth',3)
	set(gca,'XTick',[])
	set(gca,'YTick',[])
	text(3,20,['frame=' num2str(n)],'Color','black')

	%Getting nth the Movie Frame 
	mv(:,n)=getframe;
	hold off
end


