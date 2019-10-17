%
%function []=spatiotemporalelectricalmultitrialfile(FileName,T)
%
%       FILE NAME       : SPATIO TEMPORAL ELECTRICAL MULTI TRIAL FILE
%       DESCRIPTION     : Spatio temporal electrical stimulation pattern
%                         repeated sequentially. The final size is
%                         identical to the file used to generate the
%                         repeated stimuli.
%
%       FileHeader      : File name header (No extension)
%       T               : Duration for repeated segment (sec)
%
% (C) Monty A. Escabi, Jan 2012
%
function []=spatiotemporalelectricalmultitrialfile(FileName,T)

%Loading Data
load(FileName);
i=strfind(FileName,'_Block');
FileHeader=[FileName(1:i-1) '_REPEAT'];

%Parameters
Fs=ParamList.Fs;
NB=ParamList.NB;
M=ParamList.M;
N=NB/2;         %Half the buffer size
L=M/N;          %Number of buffer segments
Mrepeat=N/floor(N/(T*Fs));      %Number of samples for repeated segment
Lrepeat=floor(N/(T*Fs));        %Number of repeated segments per buffer segment

%Segmenting repeated segmnents into stimulus blocks half the buffer size
Sr=[];
Er=[];
for k=1:Lrepeat
   Sr=[Sr S(:,1:Mrepeat)]; 
   Er=[Er E(:,1:Mrepeat)];
end
E=Er;
S=Sr;
ParamList.Mrepeat=Mrepeat;
ParamList.Lrepeat=Lrepeat;

%Saving to File
for l=1:L
   
    %Saving data for each block
    S=sparse(S);
    f=['save ' FileHeader '_Block' int2strconvert(l,4) ' S E ParamList' ];
    eval(f)
end