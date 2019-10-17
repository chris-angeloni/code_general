%
%function [R]=xcorrspikesparse(spet1,spet2,Fs,Fsd,MaxTau,T,Zero,Mean,Disp)
%
%   FILE NAME   : XCORR SPIKE SPARSE
%   DESCRIPTION : X-Correlation Function of Spike Train. Uses a fast
%                 algorithm that only considers coincident spikes. This
%                 routine is useful for sparse spike trains (<1 spike/bin) 
%                 that are sampled at high sampling rates (e.g., Fsd>1000 
%                 Hz). The algorigthm is similar to XCORRSPIKEFAST but uses
%                 less memory and is about 40% faster.
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
%                 Default : 'y'
%
%RETURNED VALUES
%
%   R           : Crosscorrelation function
%
% (C) Monty A. Escabi, Aug 2009
%
function [R]=xcorrspikesparse(spet1,spet2,Fs,Fsd,MaxTau,T,Zero,Mean,Disp)

%Preliminaries
if nargin<7
	Zero='y';
end
if nargin<8
	Mean='n';
end
if nargin<9
	Disp='y';
end

%Analysis parameters
Ts=1/Fsd;
M=round(Fsd*T);
MaxLag=ceil(MaxTau/1000*Fsd);

%Resampling spike event times and selecting so that <T seconds
%index=floor(spet/Fs*Fsd)+1;
index1=find(spet1<=Fs*T);
index2=find(spet2<=Fs*T);
i1=floor(spet1(index1)/Fs*Fsd)+1;   %Floor is used so that the sampled spike train
i2=floor(spet2(index2)/Fs*Fsd)+1;   %is identical to that produced by SPET2IMPULSE

%Computing Correlation using fast algorithm that only considers coincident
%spikes. I attempted to use find(X1~=0 & X2~=0) inside the loop. Howerver,
%this search is way too slow and needs to be performed 2*MaxLag+1 times.
for k=-MaxLag:MaxLag

    %Finding Bins with coincident spikes
    i12=sort([i1 i2+k]);    %Index containing spike time entries for shifted and unshifted spike trains
    m=find(diff(i12)==0);   %This finds indeces for coincident spikes. This search is different and 
                            %faster than XCORRSPIKEFAST
  
    %Computing correlation
    R(k+MaxLag+1)=length(m)*Fsd^2;  %Computing only for coincident spikes
        
end

%Removing Center Bin
if length(spet1)==length(spet2) & strcmp(Zero,'y')
	N=length(i1);
	VarPois=N/Ts^2				%Variance for Poisson 
	R(MaxLag+1)=R(MaxLag+1)-VarPois;
end

%Normalizing Correlation
D=-MaxLag:MaxLag;
R=R./(M-abs(D));     %Unbiased estimator - see documentation for XCORR normalization

%Removing Mean if desired
if strcmp(Mean,'y')
    M1=length(spet1)/T;
    M2=length(spet2)/T;
    R=R-M1*M2;
end

%Plotting X-Correlation
if strcmp(Disp,'y')
	plot((-MaxLag:MaxLag)/Fsd,R)
	ylabel('R( T )');
	xlabel('Time Lag - T ( sec )')
	pause(0)
end