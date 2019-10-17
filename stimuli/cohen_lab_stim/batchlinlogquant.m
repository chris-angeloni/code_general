%function []=batchlinlogquant(filename,B,Tpause,L)
%
%       FILE NAME       : BATCH LIN LOG QUANT
%       DESCRIPTION     : Generates a WAV file that logarithmically and
%                         linearly quantizes the input sound. Wav file 
%                         has L repeats of all possible quantizer
%                         combinations interleaved in random order.
%
%                         Assumes int16 input signal with maximum 1024*32
%                         and minimum -1024*32 amplitudes.
%
%   filename            : Input file
%	B		            : Array of Quantization Bits for lin and log quantizer
%   Tpause              : Pause Time between adjacent sounds (sec)
%   L                   : Number of Trials
%
%RETURNED VARIABLES
%
%	NOTE: Requires SOX (Sound eXchange: http://sox.sourceforge.net/)
%
% (C) Monty A. Escabi, August 6 2004
%
function []=batchlinlogquant(filename,B,Tpause,L)

%Output File
N=find(filename=='.');
outfile=[filename(1:N-1) '_Quant'];
fid=fopen([outfile '.raw'],'w');

%Generating Randomized Qantization Sequence
%NOTE: QuantType=0 -> Linear Quantizer
%      QuantType=1 -> Log Quantizer
%
QuantType=[zeros(1,L*length(B)) ones(1,L*length(B))];
BB=[];
for k=1:L
	BB=[BB B B];
end
rand('state',0);
index=randperm(length(BB));
Bits=BB(index);
QuantType=QuantType(index);
f=['save ' outfile '_param.mat Bits QuantType'];
eval(f);

%Reading Input Data
[X,Fs]=wavread(filename);
X=round(X*1024*32);
X=[X' zeros(1,round(Tpause*Fs))];

%Generating Trigger
Trig=zeros(size(X));
Trig(1:8000)=round(1024*31*ones(1,8000));

%Generating Quantized Sound Sequence
for k=1:length(Bits)
    
    %Display Status
    clc
    disp(['Quantizing and Generating sound ' int2str(k) ' of ' int2str(length(Bits))])
    
    %Quantized Sounds
    seed=k;
    if QuantType(k)==1
        Y=lin2logquant(X,Bits(k),seed);
    elseif QuantType(k)==0
        Y=linquant(X,Bits(k),seed);
    end
    
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
%f=['!rm ' outfile '.raw'];
%eval(f)

%Closing All Files
fclose all
