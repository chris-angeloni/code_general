%
%function []=ss2spetbatch(Fs,spkwave,dT,N,B,Dir)
%
%       FILE NAME       : SS 2 SPET BATCH
%       DESCRIPTION     : Converts all 'spk' files from Mark Kvale Spike Sorter
%			  in the working directory to matlab spet files
%
%	Fs		: Sampling Rate
%	spkwave		: Find the Spike Waveforms and Models
%			  'y' or 'n' (Default =='n')
%	dT		: Time Before and After Spike (Default = .002 sec)
%	N		: Number of Waveforms to Save ( Default = 25 ) from
%			  each block. RAW Files Must be present in Directory
%	B		: File Block Size used in 'xtractch'
%			  Optional : Default = 10 Megs
%	Dir		: Directory Path 
%			  Optional : Default = '.'
%
function []=ss2spetbatch(Fs,spkwave,dT,N,B,Dir)

%Preliminaries
more off

%Input Arguments
if nargin<2
	spkwave='n';
	dT=.002;
	N=25;	
	B=10;
	Dir='.';
elseif nargin<3
	dT=.002;
	N=25;	
	B=10;
	Dir='.';
elseif nargin<4
	N=25;	
	B=10;
	Dir='.';
elseif nargin<5
	B=10;
	Dir='.';
elseif nargin<6
	Dir='.';
end

%Changing directory if Necessary
[s,CurrentDir]=system('pwd');
if ~strcmp(Dir,'.')
	f=['cd ' Dir];
	eval(f);
end

%Finding files with 'spk' extension and 'b1'
List=dir('*b1.spk');
NList=size(List,1);

%Performing 'ss2spet' on all files
for k=1:NList

	%Running ss2spet
	filename=List(k).name;
	ss2spet(filename,Fs,B);

	%Finding Spike Waveforms if Desired - RAW Files Must be present
	ch=setstr(39);
	if strcmp(spkwave,'y')
		index=find(filename=='.');
		spetfile=[filename(1:index-4) '.mat'];
		rawfile=[filename(1:index-4) '_b1.raw'];
		spkwaveform(spetfile,rawfile,dT,N,B);
		f=['mdlspike(' ch filename  ch ')'];
		eval(f);
	end
end

%Returning to Current Directory
f=['cd ' CurrentDir];
eval(f);
