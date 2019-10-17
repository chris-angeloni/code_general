function [y,Fs,Format]=wavread16(wavefile)
%WAVREA  Load Microsoft Windows 3.1 .WAV format sound files.
%   [y]=WREAD16(wavefile) loads a .WAV format file specified by "wavefile", 
%       returning the sampled data in variable "y". The .WAV extension 
%       in the filename is optional.
%
%   [y,Fs]=WREAD16(wavefile) loads a .WAV format file specified by  
%       "wavefile", returning the sampled data in variable "y" and the 
%       sample rate in variable "Fs".
%   
%   [y,Fs,Format]=WREAD16(wavefile) loads a .WAV format file specified by 
%       "wavefile",returning the sampled data in variable "y", the sample 
%       rate in variable "Fs", and the .WAV file format information in 
%       variable "Format". The format information is returned as a 6 element
%       vector with the following order:
%
%               Format(1)       Data format (always PCM) 
%               Format(2)       Number of channels
%               Format(3)       Sample Rate (Fs)
%               Format(4)       Average bytes per second (sampled)
%               Format(5)       Block alignment of data
%               Format(6)       Bits per sample
%
%  
% Note : WREAD16 loads 16 bit samples correctly both on PC's and Workstations, 
%        where the byte orderings differ. 

%       Copyright (c) 1984-94 by The MathWorks, Inc.
%       10:55PM  25/11/96 Modified by Ali Taylan Cemgil

if nargin~=1
        error('WREAD16 takes one argument, which is the name of the .WAV file');
end

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
        
        Format(1)=fread(fid,1,'ushort');       % PCM format 
        Format(2)=fread(fid,1,'ushort');       % 1 or 2 channel
        Fs=fread(fid,1,'ulong');               % samples per second
        Format(3)=Fs;               
        Format(4)=fread(fid,1,'ulong');        % average bytes per second
        Format(5)=fread(fid,1,'ushort');       % block alignment
        Format(6)=fread(fid,1,'ushort');       % bits per sample
        
        
        % read data sub-chunck
        header=fread(fid,4,'uchar');
        nsamples=fread(fid,1,'ulong');
        if Format(2)==1                         % Mono
          if Format(6)==8  
             y=fread(fid,nsamples,'uchar');     % 8 bit
             y=y-128;
          else
if strcmp(computer,'PCWIN'),
             y = fread(fid,nsamples/2,'int16');  % 16 bit
else
             y=fread(fid,nsamples,'uchar');  % 16 bit
             y = y(2:2:length(y))*256 +  y(1:2:length(y));
             indx = find(y>2^15);
             y(indx) = y(indx)-2^16;
end;
          end;
          
        elseif Format(2)==2                     % stereo
          if Format(6)==8
             y=fread(fid,nsamples,'uchar');     % 8 bit
             y=y-128;
          else
if strcmp(computer,'PCWIN'),
             y = fread(fid,nsamples/2,'int16');  % 16 bit
else
             y=fread(fid,nsamples,'uchar');  % 16 bit
             y = y(2:2:length(y))*256 +  y(1:2:length(y));
             indx = find(y>2^15);
             y(indx) = y(indx)-2^16;
end;
          end;  
          
          
          y=y';
          r1=y(1:2:(nsamples-1)/2);
          l1=y(2:2:nsamples/2);    

          y=[r1;l1];            
        
        end;            
            

        fclose(fid);
end     

 
if fid == -1
        error('Can''t open .WAV file for input!');
end;


