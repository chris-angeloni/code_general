%
% function [FTC] =
% plotftccentroid1(TankFileName,BlockNumber,T1,T2,ChannelNumber,ServerName)
%
%	FILE NAME 	: ONLINE FTC
%	DESCRIPTION : Computes Tunning Curve Online and Plots Results
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   UnitNumber      : Unit Number
%   T1              : FTC window start time
%   T2              : FTC window end time
%   ChannelNumber   : Channel Number (Default == 1)
%   ServerName      : Tank Server Name (Default=='Puente')
%
%RETURNED DATA
%   FTC             : Frequency Tunning Curve Data Structure for 
%                     all units
%   Date Last Major Edit:   March 31, 2005
function [FTC] = plotftccentroid1(TankFileName,BlockNumber,T1,T2,ChannelNumber,ServerName)

more off;
%Default Tank Serve

if nargin<4
    T1=10;
    T2=40;
end
if nargin<5
    ChannelNumber=1;
end
if nargin<6
    ServerName='Puente';
end

for k=1:length(BlockNumber)
[FTC]=onlineftc(TankFileName,BlockNumber(k),T1,T2,ChannelNumber,ServerName)

for UnitNumber=[1:length(FTC)]

FTCnew=FTC(UnitNumber)
[FTCt]=ftcthreshold(FTCnew,0.05);
%close;
figure;
ftcplot(FTCt);
[FTCStats]=ftccentroid(FTCt);
FTCLevelnew=[FTC(1).Level'];
hold on;
plot(FTCStats.Mean(6:9)/1000,FTCLevelnew(6:9),'ko');
plot(FTCStats.Mean(6:9)/1000,FTCLevelnew(6:9),'m.','markersize',14);
%double check the addition of 6
FTCcentroids=[FTCStats.Mean(6:9)/1000,round(FTCLevelnew(6:9)+6)]
CF=[sum(FTCcentroids(:,1))/4];
filename=[TankFileName 'block_' num2str(BlockNumber(k)) '_u' num2str(UnitNumber)]
f=['save ' TankFileName 'block_' num2str(BlockNumber(k)) '_u' num2str(UnitNumber)]
eval(f)

f=['print -djpeg ' TankFileName 'block_' num2str(BlockNumber(k)) '_u' num2str(UnitNumber)];
eval(f);

end
end
