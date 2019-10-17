%
%function [FTC] = ntc2ftc(dtcfile,MinT,MaxT,att)
%
%	FILE NAME   : FTC RESPONSE
%	DESCRIPTION : Converts a DTC to an FTC data structure
%
%	dtcfile     : DTC File
%	MinT        : Minimum delay to measure response (msec)
%	MaxT        : Maximum delay to measure response (msec)
%	att         : External attenuation setting (Default=0)
%
% RETURNED DATA
%
%	FTC         : Tunning Curve Data Structure
%
%                   FTC.Freq                - Frequency Axis
%                   FTC.Level               - Sound Level Axis (dB)
%                   FTC.data                - Data matrix
%
% (C) Monty A. Escabi, April 11, 2005
%
function [FTC] = ntc2ftc(dtcfile,MinT,MaxT,att)

%Input Arguments
if nargin<4
    att=0;
end

%Opening Input File
fid = fopen(dtcfile, 'r', 'a');

%Reading Data
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

%Frequency and SPL axis
faxis=fMin*2.^(nOctaves*(0:44)/44);%
spl=[2.5:(75/14):77.5]+32.5-att; %

%Data in Latency Format
latencies = zeros(lengthL,3);
numSpikes = 0;
for ampl = 1:NAMPS                  %Outermost loop goes through amplitudes
  index = index + 180;              %Jumps over blank rows
  for freq = 1:NFREQS,              %Inner for-loop goes through frequencies
    while L(index) > 0,
       numSpikes = numSpikes+1;
       latencies(numSpikes,:) = [L(index)/30 freq ampl]; %30 being the sampling rate/1000
       index = index + 1;
    end	
    index = index + 4;              %Jumps past place-holder (01) and spike
                                    %Number, to next spike latency info
    end
  end
latencies = latencies(1:numSpikes,:);

%Sort data according to latency
[y ii] = sort(latencies(:,1));
latencies = latencies(ii,:);

%Generating FTC Matrix
index=find(latencies(:,1)>MinT & latencies(:,1)<MaxT);
FTC=zeros(length(faxis),length(spl));
latencies(:,3)=75/14*(latencies(:,3)-1)+35-att;
for k=1:length(index)
    
    m=min(find(faxis>=latencies(k,2)));
    n=min(find(spl>=latencies(k,3)));
    FTC(m,n)=FTC(m,n)+1;
    
end

%Converting to FTC Data Structure
FTC.data=FTC;
FTC.Freq=faxis;
FTC.Level=spl;