%
%function [Rxy,RxyN,RxyN2,tauaxis,taxis]=xcorrst(X,Y,MaxLag,Fs,W,OF)
%
%       FILE NAME       : XCORR ST
%       DESCRIPTION     : Short term xcorrelation function.
%
%       X,Y             : Signals to be correlated
%       MaxLag          : Maximum number of delay samples. If MaxLag is >
%                         N, where N is half the window width then MaxLag
%                         is limited to N
%       Fs              : Sampling Rate
%       W               : Window used for short-term analysis (should be a 
%                         row vector with dimensions 1x2*N+1)
%       OF              : Oversampling factor - intiger value that
%                         determines how much to oversample the time axis
%                         for the specified window used (Default==inf). If
%                         using default the time axis is computed at a
%                         smapling rate of Fs.
%
%RETURNED VALUES
%       Rxy             : Short Term Correlation
%       RxyN            : Normalized short term correlation (as a Pearson
%                         correlation coefficeint)
%       RxyN2           : Normalized short term correlation (similar to
%                         RxyN but the means of X and Y are not removed)
%       tauaxis         : Delay Axis (sec)
%       taxis           : Time Axis (sec)
%
%   (C) M. Escabi, May 2016 (Edit June 20, 2016)
%
function [Rxy,RxyN,RxyN2,tauaxis,taxis]=xcorrst(X,Y,MaxLag,Fs,W,OF)

%Input arguments
if nargin<6
    OF=inf;
end

%Window Length
N=(length(W)-1)/2;

%Take square root of window - W^2 is the window used across X and Y and
%normalizing for unit area
W=sqrt(W);
    
%Limiting MaxLag if it is > than N
if MaxLag>N
    MaxLag=N;
end

%Find window bandwidth and determine step size to achieve desired
%oversampling factor
if OF==inf
    Fst=Fs;
    Nstep=1;
else
    NFFT=2^(nextpow2(2*N+1)+4);
    [dT,dF,dT3dB,dF3dB]=finddtdfw(W,Fs,NFFT);
    Fst=OF*4*dF3dB;         %Note that dF3dB/2 is the actual cutoff freuency. Choose 4*dF3dB (four times as much) to be conservative.
    Nstep=floor(Fs/Fst);    %Floor to make sure step size is integer value
    Fst=Fs/Nstep;           %This is the actual sampling rate after the floor() operation
end

%Computing short-term correlation
count=1;
for k=2*N+1:Nstep:length(X)-2*N       %Estimating short-term correlation for differnt time points - remove N points at edges to avoid edge effects

    %Selecting and Windowing data
    Xt=[zeros(1,MaxLag) X(k-N:k+N).*W.^2 zeros(1,MaxLag)];
    Yt=Y(k-N-MaxLag:k+N+MaxLag);

    %Computing Variances & Means
    MX=mean(X(k-N:k+N).*W);
    MY=mean(Y(k-N:k+N).*W);
    VarX=var(X(k-N:k+N).*W);
    VarY=var(Y(k-N:k+N).*W);
    
    %Computing Short Term Correaltion
    Rxy(:,count)=xcorr(Xt,Yt,MaxLag)'/2/N;                  %Grab only the correlation for N point lag - this is where there is no edge artifact
    RxyN(:,count)=(Rxy(:,count)-MX*MY)/sqrt(VarX*VarY);     %Normalized correaltion
    RxyN2(:,count)=Rxy(:,count)/sqrt(VarX*VarY);            %Normalized correaltion - means not removed

    %Itteration Counter
    count=count+1;    
end

%Time and delay axis
taxis=(1:size(Rxy,2))/Fst;
tauaxis=(-N:N)/Fs;