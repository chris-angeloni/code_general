%
%function []=pnbsplinemodnoisegen(outfile,BW,Fm,gamma,p,T,Tpause,Fs,L,Frozen)
%
%   FILE NAME   : PNB SPLINE MOD NOISE GEN
%   DESCRIPTION : Generates a .RAW and .WAV file which is used for 
%			      Noise shape versus peridicity experiments. The sound is a
%			      periodic B-spline. The program automatically changes the
%			      cutoff frequency across all Fm as long as Fc>Fm. The
%			      program will also vary the modulation index (gamma) and
%			      B-spline order (P) if desired.
%
%	outfile		: Output file name (No Extension)
%	BW		    : Noise Bandwidth
%		    	  Default==inf (Flat Spectrum Noise)
%		    	  Otherwise BW=[F1 F2]
%	    		  where F1 is the lower cutoff and
%	    		  F2 is the upper cutoff frequencies
%   Fm	    	: Modulation Frequency Array (Hz)
%	gamma		: Modulation Index Array : 0 < gamma < 1
%   p           : B spline order array (integer valued)
%   T	    	: Duration of Each Modulation Segment (sec) or if T is
%                 negative, abs(T) corresponds to the number of modulation
%                 periods used for each modulation rate.
%	Tpause		: Pause time (sec) between consecutive presentations
%	Fs		    : Sampling frequency
%	L 		    : Number of presentations
%   Frozen      : Frozen noise carrier (Optional, Default=='n')
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, May 2006
%
function []=pnbsplinemodnoisegen(outfile,BW,Fm,gamma,p,T,Tpause,Fs,L,Frozen)

%Input Arguments
if nargin<10
    Frozen='n';
end

%Opening Temporary File
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');
TempFile2=[outfile 'Trig.raw'];
fidtemp2=fopen(TempFile2,'wb');

%Generating Randomized Modulation Rate Sequence
FM=[];
GAMMA=[];
FC=[];
P=[];
FMb=[];         %Blocked
GAMMAb=[];      %Blocked
FCb=[];         %Blocked
Pb=[];          %Blocked
for l=1:length(gamma)
    for m=1:length(p)
        for n=1:length(Fm)
            for fc=Fm(n:length(Fm))
                FMb=[FMb Fm(n)];
                GAMMAb=[GAMMAb gamma(l)];
                Pb=[Pb p(m)];
                FCb=[FCb fc];
            end
        end
    end
end
rand('state',0);
for k=1:L
    index=randperm(length(FMb));
    FM=[FM FMb(index)];
    GAMMA=[GAMMA GAMMAb(index)];
    FC=[FC FCb(index)];
    P=[P Pb(index)];
end

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

%Generating Modulated Signal
Y=[];
for k=1:length(FM)

    %Displaying Progress 
    clc, disp(['Progress: ' int2str(k) ' out of ' int2str(length(FM)) ' sound segments generated.'])
  
    %Generaging Modulated B Spline
    if strcmp(Frozen,'y')
        seed=1;
        [X,Env,Fm]=pnbsplinemodnoise(BW,FM(k),GAMMA(k),FC(k),P(k),T,Fs,seed);
    else
        [X,Env,Fm]=pnbsplinemodnoise(BW,FM(k),GAMMA(k),FC(k),P(k),T,Fs);
    end
    NX(k)=length(X);    %Lenght of Each segment
    X=[X Xpause];
    
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

%Saving Parameters
f=['save ' outfile '_param.mat BW Fm FM gamma GAMMA p P FC T Tpause NX Fs L'];
eval(f);

%Using SOX to convert to WAV File
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 2 -4 -s ' TempFile '  -4 -f ' outfile '.wav' ];
eval(f);
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 1 -4 -s ' TempFile2 '  -4 -f ' outfile '_Trig.wav' ];
eval(f);

%Closing All Files
fclose all