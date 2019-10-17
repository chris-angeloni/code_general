%
% function [R] = onlineftchist(TankFileName,BlockNumber,T1,T2,Fsd,ChannelNumber,UnitNumber,ServerName)
%
%	FILE NAME 	: ONLINE FTC HIST
%	DESCRIPTION : Computes a histogram for FTC data using correlation 
%                 analysis between spikes and the tone onset time
%
%	TankFileName	: Data Tank File Name
%	BlockNumber     : Block Number
%   T1              : Histogram window start time
%   T2              : Histogram window end time
%   Fsd             : Desired sampling rate for histogram (Hz)
%   ChannelNumber   : Channel Number (Default == 1)
%   UnitNumber      : Unit Number (0, 1, 2 ...; Default==0)
%   ServerName      : Tank Server Name (Default=='Puente')
%
% (C) Monty A. Escabi, Aug 2005
%
%   R               : Histogrm / Correlogram
%
function [R] = onlineftchistv66(TankFileName,BlockNumber,T1,T2,Fsd,ChannelNumber,UnitNumber,ServerName)

%Default Tank Serve 
if nargin<6
    ChannelNumber=1;
end
if nargin<7
    UnitNumber=0;
end
if nargin<8
    ServerName='Puente';
end

%Reading Tank Data
[Data] = readtankv66(TankFileName,BlockNumber,ChannelNumber,ServerName);

%Generating Histrogram
Trig=round(Data.StimOn*Data.Fs);
index=find(Data.SortCode==UnitNumber);
spet=round(Data.SnipTimeStamp(index)*Data.Fs);
[R]=xcorrspike(Trig,spet,Data.Fs,Fsd,T2/1000);
R=R/length(Trig)*Fsd;

%Plotting
N=(length(R)-1)/2;
taxis=(-N:N)/Fsd;
plot(taxis*1000,R)
axis([T1 T2 0 max(R)*1.2])
xlabel('Time Following Onset (msec)')

