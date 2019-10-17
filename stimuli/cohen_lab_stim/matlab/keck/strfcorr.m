%
%function [RSTRF] = strfcorr(STRF1,STRF2,taxis,faxis,PP,MaxDelay,MaxFreqShift)
%
%   FILE NAME 	: STRF CORR
%   DESCRIPTION : Computes the correlation between two STRFs to determine
%                 the level of similarity. Returns the optimal delay,
%                 frequency shift, and the 2-D STRF correlation function. Maximum 
%                 correlation value is normalized as a similarity index 
%                 (-1<SI<1, Escabi & Schreiner 2003).
%
%   STRF1       : First STRF 
%   STRF2       : Second STRF
%   taxis       : Time Axis
%   faxis       : Frequency Axis
%   PP          : Stimulus variance
%   MaxDelay    : Maximum Allowable Delay (msec, Optional)
%   MaxFreqShift: Maximum Allowable Freq Shift (Octaves, Optional)
%
% RETURNED DATA
%
%   RSTRF       : Data structure containing the following elements:
%                 R         - STRF 2-D crosscorrelation function.
%                 tau       - Delay axis (msec)
%                 dX        - Octave Frequency axis (Octaves)
%                 delay     - Optimal temporal delay that maximizes 
%                             correlation fxn (msec).
%                 freqshift - Optimal frequency shift that maximizes
%                             correlation fxn (Oct). 
%                 SI        - Spectrotemporal SI (at optimal delay &
%                             frequency shift). SI with maximum absolute magnitude!
%                 SI00      - Spectrotemporal SI at zero delay and zero
%                             frequency shift
%                 SIt       - Temporal SI (maximum SI at zero spectral
%                             shift & variable temporal delay)
%                 SIf       - Spectral SI (maximum SI at zero delay and
%                             variable spectral shift)
%
%   (C) Monty A. Escabi, July 2006
%
function [RSTRF] = strfcorr(STRF1,STRF2,taxis,faxis,PP,MaxDelay,MaxFreqShift)

%Computing correlation using Fourier method
index=find(STRF1~=0 | STRF2~=0);
N=length(index);
X1=STRF1(index);
X2=STRF2(index);
std1=sqrt(mean(X1.^2));
std2=sqrt(mean(X2.^2));
%sigma1=sqrt(sum(sum(STRF1.*STRF1)))
%sigma2=sqrt(sum(sum(STRF2.*STRF2)))
%R=fftshift(real(ifft2(fft2(STRF1).*conj(fft2(STRF2)))))/(sigma1*sigma2);
R=fftshift(real(ifft2(fft2(STRF1).*conj(fft2(STRF2)))))/N/(std1*std2);
N1=floor(size(R,1)/2);           %Check!!!!!!!!!!!!
N2=size(R,2)/2;

%Estimating Optimal TimeDelay and SpectralShift
[i,j]=find(max(max(R))==R);
dt=mean(diff(taxis));
dx=mean(diff(log2(faxis)));
delay=(j-N2-1)*dt*1000;
freqshift=(i-N1-1)*dx;
tau=((1:size(R,2))-N2-1)*dt*1000;
dX=((1:size(R,1))-N1-1)*dx;

%Creating Data Structure
RSTRF.R=R;
RSTRF.tau=tau;
RSTRF.dX=dX;
RSTRF.delay=delay;
RSTRF.freqshift=freqshift;
[l,m]=find(max(max(abs(RSTRF.R)))==abs(RSTRF.R));
RSTRF.SI=RSTRF.R(l,m);
RSTRF.SI00=RSTRF.R(N1+1,N2+1);
l=find(max(abs(RSTRF.R(N1+1,:)))==abs(RSTRF.R(N1+1,:)));
RSTRF.SIt=RSTRF.R(N1+1,l);
m=find(max(abs(RSTRF.R(:,N2+1)))==abs(RSTRF.R(:,N2+1)));
RSTRF.SIf=RSTRF.R(m,N2+1);

%Truncating Correlation Size
if nargin>=6 & ~isempty(MaxDelay)
    NT=ceil(MaxDelay/1000/dt);
    RSTRF.R=RSTRF.R(:,N2-NT:N2+NT);
    RSTRF.tau=tau(N2-NT:N2+NT);
end
if nargin>=7 & ~isempty(MaxFreqShift)
    NX=ceil(MaxFreqShift/dx);
    RSTRF.R=RSTRF.R(N1-NX:N1+NX,:);
    RSTRF.dX=dX(N1-NX:N1+NX);
end