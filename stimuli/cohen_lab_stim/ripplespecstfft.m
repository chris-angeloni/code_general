%
%function [RipSpec]=ripplespecstfft(data,Fs,df,dFm,f1,fN,UT,UF,win,ATT,method,TW)
%	
%	FILE NAME 	: RIPPLESPEC STFFT
%	DESCRIPTION : Computes the ripple spectrum of a sound for a short-term
%                 fourier transform spectrogram representation.
%
%	data    : Input data. If data is an array it simply corresponds to the
%             sound waveform samples. If data is a data structure, then the
%             structure contains the output of STFFT as a data structure 
%             (data.faxis, data.taxis,data.stft). This is used to speed up
%             the analysis.
%	Fs		: Sampling Rate
%	df		: Frequency Window Resolution (Hz)
%			  Note that by uncertainty principle 
%			  (Chui and Cohen Books)
%			  dt * df > 1/pi (sigma_t * sigma_f > 1/4/pi)
%			  Equality holding for the gaussian case!!!
%   dFm     : Temporal modulaiton frequency resolution (Hz)
%
%Optional Parameters
%	f1		: Lower frequency to compute spectral decomposition
%             (Default=0, lowest frequency in STFT).
%	fN		: Upper freqeuncy to compute spectral decomposition
%             (Default=Fs/2, maximum frequency in STFT).
%	UT		: Temporal upsampling factor.
%			  Increases temporal sampling resolution.
%			  Must be a positive integer. 1 indicates 
%			  no upsampling.
%			  If UT=inf the STFT will not be downssampled
%			  and will have a temporal resolution of 1/Fs
%	UF		: Frequncy upsampling factor.
%			  Increases spectral sampling resolution.
%			  Must be a positive integer. 1 indicates
%			  no upsampling.
%	win		: 'sinc', 'gauss', 'sincfilt'
%			  'gauss' - gaussian window
%			  'sinc' - b-spline sinc(a,p) window 
%			  'sincfilt' - b-spline sinc(a,p) filter
%			  Default=='gauss'
%	ATT		: Attenution / Sidelobe error in dB (Optional)
%			  Default == 60 dB, ignored if win=='gauss'
%	method		: Method used to determine spectral and temporal 
%			  resolutions - dt and df
%			  '3dB'  - measures the 3dB cutoff frequency and 
%			           temporal bandwidth
%			  'chui' - uses the uncertainty principle
%			  Default == '3dB'
%	TW		: Filter Transition Width - for win=='sincfilt' only
%			  Default=0.5*df
%
%RETURNED VARIABLES
%
%   RipSpec : Ouput data structure
%             .FmAxis   : Temporal Modulation Frequency Axis
%             .RDAxis   : Ripple Density Axis   
%             .P1       : Ripple power spectrum 
%                         Normalized for unit long-term mean and local mean
%                         removed
%             .P2       : Normalized for unit long-term mean and long term 
%                         mean removed
%             .P3       : Mean long-term spectrum of sound subtracted
%             .P4       : Normalized by mean long-term spectrum
%             .P5       : Block normalized for unit local mean and local
%                         mean removed
%             .P6       : Mean of each frequency channel removed
%             .taixs    : Time axis (sec)
%             .faxis    : Frequency axis (kHz)
%             .S        : Spectrotemporal envelope (from STFFT)
%             .dF3dB    : 3dB filter frequency resolution 
%             .dT3dB    : 3dB filter temporal resolution
%             .dFU      : Filter frequency resolution (chui)
%             .dTU      : Filter temporal resolution (chui)
%             .df       : Frequency sampling resolution
%             .dt       : Temporal sampling resolution
%
% (C) Monty A. Escabi, April 2010
%
function [RipSpec]=ripplespecstfft(data,Fs,df,dFm,f1,fN,UT,UF,win,ATT,method,TW)

%Input Parameters
if nargin<5
    f1=0;
end
if nargin<6
    fN=Fs/2;
end
if nargin<7
    UT=1;
end
if nargin<8
    UF=1;
end
if nargin<9
    win='gauss';
end
if nargin<10
	ATT=30;
end
if nargin<11
	method='3dB';
end
if nargin<12
    TW=0.5*df;
end

%Checking for data structure
if ~isstruct(data)

    %Normalizing Sound for Unit Variance
    data=data/std(data);

    %Generating STFFT
    [data]=stfftgram(data,Fs,df,UT,UF,win,ATT,method,'n',TW);
    
end
S=abs(data.S);
taxis=data.taxis;
faxis=data.faxis;

%Truncate frequency axis to desired range
i=find(faxis>f1 & faxis<fN);
faxis=faxis(i);
S=S(i,:);

%Number of temporal samples used for each analysis block
Fst=1/(taxis(2)-taxis(1));
Nt=pow2(nextpow2(ceil(1/dFm*Fst)));

%Generating Temp variables and Allocating Variables
k=1;
Sksize1=size(S,1);
Sksize2=Nt;
P1=zeros(Sksize1*4,Sksize2*4);
P2=zeros(Sksize1*4,Sksize2*4);
P3=zeros(Sksize1*4,Sksize2*4);
P4=zeros(Sksize1*4,Sksize2*4);
P5=zeros(Sksize1*4,Sksize2*4);
P6=zeros(Sksize1*4,Sksize2*4);
Sk=[];

%Normalizing spectrogram
MS=mean(reshape(S,1,numel(S)));
S1=S/MS;                            %Normalizing for unit long-term mean
Sf=(mean(S1')'*ones(1,size(S1,2))); %Mean Spectrum of Sound
S3=S1-Sf;
S4=S1./Sf;

%Generating ripple spectrum
while length(S)>k*Nt

    %Computing Ripple Power Spectrum and Averaging Across Data Blocks
    %Ripple spectrum is computed using 5 different normalizations
    %   1 - normalized for unit long-term and local mean removed
    %   2 - normalized for unit long-term and long term mean removed
    %   3 - long-term mean spectrum of sound subtracted
    %   4 - normalize by mean long-term spectrum
    %   5 - Block normalized for unit mean
    %   6 - Mean of each frequency channel removed
    S1k=S1(:,(k-1)*Nt+1:k*Nt); 
    S1k=S1k-mean(mean(S1k));       %Remove local mean
    S2k=S1(:,(k-1)*Nt+1:k*Nt)-MS;  %Remove long-term mean
    S3k=S3(:,(k-1)*Nt+1:k*Nt); 
    S4k=S4(:,(k-1)*Nt+1:k*Nt);     %Normalized by Mean long-term spectrum
    S5k=S1(:,(k-1)*Nt+1:k*Nt);
    S5k=S3k/mean(mean(S3k));       %Normalized for unit local mean
    S5k=S3k-mean(mean(S3k));       %Remove local mean
    for l=1:size(S,1)
        MS=mean(S(l,(k-1)*Nt+1:k*Nt));  %Remove instantaneous spectral mean
        S6k(l,:)=S(l,(k-1)*Nt+1:k*Nt)-MS;
    end

    %Generating 2-D Kaiser Window
    if k==1
        [Beta2,N,wc] = fdesignk(40,.01*pi,.2*pi);
        W2=kaiser(Sksize2,Beta2);
        [Beta1,N,wc] = fdesignk(40,.01*pi,.2*pi);
        W1=kaiser(Sksize1,Beta1);
        WW=W1*W2';
        WW=WW/mean(mean(WW));
    end
    
    %Averaging Ripple Spectrum
    P1=P1+fftshift(abs(fft2((S1k.*WW),size(S1k,1)*4,Nt*4))).^2;
    P2=P2+fftshift(abs(fft2((S2k.*WW),size(S2k,1)*4,Nt*4))).^2;
    P3=P3+fftshift(abs(fft2((S3k.*WW),size(S3k,1)*4,Nt*4))).^2;
    P4=P4+fftshift(abs(fft2((S4k.*WW),size(S4k,1)*4,Nt*4))).^2;
    P5=P5+fftshift(abs(fft2((S5k.*WW),size(S5k,1)*4,Nt*4))).^2;
    P6=P6+fftshift(abs(fft2((S6k.*WW),size(S6k,1)*4,Nt*4))).^2;
    k=k+1;
    
    %Note - In all instances S is normalized for unit mean because this is what is necessary
    %for amplitude modulations. For instance, for SAM the DC is precisely 1. 
    %When this is done the DC signal power spectrum magnitude is precisely 1 
    %(i.e., at 0 dB).
    %
    %    imagesc(fftshift(abs(fft2(S1)))/size(P,1)/size(P,2)) %seems to work correctly
    %Also , you can interpolate by doing fft2(S1,1024,1024) , normalize the
    %same
   
end

%Normalizing FFT - note that P is power so we need to ^2 dimmensions
P1=P1/(k-1)/Sksize1^2/Sksize2^2;
P2=P2/(k-1)/Sksize1^2/Sksize2^2;
P3=P3/(k-1)/Sksize1^2/Sksize2^2;
P4=P4/(k-1)/Sksize1^2/Sksize2^2;
P5=P5/(k-1)/Sksize1^2/Sksize2^2;
P6=P6/(k-1)/Sksize1^2/Sksize2^2;
%Note: FFT Normalization requires that we normalize by
% size(Sk,1)*size(Sk,2). Note that we are computing the squared magnitude
% and hence we normalize by: size(Sk,1)^2*size(Sk,2)^2

%Spectral and Temporal Modulation Axis
Nt=size(P1,2);
Nx=size(P1,1);
dF=(faxis(2)-faxis(1))/1000;    %Units of kHz
FmAxis=(-Nt/2:Nt/2-1)/Nt*Fst;
RDAxis=1/dF*(-Nx/2:Nx/2-1)/Nx;  %Units of cycles/kHz

%Storing Data in structure
RipSpec.P1=P1;
RipSpec.P2=P2;
RipSpec.P3=P3;
RipSpec.P4=P4;
RipSpec.P5=P5;
RipSpec.P6=P6;
RipSpec.FmAxis=FmAxis;
RipSpec.RDAxis=RDAxis;
RipSpec.taxis=taxis;
RipSpec.faxis=faxis;
RipSpec.S=S;
RipSpec.dF3dB=data.dF3dB;
RipSpec.dT3dB=data.dT3dB;
RipSpec.dFU=data.dFU;
RipSpec.dTU=data.dTU;
RipSpec.df=data.df;
RopSpec.dt=data.dt;