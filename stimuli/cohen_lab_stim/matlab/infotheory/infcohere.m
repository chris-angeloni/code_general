%
%function [I,IS,Rate,F,Cab,CabS]=infcohere(spetA,spetB,Fs,Fsd,df)
%
%
%       FILE NAME       : INF COHERE
%       DESCRIPTION     : Computes the mutual information from two spike train
%                         trials using coherence measurement between trials
%
%       spetA           : Spike Event Times for trial A 
%       spetB           : Spike Event Times for trial B
%       Fs              : Sampling Rate for 'spet'
%       Fsd             : Sampling rate for generating Coherence
%       df              : Minimum desired frequency resoultion for coherence
%                         measurement
%
%RETURNED VARIABLES
%       I               : Mutual Information
%       IS              : Spike Shuffled Mutual Information - Bias Removal
%       Rate            : Spike Rate
%       F               : Frequency Array
%       Cab             : Spike Train Coherence
%       CabS            : Spike Shuffled Coherence - Bias Removal
%
%   (C) Monty A. Escabi, Aug. 2005
%
function [I,IS,Rate,F,Cab,CabS]=infcohere(spetA,spetB,Fs,Fsd,df)

%Creating a Kaiser Window of appropriate resolution
NFFT=2.^nextpow2(Fsd/df);
W=kaiser(NFFT,4.5513);		  %50 dB Kaiser Window

%Computing Coherence for Original and Shifted Data
[F,Cab]=coherespike(spetA,spetB,Fs,Fsd,df,0.5,'n',W);

%Computing Spike Shuffled Coherence
[F,CabS]=coherespike(shiftspet(spetA,Fs,max(spetA)/4/Fs),spetB,Fs,Fsd,df,0.5,'n',W);

%Mutual Information Calculation for Original and Shifted Data
%Note that 1/2 is not needed because we are integrating from 0 to Fs/2 
dF=mean(diff(F));
I=-sum(log2(1-Cab))*dF;
IS=-sum(log2(1-CabS))*dF;

%Firing Rate 
Rate=(length(spetA)/max(spetA)*Fs+length(spetB)/max(spetB)*Fs)/2;