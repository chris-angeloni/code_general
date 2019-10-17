%
% function [RASDataN] = rastertexturegenerateN(Data,PARAM,SOUND,TD,OnsetT,Unit,Order)
%
%	FILE NAME 	: RASTER TEXTURE GENERATE N
%	DESCRIPTION : Generates N dot rasters for a mutichannel recording (N channels) 
%                 for a sequence of texture sounds.
%                 The statistics of the sounds are modified using the
%                 programs of McDermott et al. The Paramters are coded as
%                 integers which represent a particular statistic.
%
%	Data        : Data structure obtained using "READTANK"
%                 Data is formated as follows:
%
%                   Data.Snips              - Snipet Waveforms
%                   Data.Fs                 - Sampling Rate
%                   Data.SnipsTimeStamp     - Snipet Time Stamps
%                   Data.SortCode           - Sort Code for the Snipets
%                   Data.ChannelNumber      - Channel Number for the Snipets
%                   Data.Trig               - Trigger Event Times
%                   Data.Attenuation        - Event Attenuation Level
%                   Data.Frequency          - Event Frequency 
%                   Data.StimOff            - Stimulus Offset Time
%                   Data.StimOn             - Stimulus Onset Time
%                   Data.EventTimeStanp     - Event Time Stamp
%
%   PARAM       : Modulation rate sequency (From Param.mat File)
%   SOUND       : Structure containing the texture sounds file Headers
%                 (From Param.mat File)
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%   Order       : Channel order for plotting (Optional, 
%                 Default 0 or [] = no mapping. Typically the channel order
%                 is a vecotor containing 16 channels with the map for the
%                 channel ordering. The following special cases can also be
%                 used: 
%
%                 Order = 1 (TDT RX)
%                      [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6]
%
%                 Order = 2 (TDT RZ)
%                      [15 1 13 3 16 2 9 7 12 6 10 8 14 4 11 5] 
%
% RETURNED DATA
%
%	RASDataN(j): RASTER Data Structure Vector (j is the channel number)
%                   RASData(k,l).RASTER              - Raster Structure for each
%                                                 texture sound (k) and parameter condition (l)
%                   RASData(k,l).Param               - Modulation Frequency Axis
%                   RASData(k,l).Sound               - Spline modulation cutoff Axis
%
%   (C) F. Khatami, Monty A. Escabi, Nov2016
%
function [RASDataN]=rastertexturegenerateN(Data,PARAM,SOUND,TD,OnsetT,Order) 

%Input Argumets
if nargin<5 | isempty(OnsetT)
    OsetT=0;
end
if nargin<6 | isempty(Order)
    N=max(Data.ChannelNumber);
    Order=1:N;                      %No channel reordering
end
if Order==1
    Order=[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6];
elseif Order==2
    Order=[15 1 13 3 16 2 9 7 12 6 10 8 14 4 11 5];
end
    
%Generate Data structure
N=length(Order);
for k=1:N
    
    [RASDataN(k).RASData] = rastertexturegenerate(Data,PARAM,SOUND,TD,OnsetT,[],Order(k));
    
end
