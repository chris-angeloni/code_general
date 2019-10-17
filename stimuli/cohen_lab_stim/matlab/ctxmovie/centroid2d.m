%function [xaxis,yaxis,I,Cx,Cy,Sx,Sy,Area]=centroid2d(data,Display)
%
%   FILE NAME 	: Centroid 2D 
%   DESCRIPTION : Computes the centroid of a 2-D map / image
%			  
%   data        : Map Data / Image
%                 Arranged so that Col 1 is the X-coordinate,
%                 Col 2 is the Y-coordinate, and Col 3 is the 
%                 amplitude of the desired parameter
%   Display     : Display results ('y' or 'n', Default=='n')
%
%RETURNED VARIABLES
%   xaxis       : X axis
%   yaxis       : Y axis
%	I           : Reconstructed Image
%   Cx,Cy       : X and Y Centroids
%   Sx,Sy       : Average widths for X and Y (second moment, standard deviation)
%   Area        : Total cummulative area
%   
%   (C) Monty A. Escabi, June 2007
%
function [xaxis,yaxis,I,Cx,Cy,Sx,Sy,Area]=centroid2d(data,Display)

%Input Args
if nargin<2
    Display=='n';
end

%setting up spatial axis
X=data(:,1);
Y=data(:,2);
Z=data(:,3);

%Finding Max Ranges
Nx=max(X);
Ny=max(Y);

%Allocating Arrays
I=zeros(Ny,Nx);
xaxis=1:Nx;
yaxis=1:Ny;

%Genrating Image
for k=1:length(X)
    I(X(k),Y(k))=Z(k);
end

%Computing Centroids and Deviates
XX=ones(1,size(I,1))'*(1:size(I,2));
YY=(1:size(I,1))'*ones(1,size(I,2));
Cx=sum(sum(I.*XX,2)) / sum(sum(I));
Cy=sum(sum(I.*YY,1)) / sum(sum(I));
Sx=sqrt( sum(sum((XX-Cx).^2.*I,2)) / sum(sum(I)) );
Sy=sqrt( sum(sum((YY-Cy).^2.*I,1)) / sum(sum(I)) );
Area=sum(sum(I));

%Plotting results if desired
if Display=='y'
    
    imagesc(xaxis,yaxis,I),colormap bone,set(gca,'YDir','normal');
    hold on
    plot(Cx,Cy,'ro','linewidth',3)
    plot([Cx Cx+Sx],[Cy Cy],'g','linewidth',3)
    plot([Cx Cx],[Cy Cy+Sy],'g','linewidth',3)
    
end