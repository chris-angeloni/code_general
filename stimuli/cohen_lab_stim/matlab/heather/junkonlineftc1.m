%
% function [FTC] = onlineftc(TankFileName,BlockNumber,T1,T2,ServerName)
%
%	FILE NAME 	: ONLINE FTC
%	DESCRIPTION : Computes Tunning Curve Online and Plots Results
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   T1              : FTC window start time
%   T2              : FTC window end time
%   ChannelNumber   : Channel Number (Default == 1)
%   ServerName      : Tank Server Name (Default=='Puente')
%
%RETURNED DATA
%   FTC             : Frequency Tunning Curve Data Structure for 
%                     all units
%
function [FTC] = onlineftc1(TankFileName,BlockNumber,T1,T2,ChannelNumber,ServerName)

%Default Tank Serve
if nargin<5
    ChannelNumber=1;
end
if nargin<6
    ServerName='Puente';
end

%Averaging Across Blocks
for k=1:length(BlockNumber)
    
    %Reading Tank Data
    [Data] = readtank(TankFileName,BlockNumber(k),ChannelNumber,ServerName);

    %Generating FTC
    [FTCtemp] = ftcgenerate(Data,T1,T2);
            
            if ~exist('FTC','var')
                %Averaging Across Units
                for l=1:length(FTCtemp)
                    FTC(l).data=FTCtemp(l).data;
                    FTC(l).Freq=FTCtemp(l).Freq;
                    FTC(l).Level=FTCtemp(l).Level;
                end
            else
                for l=1:length(FTCtemp)
                    %Averaging Across Units
                    FTC(l).data=FTC(l).data+FTCtemp(l).data;
                    FTC(l).Freq=FTCtemp(l).Freq;
                    FTC(l).Level=FTCtemp(l).Level;
                end
            end
            
end

%Plotting FTC Data
ftcplot1(FTC);