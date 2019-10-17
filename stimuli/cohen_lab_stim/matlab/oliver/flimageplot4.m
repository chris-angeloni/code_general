%
%function [] = flimageplot4(filename1,filename2,offset,alpha,FMT)
%	
%	FILE NAME       : FL IMAGE PLOT 4
%	DESCRIPTION 	: Plots a florescent 4 Image Sequence
%
%   filename1       : Red Channel Image
%   filename2       : Green Channel Image
%   offset          : Starting offset for sequence
%   alpha           : Intensity scaling - 0 to 1 (Default==1)
%                     If alpha is a 2 element array scales Red and Green
%                     channels independently. First Element corresponds to
%                     Red and second element to green.
%   FMT             : Image format (Default=='TIFF')
%
% (C) Monty A. Escabi, April 2007
%
function [] = flimageplot4(filename1,filename2,offset,alpha,FMT)

if nargin<4
    alpha=1;
end
if nargin<5
    FMT='TIFF';
end

%Finding Image Index
file1=filename1;
file2=filename2;
index1=findstr(file1,'No');
index2=findstr(file2,'No');

%Indexing and Plotting Images
for k=1:4
    subplot(2,2,k)
    file1(index1+2)=int2str(offset+k-1);
    file2(index2+2)=int2str(offset+k-1);
    flimageplot(file1,file2,alpha,FMT);
end