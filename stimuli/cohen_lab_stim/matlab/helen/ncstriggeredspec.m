%
% function [taxis,faxis,Spec] = ncstriggeredspec(filename,Trig,df,f1,f2)
%
%	FILE NAME 	: NCS TRIGGERED SPEC
%	DESCRIPTION : Generates a triggered average neuroanol spectrogram
%                 using behavioral events as triggeres
%
%   filename    : Data file name (WAV format)
%   Trig        : Trigger Times (sample number)
%   T1          : Delay before trigger (msec)
%   T2          : Delay after trigger (msec)
%   f1          : Lower Frequency (Hz)
%   f2          : Upper Frequency (Hz)
%   df          : Frequency Resolution (Hz)
%
% RETURNED DATA
%
%   faxis       : Frequency Axis
%
function [taxis,faxis,Spec] = ncstriggeredspec(filename,Trig,T1,T2,df,f1,f2)

%Reading Input Data File
[Y,Fs]=wavread(filename);

%Generating Event Triggered Spectrogram
N1=round(T1*Fs/1000);
N2=round(T2*Fs/1000);
N=length(Y);
Spec=[];
for k=1:length(Trig)
    if Trig(k)-N1>=1 & Trig(k)+N2<=N
    
        %Extracting Segment About Trigger
        YY=(Trig(k)-N1:Trig(k)+N2);
        
        %Computing Triggered Average Spectrogram
        [taxis,faxis,stft,M,Nt,Nf]=stfft(YY,Fs,df,2,2,'sinc',30,'chui');
        Spec=Spec+20*log10(abs(stft));
        
    end
end