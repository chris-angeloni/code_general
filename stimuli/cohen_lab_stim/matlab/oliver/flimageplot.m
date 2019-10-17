%
%function [X] = flimageplot(filename1,filename2,alpha,FMT)
%	
%	FILE NAME       : FL IMAGE PLOT
%	DESCRIPTION 	: Plots a florescent Image
%
%   filename1       : Red Channel Image
%   filename2       : Green Channel Image
%   alpha           : Intensity scaling - 0 to 1 (Default==1)
%                     If alpha is a 2 element array scales Red and Green
%                     channels independently. First Element corresponds to
%                     Red and second element to green.
%   FMT             : Image format (Default=='TIFF')
%
%RETURNED VARIABLES
%
%   X               : Image in RGB format
%
% (C) Monty A. Escabi, April 2007
%
function [X] = flimageplot(filename1,filename2,alpha,FMT)

%Input Arguments
if nargin<3
    alpha=[1 1];
end
if nargin<4
   FMT='TIFF'; 
end
if length(alpha)==1
   alpha=alpha*[1 1]; 
end

%Reading Image Data
X1 = imread(filename1,FMT);
X2 = imread(filename2,FMT);

%Converting into RGB Image
X(:,:,1)=double(X1)/4095;
X(:,:,2)=double(X2)/4095;
X(:,:,3)=zeros(size(X1));

%Scaling Image
X=X/max(max(max(X)));
X(:,:,1)=X(:,:,1)*alpha(1);
X(:,:,2)=X(:,:,2)*alpha(2);

%Plotting Image
imagesc(X)