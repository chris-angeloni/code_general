%function [mv]=playmv(N,file,dB)
%
%	FILE NAME 	: PLAY MV 
%	DESCRIPTION 	: Generates a PSTH Movie
%
%	N		: Number of Frames
%	file		: File used for movie
%	mv		: Returned Movie. Can be played with the matlab
%			  command -> MOVIE
%	dB		: Display Maginitude in dBs: 'y' or 'n'
%
function [mv]=playmv(N,file,dB)

Max=-9999;
Min=9999;

%Loading Movie Files
for n=1:N
	f=['load ',file,'.',num2str(n),'.mat'];
	disp(f);
	eval(f);
	f=['MV',num2str(n),'=I;'];
	eval(f);
end

%Finding Ranges
for n=1:N
	f=['Min=min([min(min(MV',num2str(n),')) Min]);'];
	eval(f);
	f=['Max=max([max(max(MV',num2str(n),')) Max]);'];
	eval(f);
end

%Setting Magnitude to dB
if dB=='y'
	for n=1:N
		f=['MV',num2str(n),'=20*log10(abs(MV',num2str(n),'-Min+1));'];
		eval(f);
	end
	
	Min=20*log10(1);
	Max=20*log10(Max-Min+1);
end
Min
Max
pause
%Setting ranges for (1-64)
for n=1:N
	f=['MV',num2str(n),'=round((MV',num2str(n),'-Min)/(Max-Min)*63+1);'];
	eval(f);
end

%Generating Movie
mv=moviein(N);
figure;
quote=setstr(39);
for n=1:N
%	f=['image(rot90(MV',num2str(n),quote,'));'];
	f=['pcolor(MV',num2str(n),');'];
%f=['pcolor(-MV',num2str(n),'+45);'];
	eval(f);
	shading interp;
	colormap jet;
	caxis([1 64])
	hold on

	%Setting Borders
	set(gca,'LineWidth',3.5,'XColor',[.45 .45 .45],'Ycolor',[.45 .45 .45],'Box','on')
	set(gca,'XTick',[])
	set(gca,'YTick',[])

	mv(:,n)=getframe;
	hold off
end


