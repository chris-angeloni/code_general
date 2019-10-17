%
%function []=mtf3noisegen(outfile,BW,Fm,gamma,Tmin,Nmin,dt,rt,Tpause,Fs,L)
%
%   FILE NAME   : MTF 3 NOISE GEN
%   DESCRIPTION : Generates a .RAW and .WAV file which is used for 
%                 Noise MTF Experiment. Contains both SAM and Noise
%                 Bursts in randomized order.
%
%                 Same as MTF2NOISEGEN except that additional parameter
%                 Nmin is used to assure that a minimum number of
%                 periods is used.
%
%   outfile     : Output file name (No Extension)
%   BW          : Noise Bandwidth
%                 Default==inf (Flat Spectrum Noise)
%                 Otherwise BW=[F1 F2]
%                 where F1 is the lower cutoff and
%                 F2 is the upper cutoff frequencies
%   Fm	    	: Modulation Frequency Array (Hz)
%   gamma       : Modulation Index : 0 < gamma < 1
%   Tmin	   	: Minimum duration of Each Modulation Segment (sec) 
%   Nmin        : Minimum number of modulation periods used for each
%                 modulation rate.
%   dt          : Noise Burst Window Width (msec)
%   rt          : Noise Burst Rise Time (msec)
%   Tpause      : Pause time (sec) between consecutive presentations
%   Fs          : Sampling frequency
%   L           : Number of presentations
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, July 2006
%
function []=mtf3noisegen(outfile,BW,Fm,gamma,Tmin,Nmin,dt,rt,Tpause,Fs,L)

%Opening Temporary File
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');

%Generating Randomized Modulation Rate Sequence
flag=[];
Flag=[zeros(size(Fm)) ones(size(Fm))];
FM=[];
Fm=[Fm Fm];
rand('state',0);
for k=1:L
    index=randperm(length(Fm));
    FM=[FM Fm(index)];              %Permuted Modulation Rates
    flag=[flag Flag(index)];        %Permuted flags for Burst or SAM
end
Code=['Flag=1 for Noise Burst; Flag=0 for SAM Noise'];
T=max(Tmin,Nmin./FM);   %Actual Durations used for each mod segment
f=['save ' outfile '_param.mat BW Fm gamma Tmin T Nmin dt rt Tpause Fs L FM flag Code'];
eval(f);

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

%Generating Modulated Signal
Y=[];
for k=1:length(FM)

    %Displaying Progress 
    clc, disp(['Progress: ' int2str(k) ' out of ' int2str(length(FM)) ' sound segments generated.'])
    
    %Generaging SAM or Burst Modulation Segment for each FM
    if flag(k)==1      %Noise Burst AM
        X=[ammodnoise(BW,FM(k),gamma,T(k),dt,rt,Fs) Xpause];
    else                %SAM Noise
        X=[sammodnoise(BW,FM(k),gamma,T(k),Fs) Xpause];
    end
    
    %Generating Trigger Signal
    Trig=[zeros(1,length(X))];
    Trig(1:2000)=round(2^31*ones(1,2000));

	%Wrtting to File 
	%Maximum Observed experimental Max=abs(X) was ~ 6
	%Normalized so the 2^27*6<2^27*10<2^31
	%This Guarantees No Clipping
    clear Y
	Y(1:4:4*length(X))=round(X*2^27);
    Y(2:4:4*length(X))=round(X*2^27);
	Y(3:4:4*length(X))=Trig;
    Y(4:4:4*length(X))=Trig;
	fwrite(fidtemp,Y,'int32');

end

%Using SOX to convert to WAV File
f=['!sox -r ' int2str(Fs) ' -c 4 -l -s ' TempFile ' -l ' outfile '.wav' ];
eval(f)
%f=['!rm test.raw'];
%eval(f)

%Closing All Files
fclose all