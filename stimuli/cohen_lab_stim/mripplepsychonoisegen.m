%
%function []=mripplepsychonoisegen(outfile,f1,f2,RD,FM,Gamma,ModType,M,Fs,NS,RP,DF)
%
%   FILE NAME   : M RIPPLE PSYCHO NOISE GEN
%   DESCRIPTION : Genrates Moving Ripple sound sequence used for
%                 'psychophysical' equivalent RTF measurements.
%
%	outfile		: Output file name (No Extension)
%   f1          : Lower Noise Frequency
%   f2          : Upper Noise Frequnecy
%   Rd          : Ripple Density Array (cycles/octave)
%   Fm          : Temporal Modulation Rate Array (Hz)
%   Beta        : Modulation Index Array (dB or Lin). When using Lin
%                 modulation index values are between [0 1]. If using dB,
%                 the modulation indexes correspond to the peak-to-peak
%                 amplitude of the ripples in units of dB.
%   ModType     : Ripple Envelope modulation Type: 'Log' or 'Lin'
%                 Log - Logarithmic modulations in dB
%                 Lin - linear modulation, App corresponds to the
%                 modulation index [0 1]
%   T	    	: Duration of Each Modulation Segment (sec) or if T is
%                 negative, abs(T) corresponds to the number of modulation
%                 periods used for each modulation rate.
%   Tpause		: Pause time (sec) between consecutive presentations
%   RT          : Gating window rise time (msec)
%   Fs		    : Sampling frequency
%   NS          : Number of sinusoid carriers
%   RP          : Ripple Phase [0,2*pi]
%                 Optional - default = random from [0,2*pi]
%   L           : Number of presentations
%
%RETURNED VALUES
%
% (C) Monty Escabi, May 2009
%
function []=mripplepsychonoisegen(outfile,f1,f2,Rd,Fm,Gamma,ModType,T,Tpause,RT,Fs,NS,RP,L)

%Opening Temporary Files
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');
TempFile2=[outfile 'Trig.raw'];
fidtemp2=fopen(TempFile2,'wb');

%Initialize random phase for block randomized sequence
rand('state',0);

%Generating Blocked Randomized Modulation Rate and index sequences
FM=[];
GAMMA=[];
RD=[];
FMb=[];         %Blocked
GAMMAb=[];      %Blocked
RDb=[];         %Blocked
for k=1:L
    for l=1:length(Gamma)
        for m=1:length(Rd)
            FMb=[FMb Fm];
            GAMMAb=[GAMMAb ones(1,length(Fm))*Gamma(l)];
            RDb=[RDb ones(1,length(Fm))*Rd(m)];
        end
    end
    index=randperm(length(FMb));
    FM=[FM FMb(index)];
    GAMMA=[GAMMA GAMMAb(index)];
    RD=[RD RDb(index)]
    GAMMAb=[];
    FMb=[];
    RDB=[];
end
f=['save ' outfile '_param.mat f1 f2 Fm FM Rd RD Gamma GAMMA T RT Tpause Fs NS RP L'];
eval(f);

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

%Generating Modulated Signal
Y=[];
for k=1:length(FM)

    %Displaying Progress 
    clc, disp(['Progress: ' int2str(k) ' out of ' int2str(length(FM)) ' sound segments generated.'])
    
    %Generaging Moving Ripple Segment for each FM and RD and GAMMA
    p=3;
    M=round(T*Fs);
    X=mripple(f1,f2,RD(k),FM(k),GAMMA(k),ModType,M,Fs,NS,RP,1);
    [W]=windowm(Fs,p,M,RT);
    X=[X.*W Xpause];

    %Generating Trigger Signal
    Trig=[zeros(1,length(X))];
    Trig(1:2000)=floor(2^31*ones(1,2000)-1);
    
	%Wrtting to File 
	%Maximum Observed experimental Max=abs(X) was ~ 6
	%Normalized so the 2^27*6<2^27*10<2^31
	%This Guarantees No Clipping
    clear Y
	Y(1:2:2*length(X))=round(X*2^27);
    Y(2:2:2*length(X))=round(X*2^27);
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
fclose all