%
%function []=mtfmodnoiseunifgen(outfile,Fu,gamma,ModType,T,Tp,L,Np,Tpause,rt,Fs,DS)
%
%   FILE NAME   : MTF MOD NOISE UNIF GEN
%   DESCRIPTION : Generates  .WAV file that is used for bandlimted noise
%                 experimetns. The program generates uniformly distributed 
%                 noise used to compute the impulse response using REVCORR.
%                 The program will also inteleave short segements that are
%                 used for prediction. The sound parameters and envelopes
%                 are stored as a PARAM file.
%
%                 The program generatesthe modulation envelopes and stores 
%                 them as a RAW file. The modulated sounds are then 
%                 generated using MODADDCARRIER.
%
%   outfile     : Output file name (No Extension)
%   Fu          : Upper cutoff frequency (Hz)
%   gamma       : Modulation Index : 0 < gamma < 1 for Lin; in dB for log
%   Modtype     : Type of modulation: dB or Lin
%   T           : Duration of Each Modulation Segment (sec)
%   Tp          : Duration of prediction segments (sec)
%   L           : Number of presentations (must be an interger multiple of
%                 2). Note that L/2 sounds will be presented 2 times each
%                 so that we can compute shuffled correlograms.
%   Np          : Number of presentations for prediction segments following
%                 each estimation segment. The total number of prediction
%                 segments is L/2*Np
%   Tpause      : Pause time (sec) between consecutive presentations
%   rt          : Rise time for window function at begining and end of
%                 sound (msec). If rt==0 parameter is ignored.
%   Fs          : Sampling frequency
%   DS          : Down Sampling Factor for Envelope
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, December 2010
%
function []=mtfmodnoiseunifgen(outfile,Fu,gamma,ModType,T,Tp,L,Np,Tpause,rt,Fs,DS)

%Opening Temporary File
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');
TempFile2=[outfile 'Trig.raw'];
fidtemp2=fopen(TempFile2,'wb');

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

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

%Saving Envelope
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
    
    %Generating Trigger Signal
	if k==1
		Trig=[zeros(1,length(Env))];
		Trig(1:2000)=round(32*1024*ones(1,2000));
		Trigp=[zeros(1,length(Envp))];
        Trigp(1:2000)=round(32*1024*ones(1,2000));
    end
    
    %Saving Estimation Segments to File. Note the same sound is saved
    %twice. This allows for shuffled correlogram analysis etc.
	fwrite(fidtemp,[Env Xpause],'float');
    fwrite(fidtemp,[Env Xpause],'float');
    fwrite(fidtemp2,[Trig Xpause],'int16');
    fwrite(fidtemp2,[Trig Xpause],'int16');
    SoundOrder=[SoundOrder ; 'E'];
    SoundOrder=[SoundOrder ; 'E'];
    
    %Saving Prediction Segments. These are already generated above.
    for m=1:Np
        
        %Saving Estimation Segments to File. Note the same sound is saved
        %twice. This allows for shuffled correlogram analysis etc.
        fwrite(fidtemp,[Envp Xpause],'float');
        fwrite(fidtemp2,[Trigp Xpause],'int16');
        SoundOrder=[SoundOrder ; 'P'];
    end
   
    %Down Sampling Estimation Envelope and Adding to structure
    SoundEstimationEnv(k).Env=Env(1:DS:end);
    
end

%Closing All Files
fclose all;

%Downsampling Prediction Envelope
SoundPredictionEnv=Envp(1:DS:end);

%Sound Parameters
SoundParam.Fu=Fu;
SoundParam.gamma=gamma;
SoundParam.ModType=ModType;
SoundParam.T=T;
SoundParam.Tp=Tp;
SoundParam.L=L;
SoundParam.Np=Np;
SoundParam.Tpause=Tpause;
SoundParam.rt=rt;
SoundParam.Fs=Fs;
SoundParam.SoundOrder=SoundOrder;
SoundParam.Xpause=Xpause;
SoundParam.DS=DS;
SoundParam.Envp=Envp;

%Saving Parameter File
f=['save ' outfile '_param.mat SoundParam SoundEstimationEnv SoundPredictionEnv'];
eval(f);

%Using SOX to convert to WAV File
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 1 -s -2 ' TempFile2 ' ' outfile 'Trig.wav' ];
eval(f);