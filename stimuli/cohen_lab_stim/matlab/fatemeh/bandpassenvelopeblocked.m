%
%function [E,Xa]=bandpassenvelopeblocked(X,f1,f2,fm,Fs,FiltType,M,N)
%
%   FILE NAME   : BANDPASS ENVELOPE BLOCKED
%   DESCRIPTION : Extracts the envelope of a signal within a band between
%                 f1 and f2. The modulations are limited to a frequency fm.
%                 Uses Overlap Save method to assure that there are no edge
%                 artifacts. See FILTFILE.m. The output is identical to
%                 BANDPASSENVELOPE but the routine is implemented in data
%                 blocks of size M.
%
%   X           : Input signal
%   f1          : Lower cutoff frequency of bandpass filter (Hz)
%   f2          : Upper cutoff frequency of bandpass filter (Hz)
%   fm          : Upper modulation frequency limit (Hz)
%   Fs          : Samping rate (Hz)
%   FiltType    : Filter type: b-spline ('b') or Kaiser ('k'). Default=='b'
%   M           : Block Size (Defaul=1024*128)
%   N           : Number of filter coefficients (2*N+1) used for the
%                 Hilbert Kernel (Optional, Default==1000)
%
%RETURNED OUTPUTS
%
%   E           : Bandlimited envelope
%   Xa          : Bandpass Filtered Signal
%
% (C) Monty A. Escabi, Jan 2016
%
function [E,Xa] = bandpassenvelopeblocked(X,f1,f2,fm,Fs,FiltType,M,N)

%Inputu Args
if nargin<6
    FiltType='b';
end
if nargin<7
   M=1024*128; 
end
if nargin<8
   N=1000; 
end

%Generating input and output filters
ATT=60;
TWa=0.25*(f2-f1);
TWb=0.25*fm;
Ha=bandpass(f1,f2,TWa,Fs,ATT,'n');
Na=(length(Ha)-1)/2;
if strcmp(FiltType,'k')
    Hb=lowpass(fm,TWb,Fs,ATT,'n');
else
    Hb=bsplinelowpass(fm,5,Fs);
end
Nb=(length(Hb)-1)/2;
Hb=Hb/sum(Hb);  %Normalized for unit DC gain

%Generate Temporary File
infile='XInputData.bin';
outfileXa='XaOutputData.bin';   %Contains bandpass filtered signal
outfileXh='XhOutputData.bin';   %Contains hilbert transform of Xa
outfileE='EOutputData.bin';     %Contains envelope signal
outfileEb='EbOutputData.bin';   %Contains filtered envelope signal
fid=fopen(infile,'wb');
fwrite(fid,X,'float');
fclose(fid);

%Bandpass filtering input
filtfile(infile,outfileXa,[],[],[],[],Fs,M,[],'float',Ha);

%Computing Envelope - to do this step we will compute the Hilbert
%transform by convolving the Hilbert Kernel with the input. We then
%generate the anlytic signal and its magnitude to estimate the Envelope.

%Generating Hilbert Kernel - there is a N+1 point group delay in the output
%that needs to be subtracted
n=-N:N;                                 %2*N+1 filter coefficients for Hilber Kernel
Hh=real([(1-(exp(j*pi*n)))./pi./n]);    %See Gold, Oppenheim, Rader - 1969 - Eqn. 24 defines the Hilbert Kernel
Hh(N+1)=0;
filtfile(outfileXa,outfileXh,[],[],[],[],Fs,M,[],'float',Hh);

%Computing Unfiltered Envelope
addfilemag(outfileXa,outfileXh,outfileE,'float',M);

%Lowpass filtering Envelope
filtfile(outfileE,outfileEb,[],[],[],[],Fs,M,[],'float',Hb);

%Reading Data
fid=fopen(outfileEb,'rb');
E=fread(fid,inf,'float')';
fclose(fid);
fid=fopen(outfileXa,'rb');
Xa=fread(fid,inf,'float')';
fclose(fid);

%Removing Temporary Files 
if isunix
    eval('!rm *InputData.bin *OutputData.bin')
end
if ispc
   eval('!del *InputData.bin *OutputData.bin') 
end