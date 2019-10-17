%
%function [RipSpec]=ripplespec(data,Fs,dX,dFm,f1,fN,Fm,OF,Norm,GDelay,dis,ATT)
%	
%	FILE NAME 	: RIPPLESPEC
%	DESCRIPTION : Computes the ripple spectrum of a sound.
%
%	data    : Input data. If data is an array it simply corresponds to the
%             sound waveform samples. If data is a data structure, then the
%             structure contains the output of AUDIOGRAM. This is used to
%             speed up the analysis.
%	Fs		: Sampling Rate
%	dX		: Spectral Filter separation in octaves
%			  Usually a fraction of an octave ~ 1/8 would allow 
%			  for a spectral envelope resolution of up to 4 
%			  cycles per octave. However, note that the filter bandwidhts
%			  will ultimately limit the maximum spectral modulation
%			  frequency of the signal.
%
%			  Note that X=log2(f/f1) as defined for the ripple 
%			  representation 
%   dFm     : Temporal modulaiton frequency resolution (Hz)
%	f1		: Lower frequency to compute spectral decomposition
%	fN		: Upper freqeuncy to compute spectral decomposition
%	Fm		: Maximum Modulation frequency allowed for temporal
%			  envelope at each band. If Fm==inf full range of Fm is used.
%	OF		: Oversampling Factor for temporal envelope
%			  Since the maximum frequency of the envelope is 
%			  Fm, the Nyquist Frequency is 2*Fm
%			  The Frequency used to sample the envelope is 
%			  2*Fm*OF
%   Norm    : Amplitude normalization (Optional)
%             En:  Equal Energy (Default)
%             Amp: Equal Amplitude
%   GDelay  : Remove group delay of filters prior to computing ripple 
%             spectrum (Optional, 'y' or 'n': Default=='n')
%	dis		: display (optional): 'log' or 'lin' or 'n'
%			  Default == 'n'
%	ATT		: Attenution / Sidelobe error in dB (Optional)
%			  Default == 60 dB
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
%             .S        : Spectrotemporal envelope (see AUDIOGRAM)
%
% (C) Monty A. Escabi, July 2008 (Edit June 2009, Nov 2009)
%
function [RipSpec]=ripplespec(data,Fs,dX,dFm,f1,fN,Fm,OF,Norm,GDelay,dis,ATT)

%Input Parameters
if nargin<9
    Norm='En';
end
if nargin<10
    GDelay='n';
end
if nargin<11
	dis='n';
end
if nargin<12
	ATT=60;
end

%Checking for data structure
if ~isstruct(data)
    
    %Temporal Down Sampling Factor - see Audiogram.m
    DF=ceil(Fs/2/Fm/OF);

    %Normalizing Sound for Unit Variance
    data=data/std(data);

    %Generating Audiogram
    [data]=audiogram(data,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT);
end
taxis=data.taxis;
faxis=data.faxis;
S=data.S;
NormGain=data.NormGain;
GroupDelay=data.GroupDelay;

%Removing Group Delay if Desired (Nov 2009)
if strcmp(GDelay,'y') & isfield(data,{'Sc'})    %Corrected audiogram is stored in 'data'

    S=data.Sc;
    size(S)
    taxis=(0:size(data.Sc,2)-1)*(taxis(2)-taxis(1));

elseif strcmp(GDelay,'y')                       %Corrected audiogram is not stored in 'data'
    
    %Computing delay parameters
    Fst=1/(taxis(2)-taxis(1));
    NMax=round(max(GroupDelay*Fst));
    L=size(S,2);
    
    %Removing Delay
    for k=1:size(S,1)        
        Ndelay=round(GroupDelay(k)*Fst)+1;
        SS(k,:)=S(k,Ndelay:L-NMax+Ndelay-1);
    end
    S=SS;
    taxis=taxis(1:size(S,2));
end

%Checking and fixing Normalization
if strcmp(Norm,'Amp') & ~strcmp(Norm,data.Norm)
    for k=1:length(NormGain)
        S(k,:)=S(k,:)/NormGain(k);
    end
end
if strcmp(Norm,'En') & ~strcmp(Norm,data.Norm)
    for k=1:length(NormGain)
        S(k,:)=S(k,:)*NormGain(k);
    end
end     

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

%Normalizing audiograms
MS=mean(reshape(S,1,numel(S)));
S1=S/MS;                            %Normalizing for unit long-term mean
Sf=(mean(S1')'*ones(1,length(S1))); %Mean Spectrum of Sound
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
        WW=WW/mean(W1)/mean(W2);
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
FmAxis=(-Nt/2:Nt/2-1)/Nt*Fst;
RDAxis=1/dX*(-Nx/2:Nx/2-1)/Nx;

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
RipSpec.NormGain=NormGain;
RipSpec.Norm=Norm;