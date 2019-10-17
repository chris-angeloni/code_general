%
%function [R,Noise,Thresh] = onlineftchistboot(TankFileName,BlockNumber,T1,T2,Fsd,ChannelNumber,UnitNumber,NB,p,TS1,TS2,ServerName)
%
%	FILE NAME 	: ONLINE FTC HIST BOOT
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
%   NB              : Number of bootstraps
%   p               : Significance value
%   TS1             : Window start time for significance (msec)
%   TS2             : Window end time for significance (msec)
%   ServerName      : Tank Server Name (Default=='Puente')
%
% (C) Monty A. Escabi, Aug. 2005
%
%   R               : Bootsrapped Histograms (Correlograms)
%   Noise           : Bootstrap noise levels between TS1 and TS2
%   p               : Significance probability
%
function [R,Noise,Thresh] = onlineftchistboot(TankFileName,BlockNumber,T1,T2,Fsd,ChannelNumber,UnitNumber,NB,p,TS1,TS2,ServerName)

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
[Data] = readtank(TankFileName,BlockNumber,ChannelNumber,ServerName);

%Generating Histrogram
Trig=round(Data.StimOn*Data.Fs);
index=find(Data.SortCode==UnitNumber);
spet=round(Data.SnipTimeStamp(index)*Data.Fs);
for k=1:NB
    spetboot=bootrsp(spet,1);
    spetboot=sort(spetboot);
    [R(k,:)]=xcorrspike(Trig,spetboot,Data.Fs,Fsd,T2/1000);
    R(k,:)=R(k,:)/length(Trig)*Fsd;
end
Lcenter=(length(R)-1)/2+1
L1=Lcenter+round(T1*Fsd)
L2=Lcenter+round(T2/1000*Fsd)
R=R(:,L1:L2)

%Computing Significance Threshold
LS1=ceil(TS1/1000*Fsd);
LS2=floor(TS2/1000*Fsd);
RR=R(:,LS1:LS2);
Noise=sort(reshape(RR,1,NB*length(RR)));
Thresh=Noise(ceil((1-p)*length(Noise)));