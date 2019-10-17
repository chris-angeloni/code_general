%
%function  []=batchcohereall(Header,df,NW,N,flag)
%
%DESCRIPTION: Batch file to analyze periodogram and multi-taper coherence.
%             Requires that the data is saved as two matlab files using the
%             continuous and blocked data format. Program searches for the
%             followign file names:
%
%               HEADER_DataAll.mat
%               HEADER_BlockDataAll.mat
%
%             The program then saves all of the analyzed data.
%
%   Header  : Data header
%   df		: Spectral Resolution in Hz for periodogram Coherence
%   NW      : Number of tapers%   N       : Number of bootstraps
%   flag    : Significance criterion
%             1: Fixed Threshold (Default)
%             2: Frequency Dependent Threshold
%
%RETURNED VARIABLES
%
%Monty A. Escabi, Jan 2007
%
function  []=batchcohereall(Header,df,NW,N,flag)

%Loadin Continuous Data
f=['load ' Header '_DataAll.mat'];
eval(f)

%Data Channels
chan1=1:length(Data);
chan2=1:length(Data);

%Computing Periodogram and Multi-Taper Coherence
[AnalData.C]=ncscohere(Data,chan1,chan2,df);
[AnalData.CMT]=ncsmtcohere(Data,chan1,chan2,NW);
[AnalData.Cs]=ncscohereshuffle(Data,chan1,chan2,df,N,flag);
[AnalData.CMTs]=ncsmtcohereshuffle(Data,chan1,chan2,NW,N,flag);

%Saving Data Before Area Analysis in case of CRASH
f=['save ' Header '_AnalDataAll AnalData'];
eval(f)

%Computing Areas for relevant frequency ranges
AnalData.Area4to12=ncscoherearea(AnalData.C, AnalData.Cs, 4, 12);
AnalData.Area6to10=ncscoherearea(AnalData.C, AnalData.Cs, 6, 10);
AnalData.Area16to30=ncscoherearea(AnalData.C, AnalData.Cs, 16, 30);
AnalData.Area31to50=ncscoherearea(AnalData.C, AnalData.Cs, 31, 50);
AnalData.Area51to70=ncscoherearea(AnalData.C, AnalData.Cs, 51, 70);
AnalData.Area71to90=ncscoherearea(AnalData.C, AnalData.Cs, 71, 90);
AnalData.Area91to110=ncscoherearea(AnalData.C, AnalData.Cs, 91, 110);
AnalData.Area40to110=ncscoherearea(AnalData.C, AnalData.Cs, 40, 110);

%Computing Areas for relevant frequency ranges using Multi-Tapers
AnalData.AreaMT4to12=ncscoherearea(AnalData.CMT, AnalData.CMTs, 4, 12);
AnalData.AreaMT6to10=ncscoherearea(AnalData.CMT, AnalData.CMTs, 6, 10);
AnalData.AreaMT16to30=ncscoherearea(AnalData.CMT, AnalData.CMTs, 16, 30);
AnalData.AreaMT31to50=ncscoherearea(AnalData.CMT, AnalData.CMTs, 31, 50);
AnalData.AreaMT51to70=ncscoherearea(AnalData.CMT, AnalData.CMTs, 51, 70);
AnalData.AreaMT71to90=ncscoherearea(AnalData.CMT, AnalData.CMTs, 71, 90);
AnalData.AreaMT91to110=ncscoherearea(AnalData.CMT, AnalData.CMTs, 91, 110);
AnalData.AreaMT40to110=ncscoherearea(AnalData.CMT, AnalData.CMTs, 40, 110);

%Saving Data
f=['save ' Header '_AnalDataAll AnalData'];
eval(f)


%Loadin Blocked Data
f=['load ' Header '_BlockDataAll.mat'];
eval(f)

%Computing Periodogram and Multi-Taper Coherence
[AnalData.CB]=ncscohereblock(Data,chan1,chan2,df);
[AnalData.CMTB]=ncsmtcohereblock(Data,chan1,chan2,NW);
[AnalData.CBs]=ncscohereblockshuffle(Data,chan1,chan2,df,N,flag);
[AnalData.CMTBs]=ncsmtcohereblockshuffle(Data,chan1,chan2,NW,N,flag);

%Saving Data Before Area Analysis in case of CRASH
f=['save ' Header '_AnalBlockDataAll AnalData'];
eval(f)

%Computing Areas for relevant frequency ranges
AnalData.AreaB4to12=ncscoherearea(AnalData.CB, AnalData.CBs, 4, 12);
AnalData.AreaB6to10=ncscoherearea(AnalData.CB, AnalData.CBs, 6, 10);
AnalData.AreaB16to30=ncscoherearea(AnalData.CB, AnalData.CBs, 16, 30);
AnalData.AreaB31to50=ncscoherearea(AnalData.CB, AnalData.CBs, 31, 50);
AnalData.AreaB51to70=ncscoherearea(AnalData.CB, AnalData.CBs, 51, 70);
AnalData.AreaB71to90=ncscoherearea(AnalData.CB, AnalData.CBs, 71, 90);
AnalData.AreaB91to110=ncscoherearea(AnalData.CB, AnalData.CBs, 91, 110);
AnalData.AreaB40to110=ncscoherearea(AnalData.CB, AnalData.CBs, 40, 110);

%Computing Areas for relevant frequency ranges using Multi-Tapers
AnalData.AreaMTB4to12=ncscoherearea(AnalData.CMTB, AnalData.CMTBs, 4, 12);
AnalData.AreaMTB6to10=ncscoherearea(AnalData.CMTB, AnalData.CMTBs, 6, 10);
AnalData.AreaMTB16to30=ncscoherearea(AnalData.CMTB, AnalData.CMTBs, 16, 30);
AnalData.AreaMTB31to50=ncscoherearea(AnalData.CMTB, AnalData.CMTBs, 31, 50);
AnalData.AreaMTB51to70=ncscoherearea(AnalData.CMTB, AnalData.CMTBs, 51, 70);
AnalData.AreaMTB71to90=ncscoherearea(AnalData.CMTB, AnalData.CMTBs, 71, 90);
AnalData.AreaMTB91to110=ncscoherearea(AnalData.CMTB, AnalData.CMTBs, 91, 110);
AnalData.AreaMTB40to110=ncscoherearea(AnalData.CMTB, AnalData.CMTBs, 40, 110);

%Saving Data
f=['save ' Header '_AnalBlockDataAll AnalData'];
eval(f)