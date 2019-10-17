%function []=batchlin2logquant(filename,B,Tpause,L)
%
%       FILE NAME       : BATCH LIN 2 LOG QUAN
%       DESCRIPTION     : Generates a WAV file that logarithmically
%                         quantizes the input sound. 
%                         Assumes int16 input signal with maximu 1024*32
%                         and minimu - 1024*32 amplitudes.
%
%   filename            : Input file
%	B		            : Array of Quantization Bits for log quantizer
%   Tpause              : Pause Time between adjacent sounds
%   L                   : Number of Trials
%
%RETURNED VARIABLES
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, April 2004
%
function []=batchlin2logquant(filename,B,Tpause,L)

%Output File
N=find(filename=='.');
outfile=[filename(1:N-1) '_Quant'];
fid=fopen([outfile '.raw'],'w');

%Generating Randomized Qantization Sequence
BB=[];
for k=1:L
	BB=[BB B];
end
rand('state',0);
index=randperm(length(BB));
BB=BB(index);
f=['save ' outfile '_param.mat BB'];
eval(f);

%Reading Input Data
[X,Fs]=wavread(filename);
X=round(X*1024*32);
X=[X' zeros(1,round(Tpause*Fs))];

%Generating Trigger
Trig=zeros(size(X));
Trig(1:8000)=round(1024*31*ones(1,8000));

%Generating Quantized Sound Sequence
for k=1:length(BB)
    
    %Quantized Sounds
    Y=lin2logquant(X,BB(k));

    %Output Interlace Sound and Trigger
    YY(1:2:length(Y)*2)=Y;
    YY(2:2:length(Y)*2)=Trig;
    
    %Writing Output File
    fwrite(fid,YY,'int16');
end

%Converting to WAV file with SOX
%Using SOX to convert to WAV File
f=['!sox -r ' int2str(Fs) ' -c 2 -w -s ' outfile '.raw -w ' outfile '.wav' ];
eval(f)
%f=['!rm test.raw'];
%eval(f)

%Closing All Files
fclose all
