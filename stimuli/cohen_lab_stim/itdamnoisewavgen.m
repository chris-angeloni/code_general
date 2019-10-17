%
%function []=itdamnoisewavgen(outfile,f1,f2,ITDMax,Fm,Fs,T,RT,Tpause,L)
%
%       FILE NAME       : ITD AM NOISE WAV GEN
%       DESCRIPTION     : Generates a noise signal with sinusoidally
%                         varying ITD profile
%
%       Outfile         : Output file name header
%       f1              : Lower noise cutoff frequency (Hz)
%       f2              : Upper noise cutoff frequency (Hz)
%       ITDMax          : Array containg the Maximum ITD (micro sec)
%       Fm              : Array containing ITD Beat Frequency (Hz)
%       Fs              : Sampling Frequency
%       T               : Sound segement duartion (msec)
%       RT              : Rise Time (msec)
%       Tpause          : Inter stimulus period (msec)
%       L               : Number of repeats
%
% (C) Monty A. Escabi, Jan 2009
%
function []=itdamnoisewavgen(outfile,f1,f2,ITDMax,Fm,Fs,T,RT,Tpause,L)

%Opening Temporary Files
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');
TempFile2=[outfile 'Trig.raw'];
fidtemp2=fopen(TempFile2,'wb');

%Initialize random phase for block randomized sequence
rand('state',0);

%Generates Parameter Sequence in Block Randomized Order
FM=[];
ITDMAX=[];
FMb=[];     %Blocked
ITDMAXb=[]; %Blocked
for k=1:L
    for l=1:length(ITDMax)
        FMb=[FMb Fm];
        ITDMAXb=[ITDMAXb ones(size(Fm))*ITDMax(l)];
    end
    index=randperm(length(FMb));
    FM=[FM FMb(index)];
    ITDMAX=[ITDMAX ITDMAXb(index)];
    ITDMAXb=[];
    FMb=[];
end
f=['save ' outfile '_param.mat f1 f2 Fm FM ITDMax ITDMAX T RT Tpause Fs L'];
eval(f);

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause/1000));

%Generatig Sound
M=round(T/1000*Fs);
for k=1:length(ITDMAX)
          
    %Displaying Progress 
    clc, disp(['Progress: ' int2str(k) ' out of ' int2str(length(ITDMAX)) ' sound segments generated.'])

    %Generaging ITD Noise Segment for each ITDMax and Fm
    [Xl,Xr,ITD]=itdamnoisegen(f1,f2,ITDMAX(k),FM(k),Fs,M);
    
    %Multiplying by Window Function - Odd procedure because W may not be
    %the same length as Xl and Xr
    [W]=window(Fs,3,T,RT);
    W=W(1:floor(length(W)/2));
    Xl(length(Xl):-1:length(Xl)-length(W)+1)=Xl(length(Xl):-1:length(Xl)-length(W)+1).*W;
    Xl(1:length(W))=Xl(1:length(W)).*W;
    Xr(length(Xr):-1:length(Xr)-length(W)+1)=Xr(length(Xr):-1:length(Xr)-length(W)+1).*W;
    Xr(1:length(W))=Xr(1:length(W)).*W;
    
    %Appending All segments and Pause
    Xl=[Xl Xpause];
    Xr=[Xr Xpause];
    
    %Generating Trigger Signal
    Trig=[zeros(1,length(Xl))];
    Trig(1:2000)=floor(2^31*ones(1,2000)-1);

	%Wrtting to File 
	%Maximum Observed experimental Max=abs(X) was ~ 6
	%Normalized so the 2^27*6<2^27*10<2^30
	%This Guarantees No Clipping
    clear Y
	Y(1:2:2*length(Xl))=round(Xl*2^27);
    Y(2:2:2*length(Xr))=round(Xr*2^27);
	fwrite(fidtemp,Y,'int32');
    fwrite(fidtemp2,Trig,'int32');
    
end

%Using SOX to convert to WAV File
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 2 -4 -s ' TempFile '  -4 -f ' outfile '.wav' ];
eval(f);
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 1 -4 -s ' TempFile2 '  -4 -f ' outfile '_Trig.wav' ];
eval(f);
%f=['!rm test.raw'];
%eval(f)

%Closing All Files
fclose all;
