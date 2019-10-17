%
% function [RSTRF] =
% strfcorrcorrected(STRF1A,STRF1B,STRF1s,STRF2A,STRF2B,STRF2s,taxis,faxis,PP,NoiseFlag,MaxDelay,MaxFreqShift)
%
%   FILE NAME 	: STRF CORR
%   DESCRIPTION : Computes the correlation between two STRFs to determine
%                 the level of similarity. Returns the optimal delay,
%                 frequency shift, and the 2-D STRF correlation function. Maximum 
%                 correlation value is normalized as a similarity index 
%                 (-1<SI<1, Escabi & Schreiner 2003).
%
%                 Unlike STRFCORR this program compensates for reductions
%                 in the SI due to internal noise.
%
%   STRF1A,B,s  : First STRF- STRF1A and STRF1B assume the following
%                 possibilites:
%
%                 If NoiseFlag==1, then STRF1A and STRF1B are obtained from
%                 independent trials. STRF1s is the significant STRF.
%
%                 If NoiseFlag==2. Assumes one trial so that STRF1B is not
%                 needed. Simply plug in STRF1 twice (for STRF1A and
%                 STRF1B). STRF1s is the significant STRF.
%
%   STRF2A,B,s  : Second STRF - STRF1A and STRF1B assume the following
%                 possibilites:
%
%                 If NoiseFlag==1, then STRF2A and STRF2B are obtained from
%                 independent trials. STRF2s is the significant STRF.
%
%                 If NoiseFlag==2. Assumes one trial so that STRF2B is not
%                 needed. Simply plug in STRF2 twice (for STRF2A and
%                 STRF2B). STRF2s is the significant STRF.
%
%   taxis       : Time Axis
%   faxis       : Frequency Axis
%   PP          : Stimulus variance
%   NoiseFlag   : Method for estimating noise variance
%                 1: Subtracts STRF from two independent trials (Default)
%                 2: Uses non significant samples to estimate noise
%                    variance
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
%                             frequency shift). SI with maximum absolute
%                             magnitude!
%                 SI00      - Spectrotemporal SI at zero delay and zero
%                             frequency shift
%                 SIt       - Temporal SI (maximum SI at zero spectral
%                             shift & variable temporal delay)
%                 SIf       - Spectral SI (maximum SI at zero delay and
%                             variable spectral shift)
%
%   (C) Monty A. Escabi, September 2006 (Nov 2007)
%
function [RSTRF] = strfcorrcorrected(STRF1A,STRF1B,STRF1s,STRF2A,STRF2B,STRF2s,taxis,faxis,PP,NoiseFlag,MaxDelay,MaxFreqShift)

%Input Arguments
if nargin<10
   NoiseFlag=1; 
end

%Estimating Noise Variance
if NoiseFlag==2
    index1=find(STRF1s==0);
    index2=find(STRF2s==0);
    VarN1=var(STRF1A(index1));
    VarN2=var(STRF2A(index2));
else    %Default Case, NoiseFlag==1
    E1=reshape(STRF1A-STRF1B,1,size(STRF1A,1)*size(STRF1A,2));
    E2=reshape(STRF2A-STRF2B,1,size(STRF2A,1)*size(STRF2A,2));
    VarN1=var(E1)/2;            %Divide Variance by two because subtraction doubles the variance
    VarN2=var(E2)/2;            %Divide Variance by two because subtraction doubles the variance
end

%Estimating Signal + Noise Variances
index=find(STRF1s~=0 | STRF2s~=0);
N=length(index);
X1=STRF1s(index);   %Assume mean value is zero according to Escabi & Schreiner 2002, take mean X^2
X2=STRF2s(index);   %Assume mean value is zero according to Escabi & Schreiner 2002, take mean X^2
Var1=mean(X1.^2);   %Signal + Noise Variance
Var2=mean(X2.^2);   %Signal + Noise Variance

%Computing correlation using Fourier method
%sigma1=sqrt(sum(sum(STRF1.*STRF1)))
%sigma2=sqrt(sum(sum(STRF2.*STRF2)))
%R=fftshift(real(ifft2(fft2(STRF1).*conj(fft2(STRF2)))))/(sigma1*sigma2);
R=fftshift(real(ifft2(fft2(STRF1s).*conj(fft2(STRF2s)))))/(N-1)/sqrt((Var1-VarN1)*(Var2-VarN2));
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
if nargin>=11 & ~isempty(MaxDelay)
    NT=ceil(MaxDelay/1000/dt);
    RSTRF.R=RSTRF.R(:,N2-NT:N2+NT);
    RSTRF.tau=tau(N2-NT:N2+NT);
end
if nargin>=12 & ~isempty(MaxFreqShift)
    NX=ceil(MaxFreqShift/dx);
    RSTRF.R=RSTRF.R(N1-NX:N1+NX,:);
    RSTRF.dX=dX(N1-NX:N1+NX);
end