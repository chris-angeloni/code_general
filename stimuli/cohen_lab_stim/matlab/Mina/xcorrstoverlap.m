%
%function [Rxy,tauaxis,taxis]=xcorrstoverlap(X,Y,MaxLag,Fs,W,Overlap)
%
%       FILE NAME       : XCORR ST OVERLAP
%       DESCRIPTION     : Short term xcorrelation funciton. Uses a fast
%                         convolution algorithm to compute short-term correlation.
%                         Produces identical results as XCORRST.m but is
%                         about three times faster.
%
%       X,Y             : Signals to be correlated
%       MaxLag          : Maximum number of delay samples 
%       Fs              : Sampling Rate
%       W               : Window used for short-term analysis (1x2*N+1
%                         vector)
%       Overlap         : Percent overlap between consecutive windows. 
%                         Overlap = 0 to 1. 0 indicates no overlap. 0.9 
%                         would indicate 90 % overlap.
%
%RETURNED VALUES
%       Rxy             : Short Term Correlation
%       tauaxis         : Delay Axis (sec)
%       taxis           : Time Axis (sec)
%
%   (C) M. Escabi, May 2016
%
function [Rxy,tauaxis,taxis]=xcorrstfastoverlap(X,Y,MaxLag,Fs,W)

%Window Length
N=(length(W)-1)/2;

%Computing short-term correlation
Y=[zeros(1,MaxLag) Y(MaxLag+1:end-MaxLag) zeros(1,MaxLag)];             %Replace signal with zeros at extremities to avoide edge artifacts
for k=-MaxLag:MaxLag
   
    Rtemp=conv(circshift(Y',k)'.*X,W)';
    Rxy(k+MaxLag+1,:)=Rtemp((MaxLag+2*N+1:end-3*N-MaxLag)+k+MaxLag);    %Selecting appropriate segment to remove edge artifacts and lags created by circular shifts above
    
end

%Time and delay axis
taxis=(1:size(Rxy,2))/Fs;
tauaxis=(-N:N)/Fs;