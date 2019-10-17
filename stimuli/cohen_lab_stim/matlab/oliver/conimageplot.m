%
%function [X] = flimageplot(filename,alpha,FMT)
%	
%	FILE NAME       : CON IMAGE PLOT
%	DESCRIPTION 	: Plots a confocal Image
%
%   filename        : Green / Red Merged Image
%   alpha           : Intensity scaling - 0 to 1 (Default==1)
%                     If alpha is a 2 element array scales Red and Green
%                     channels independently
%   FMT             : Image format (Default=='JPEG')
%
%RETURNED VARIABLES
%
%   X               : Image in RGB format
%
% (C) Monty A. Escabi, April 2007
%
function [X] = flimageplot(filename,alpha,FMT)

%Input Arguments
if nargin<2
    alpha=[1 1];
end
if length(alpha)==1
   alpha=alpha*[1 1]; 
end
if nargin<3
   FMT='JPEG'; 
end

%Reading Image Data - should be in RGB
X = imread(filename,FMT);

%Scaling Image
X=double(X)/max(max(max(double(X))));
X(:,:,1)=X(:,:,1)*alpha(1);
X(:,:,2)=X(:,:,2)*alpha(2);

%Plotting Image
imagesc(X)