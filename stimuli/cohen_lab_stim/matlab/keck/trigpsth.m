%
%function [TrigTimes]=trigpsth(TrigTimes,Fs,Tresh)
%
%       FILE NAME       : TRIG PSTH
%       DESCRIPTION     : Fixes the trigger times for a PSTH sequence
%
%	TrigTimes	: Trigger Time Vector (in sample number)
%	Fs		: Sampling Rate for Trigger
%	Tresh		: Treshhold -> [0 .5] -> percentage of the Mean
%			  of diff(TrigTimes)
%
function [TrigTimes]=trigpsth(TrigTimes,Fs,Tresh)

%Finding difference 
dTrig=diff(TrigTimes);
MeandTrig=mean(dTrig);

%Thresholding for New Trigger sequneces
index=find(dTrig<MeandTrig*Tresh);

%Thresholding for Old Trigger sequneces
%index=find(dTrig/Fs>0.74);

%Assigning Trigger Times
%TrigTimes=round(TrigTimes(index+1)-.045*Fs);
TrigTimes=round(TrigTimes(index));
