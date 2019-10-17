%function [Xshift,Xscale]=fimodelcombine(HarmonicData,L)
%	
%	FILE NAME       : FI MODEL COMBINE
%	DESCRIPTION     : Generate synthetic phonation sisgnals
%
%   HarmonicData(k) : Array of data structure containing
%                     .Y
%                     .Phase
%                     .Fi
%   L               : Number of harmonics to combine
%
%   RETURNED VARIABLES
%
%   Xshift
%   Xscale
%
% (C) Monty A. Escabi, June 2010
%
function [Xshift,Xscale]=fimodelcombine(HarmonicData,L)

Xshift=zeros(size(HarmonicData(1).Phase));
Xscale=zeros(size(HarmonicData(1).Phase));
for k=1:L

    %Combining by shifting the fundamental
    Phase=HarmonicData(1).Phase;
    Fo=mean(HarmonicData(1).Fi);
    time=(1:length(HarmonicData(k).Phase))/HarmonicData(k).Fs;
    Xshift=Xshift+sin(2*pi*Fo*(k-1)*time+Phase)/(1/sqrt(2))*std(HarmonicData(k).Y);
    
    %Combining by Scaling the fundamental
    Phase=HarmonicData(1).Phase;
    Xscale=Xscale+sin(k*Phase)/(1/sqrt(2))*std(HarmonicData(k).Y);
    
end