%
%function []=itdrandamnoisewavgen(outfile,f1,f2,ITDMax,Fmb,Fs,M)
%
%       FILE NAME       : ITD RAND AM NOISE WAV GEN
%       DESCRIPTION     : Generates a random noise "binaural beat" WAV FILE. This is
%                         done time warping the time axis of the signal by 
%                         a random ITD profile and interpolating at the 
%                         original samples times. The random ITD profile is
%                         uniformly distributed with a maximum ITD
%                         excursion of ITDMax. The maximum rate of change
%                         of the ITD profile is given by Fmb.
%
%       outfile         : Output file header
%       f1              : Lower noise cutoff frequency (Hz)
%       f2              : Upper noise cutoff frequency (Hz)
%       ITDMax          : Maximum ITD (micro sec)
%       Fmb             : ITD Upper Beat Frequency (Hz)
%       Fs              : Sampling Frequency
%       M               : Number of Samples
%
% (C) Monty A. Escabi, Jan 2009
%
function []=itdrandamnoisewavgen(outfile,f1,f2,ITDMax,Fmb,Fs,M)

%Generating Noise with Random ITD Profile
[Xl,Xr,ITD]=itdrandamnoisegen(f1,f2,ITDMax,Fmb,Fs,M);

%Saving Parameter File
f=['save ' outfile '_Param ITD f1 f2 ITDMax Fmb Fs M'];
eval(f)

%Generating Trigger Array
XTrig=zeros(1,Fs);
XTrig(1:1000)=ones(1,1000);
Trig=[];
while length(Trig)<length(Xl)
    Trig=[Trig XTrig];
end
Trig=Trig(1:length(Xl));

%Normalize Amplitude
Max=max(max(abs([Xl Xr])));
Y(1:2:2*length(Xl))=round(Xl*2^28);
Y(2:2:2*length(Xl))=round(Xr*2^28);
YT=floor(Trig*(2^31-1));

%Opening Output Files
TempFile=[outfile '.raw'];
fidtemp=fopen(TempFile,'wb');
TempFileTrig=[outfile 'Trig.raw'];
fidtrig=fopen(TempFileTrig,'wb');

%Writing Output Data
fwrite(fidtrig,YT,'int32');
fwrite(fidtemp,Y,'int32');
fclose all;

%Using SOX to convert to WAV File
f=['!sox -r ' int2str(Fs) ' -c 2 -4 -s ' TempFile ' -4 -f ' outfile '.wav' ];
f2=['!sox -r ' int2str(Fs) ' -c 1 -4 -s ' TempFileTrig ' -4 -f ' outfile 'Trig.wav' ];
%f=['!sox -r ' int2str(Fs) ' -c 4 -l -s ' TempFileTrig ' -l ' outfile 'Trig.wav' ];
eval(f);
eval(f2);