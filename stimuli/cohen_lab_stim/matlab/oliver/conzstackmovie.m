%
%function [Z] = conzstackmovie(filename,alpha,FMT)
%	
%	FILE NAME       : CON Z STACK MOVIE
%	DESCRIPTION 	: Plots a confocal Z Stack Movie
%
%   filename       : First Image in Z Stack Sequence
%   alpha           : Intensity scaling - 0 to 1 (Default==1)
%                     If alpha is a 2 element array scales Red and Green
%                     channels independently
%   FMT             : Image format (Default=='JPEG')
%
%RETURNED VARIABLES
%
%   Z               : Z Stack Movie in RGB format
%
% (C) Monty A. Escabi, May 2007
%
function [Z] = conzstackmovie(filename,alpha,FMT)

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

%Reading Image Files
index=findstr('_z',filename);
k=1;
Max=-9999;
while exist([filename(1:index+1) int2strconvert(k,2) filename(index+4:length(filename))],'file')
    
    %Read File and Finding Maximum for Scaling
    file=[filename(1:index+1) int2strconvert(k,2) filename(index+4:length(filename))];
    X = imread(file,FMT);
    Max=max(max(max(double(X))));
    
    %Increment File Number
    k=k+1;
end
k=1
while exist([filename(1:index+1) int2strconvert(k,2) filename(index+4:length(filename))],'file')
    
    %Read File
    file=[filename(1:index+1) int2strconvert(k,2) filename(index+4:length(filename))];
    X = imread(file,FMT);
    
    %Scaling Image
    X=double(X)/Max;
    X(:,:,1)=X(:,:,1)*alpha(1);
    X(:,:,2)=X(:,:,2)*alpha(2);
    X(:,:,3)=zeros(size(X(:,:,3)));
    
    %Append To Movie Buffer
    imagesc(X)
    Z(k)=getframe;
    
    %Increment File Number
    k=k+1;
end