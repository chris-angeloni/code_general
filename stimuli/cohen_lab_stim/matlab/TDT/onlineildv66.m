% %
% % function [FTC] = onlineftc(TankFileName,BlockNumber,T1,T2,ChannelNumber,ServerName)
% %

function [ILDHist] = onlineildv66(TankFileName,BlockNumber,T1,T2,ChannelNumber,ServerName)

%Default Tank Serve
if nargin<5
    ChannelNumber=1;
end
if nargin<6
    ServerName='Puente';
end
load ParamList.mat
[Data] = readtankv66(TankFileName,BlockNumber,ChannelNumber,ServerName);
[ILDHist] = ildhistgenerate(Data,ParamList,T1,T2,96000);


% 
% %Averaging Across Blocks
% for k=1:length(BlockNumber)
%     
    %Reading Tank Data
    [Data] = readtankv66(TankFileName,BlockNumber(k),ChannelNumber,ServerName);
% 
%     %Generating FTC
%     [FTCtemp] = ftcgenerate(Data,T1,T2);
%             
%             if ~exist('FTC','var')
%                 %Averaging Across Units
%                 for l=1:length(FTCtemp)
%                     FTC(l).data=FTCtemp(l).data;
%                     FTC(l).Freq=FTCtemp(l).Freq;
%                     FTC(l).Level=FTCtemp(l).Level;
%                     FTC(l).NFTC=FTCtemp(1).NFTC;
%                     FTC(l).T1=FTCtemp(1).T1;
%                     FTC(l).T2=FTCtemp(1).T2;
%                 end
%             else
%                 for l=1:length(FTCtemp)
%                     %Averaging Across Units
%                     FTC(l).data=FTC(l).data+FTCtemp(l).data;
%                     FTC(l).Freq=FTCtemp(l).Freq;
%                     FTC(l).Level=FTCtemp(l).Level;
%                     FTC(l).NFTC=FTCtemp(1).NFTC;
%                     FTC(l).T1=FTCtemp(1).T1;
%                     FTC(l).T2=FTCtemp(1).T2;
%                 end
%             end
%             
% end

%Plotting FTC Data
figure;
ftcplot(FTC);