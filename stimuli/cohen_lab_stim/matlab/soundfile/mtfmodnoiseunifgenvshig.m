%
%function []=mtfmodnoiseunifgenvshig(outfile,Fu,gamma,ModType,T,Tp,L,rt,Fs)
%
%   FILE NAME   : MTF MOD NOISE UNIF GEN V SHIG
%   DESCRIPTION : Generates  .WAV file that is used for bandlimted noise
%                 experimetns. The program generates uniformly distributed 
%                 noise used to compute the impulse response using REVCORR.
%                 The program will also inteleave short segements that are
%                 used for prediction. The sound parameters and envelopes
%                 are stored as a PARAM file.
%
%                 This version is used for SHIG'S SYSTEM 3 PROGRAM
%
%                 The program generatesthe modulation envelopes and stores 
%                 them as a RAW file. The modulated sounds are then 
%                 generated using MODADDCARRIER.
%
%   outfile     : Output file name header (No Extension)
%   Fu          : Upper cutoff frequency (Hz)
%   gamma       : Modulation Index : 0 < gamma < 1 for Lin; in dB for log
%   Modtype     : Type of modulation: dB or Lin
%   T           : Duration of Each Modulation Segment (sec)
%   Tp          : Duration of prediction segments (sec)
%   L           : Number of presentations (must be an interger multiple of
%                 2). Note that L/2 sounds will be presented 2 times each
%                 so that we can compute shuffled correlograms.
%   rt          : Rise time for window function at begining and end of
%                 sound (msec). If rt==0 parameter is ignored.
%   Fs          : Sampling frequency
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, May 2011
%
function []=mtfmodnoiseunifgenvshig(outfile,Fu,gamma,ModType,T,Tp,L,rt,Fs)

%Downsampling Factor, for SHIG's there is no need to downsample
DS=1;
Np=NaN;

%File Headers
EstHeader='EstEnv';
PreHeader='PreEnv';

%Generate Window
M=round(T*Fs);
Mp=round(Tp*Fs);
if rt==0
    W=ones(1,M);
    Wp=ones(1,Mp);
else
    W=windowm(Fs,3,M,rt);
    Wp=windowm(Fs,3,Mp,rt);
end

%Prediction Noise Segment (Linear or Log modulations)
Envp=noiseunifh(0,Fu,Fs,Mp,0);      %Use seed=0 for prediction segment
if strcmp(ModType,'Lin')
    Envp=Envp.*gamma+(1-gamma);
else
    Envp=10.^((Envp*gamma-gamma)/20);
end
Envp=Envp.*Wp;

%Generating Estimation Envelopes
SoundOrder=[];  %Sound ordering for each trigger, E=Estimation; P=Prediction
for k=1:L/2

    %Display
    clc
    disp(['Generating Segment: ' num2str(k) ' of ' num2str(L/2)])
    
    %Estimation Noise Segment (Linear or Log modulations)
    Env=noiseunifh(0,Fu,Fs,M,k);    %Use seed=k for kth estimation segment
    if strcmp(ModType,'Lin')
        Env=Env.*gamma+(1-gamma);
    else
        Env=10.^((Env*gamma-gamma)/20);
    end
    Env=Env.*W;
    
    %Down Sampling Estimation Envelope and Adding to structure
    SoundEstimationEnv(k).Env=Env;
    
end

%Downsampling Prediction Envelope
SoundPredictionEnv=Envp;

%Sound Parameters
SoundParam.Fu=Fu;
SoundParam.gamma=gamma;
SoundParam.ModType=ModType;
SoundParam.T=T;
SoundParam.Tp=Tp;
SoundParam.L=L;
SoundParam.Np=Np;
SoundParam.rt=rt;
SoundParam.Fs=Fs;
SoundParam.SoundOrder=SoundOrder;
SoundParam.DS=DS;
SoundParam.Envp=Envp;

%Saving Parameter File
f=['save ' outfile '_param.mat SoundParam SoundEstimationEnv SoundPredictionEnv'];
eval(f);