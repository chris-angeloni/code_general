%
%function []=mtfmodaddcarrierioffbf(filename,f1,f2)
%
%   FILE NAME   : MTF MOD ADD CARRIER OFF BF
%   DESCRIPTION : Takes two RAW file as input (int32) containing the
%                 envelopes of the desired modulation signals. The signals
%                 are then used to modulate a carrier of frequency f1 and 
%                 an adjacent frequency F2. The output is saved
%                 and converted to a WAV file.
%
%   filename    : File HEADER containng the envelope signal for the BF envelope
%   f1          : BF carrier frequency (Hz)
%   f2          : Off BF carrier frequency (Hz)
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, December 2010
%
function []=mtfmodaddcarrieroffbf(filename,f1,f2)

%Loading Param File
load([filename '_Param.mat']);

%Opening Input/Output File
fidin1=fopen([filename '1.raw']);
fidin2=fopen([filename '2.raw']);
fidout=fopen([filename 'Temp.raw'],'wb');

%Adding Carrier
if ~exist('Fs')
    Fs=SoundParam.Fs;
end
M=Fs*32;
count=0;
while ~feof(fidin1)
    %Display Progress
    clc
    disp(['Percent Done: ' num2str(100*count/SoundParam.L,3) ' %'])
    
    %Adding Carrier    
    X1=fread(fidin1,M,'float32')';
    X1=X1.*sin(2*pi*f1*(count*M+(1:length(X1)))/Fs);
    X2=fread(fidin2,M,'float32')';
    X2=X2.*sin(2*pi*f2*(count*M+(1:length(X2)))/Fs);
    X=(X1+X2)/2;
    count=count+1;
    
    %For visualization
    %[FM(count) BW(count)]
    %psd(X,1024*32,96000),axis([500 1500 -40 10])
    %set(gca,'Xtick',1000+[16 32 64 128 256])
    %pause
    
    %Saving To File
    fwrite(fidout,X,'float32');
end

%Closing Files
fclose all;

%Using SOX to convert to WAV File
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 1 -f -4 ' filename 'Temp.raw ' filename '.wav gain -12' ];
eval(f);

%Removing Temporary Files
%!rm *Temp.raw