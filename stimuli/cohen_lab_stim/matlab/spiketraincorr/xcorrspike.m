%
%function [R]=xcorrspike(spet1,spet2,Fs,Fsd,MaxTau,T,Zero,Mean,Disp)
%
%   FILE NAME   : XCORR SPIKE
%   DESCRIPTION : X-Correlation Function of Spike Train
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
% (C) Monty A. Escabi, Edit Aug 2009
%
function [R]=xcorrspike(spet1,spet2,Fs,Fsd,MaxTau,T,Zero,Mean,Disp)

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

%Converting SPET to a sampled diract impulse array
Ts=1/Fsd;
X1=spet2impulse(spet1,Fs,Fsd,T);
X2=spet2impulse(spet2,Fs,Fsd,T);

%Matching Length if X1~=X2
if length(spet1)~=length(spet2)
	if length(X1)<length(X2)
		X2=X2(1:length(X1));
	else
		X1=X1(1:length(X2));
	end
end
M=max(length(X1),length(X2));

%Computing X-Correlation
MaxLag=ceil(MaxTau/1000*Fsd);
R=xcorr(X1,X2,MaxLag);

%Removing Center Bin
if length(spet1)==length(spet2) & strcmp(Zero,'y')
	N=sum(X1*Ts);
	VarPois=N/Ts^2				%Variance for Poisson 
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
