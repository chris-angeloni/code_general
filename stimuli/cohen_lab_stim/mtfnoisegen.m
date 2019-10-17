%
%function []=mtfnoisegen(outfile,BW,Fm,gamma,T,dt,rt,Tpause,Fs,L)
%
%   FILE NAME   : MTF NOISE GEN
%   DESCRIPTION : Generates a .RAW and .WAV file which is used for 
%			      Noise MTF Experiment
%
%	outfile		: Output file name (No Extension)
%	BW		    : Noise Bandwidth
%		    	  Default==inf (Flat Spectrum Noise)
%		    	  Otherwise BW=[F1 F2]
%	    		  where F1 is the lower cutoff and
%	    		  F2 is the upper cutoff frequencies
%   Fm	    	: Modulation Frequency Array (Hz)
%	gamma		: Modulation Index : 0 < gamma < 1
%	Texp		: Experiment time (sec)
%	T	    	: Duration of Each Modulation Segment (sec)
%	dt		    : Noise Burst Window Width (msec)
%	rt		    : Noise Burst Rise Time (msec)
%	Tpause		: Pause time (sec) between consecutive presentations
%	Fs		    : Sampling frequency
%	L 		    : Number of presentations
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, Oct 2005
%
function []=mtfnoisegen(outfile,BW,Fm,gamma,T,dt,rt,Tpause,Fs,L)

%Opening Temporary File
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');

%Generating Randomized Modulation Rate Sequence
FM=[];
for k=1:L
	FM=[FM Fm];
end
rand('state',0);
index=randperm(length(FM));
FM=FM(index);
f=['save ' outfile '_param.mat BW Fm gamma T dt rt Tpause Fs L FM'];
eval(f);

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

%Generating Modulated Signal
Y=[];
for k=1:length(FM)

	%Generaging Modulation Segment for each FM
	X=[ammodnoise(BW,FM(k),gamma,T,dt,rt,Fs) Xpause];

	%Generating Trigger Signal
	if k==1
		Trig=[zeros(1,length(X))];
		Trig(1:2000)=round(2^31*ones(1,2000));
	end

	%Wrtting to File 
	%Maximum Observed experimental Max=abs(X) was ~ 6
	%Normalized so the 2^27*6<2^27*10<2^31
	%This Guarantees No Clipping
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