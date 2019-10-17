% function
% [taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=strfgenerate(Data)
%   DESCRIPTION : Generates STRF
% Yi Zheng, Nov 2006

function [taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=strfgenerate(Data)

spet=round(Data.SnipTimeStamp*Data.Fs);
NTrig=900;
Fs=Data.Fs;
TrigTimes=round(Data.Trig*Data.Fs);
[TrigA TrigB]=trigfixstrf2(TrigTimes,400,NTrig);
%[Trig]=trigfixstrf(TrigTimes,400,NTrig);

[taxis,faxis,STRF1A,STRF2A,PP,Wo1A,Wo2A,No1A,No2A,SPLN]=rtwstrfdb('dynamicripple500ic.spr',0,.05,spet,TrigA,Fs,80,30,'dB','MR',100,'float')
[taxis,faxis,STRF1B,STRF2B,PP,Wo1B,Wo2B,No1B,No2B,SPLN]=rtwstrfdb('dynamicripple500ic.spr',0,.05,spet,TrigB,Fs,80,30,'dB','MR',100,'float')

STRF1 = (STRF1A+STRF1B)/2;
STRF2 = (STRF2A+STRF2B)/2;
No1 = No1A+No1B;
Wo1 = (Wo1A+Wo1B)/2;
No2 = No2A+No2B;
Wo2 = (Wo2A+Wo2B)/2;

figure
pcolor(taxis,log2(faxis/500),Wo2/PP*STRF2/No2*sqrt(PP))
shading flat,colormap jet,colorbar
title(['No = ' int2str(No2) ' ( Spikes ) , Wo = ' num2str(Wo2,5) ' ( Spikes/Sec )'])
			
strf = Wo2/PP*STRF2/No2*sqrt(PP);
indexpeak = find(strf==max(max(strf)));
indextrf = indexpeak-floor(indexpeak/size(strf,1))*size(strf,1);
figure
plot(taxis,strf(indextrf,:))
title('TRF');