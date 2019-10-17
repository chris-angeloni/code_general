%
% function [RASDataN] = rastertextureNconvert(Data,PARAM,SOUND,TD,OnsetT,Unit)
%
%	FILE NAME 	: RASTER TEXTURE N CONVERT
%	DESCRIPTION : Changes the data format by swapping out the data 
%                 structure order. Channels are swapped for sound
%                 conditions.
%
%	RASDataN(j): RASTER Data Structure Vector (j is the channel number)
%                   RASData(k,l).RASTER              - Raster Structure for each
%                                                      texture sound (k) and parameter condition (l)
%                   RASData(k,l).Param               - Sound parameters
%                   RASData(k,l).Sound               - Sound Condition
%
%   RETURNED VARIABLE
%
%	RASDataN2(k,l): RASTER Data Structure Vector (k is the sound and l is the sound parameter)
%                   RASData(m).RASTER              - Raster Structure for
%                                                    each channel
%                                                    (m==channel number)
%                                                  
%                   RASData(m).Param               - Sound parameters
%                   RASData(m).Sound               - Sound Condition
%
%
%   (C) F. Khatami, Monty A. Escabi, Nov2016
%
function [RASDataN2]=rastertextureNconvert(RASDataN) 

%Swapping out channels and sound conditions
for k=1:size(RASDataN(1).RASData,1)
    for l=1:size(RASDataN(1).RASData,2)
        for m=1:length(RASDataN)
                RASDataN2(k,l).RASData(m)=RASDataN(m).RASData(k,l);
        end
    end
end
