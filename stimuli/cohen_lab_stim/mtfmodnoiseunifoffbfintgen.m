%
%function []=mtfmodnoiseunifoffbfintgen(outfile,Fu,gamma,ModType,T,L,Tpause,rt,Fs,DS)
%
%   FILE NAME   : MTF MOD NOISE UNIF OFF BF INT GEN
%   DESCRIPTION : Generates  .WAV file that is used for bandlimted noise
%                 experimetns. The program generates uniformly distributed 
%                 noise used to compute the impulse response and second 
%                 order kernel response using REVCORR. Modulated sounds are
%                 presented at the BF of the neuron and also at off BF
%                 frequencies. The interaction kernel between BF and off BF
%                 frequencies will then be computed.
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
%   L           : Number of presentations (must be an interger multiple of
%                 2). Note that L/2 sounds will be presented 2 times each
%                 so that we can compute shuffled correlograms.
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
function []=mtfmodnoiseunifoffbfintgen(outfile,Fu,gamma,ModType,T,L,Tpause,rt,Fs,DS)

%Opening Temporary File
TempFile1=[outfile '1.raw'];
fidtemp1=fopen(TempFile1,'wb');
TempFile2=[outfile '2.raw'];
fidtemp2=fopen(TempFile2,'wb');
TempFile3=[outfile 'Trig.raw'];
fidtemp3=fopen(TempFile3,'wb');

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

%Generate Window
M=round(T*Fs);
if rt==0
    W=ones(1,M);
else
    W=windowm(Fs,3,M,rt);
end

%Saving Envelope
SoundOrder=[];  %Sound ordering for each trigger, E=Estimation
for k=1:L/2

    %Display
    clc
    disp(['Generating Segment: ' num2str(k) ' of ' num2str(L/2)])
    
    %BF and off BF Noise Segments (Linear or Log modulations)
    Env1=noiseunifh(0,Fu,Fs,M,k*2-1);  %Use seed=2*k-1 for kth on BF segment
    Env2=noiseunifh(0,Fu,Fs,M,k*2);    %Use seed=2*k for kth off BF segment
    if strcmp(ModType,'Lin')
        Env1=Env1.*gamma+(1-gamma);
        Env2=Env2.*gamma+(1-gamma);
    else
        Env1=10.^((Env1*gamma-gamma)/20);
        Env2=10.^((Env2*gamma-gamma)/20);
    end
    Env1=Env1.*W;
    Env2=Env2.*W;
    
    %Generating Trigger Signal
	if k==1
		Trig=[zeros(1,length(Env1))];
		Trig(1:2000)=round(32*1024*ones(1,2000));
    end
    
    %Saving Estimation Segments to File. Note the same sound is saved
    %twice. This allows for shuffled correlogram analysis etc.
	fwrite(fidtemp1,[Env1 Xpause],'float32');
    fwrite(fidtemp1,[Env1 Xpause],'float32');
	fwrite(fidtemp2,[Env2 Xpause],'float32');
    fwrite(fidtemp2,[Env2 Xpause],'float32');    
    fwrite(fidtemp3,[Trig Xpause],'int16');
    fwrite(fidtemp3,[Trig Xpause],'int16');
    SoundOrder=[SoundOrder ; 'E'];
    SoundOrder=[SoundOrder ; 'E'];
    
    %Down Sampling Estimation Envelope and Adding to structure
    SoundEstimationEnv(k).Env1=Env1(1:DS:end);
    SoundEstimationEnv(k).Env2=Env2(1:DS:end);
    
end

%Closing All Files
fclose all;

%Sound Parameters
SoundParam.Fu=Fu;
SoundParam.gamma=gamma;
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
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 1 -s -2 ' TempFile3 ' ' outfile 'Trig.wav' ];
eval(f);