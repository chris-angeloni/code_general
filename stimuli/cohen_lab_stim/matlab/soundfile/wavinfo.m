function OutFormat=wavinfo(wavefile,action)
%WAVINFO   Get Information about Microsoft Windows 3.1 .WAV format sound files.
%
% Format = WAVEINFO(wavefile,<option>) shows information about a .WAV format 
%       file specified by "wavefile". The format information is returned 
%       as a 6 element vector with the following order:
%
%       Format(1)       Data format (always PCM) 
%       Format(2)       Number of channels
%       Format(3)       Sample Rate (Fs)
%       Format(4)       Average bytes per second (sampled)
%       Format(5)       Block alignment of data
%       Format(6)       Bits per sample
%       Format(7)       # of samples;
%
%       option = 'n' no print out. 
%
%       WAVINFO without any arguments opens a dialog 

%       Copyright (c) 1984-93 by The MathWorks, Inc.
%       11:17AM  21/09/94 Modified by Ali Taylan Cemgil
%
global wavdir
PATHNAME = '';

if nargin<1,
        if ~exist('wavdir') wavdir = '/disk2/cemgil/wav/'; end;
        cur = cd;
        cd(wavdir);     
        [FILENAME, PATHNAME] = uigetfile('*.wav', 'Open Wave File', 10 , 10);

        wavdir = PATHNAME(1:length(PATHNAME)-1);
        cd(cur);
        wavefile = [PATHNAME FILENAME];
end;

if nargin<2,
        action = '';
end;

if findstr(wavefile,'.')==[]
        wavefile=[wavefile,'.wav'];
end

fid=fopen(wavefile,'rb','l');
if fid ~= -1 
        % read riff chunk
        header=fread(fid,4,'uchar');
        header=fread(fid,1,'ulong');
        header=fread(fid,4,'uchar');
        
        % read format sub-chunk
        header=fread(fid,4,'uchar');
        header=fread(fid,1,'ulong');
        
        Format(1)=fread(fid,1,'ushort');                % PCM format 
        Format(2)=fread(fid,1,'ushort');                % 1 channel
        Fs=fread(fid,1,'ulong');        % samples per second
        Format(3)=Fs;
        Format(4)=fread(fid,1,'ulong'); % average bytes per second
        Format(5)=fread(fid,1,'ushort');                % block alignment
        Format(6)=fread(fid,1,'ushort');                % bits per sample
        
        % read data sub-chunck
        header=fread(fid,4,'uchar');
        nsamples=fread(fid,1,'ulong');
        Format(7)=nsamples;
        fclose(fid);
        if strcmp(action,''),
                disp(wavefile);
                formatstr = str2mat('PCM','<Unknown>','<Unknown>','<Unknown>','<Unknown>','CCITT-A','CCITT-mu');

                fprintf(1,'\nData Format       : %s\n',formatstr(Format(1),:));
                fprintf(1,'Size in .wav      : %d Bytes\n',Format(7));
                fprintf(1,'Size in MatLab    : %7.2f KBytes\n',8*Format(7)*8/(1024*Format(6)*Format(2)));
                fprintf(1,'Length            : %d Samples\n',Format(7)*8/(Format(6)*Format(2)));
                fprintf(1,'Time              : %5.2f Seconds\n',Format(7)*8/(Format(6)*Format(2)*Format(3)));
                fprintf(1,'Fs                : %d Hz\n',Format(3));
                fprintf(1,'Channels          : %d\n',Format(2));
                fprintf(1,'Average bytes/sec : %d\n',Format(4));
                fprintf(1,'Block Alignment   : %d\n',Format(5));
                fprintf(1,'Bits/Sample       : %d\n',Format(6));
        end;    
        if nargout > 0,
                OutFormat = Format;
        end
end     
if fid == -1
        error('Can''t open .WAV file for input!');
end;
