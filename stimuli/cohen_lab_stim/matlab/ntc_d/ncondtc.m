function [latencies, header, fMin, nOctaves] = ncondtc(filename);
% function [latencies, header, fMin, nOctaves] = ncondtc(filename);
%%%
%%% **** this function does not work properly -- it is here for historical ****
%%% **** reasons, to that old analyses can be compared with new analyses.  ****
%%%
%  reads .dtc tuning curve file (filename)
%  returns
%           latencies - nx3 matrix
%                            column 1 - spike latency
%                            column 2 - stimulus frequency index
%                            column 3 - stimulus amplitude index
%           header       - 70-byte character string from dtc file legend
%           frequency    - array of stimulus frequencies
%           amps         - array of stimulus amplitudes

% created 8/20/97 - B.Bonham
% modified:
%
%
%

%  (this was originally modified from condtc program of M.Kilgard and L.Miller)

%-------------------

global NFREQS NAMPS

INCLUDE_DEFS;

%-------------------

fid = fopen(filename, 'r', 'a');

H1 = fread(fid, 70, 'char');            % read file legend as 8 bit characters
H2 = fread(fid, 1, 'short');            % read the rest of header
H3 = fread(fid, 6, 'float');         	% fmin, octaves, fmax, ampl, window, flag
H4 = fread(fid, 2850, 'short');         % skip to start of latency data
[L, lengthL] = fread(fid, 'short');	% read latency data

status = fclose(fid);

fMin= H3(1);
nOctaves= H3(2);

header = sprintf('%c', H1(1:69));

index = 1;		        % index within array L, where latency data begins
lengthL = length(L);

NAMPS = 15;
NFREQS = 45;

latencies = zeros(lengthL,3);
numSpikes = 0;
for ampl = 1:NAMPS                 % outermost loop goes through amplitudes
  index = index + 180;          % jumps over blank rows
  for freq = 1:NFREQS,              % inner for-loop goes through frequencies
    while L(index) > 0,
      numSpikes = numSpikes+1;
      latencies(numSpikes,:) = [L(index)/SAMP_RATE freq ampl];
      index = index + 1;
      end	
    index = index + 4;          % jumps past place-holder (01) and spike
                                %   number, to next spike latency info
    end
  end
latencies = latencies(1:numSpikes,:);

% sort data according to latency
[y ii] = sort(latencies(:,1));
latencies = latencies(ii,:);

return

%-------------------------
