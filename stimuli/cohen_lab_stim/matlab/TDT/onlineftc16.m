%
% function [FTC] = onlineftc16(TankFileName,BlockNumber,T1,T2,ServerName,Order)
%
%	FILE NAME 	: ONLINE FTC 16
%	DESCRIPTION : Computes Tunning Curve Online and Plots Results
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number vector
%   T1              : FTC window start time
%   T2              : FTC window end time
%   ServerName      : Tank Server Name (Default=='Puente')
%   Order           : Channel order for plotting
%
%RETURNED DATA
%   FTC             : Frequency Tunning Curve Data Structure for 
%                     all units
%
function [FTC16] = onlineftc16(TankFileName,BlockNumber,T1,T2,ServerName,Order)

%Default Tank Serve
if nargin<5
    ServerName='Puente';
end
if nargin<6
    Order=[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6];    
end

%Averaging Across Blocks
for chan=1:16
    for k=1:length(BlockNumber)
    
    %Reading Tank Data
    [Data] = readtankv66(TankFileName,BlockNumber(k),chan,ServerName);

    %Generating FTC
    [FTCtemp] = ftcgenerate(Data,T1,T2);
            
            if ~exist('FTC','var')
                %Averaging Across Units
                for l=1:length(FTCtemp)
                    FTC(l).data=FTCtemp(l).data;
                    FTC(l).Freq=FTCtemp(l).Freq;
                    FTC(l).Level=FTCtemp(l).Level;
                    FTC(l).NFTC=FTCtemp(l).NFTC;
                    FTC(l).T1=FTCtemp(l).T1;
                    FTC(l).T2=FTCtemp(l).T2;
                end
            else
                for l=1:length(FTCtemp)
                    %Averaging Across Units
                    FTC(l).data=FTC(l).data+FTCtemp(l).data;
                    FTC(l).Freq=FTCtemp(l).Freq;
                    FTC(l).Level=FTCtemp(l).Level;
                    FTC(l).NFTC=FTCtemp(l).NFTC;
                    FTC(l).T1=FTCtemp(l).T1;
                    FTC(l).T2=FTCtemp(l).T2;
                end
            end
    end
    FTC16(chan)=FTC(1);
    clear FTC
end

%Plotting FTC Data
subplotorder=[1:2:16 2:2:16];
for chan=1:16
    ftcsubplot(FTC16(Order(chan)),[8 2 subplotorder(chan)]);
end