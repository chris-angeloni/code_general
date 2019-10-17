%
%function [TrigTimes1,TrigTimes2]=trigfixstrf2(TrigTimes,Ndouble,NTrig)
%
%       FILE NAME       : TRIG FIX STRF 2
%       DESCRIPTION     : Checks a trigger sequence for Multiple Triggers
%			  and for missing triggers of a Moving Ripple
%			  or Ripple Noise Trigger File
%			  Where the sound is presented TWICE in sequence
%			  (i.e. used for shift predictor)
%
%	TrigTimes	: Trigger Time Vector (in sample number)
%			  Contains trigers for sequential presentations 
%			  of the MR or RN sounds - "Shift Predictor"
%	Ndouble		: Number of blocks between double triggers
%	NTrig		: Number of Triggers in original sound file for
%			  a single presentation
%
function [TrigTimes1,TrigTimes2]=trigfixstrf2(TrigTimes,Ndouble,NTrig)

%Finding Triggers for First Presentation
[TrigTimes1]=trigfixstrf(TrigTimes,Ndouble,NTrig);

%Finding Triggers for Second Presentation
index=find(TrigTimes>TrigTimes1(NTrig));
[TrigTimes2]=trigfixstrf(TrigTimes(index),Ndouble,NTrig);

