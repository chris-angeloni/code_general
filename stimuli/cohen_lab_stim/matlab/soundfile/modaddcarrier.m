%
%function []=modaddcarrier(filename,fc,Fs)
%
%   FILE NAME   : MOD ADD CARRIER
%   DESCRIPTION : Takes a RAW file as input (float) containing the envelope
%                 of a desired modulation signal. The signal is used to
%                 modulate a carrier of frequency fc. The output is saved
%                 and converted to a WAV file.
%
%   filename    : File containng the envelope signal
%   fc          : Carrier frequency (Hz)
%   Fs          : Sampling rate (Hz)
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, December 2010
%
function []=modaddcarrier(filename,fc,Fs)

%Loading Param File
%i=strfind(filename,'.raw');
%load([filename(1:i-1) '_Param.mat']);

%Opening Input/Output File
fidin=fopen(filename);
i=strfind(filename,'.raw');
outfile=[filename(1:i-1) ];
fidout=fopen([outfile 'Temp.raw'],'wb');

%Adding Carrier
M=Fs*32;
count=0;
while ~feof(fidin)
    %Display Progress
    clc
    %disp(['Percent Done: ' num2str(100*((count+1)*M)/(length(FM)*(T+Tpause)*Fs),3) ' %'])
    disp(['Block Number: ' num2str(count+1) ])
    
    %Adding Carrier
    X=fread(fidin,M,'float')';
    X=X.*sin(2*pi*fc*(count*M+(1:length(X)))/Fs);
    count=count+1;
    
    %For visualization
    %[FM(count) BW(count)]
    %psd(X,1024*32,96000),axis([500 1500 -40 10])
    %set(gca,'Xtick',1000+[16 32 64 128 256])
    %pause
    
    %Saving To File
    fwrite(fidout,X,'float');
end

%Closing Files
fclose all;

%Using SOX to convert to WAV File
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 1 -f -4 ' outfile 'Temp.raw ' outfile '.wav gain -6' ];
eval(f);

%Removing Temporary Files
%!rm *Temp.raw