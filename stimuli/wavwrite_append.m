function wavwrite_append(s, fn, chunk_size, fs, nbits)

fid = [];
fmt = [];

if ~exist('chunk_size','var') || isempty(chunk_size)
    chunk_size = 1e6;
end

l = length(s);
n = floor(l / chunk_size);
last_chunk = l - (n * chunk_size); 

for i = 1:n + 1
    fprintf('\t\tWriting chunk %g/%g...\n',i,n+1);
    start_idx = (chunk_size * (i-1)) + 1;
    end_idx = start_idx + chunk_size - 1;
    switch(i)
        case 1
            write = 1;
        case n + 1
            write = 4;
            end_idx = l;
        otherwise
            write = 3;
    end
    [fid,fmt] = wavwriteStim(s(start_idx:end_idx,:),fs,nbits,fn,write,l,fid,fmt);
end




















function [fid, fmt] = wavwriteStim(y,Fs,nbits,wavefile, Start, SamplesTot, fid, fmt)
%WAVWRITE Write Microsoft WAVE (".wav") sound file.

%MODIFIED FOR THE STIMULUS PROGRAM WITH THE OPTION TO LEAVE THE FILE OPEN
%AND CONTINUE WRITING TO THE FILE 

%Start has 4 options: start file (do not close); start file and close;
%continue file (do not close); continue writing to file and close
%Samplestot gives the expected total number of samples

%   WAVWRITE(Y,FS,NBITS,WAVEFILE) writes data Y to a Windows WAVE
%   file specified by the file name WAVEFILE, with a sample rate
%   of FS Hz and with NBITS number of bits.  NBITS must be 8, 16,
%   24, or 32.  Stereo data should be specified as a matrix with two 
%   columns. For NBITS < 32, amplitude values outside the range 
%   [-1,+1] are clipped.
%
%
%   8-, 16-, and 24-bit files are type 1 integer PCM.  32-bit files 
%   are written as type 3 normalized floating point.
%
%   See also WAVREAD, AUWRITE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/05/06 15:55:23 $

%   D. Orofino, 11/95

% Parse inputs:
error(nargchk(2,8,nargin));
% If input is a vector, force it to be a column:
if ndims(y) > 2,
  error('MATLAB:wavwrite:invalidInputFormat','Data array cannot be an N-D array.');
end
if size(y,1)==1,
   y = y(:);
end

if (Start == 1) || (Start == 2)
    [samples, channels] = size(y);


    % Determine number of bytes in chunks
    % (not including pad bytes, if needed):
    % ----------------------------------
    %  'RIFF'           4 bytes
    %  size             4 bytes
    %  'WAVE'           4 bytes
    %  'fmt '           4 bytes
    %  size             4 bytes
    % <wave-format>     14 bytes
    % <format_specific> 2 bytes (PCM)
    %  'data'           4 bytes
    %  size             4 bytes
    % <wave-data>       N bytes
    % ----------------------------------
    bytes_per_sample = ceil(nbits/8);
    %total_samples    = samples * channels;
    
    total_samples    = SamplesTot * channels;
    total_bytes      = total_samples * bytes_per_sample;

    riff_cksize = 36+total_bytes;   % Don't include 'RIFF' or its size field
    fmt_cksize  = 16;               % Don't include 'fmt ' or its size field
    data_cksize = total_bytes;      % Don't include 'data' or its size field

    % Determine pad bytes:
    data_pad    = rem(data_cksize,2);
    riff_cksize = riff_cksize + data_pad; % + fmt_pad, always 0

    % Open file for output:
    fid = OpenWaveWrite(wavefile);

    % file is now open, wrap the rest of the calls
    % in a try catch so we can close the file if there is a failure
    try
        % Prepare basic chunk structure fields:
        ck=[]; ck.fid=fid; ck.filename = wavefile;

        % Write RIFF chunk:
        ck.ID   = 'RIFF';
        ck.Size = riff_cksize;
        write_ckinfo(ck);

        % Write WAVE subchunk:
        ck.ID   = 'WAVE';
        ck.Size = [];  % Indicate a subchunk (no chunk size)
        write_ckinfo(ck);

        % Write <fmt-ck>:
        ck.ID   = 'fmt ';
        ck.Size = fmt_cksize;
        write_ckinfo(ck);

        % Write <wave-format>:
        fmt.filename        = wavefile;
        if nbits == 32,
            fmt.wFormatTag  = 3;            % Data encoding format (1=PCM, 3=Type 3 32-bit)
        else
            fmt.wFormatTag  = 1;
        end
        fmt.nChannels       = channels;     % Number of channels
        fmt.nSamplesPerSec  = Fs;           % Samples per second
        fmt.nAvgBytesPerSec = channels*bytes_per_sample*Fs; % Avg transfer rate
        fmt.nBlockAlign     = channels*bytes_per_sample;    % Block alignment
        fmt.nBitsPerSample  = nbits;        % standard <PCM-format-specific> info
        write_wavefmt(fid,fmt);

        % Write <data-ck>:
        ck.ID   = 'data';
        ck.Size = data_cksize;
        write_ckinfo(ck);

        % Write <wave-data>, and its pad byte if needed:
        write_wavedat(fid,fmt,y);

        % Close file:
        %fclose(fid);
    catch
        fclose(fid);
        rethrow(lasterror);
    end
end
if (Start == 3) || (Start == 4)
    try
        write_wavedat(fid,fmt,y);
    catch
        fclose(fid);
        rethrow(lasterror);
    end
end
if (Start == 2) || (Start == 4)
    fclose(fid);
end

% end of wavwrite()


% ------------------------------------------------------------------------
% Private functions:
% ------------------------------------------------------------------------


% ------------------------------------------------------------------------
function [fid] = OpenWaveWrite(wavefile)
% OpenWaveWrite
%   Open WAV file for writing.
%   If filename does not contain an extension, add ".wav"

fid = [];
if ~ischar(wavefile),
   error('MATLAB:wavewrite:InvalidFileNameType', 'Wave file name must be a string.'); 
end
if isempty(findstr(wavefile,'.')),
  wavefile=[wavefile '.wav'];
end
% Open file, little-endian:
[fid,err] = fopen(wavefile,'wb','l');
if (fid == -1)
    error('MATLAB:wavewrite:unableToOpenFile', err );
end
return


% ------------------------------------------------------------------------
function write_ckinfo(ck)
% WRITE_CKINFO: Writes next RIFF chunk, but not the chunk data.
%   Assumes the following fields in ck:
%         .fid   File ID to an open file
%         .ID    4-character string chunk identifier
%         .Size  Size of chunk (empty if subchunk)
%
%
%   Expects an open FID pointing to first byte of chunk header,
%   and a chunk structure.
%   ck.fid, ck.ID, ck.Size, ck.Data

errMsg = ['Failed to write ' ck.ID ' chunk to WAVE file: ' ck.filename];
errMsgID = 'MATLAB:wavewrite:failedChunkInfoWrite';

if (fwrite(ck.fid, ck.ID, 'char') ~= 4),
   error(errmsgID,errmsg);
end

if ~isempty(ck.Size),
  % Write chunk size:
  if (fwrite(ck.fid, ck.Size, 'uint32') ~= 1),
     error(errMsgID, errMsg);
  end
end

return

% ------------------------------------------------------------------------
function write_wavefmt(fid, fmt)
% WRITE_WAVEFMT: Write WAVE format chunk.
%   Assumes fid points to the wave-format subchunk.
%   Requires chunk structure to be passed, indicating
%   the length of the chunk.

errMsg = ['Failed to write WAVE format chunk to file' fmt.filename];
errMsgID = 'MATLAB:wavewrite:failedWaveFmtWrite';

% Create <wave-format> data:
if (fwrite(fid, fmt.wFormatTag,      'uint16') ~= 1) | ...
   (fwrite(fid, fmt.nChannels,       'uint16') ~= 1) | ...
   (fwrite(fid, fmt.nSamplesPerSec,  'uint32' ) ~= 1) | ...
   (fwrite(fid, fmt.nAvgBytesPerSec, 'uint32' ) ~= 1) | ...
   (fwrite(fid, fmt.nBlockAlign,     'uint16') ~= 1),
   error(errMsgID,errMsg);
end

% Write format-specific info:
if fmt.wFormatTag==1 | fmt.wFormatTag==3,
  % Write standard <PCM-format-specific> info:
  if (fwrite(fid, fmt.nBitsPerSample, 'uint16') ~= 1),
     error(errMsgID,errMsg);
  end
  
else
  error('MATLAB:wavewrite:unknownDataFormat','Unknown data format.');
end

return


% -----------------------------------------------------------------------
function y = PCM_Quantize(x, fmt)
% PCM_Quantize:
%   Scale and quantize input data, from [-1, +1] range to
%   either an 8-, 16-, or 24-bit data range.

% Clip data to normalized range [-1,+1]:
ClipMsg  = ['Data clipped during write to file:' fmt.filename];
ClipMsgID = 'MATLAB:wavwrite:dataClipped';
ClipWarn = 0;

% Determine slope (m) and bias (b) for data scaling:
nbits = fmt.nBitsPerSample;
m = 2.^(nbits-1);

switch nbits
case 8,
   b=128;
case {16,24},
   b=0;
otherwise,
   error('MATLAB:wavwrite:invalidBitsPerSample','Invalid number of bits specified.');
end

y = round(m .* x + b);

% Determine quantized data limits, based on the
% presumed input data limits of [-1, +1]:
ylim = [-1 +1];
qlim = m * ylim + b;
qlim(2) = qlim(2)-1;

% Clip data to quantizer limits:
i = find(y < qlim(1));
if ~isempty(i),
   warning(ClipMsgID,ClipMsg); ClipWarn=1;
   y(i) = qlim(1);
end

i = find(y > qlim(2));
if ~isempty(i),
   if ~ClipWarn, warning(ClipMsgID,ClipMsg); end
   y(i) = qlim(2);
end

return


% -----------------------------------------------------------------------
function write_wavedat(fid,fmt,data)
% WRITE_WAVEDAT: Write WAVE data chunk
%   Assumes fid points to the wave-data chunk
%   Requires <wave-format> structure to be passed.

if fmt.wFormatTag==1 | fmt.wFormatTag==3,
   % PCM Format
   
   % 32-bit Type 3 is normalized, so no scaling needed.
   if fmt.nBitsPerSample ~= 32,
       data = PCM_Quantize(data, fmt);
   end
   
   switch fmt.nBitsPerSample
   case 8,
      dtype='uchar'; % unsigned 8-bit
   case 16,
      dtype='int16'; % signed 16-bit
   case 24,
	  dtype='bit24'; % signed 24-bit
   case 32,
      dtype='float'; % normalized 32-bit floating point
   otherwise,
      error('MATLAB:wavewrite:invalidBitsPerSample','Invalid number of bits specified.');
   end
   
   % Write data, one row at a time (one sample from each channel):
   [samples,channels] = size(data);
   total_samples = samples*channels;
   
   if (fwrite(fid, reshape(data',total_samples,1), dtype) ~= total_samples),
      error('MATLAB:wavewrite:failedToWriteSamples','Failed to write PCM data samples.');
   end
   
   % Determine # bytes/sample - format requires rounding
   %  to next integer number of bytes:
   BytesPerSample = ceil(fmt.nBitsPerSample/8);
   
   % Determine if a pad-byte must be appended to data chunk:
   if rem(total_samples*BytesPerSample, 2) ~= 0,
      fwrite(fid,0,'uchar');
   end
   
else
  % Unknown wave-format for data.
  error('MATLAB:wavewrite:unsupportedDataFormat','Unsupported data format.');
end

return

% end of wavwrite.m
