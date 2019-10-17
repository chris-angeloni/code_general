%
%function [R]=xcorrspikefast(spet1,spet2,Fs,Fsd,MaxTau,T,Zero,Mean,Disp)
%
%   FILE NAME   : XCORR SPIKE FAST
%   DESCRIPTION : X-Correlation Function of Spike Train. Uses a fast
%                 algorithm that only considers coincident spikes. 
%
%   spet1,spet2	: Input Spike Event Times
%   Fs          : Samping Rate of SPET
%   Fsd         : Sampling Rate for R(T)
%   MaxTau      : X-Correlation Temporal Lag (msec)
%   T           : Experiment Duration (sec)
%   Zero        : Correct the Zeroth Bin when computing
%                 autocorrelation: spet1==spet2
%                 Default: 'y'
%   Mean        : Remove Mean Value
%                 Default: 'n'
%   Disp        : Display : 'y' or 'n'
%                 Default : 'n'
%
%RETURNED VALUES
%
%   R           : Crosscorrelation function
%
% (C) Monty A. Escabi, Aug 2009
%
function [R]=xcorrspikefast(spet1,spet2,Fs,Fsd,MaxTau,T,Zero,Mean,Disp)

%Preliminaries
if nargin<7
	Zero='y';
end
if nargin<8
	Mean='n';
end
if nargin<9
	Disp='n';
end

%Converting SPET to a sampled diract impulse array
Ts=1/Fsd;
X1=spet2impulse(spet1,Fs,Fsd,T);
X2=spet2impulse(spet2,Fs,Fsd,T);
M=length(X1);

%Computing X-Correlation
MaxLag=ceil(MaxTau/1000*Fsd);

%Finding Nonzero Entries for X1 and X2
i1=find(X1~=0);
i2=find(X2~=0);

%Computing Correlation using fast algorithm that only considers coincident
%spikes. I attempted to use find(X1~=0 & X2~=0) inside the loop. Howerver,
%this search is way too slow and needs to be performed 2*MaxLag+1 times.
for k=-MaxLag:MaxLag

    %Finding Bins with coincident spikes
    i12=sort([i1 i2+k]);    %Index containing spike time entries for shifted and unshifted spike trains
    m=find(diff(i12)==0);   %This finds indeces for coincident spikes

    %Index for the original spike trains
    index1=i12(m);
    index2=i12(m)-k;
    
    %Computing correlation
    R(k+MaxLag+1)=sum(X1(index1).*X2(index2));  %Computing only for coincident spikes
        
end

%Removing Center Bin
if length(spet1)==length(spet2) & strcmp(Zero,'y')
	N=sum(X1*Ts);
	VarPois=N/Ts^2;				%Variance for Poisson 
	R(MaxLag+1)=R(MaxLag+1)-VarPois;
end

%Normalizing Correlation
D=-MaxLag:MaxLag;
R=R./(M-abs(D));     %Unbiased estimator - see documentation for XCORR normalization

%Removing Mean if desired
if strcmp(Mean,'y')
    M1=mean(X1);
    M2=mean(X2);
    R=R-M1*M2;
end

%Plotting X-Correlation
if strcmp(Disp,'y')
	plot((-MaxLag:MaxLag)/Fsd,R)
	ylabel('R( T )');
	xlabel('Time Lag - T ( sec )')
	pause(0)
end