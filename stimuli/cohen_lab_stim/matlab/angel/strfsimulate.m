%function [timeaxis,freqaxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=strfsimulate(filename,sprfile,SoundType,Nsig,L);
% 
%Funcntion       using different sound and threshold, reconstruct the STRF
%
%Input
%           filename       : STRF file
%           sprfile        : Spectrotemporal envelope input file
%	         Tau		      : Integration time constant (msec)
%	         Nsig		      : Number of standard deviations of the
%			                    intracellular voltage to set the spike threshold
%	         SNR		      : Signal to Noise Ratio
%			                    SNR = sigma_in/sigma_n
%           SoundType      : 'MR' or 'RN'
%           L		         : Number of blocks to analyze (Default==inf)
%
%Output
%           Y              : The output of strfsprpre.m, continuous spike train
%           X              : The impulse of spike train
%           timeaxis		   : Time Axis
%        	freqaxis       : Frequency Axis (Hz)
%        	STRF1 , STRF2  : Spectro-Temporal Receptive Field
%        	PP		         : Power Level
%           Wo1, Wo2	      : Zeroth-Order Kernels ( Average Number of Spikes / Sec )
%           No1, No2	      : Number of Spikes
%        	SPLN	         : Sound Pressure Level per Frequency Band

function [X,Y,timeaxis,freqaxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=strfsimulate(filename,sprfile,SoundType,Nsig,L);

tic
%to initialize some parameters
if nargin<4
	L=inf;
end;

if SoundType=='MR'
   k=1:1706;
else
   k=1:1500;
end;

%to caculate continuous spike train
f=['load ' filename];
eval(f);
%STRF1,STRF2,STRF1s,STRF2s,Wo1,Wo2,No1,N02,PP,ModType,MdB,Sound,faxis,taxis
clear STRF1 STRF2 Wo1 Wo2 No1 No2 PP Sound SPLN;
N=size(STRF1s,2);
STRF1=STRF1s(:,1:4:N);
STRF2=STRF2s(:,1:4:N);
taxis=taxis(1:4:N);
[T,Y]=strfsprpre(sprfile,taxis,faxis,STRF1,STRF2,MdB,L);

%to caculate the dicrete spike train
%to initialize some parameters for integratefile
Tau=8;                %time constant for integrate_fire model (msec)
Tref=1;               %refractory period  (msec)
Vtresh=-50;           %threshold for the action potential
Vrest=-65;            %the rest potential of the membrane
%Nsig=1;               %it decides the threshold. Its range is from 0.5 to 4
SNR=3;                %signal to noise ratio, the range is from 1 to 100  9
Fs=44100/44;
Fsd=24000;
[X,Vm,R,C,sigma_m,sigma_i]=integratefire(Y,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs);
%to convert impulse to spike train with desired sample frequency 
[spet]=impulse2spet(X,Fs,Fsd);

%to generate Trigger signal
Trig=round(((k-1)*728+1)/Fs*Fsd);

%to reconstruct STRF
clear taxis faxis;
[timeaxis,freqaxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrfdb(sprfile,0,.1,spet,Trig,Fsd,60,MdB,ModType,SoundType,50,'float');

toc
