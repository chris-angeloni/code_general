%
%function []=comodenvelopefile(FileHeader,Fm,Beta,M,EnvType,Fs,rt,p,seed)
%
%       FILE NAME       : COMOD ENVELOPE FILE
%       DESCRIPTION     : Generates an envelope used to modulation
%                         electrical stimulation signals. Three types of
%                         commodulation signals can be generated. 
%
%       FileHeader      : File name header (No extension)
%       Fm              : Modulation freq. or Max Modulation Freq. (Hz)
%       Beta            : Modulation index (0 - 1)
%       M               : Number of samples
%       EnvType         : Envelope type ('mls', 'sin' or 'sqr')
%                           'mls' - maximum length sequence
%                           'sin' - sinusoid
%                           'sqr' - square wave
%       Fs              : Sampling Rate (Hz, Default=12207.03125)
%       rt              : Rise time for 'sqr' and 'mls' (ms, optional, 
%                         default==5). Not used for 'sin' option.
%       p               : Bslpline order for rise time (Default==5). Not
%                         used for 'sin' option
%       seed            : Seed for random number generator
%                         (Default = 0)
%        
%RETURNED VARIABLES
%
%       No returned values. Saves data to file.
%
% (C) Monty A. Escabi, Jan 2012
%
function []=comodenvelopefile(FileHeader,Fm,Beta,M,EnvType,Fs,rt,p,seed)

%Input Args
if nargin<7
    rt=5;
end
if nargin<8
    p=5;
end
if nargin<9
    seed=0;    
end

%Smoothing Window
rt=rt/1000;
W1=ones(1,round(rt*Fs/p));
W=ones(1,round(rt*Fs/p));
for k=1:p-1
	W=conv(W,W1);
end

%Generating Envelope
if strcmp(EnvType,'mls')
    UF=Fs/2/Fm;
    N=ceil(log2(M/UF));
    Ec=mls(N);
    Ec=round(interp1((0:length(Ec)-1),Ec,(0:1/UF:length(Ec)-1),'nearest'));
    Ec=(Ec(1:M)+1)*Beta/2+(1-Beta)/2;
    Ec=conv(Ec,W);
    Ec=Ec(1:M);
    Ec=Ec/max(Ec);
elseif strcmp(EnvType,'sqr')
    Ec=round(1/2-cos(2*pi*Fm*(1:M)/Fs)/2)*Beta+(1-Beta);
    Ec=conv(Ec,W);
    Ec=Ec(1:M);
    Ec=Ec/max(Ec);
else
    Ec=(1/2-cos(2*pi*Fm*(1:M)/Fs)/2)*Beta+(1-Beta);
end

%Parameters
Param.seed=seed;
Param.Fs=Fs;
Param.Fm=Fm;
Param.Beta=Beta;
Param.M=M;
Param.rt=rt;
Param.p=p;
Param.EnvType=EnvType;

%Saving Envelope to File
f=['save ' FileHeader 'Env Ec Param'];
eval(f)