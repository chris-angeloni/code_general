function []=dtc2ntc(infile,datfile,chnl)
%	FUNCTION DTC2NTC
%	
%	DESCRIPTION:	Converts .dtc files to the matlab-friendly ntc.mat files.
%			Also converts the dtc filename to the corresponding dat
%			filename, including a channel number (manually set to
%			the corresponding dat channel), a 'fake' unit designation u1
%			(for use with ntcplot), and the ntc.mat extention.
%			This is basically a slimmed-down version of ncondtc.m.
%	infile:		The dtc file to be converted.
%	datfile:	A STRING to be used in the filename, eg 't2f13'
%	chnl:		the corresp. dat channel number, manually set.
%
%
%		[]=dtc2ntc(infile,datfile,chnl);

%  reads .dtc tuning curve file (filename)
%  writes to file
%           latencies - nx3 matrix
%                            column 1 - spike latency
%                            column 2 - stimulus frequency index
%                            column 3 - stimulus amplitude index
%           header       - 70-byte character string from dtc file legend
%           fMin    	- array of stimulus frequencies
%           nOctaves         - array of stimulus amplitudes


fid = fopen(infile, 'r', 'a');

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
       latencies(numSpikes,:) = [L(index)/30 freq ampl]; %30 being the sampling rate/1000
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

index = findstr(infile,'.');
outfile = [infile(1:index-4) '_' datfile 'M_ch' num2str(chnl) '_u1_ntc.mat'];	%M for multi-unit

eval(['save ' outfile ' latencies header fMin nOctaves ']);

dispstr = ['Saved ' outfile '.'];
disp(dispstr);
