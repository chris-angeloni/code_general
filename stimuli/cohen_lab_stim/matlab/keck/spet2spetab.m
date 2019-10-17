%
%function [spetA,spetB,TrigA,TrigB,T]=spet2spetab(spet,TrigA,TrigB,Fs)
%
%   FILE NAME   : SPET 2 SPET AB
%   DESCRIPTION : Converts a SPET Array obtained for a double
%                 stimulus presentation of DR or RN and converts it
%                 to separate spet arrays for stimulus presentations A and B
%
%   spet        : Spike Event Time Array
%   TrigA       : Trigger Array for the first stimulus presenttion
%   TrigB       : Trigger Array for the second stimulus presenttion
%
%RETURNED VARIABLE
%   spetA       : Spike Event Time Array for stimulus A
%   spetB       : Spike Event Time Array for stimulus B
%   TrigA       : Corrected TrigA so that the starting trigger is at time
%                 zero
%   TrigB       : Corrected TrigA so that the starting trigger is at time
%                 zero
%   T           : Experiment duration for one trial
%
% (C) Monty A. Escabi, Edit July 2009
%
function [spetA,spetB,TrigA,TrigB,T]=spet2spetab(spet,TrigA,TrigB,Fs)

%Finding SPETA and SPETB
iA=find(spet>TrigA(1) & spet<max(TrigA));
iB=find(spet>TrigB(1) & spet<max(TrigB));
spetA=spet(iA)-TrigA(1);
spetB=spet(iB)-TrigB(1);

%Corrected Triggers
TrigA=TrigA-TrigA(1);
TrigB=TrigB-TrigB(1);

%Stimulus Duration
T=(max(TrigA)-min(TrigA)+max(TrigB)-min(TrigB))/2/Fs;