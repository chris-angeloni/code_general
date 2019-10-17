%
%function []=mtf2noisegen(outfile,BW,Fm,gamma,T,dt,rt,Tpause,Fs,L)
%
%   FILE NAME   : MTF 2 NOISE GEN
%   DESCRIPTION : Generates a .RAW and .WAV file which is used for 
%			      Noise MTF Experiment. Contains both SAM and Noise
%                 Bursts in randomized order
%
%	outfile		: Output file name (No Extension)
%	BW		    : Noise Bandwidth
%		    	  Default==inf (Flat Spectrum Noise)
%		    	  Otherwise BW=[F1 F2]
%	    		  where F1 is the lower cutoff and
%	    		  F2 is the upper cutoff frequencies
%   Fm	    	: Modulation Frequency Array (Hz)
%	gamma		: Modulation Index : 0 < gamma < 1
%   T	    	: Duration of Each Modulation Segment (sec) or if T is
%                 negative, abs(T) corresponds to the number of modulation
%                 periods used for each modulation rate.
%	dt		    : Noise Burst Window Width (msec)
%	rt		    : Noise Burst Rise Time (msec)
%	Tpause		: Pause time (sec) between consecutive presentations
%	Fs		    : Sampling frequency
%	L 		    : Number of presentations
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, May 2006
%
function []=mtf2noisegen(outfile,BW,Fm,gamma,T,dt,rt,Tpause,Fs,L)

%Opening Temporary File
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');

%Generating Randomized Modulation Rate Sequence
FM=[];
flag=[];
for k=1:L
	FM=[FM Fm Fm];
    flag=[flag zeros(size(Fm)) ones(size(Fm))];
end
rand('state',0);
index=randperm(length(FM));
FM=FM(index);
flag=flag(index);
Code=['Flag=1 for Noise Burst; Flag=0 for SAM Noise'];
f=['save ' outfile '_param.mat BW Fm gamma T dt rt Tpause Fs L FM flag Code'];
eval(f);

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

%Generating Modulated Signal
Y=[];
for k=1:length(FM)

    %Displaying Progress 
    clc, disp(['Progress: ' int2str(k) ' out of ' int2str(length(FM)) ' sound segments generated.'])
    
    %Generaging SAM or Burst Modulation Segment for each FM
    if T>0
        if flag(k)==1      %Noise Burst AM
            X=[ammodnoise(BW,FM(k),gamma,T,dt,rt,Fs) Xpause];
        else                %SAM Noise
            X=[sammodnoise(BW,FM(k),gamma,T,Fs) Xpause];
        end
    else    %Fixed number of modulation periods for each FM
        Tp=abs(T)/FM(k);    %Number of seconds required for fixed number of modulation periods
        if flag(k)==1       %Noise Burst AM
            X=[ammodnoise(BW,FM(k),gamma,Tp,dt,rt,Fs) Xpause];
        else                %SAM Noise
            X=[sammodnoise(BW,FM(k),gamma,Tp,Fs) Xpause];
        end
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