%
%function []=samonsetnoise(outfile,BW,Fm,gamma,Fs,L,T)
%
%   FILE NAME   : SAM ONSET NOISE
%   DESCRIPTION : Generates a .RAW and .WAV file which containsts
%                 the onset component of SAM modulated noise. This
%                 will be used in conjunction with "mtfnoisegen"
%                 to try to predict response from "mtfsamnoisegen"
%
%   outfile     : Output file name (No Extension)
%   BW          : Noise Bandwidth
%                 Default==inf (Flat Spectrum Noise)
%                 Otherwise BW=[F1 F2]
%                 where F1 is the lower cutoff and
%                 F2 is the upper cutoff frequencies
%   Fm          : Modulation Frequency Array (Hz)
%   gamma       : Modulation Index : 0 < gamma < 1
%   Fs          : Sampling frequency (Hz)
%   L           : Number of trials
%   T           : Onset Segment time (sec; Default==1/min(Fm))
%
%   NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi , October 2005
%
function []=samonsetnoise(outfile,BW,Fm,gamma,Fs,L,T)

%Input Arguments
if nargin<7
    T=1/min(Fm);
end

%Opening Temporary File
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');

%Generating Onset Envelopes
Env=zeros(length(Fm),ceil(T*Fs)+1);
for k=1:length(Fm)
   Env(k,1:ceil(1/Fm(k)*Fs))=cos(2*pi*Fm(k)/Fs*(1:ceil(1/Fm(k)*Fs))+pi)+1; 
end

%Generating Randomized Modulation Rate Sequence
FM=[];
for k=1:L
	FM=[FM Fm];
end
rand('state',0);
index=randperm(length(FM));
FM=FM(index);
f=['save ' outfile '_param.mat BW Fm gamma T Fs L FM Env'];
eval(f);

%Generating Onset Signal
Y=[];
NE=size(Env,2);
for k=1:length(FM)

	%Generaging Modulation Segment for each FM
    if BW~=inf
        N=noiseblfft(BW(1),BW(2),Fs,NE);
    else
        N=2*(rand(1,NE)-0.5);     
    end
    index=find(FM(k)==Fm);
    X=N.*Env(index,:);
    
	%Generating Trigger Signal
	if k==1
		Trig=zeros(1,NE);
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