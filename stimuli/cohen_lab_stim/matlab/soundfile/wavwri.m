function wavwri(waveData,sRate,res,nchannel,wavefile)
%WAVWRI Saves Microsoft Windows 3.1 .WAV format sound files.
%   WAVWRI(y,Fs,res,nchannel,wavefile) saves a .WAV format file
%   specified by "wavefile".
%
%   The input arguments for WAVWRITE are as follows:
%
%       y           The sampled data to save (16 bit max)
%       Fs          The rate at which the data was sampled
%       res         Resulution 8-, 16-bit, 24-bit, 32-bit
%       nchannel    Number of channels (1 or 2);
%       wavefile    A string containing the name of the .WAV file to create
%
%
%   Note: WAVWRI will create an res-bit, single channel wave file. Non 16-bit
%   sample data will be truncated.
%
%   See also WAVREA.


if nargin~=5
        error('WAVWRI needs five arguments!');
end

limit=max(max(abs(waveData)));             % Maximum wird berechnet

%if limit>=1                                % wenn limit>=1 wird normiert
  if res==8
     waveData=round(waveData/limit*(128));    % bei 8 bit
  elseif res==16
     waveData=round(waveData/limit*(32768));  % bei 16 bit
  elseif res==24
     waveData=round(waveData/limit*(2^23-1)); 
  elseif res==32
     waveData=round(waveData/limit*(2^31-1));  
end;
%end;

if isstr(waveData) %old symtax, reorder args
   tmp = waveData;
   waveData = wavefile;
   wavefile = sRate;
   sRate = tmp;
end


if isempty(findstr(wavefile,'.'))
        wavefile=[wavefile,'.wav'];
end

fid=fopen(wavefile,'wb','l');

if fid ~= -1
        [m,n]=size(waveData);
        nsamples=m*n;
        fac=res/8;

        riffsize=36+nsamples;

        % write riff chunk
        fwrite(fid,'RIFF','uchar');
        fwrite(fid,riffsize,'ulong');
        fwrite(fid,'WAVE','uchar');

        % write format sub-chunk
        fwrite(fid,'fmt ','uchar');
        fwrite(fid,16,'ulong');

        fwrite(fid,1,'ushort');         % PCM format
        fwrite(fid,nchannel,'ushort');  % 1 or 2 channel
        fwrite(fid,sRate,'ulong');      % samples per second
        fwrite(fid,fac*sRate*nchannel,'ulong');  % average bytes per second
        fwrite(fid,fac*nchannel,'ushort');       % block alignment
        fwrite(fid,fac*8,'ushort');     % bits per sample


        % write data sub-chunck
        fwrite(fid,'data','uchar');
        fwrite(fid,nsamples*fac,'ulong');
        
        if nchannel==2 waveData=waveData(:);  end;   % Wenn Stereo
    
          if fac==4
            fwrite(fid,waveData,'int32');   % 32 bit
          elseif fac==3
            fwrite(fid,waveData,'int24');   % 24 bit
          elseif fac==2
            fwrite(fid,waveData,'int16');   % 16 bit
          else
            fwrite(fid,waveData,'int8');    %  8 bit
          end;

    %    end;
        fclose(fid);
end;

if fid == -1
        error('Can''t open .WAV file for input!');
end;
