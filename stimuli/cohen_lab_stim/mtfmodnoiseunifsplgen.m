%
%function []=mtfmodnoiseunifsplgen(outfile,Fu,gamma,ATT,ModType,T,L,Tpause,rt,Fs,DS)
%
%   FILE NAME   : MTF MOD NOISE UNIF SPL GEN
%   DESCRIPTION : Generates  .WAV file that is used for bandlimted noise
%                 experimetns. The program generates uniformly distributed 
%                 noise used to compute the impulse response and second 
%                 order kernel response using REVCORR. Modulated sounds are
%                 presented at different attenuation levels (ATT). 
%
%                 The program generatesthe modulation envelopes and stores 
%                 them as a RAW file. The modulated sounds are then 
%                 generated using MODADDCARRIER.
%
%   outfile     : Output file name (No Extension)
%   Fu          : Upper cutoff frequency (Hz)
%   gamma       : Modulation Index : 0 < gamma < 1 for Lin; in dB for log
%   ATT         : Vector containing the desired attenuation levels.
%   Modtype     : Type of modulation: dB or Lin
%   T           : Duration of Each Modulation Segment (sec)
%   L           : Number of presentations per ATT condition
%   Tpause      : Pause time (sec) between consecutive presentations
%   rt          : Rise time for window function at begining and end of
%                 sound (msec). If rt==0 parameter is ignored.
%   Fs          : Sampling frequency
%   DS          : Down Sampling Factor for Envelope
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, March 2011
%
function []=mtfmodnoiseunifsplgen(outfile,Fu,gamma,ATT,ModType,T,L,Tpause,rt,Fs,DS)

%Opening Temporary File
TempFile1=[outfile '.raw'];
fidtemp1=fopen(TempFile1,'wb');
TempFile2=[outfile 'Trig.raw'];
fidtemp2=fopen(TempFile2,'wb');

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

%Generate Window
M=round(T*Fs);
if rt==0
    W=ones(1,M);
else
    W=windowm(Fs,3,M,rt);
end

%ATT Ordering - Random Interleave Order
ATTorder=[];
for k=1:L
    ATTorder=[ATTorder randsample(ATT,length(ATT))];
end

%Saving Envelope
SoundOrder=[];  %Sound ordering for each trigger, E=Estimation
for k=1:length(ATTorder)

    %Display
    clc
    disp(['Generating Segment: ' num2str(k) ' of ' num2str(length(ATTorder))])
    
    %Envelope at multiple SPL (Linear or Log modulations)
    %Uses the same Envelope for each ATT block. This can be used to do
    %crosscorrelation analysis and compare resposes at multiple SPL
    if floor((k-1)/length(ATT))==(k-1)/length(ATT)    %Generate only one envelope for each BLOCK
        Env=noiseunifh(0,Fu,Fs,M,k);  %Use seed k for kth on BF segment
        if strcmp(ModType,'Lin')
            Env=Env.*gamma+(1-gamma);
        else
            Env=10.^((Env*gamma-gamma)/20);
        end
    end
    EnvSPL=Env.*W*10.^(-ATTorder(k)/20);

    %Generating Trigger Signal
	if k==1
		Trig=[zeros(1,length(Env))];
		Trig(1:2000)=round(32*1024*ones(1,2000));
    end
    
    %Saving Estimation Segments to File. Note the same sound is saved
    %twice. This allows for shuffled correlogram analysis etc.
	fwrite(fidtemp1,[EnvSPL Xpause],'float32');
    fwrite(fidtemp2,[Trig Xpause],'int16');
    SoundOrder=[SoundOrder ; 'E'];
    
    %Down Sampling Estimation Envelope and Adding to structure
    SoundEstimationEnv(k).Env=EnvSPL(1:DS:end);
    
end

%Closing All Files
fclose all;

%Sound Parameters
SoundParam.Fu=Fu;
SoundParam.gamma=gamma;
SoundParam.ATT=ATT;
SoundParam.ATTorder=ATTorder;
SoundParam.ModType=ModType;
SoundParam.T=T;
SoundParam.L=L;
SoundParam.Tpause=Tpause;
SoundParam.rt=rt;
SoundParam.Fs=Fs;
SoundParam.SoundOrder=SoundOrder;
SoundParam.Xpause=Xpause;
SoundParam.DS=DS;

%Saving Parameter File
f=['save ' outfile '_param.mat SoundParam SoundEstimationEnv'];
eval(f);

%Using SOX to convert to WAV File
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 1 -s -2 ' TempFile2 ' ' outfile 'Trig.wav' ];
eval(f);