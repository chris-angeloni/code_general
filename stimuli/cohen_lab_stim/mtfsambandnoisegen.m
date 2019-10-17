%
%function []=mtfsambandnoisegen(outfile,BW,Fm,gamma,T,Tpause,rt,Fs,L)
%
%   FILE NAME   : MTF SAM BAND NOISE GEN
%   DESCRIPTION : Generates  .WAV file that is used for bandlimted noise
%                 experimetns. The program will vay the modulatin frequency
%                 of the SAM as well as the noise bandwidths for the
%                 speficied paramters. The program generatesthe modulation
%                 envelopes and stores them as a MAT file. The modulated
%                 sounds are then generated using MODADDCARRIER.
%
%   outfile     : Output file name (No Extension)
%   BW          : Vector containing Noise Bandwidths for experiment
%   Fm          : Modulation Frequency Array (Hz)
%   gamma       : Modulation Index : 0 < gamma < 1
%   T           : Duration of Each Modulation Segment (sec)
%   Tpause      : Pause time (sec) between consecutive presentations
%   rt          : Rise time for window function at begining and end of
%                 sound (msec). If rt==0 parameter is ignored.
%   Fs          : Sampling frequency
%   L           : Number of presentations
%   Frozen      : Frozen noise carrier (Optional, Default=='n')
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, December 2010
%
function []=mtfsambandnoisegen(outfile,BW,Fm,gamma,T,Tpause,rt,Fs,L)

%Opening Temporary File
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');
TempFile2=[outfile 'Trig.raw'];
fidtemp2=fopen(TempFile2,'wb');

%Generating Randomized Modulation Rate and Bandwidth Sequence
bw=BW;
FM=[];
BW=[];
FMb=[];     %Blocked
BWb=[];     %Blocked
for k=1:length(Fm)
    FMb=[FMb Fm(k)*ones(size(bw))];
    BWb=[BWb bw];
end
rand('state',0);
for k=1:L
    index=randperm(length(FMb));
    FM=[FM FMb(index)];
    BW=[BW BWb(index)];
end

%Saving Parameter File
f=['save ' outfile '_param.mat BW FM Fm bw gamma T rt Tpause Fs L '];
eval(f);

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

%Generating noise carrier for different bandwidhts. The same noise is used
%for all modulation frequencies. In theory, we can do shuffling across FM. 
M=round(T*Fs);
if rt==0
    W=ones(1,M);
else
    W=windowm(Fs,3,M,rt);
end
for k=1:length(bw)
    if bw(k)==0
        NoiseBL(k).Xc=ones(1,M).*W;
    elseif bw(k)==inf
        NoiseBL(k).Xc=noiseblh(0,Fs/2,Fs,M).*W; %I could use gaussian noise, however, better to use this to preserve statistics
    else
        NoiseBL(k).Xc=noiseblh(0,bw(k)/2,Fs,M).*W;
    end
end

%Generating Modulation Envelope Signal
Y=[];
for k=1:length(FM)

	%Generaging Modulation Segment for each FM
    i=find(bw==BW(k));
    Y=[NoiseBL(i).Xc.*(1-cos(2*pi*FM(k)*(1:M)/Fs)) Xpause];
    
	%Generating Trigger Signal
	if k==1
		Trig=[zeros(1,length(Y))];
		Trig(1:2000)=round(32*1024*ones(1,2000));
	end

	%Writting to File 
	%Maximum Observed experimental Max=abs(X) was ~ 8.8 (for white noise)
    %Note: Onece the carrier is imposed using the SD of the signal is ~0.75
    %Normalize by 10 so no cliping, signal will exist between -1 to 1
    %After normalizing by 10 the variance of the final signal is 100 x smaller, ~0.0075
    Y=Y/10;
	fwrite(fidtemp,Y,'float');
    fwrite(fidtemp2,Trig,'int16');

end

%Closing All Files
fclose all;

%Using SOX to convert to WAV File
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 1 -s -2 ' TempFile2 ' ' outfile 'Trig.wav' ];
eval(f);