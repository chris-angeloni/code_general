%
%function [Rxy,RxyN,RxyN2,tauaxis,taxis]=xcorrstfast(X,Y,MaxLag,Fs,W,OF)
%
%       FILE NAME       : XCORR ST FAST
%       DESCRIPTION     : Short term xcorrelation funciton. Uses a fast
%                         convolution algorithm to compute short-term correlation.
%                         Produces identical results as XCORRST.m but is
%                         about three times faster at full sampling rate.
%                         However, unlike XCORRST the fucntion cannot
%                         downsample the short-term correlation.
%
%       X,Y             : Signals to be correlated
%       MaxLag          : Maximum number of delay samples 
%       Fs              : Sampling Rate
%       W               : Window used for short-term analysis (1x2*N+1
%                         vector)
%       OF              : Oversampling factor - intiger value that
%                         determines how much to oversample the time axis
%                         for the specified window used (Default==inf). If
%                         using default the time axis is computed at a
%                         smapling rate of Fs.
%
%RETURNED VALUES
%       Rxy             : Short Term Correlation
%       RxyN            : Normalized Short Term Correlation (as a Pearson
%                         correlation coefficeint)
%       RxyN2           : Normalized short term correlation (similar to
%                         RxyN but the means of X and Y are not removed)
%       tauaxis         : Delay Axis (sec)
%       taxis           : Time Axis (sec)
%
%   (C) M. Escabi, May 2016 (Edit June 20, 2016)
%
function [Rxy,RxyN,RxyN2,tauaxis,taxis]=xcorrstfast(X,Y,MaxLag,Fs,W,OF)

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
for k=-MaxLag:MaxLag
   
    Rtemp=conv(circshift(Y',k)'.*X,W.^2)'/2/N;
    Rxy(k+MaxLag+1,:)=Rtemp((3*N+1:end-3*N));   %Selecting appropriate segment to remove edge artifacts and lags created by circular shifts above
    
end

%Computing Normalized short-term correlation
count=1;
for k=2*N+1:length(X)-2*N

    %Computing Variances & Means
    MX=mean(X(k-N:k+N).*W);
    MY=mean(Y(k-N:k+N).*W);
    VarX=var(X(k-N:k+N).*W);
    VarY=var(Y(k-N:k+N).*W);
    
    %Computing Normalized Short Term Correaltion
    RxyN(:,count)=(Rxy(:,count)-MX*MY)/sqrt(VarX*VarY);     %Normalized correaltion
    RxyN2(:,count)=Rxy(:,count)/sqrt(VarX*VarY);            %Normalized correaltion - means not removed

    %Itteration Counter
    count=count+1;    
end

%Downsampling Data
Rxy=Rxy(:,1:Nstep:end);
RxyN=RxyN(:,1:Nstep:end);
RxyN2=RxyN2(:,1:Nstep:end);

%Time and delay axis
taxis=(1:size(Rxy,2))/Fst;
tauaxis=(-N:N)/Fs;