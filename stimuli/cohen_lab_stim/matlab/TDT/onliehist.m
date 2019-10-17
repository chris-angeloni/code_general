%
% function [] = onlinehist(TankFileName,BlockNumber,T1,T2,ServerName)
%
%	FILE NAME 	: ONLINE HIST
%	DESCRIPTION : Computes a histogram using correlation analysis between
%	              spikes and the triggers
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   T1              : FTC window start time
%   T2              : FTC window end time
%   ServerName      : Tank Server Name (Default=='Puente')
%
function [] = onlinehist(TankFileName,BlockNumber,T1,T2,ServerName)

%Default Tank Serve 
if nargin<5
    ServerName='Puente';
end

%Generating Histrogram
Trig=round(Data.Trig*Data.Fs);
spet=round(Data.SnipTimeStamp*Data.Fs);
    
[R]=xcorrspike(spet,Trig,Data.Fs,1000,T2/1000);
axis([T1 T2/1000 0 max(R)*1.2])
    
    
