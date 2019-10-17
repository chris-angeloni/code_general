%
%function  [Data]=readncs(filename)
%
%DESCRIPTION: Reads an NCS file and returns data as a data structure
%
%   filename    : Input file name
%
%Monty A. Escabi, Feb. 2004
%
function  [Data]=readncs(filename)

%Opening input file
fid=fopen(filename,'r');

%Reading Header
Header=(fread(fid,2*(1024*8),'char'))';
indexreturn=find(Header==10);
Header=setstr(Header);

%Extracting Sampling Frequency and AD Converter Parameters
	index1=findstr('-ADChannel',Header);
	index2=indexreturn(min(find(indexreturn>index1)));
Data.ADChannel=str2num(Header(index1+10:index2-1));
	index1=findstr('-ADGain',Header);
	index2=indexreturn(min(find(indexreturn>index1)));
Data.ADGain=str2num(Header(index1+7:index2-1));
	index1=findstr('-AmpGain',Header);
	index2=indexreturn(min(find(indexreturn>index1)));
Data.AmpGain=str2num(Header(index1+8:index2-1));
	index1=findstr('-AmpLowCut',Header);
	index2=indexreturn(min(find(indexreturn>index1)));
Data.AmpLowCut=str2num(Header(index1+10:index2-1));
	index1=findstr('-AmpHiCut',Header);
	index2=indexreturn(min(find(indexreturn>index1)));
Data.AmpHighCut=str2num(Header(index1+9:index2-1));
	index1=findstr('-SubSamplingInterleave',Header);
	index2=indexreturn(min(find(indexreturn>index1)));
Data.SubSamplingInterleave=str2num(Header(index1+23:index2-1));
	index1=findstr('-SamplingFrequency',Header);
	index2=indexreturn(min(find(indexreturn>index1)));
Data.Fs=str2num(Header(index1+18:index2-1));
	index1=findstr('-ADBitVolts',Header);
	index2=indexreturn(min(find(indexreturn>index1)));
Data.ADBitVolts=str2num(Header(index1+11:index2-1));
	index1=findstr('-ADMaxValue',Header);
	index2=indexreturn(min(find(indexreturn>index1)));
Data.ADMaxValue=str2num(Header(index1+11:index2-1));

%Extracting Header for First Data Block
Header=(fread(fid,10,'int16'))';

%Reading file Data
Data.X=[];
while ~feof(fid)

    Data.X=[Data.X fread(fid,Header(9),'int16')'];
    Header=fread(fid,10,'int16');

end
