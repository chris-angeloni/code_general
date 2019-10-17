%
%function []=mtfpsychonoisegen(outfile,BW,Fm,gamma,T,dt,rt,Tpause,Fs,L)
%
%   FILE NAME   : MTF PSYCHO NOISE GEN
%   DESCRIPTION : Generates a .RAW and .WAV file which is used for 
%			      Noise MTF Experiment. Contains SAM noise with variable
%			      modulation index. Used to construct a "psychophysical"
%			      version of the MTF
%
%	outfile		: Output file name (No Extension)
%	BW		    : Noise Bandwidth
%		    	  Default==inf (Flat Spectrum Noise)
%		    	  Otherwise BW=[F1 F2]
%	    		  where F1 is the lower cutoff and
%	    		  F2 is the upper cutoff frequencies
%   Fm	    	: Modulation Frequency Array (Hz)
%	gamma		: Modulation Index Array: 0 < gamma < 1
%   T	    	: Duration of Each Modulation Segment (sec) or if T is
%                 negative, abs(T) corresponds to the number of modulation
%                 periods used for each modulation rate.
%	Tpause		: Pause time (sec) between consecutive presentations
%   RT          : Gating window rise time (msec)
%	Fs		    : Sampling frequency
%	L 		    : Number of presentations
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, May 2006
%
function []=mtfpsychonoisegen(outfile,BW,Fm,gamma,T,RT,Tpause,Fs,L)

%Opening Temporary Files
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');
TempFile2=[outfile 'Trig.raw'];
fidtemp2=fopen(TempFile2,'wb');

%Initialize random phase for block randomized sequence
rand('state',0);

%Generating Blocked Randomized Modulation Rate and index sequences
% FM=[];
% GAMMA=[];
% for k=1:L
%     for l=1:length(gamma)
%         FM=[FM Fm];
%         GAMMA=[GAMMA ones(size(Fm))*gamma(l)];
%     end
% end
% rand('state',0);
% index=randperm(length(FM));
% FM=FM(index);
% GAMMA=GAMMA(index);

FM=[];
GAMMA=[];
FMb=[];         %Blocked
GAMMAb=[];      %Blocked
for k=1:L
    for l=1:length(gamma)
        FMb=[FMb Fm];
        GAMMAb=[GAMMAb ones(size(Fm))*gamma(l)];
    end
    index=randperm(length(FMb));
    FM=[FM FMb(index)];
    GAMMA=[GAMMA GAMMAb(index)];
    GAMMAb=[];
    FMb=[];
end
f=['save ' outfile '_param.mat BW Fm FM gamma GAMMA T RT Tpause Fs L'];
eval(f);

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

%Generating Modulated Signal
Y=[];
for k=1:length(FM)

    %Displaying Progress 
    clc, disp(['Progress: ' int2str(k) ' out of ' int2str(length(FM)) ' sound segments generated.'])
    
    %Generaging SAM Modulation Segment for each FM and GAMMA
    X=[sammodnoise2(BW,FM(k),GAMMA(k),T,Fs,RT) Xpause];
    
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