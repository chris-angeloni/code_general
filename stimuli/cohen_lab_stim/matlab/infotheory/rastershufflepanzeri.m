%
%function [RASTERsh]=rastershufflepanzeri(RASTER)
%
%   FILE NAME       : RASTER SHUFFLE PANZERI
%   DESCRIPTION     : Shuffles a raster by randomizing individual bins
%                     across trials using the procedure by Panzeri.
%
%	RASTER          : Dot raster in matrix format
%
%Returned Variables
%	RASTERsh        : Shuffled rastergram.
%
% (C) Monty A. Escabi, Aug 2012
%
function [RASTERsh]=rastershufflepanzeri(RASTER)

%Randomizing bins across trials
N1=size(RASTER,1);
N2=size(RASTER,2);
for k=1:N2
    index=randperm(N1)';
    RASTERsh(:,k)=RASTER(index,k);
end