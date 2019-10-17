function [latencies, header, fMin, nOctaves] = ncondtc2(filename);
% function [latencies, header, fMin, nOctaves] = ncondtc2(filename);

%  reads .dtc tuning curve file (filename)
%  returns
%           latencies - nx3 matrix
%                            column 1 - spike latency
%                            column 2 - stimulus frequency index
%                            column 3 - stimulus amplitude index
%           header    - 70-byte character string from dtc file legend
%           fMin      - minimum stimulus frequency
%           nOctaves  - number of octaves in stimulus frequency range

% created 7/20/98 - B.Bonham

INCLUDE_DEFS;

global NAMPS NFREQS

SIZEOFINT16 = 2;                  % size of int16 in bytes
TWO = 2;                          % to remind me I don't know why this is here

fid = fopen(filename, 'r', 'a');

H1 = fread(fid, 70, 'char');      % read file legend as 8 bit characters

% read the rest of header
H2 = fread(fid, 1, 'uint16');     % ProgMagic           
H3 = fread(fid, 6, 'float');      % fmin, octaves, fmax, ampl, window, flag
H4 = fread(fid, 80, 'uint16');    % the remainder of the header...

    Hst_s =  H4(74);              % step size in amplitudes
    Hday =   H4(76);              % file date information
    Hmonth = H4(77);
    Hyear =  H4(78);
    Hnrep =  H4(79);              % number of repetitions?
    Hnvar =  H4(80);              % number of variations?

    num_as = Hnvar/Hst_s;

% figure out how many bytes of rate data to read per stim
tpos = ftell(fid);          
rate_size1 = fread(fid, 2, 'uint32');  
fseek(fid, tpos, 'bof');

    a_size = rate_size1(2);
    numBytes = (4+4+a_size*4)*num_as;
    
rates_sizes = fread(fid, numBytes, 'uchar');  % read the rate data

mark = fread(fid, 12, 'uint8')';      % read the string '[Latencies]'
if sum(mark-[double('[Latencies]') 0]),
    warning('probable error reading file - missed string ''[Latencies]''');
  end % (if)

L = fread(fid, 'uint16');            % read the latency data

fclose(fid);

% --- done with file operations ---

% now decode the latency data

maxNumLats = length(L);
numlats = zeros(maxNumLats, 1);
latencies = zeros(maxNumLats, 3);

max_ra = Hnvar;
max_rf = a_size;
numSpikes=0;
index = 1;
for ampl=1:max_ra,
  for freq = 1:max_rf,
    numlatencies = L(index)-1;
    index = index+1;
    if numlatencies>0,
        numlats(numSpikes+1) = numlatencies;
        latencies(numSpikes+(1:numlatencies),:) = [L(index:(index+numlatencies-1)), ...
                        freq*ones(numlatencies,1), ampl*ones(numlatencies,1)];
        index = index+numlatencies;
        numSpikes = numSpikes+numlatencies;
      end % (if)
    index = index+1;     % skip marker for end of latencies for this stimulus
    end % (for)
  end % (for)

if (index-maxNumLats-1)~=0,
    warning('probable error reading file - latency records too long or short');
  end % (if)

numlats = numlats(1:numSpikes);        % take off the extra 0's at the end...
latencies = latencies(1:numSpikes,:)./(ones(numSpikes,1)*[SAMP_RATE TWO TWO]);

% sort data according to latency
[y ii] = sort(latencies(:,1));
latencies = latencies(ii,:);

fMin= H3(1);
nOctaves= H3(2);
header = sprintf('%c', H1(1:69));

NAMPS = 15;
NFREQS = 45;

return

% to decode the rate data by reading the file instead of reading a block...

for ii=1:num_as,
  a_rates(ii,:) = fread(fid, 4, 'uchar')';
  a_sizes(ii) = fread(fid, 1, 'uint32');
  ibuf = [ibuf, fread(fid, a_sizes(ii), 'uint16')];
  ilat = [ilat, fread(fid, a_sizes(ii), 'uint16')];
  end % (for)




