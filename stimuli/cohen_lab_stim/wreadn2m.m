function [y, Fs, format]=wreadn2m(wavefile,offset,len)
%WREADN2M  Loads a portion of Microsoft Windows 3.1 .WAV format sound files.
%
%   [Y, Fs, format]=WREADN2M(wavefile,offset,len) loads a .WAV format file specified by 
%       "wavefile", returning the sampled data in Y and the 
%       .WAV file format information in variable "format" starting from offset'th sample reading LEN samples. 
%       The format information is returned as a 6 element vector with the 
%       following order:
%
%               format(1)       Data format (Only PCM for now is known). 
%               format(2)       Number of channels
%               format(3)       Sample Rate (Fs)
%               Format(4)       Average bytes per second (sampled)
%               Format(5)       Block alignment of data
%               format(6)       Bits per sample
%               
% Note : WREADN2M loads 16 bit samples correctly both on PC's and Workstations, 
%        where the byte orderings differ. 

%       Copyright (c) 1984-93 by The MathWorks, Inc.
%       10:35PM  25/11/96 Modified by Ali Taylan Cemgil

if nargin<3,
        error('Usage Example : [vivaldi ,format] = wreadn2m(''vivaldi'', 10000, 4*4096)');
end

if isempty(findstr(wavefile,'.'))
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

        format(1)=fread(fid,1,'ushort');                % Format 
        format(2)=fread(fid,1,'ushort');                % Channel
        format(3)=fread(fid,1,'ulong');                 % Samples per second
        Fs = format(3);
        header=fread(fid,1,'ulong');
        block=fread(fid,1,'ushort');
        format(4) = header;
        format(5) = block;
        format(6)=fread(fid,1,'ushort');                % Bits per sample

        % read data sub-chunck
        header=fread(fid,4,'uchar');
        nbyteforsamples=fread(fid,1,'ulong');

        nsamples=nbyteforsamples/block;
        if (offset+len) > nsamples, len = max(0,nsamples-offset); end;

        % Mono 8 bits
        if (format(6)+format(2) == 9)
          fseek(fid,offset,0);
          y = fread(fid,len,'uchar');
          y = y-128;
        end

        % Stereo 8 bits
        if (format(6)+format(2) == 10)
          fseek(fid,offset*2,0);
          y = fread(fid,[2,len],'char');
        end

        % Mono 16 bits
        if (format(6)+format(2) == 17)
            fseek(fid,offset*2,0);
	    y = fread(fid,len,'int16');  % 16 bit
        end

        % Stereo 16 bits
        if (format(6)+format(2) == 18)
            fseek(fid,offset*4,0);
	    y = fread(fid,[2,len],'int16');  % 16 bit
        end
end     

if fid == -1
        error('Can''t open .WAV file for input!');
end;
