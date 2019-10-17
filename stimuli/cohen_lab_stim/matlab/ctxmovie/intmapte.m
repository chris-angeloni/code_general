%function [xaxis,yaxis,I]=intmapte(data,N,wcx,wcy,M,disp)
%
%	FILE NAME 	: INT MAP TE
%	DESCRIPTION 	: Interpolates a randomly sampled map or image.
%			  Uses the 2-D Tesselation Routine followed by
%			  an FIR 2-D Escabi/Roark windowed ideal sinc 
%			  low pass filter.  The interpolation uses a 
%			  periodic extension of the Image / Map to reduce
%			  error at the edge boundaries    
%			  
%	data		: Map Data / Image
%			  Arranged so that Col 1 is the X-coordinate,
%			  Col 2 is the Y-coordinate, and Col 3 is the 
%			  amplitude of the desired parameter
%	N		: Number of samples for reconstructed map (N x N)
%	wcx,wcy		: Discrete Lowpass Filter Cuttoff Frequency
%	M		: Half of filter order (2M x 2M)
%	xaxis, yaxis	: X and Y axis.  Normalized [0,1]
%	I		: Reconstructed map/Image
%	disp		: Display - 'y' or 'n'
%
function [xaxis,yaxis,I]=intmapte(data,N,wcx,wcy,M,disp)

%Tesselating
[I,xaxis,yaxis]=tesselate(data,N,N);

%Periotic Extension
[Iext]=perextu(I);

%Making 2-D axis for ER MaxFlat / FIR Filter
for k=1:2*M+1
	Xaxis(k,:)=-M:M;
end
for k=1:2*M+1
	Yaxis(:,k)=(-M:M)';
end

%Filter Design / ER MaxFlat
%Normalized relative to Ts
[Tsx,Tsy]=findT(data,3,'n');
Tsx=(max(data(:,1))-min(data(:,1)))/sqrt(length(data));
Tsy=(max(data(:,2))-min(data(:,2)))/sqrt(length(data));
alpha=1;
Tnewx=(max(data(:,1))-min(data(:,1)))/N;
Tnewy=(max(data(:,2))-min(data(:,2)))/N;
wcx=wcx*Tnewx/Tsx;
wcy=wcy*Tnewy/Tsy;
Px=(M+1)*wcx/pi;
Py=(M+1)*wcy/pi;
hf=h(Xaxis,wcx,alpha,Px).*h(Yaxis,wcy,alpha,Py);

%Filtering
I=conv2(hf,Iext);
naxis=floor(length(I(1,:))/2)-N/2+1:floor(length(I(1,:))/2)+N/2;
maxis=floor(length(I(:,1))/2)-N/2+1:floor(length(I(:,1))/2)+N/2;
I=I(naxis,maxis);

%Displaying
if disp=='y'
	figure
	clf
	set(gcf,'units','pixel','Position',[850 300  512/N*2*M 512/N*2*M])
	pcolor(hf)
	set(gca,'Xtick',[],'Ytick',[])
	colormap jet
	shading flat
	%colorbar

	figure
	clf
	set(gcf,'units','pixel','Position',[300 300 512 512])
	title('h(x,y)')
	pcolor(xaxis,yaxis,I)
	shading flat
	colormap jet
	%colorbar
end
