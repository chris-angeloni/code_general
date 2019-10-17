%
%function [Trig]=trigpsth2(TrigTimes,Fs,Tresh)
%
%       FILE NAME       : TRIG PSTH
%       DESCRIPTION     : Fixes the trigger times for a PSTH sequence
%                         This routine was written for ICG_315 which has a
%                         different trigger format than for other
%                         experiments
%
%       TrigTimes       : Trigger Time Vector (in sample number)
%       Fs              : Sampling Rate for Trigger
%       Tresh           : Treshhold -> Percent above minimum observed
%                         threshold (of diff(TrigTimes)   
%
function [Trig]=trigpsth2(TrigTimes,Fs,Tresh)

%Finding difference 
dTrig=diff(TrigTimes);
Min=min(dTrig);

%Thresholding for Old Trigger sequneces
index=find(dTrig/Fs>0.74);

%Assigning Trigger Times
%TrigTimes=round(TrigTimes(index+1)-.045*Fs);
Trig=round(TrigTimes(index+1)-0.045*Fs);    %This appears to be correct, with correction for 45 msec trigger offset