%
%function [] = flimageplot(filename1,filename2)
%	
%	FILE NAME       : FL IMAGE PLOT
%	DESCRIPTION 	: Plots a florescent Image
%
%   filename1       : Green Channel Image
%   filename2       : Red Channel Image
%
%RETURNED VARIABLES
%
%   X               : Image in RGB format
%
% (C) Monty A. Escabi, April 2007
%
function [X1,X2,C] = flimageimagealign(filename1,filename2,FMT)

%Reading Image Data
X1 = double(imread(filename1,FMT));
X2 = double(imread(filename2,FMT));

LL=5
N1=floor(size(X1,1)/LL);
N2=floor(size(X2,2)/LL);        
for k=1:LL
    for l=1:LL
    [k l]
        index1=(k-1)*N1+(1:N1);
        index2=(l-1)*N2+(1:N2);
        S=X1(index1,index2);
        C(:,:,k,l) = normxcorr2(S,X2);

    subplot(LL,LL,(k-1)*LL+l)
    imagesc(C(:,:,k,l))
    caxis([-1 1])
    pause(1)
    
    end
end




%subplot(221)
%imagesc(X1)
%subplot(222)
%imagesc(X2)
