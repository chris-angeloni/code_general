%function [I,xaxis,yaxis]=tesselate(data,Nx,Ny)
%
%	FILE NAME 	: TESILATE
%	DESCRIPTION 	: An asproximate Tesselation routine which returns 
%			  a sampled version of the tesilated Map/Image
%			  
%	data		: Map Data / Image
%			  Arranged so that Col 1 is the X-coordinate,
%			  Col 2 is the Y-coordinate, and Col 3 is the 
%			  amplitude of the desired parameter
%	Nx,Ny		: Number of samples for reconstructed map (Ny x Nx)
%	xaxis, yaxis	: X and Y axis.  Normalized [0,1]
%	I		: Tesilated map/Image
%
function [I,xaxis,yaxis]=tesselate(data,Nx,Ny)

%Normalizing X and Y
%[data]=normmap(data);

%setting up spatial axis
X=data(:,1);
Y=data(:,2);
Z=data(:,3);

%Finding Max Ranges
maxX=max(X);
minX=min(X);
maxY=max(Y);
minY=min(Y);

%Allocating Arrays
I=zeros(Ny,Nx);
xaxis=(0:Nx-1)/(Nx-1)*(maxX-minX) + minX;
yaxis=(0:Ny-1)/(Ny-1)*(maxY-minY) + minY;

%Tesilating
for j=1:Nx
	for k=1:Ny
		dis2=(xaxis(j)-X).^2+(yaxis(k)-Y).^2;
		index= find( dis2==min(dis2) );
		I(k,j)=Z(index);
	end
end

