%
%function []=trigbatch(Fs,tapenum,filenum,chan,Ndouble,Ntrig,dir,M,Tresh,Trigfix)
%
%       FILE NAME       : TRIG BATCH
%       DESCRIPTION     : Converts all Trigger files in the working 
%			  directory into a sequence of Trigger Times
%			  and stores to a MATLAB file
%
%	Fs		: Sampling rate
%	tapenum		: Tape number
%	filenum		: Array of filenumbers
%	chan		: Array of Channels used for trigger data
%	Ndouble		: Number of blocks between double triggers
%	NTrig		: Number of Triggers in original sound file
%	dir		: Directory Path 
%			  Optional : Default = '.'
%       M               : Block Size
%                         Default: M==1024*256
%                         M must be Dyadic and < = 1024*1024
%       Tresh           : Threshhold : Normalized [.5 , 1]
%                         Default: Tresh==.75
%	Trigfix		: Fix the Triggers : 'y' or 'n'
%			  Default=='y'
%
function []=trigbatch(Fs,tapenum,filenum,chan,Ndouble,Ntrig,dir,M,Tresh,Trigfix)

%Preliminaries
more off

%Input Arguments
if nargin<7
	dir='.';
	M=1024*256;
	Tresh=.75;
	Trigfix='y';
elseif nargin<8
	M=1024*256;
        Tresh=.75;
	Trigfix='y';
elseif nargin<9
	Tresh=.75;
	Trigfix='y';
elseif nargin<10
	Trigfix='y';
end

%Changing directory if Necessary
[s,CurrentDir]=unix('pwd');
if ~strcmp(dir,'.')
	f=['cd ' dir];
	eval(f);
end

%Finding files with 'raw' extension, Tape Number, Trigger channel and File Number
f='';
if filenum(1)<10
	f=['ls *t' int2str(tapenum) '*f0' int2str(filenum(1)) '*ch' int2str(chan(1)) '*_b1.raw '];
else
	f=['ls *t' int2str(tapenum) '*f' int2str(filenum(1)) '*ch' int2str(chan(1)) '*_b1.raw '];
end
if length(chan)>1
	for l=2:length(chan)	
		if filenum(1)<10
			f=[f '*t' int2str(tapenum) '*f0'  int2str(filenum(1)) '*ch' int2str(chan(l)) '*_b1.raw '];
		else
			f=[f '*t' int2str(tapenum) '*f'  int2str(filenum(1)) '*ch' int2str(chan(l)) '*_b1.raw '];
		end
	end
end
if length(filenum)>1
	for k=2:length(filenum)
		for l=1:length(chan)
			if filenum(k)<10
				f=[f '*t' int2str(tapenum) '*f0' int2str(filenum(k)) '*ch' int2str(chan(l)) '*_b1.raw '];
			else
				f=[f '*t' int2str(tapenum) '*f' int2str(filenum(k)) '*ch' int2str(chan(l)) '*_b1.raw '];
			end
		end
	end
end
[s,List]=unix(f);
List=[setstr(10) List setstr(10)];
rawindex=findstr(List,'raw');
returnindex=findstr(List,setstr(10));

%Performing 'trigfind' on all files
for k=1:length(rawindex)

	%Finding all Files and Ruinning 'trigfind'
	index=find(rawindex(k) > returnindex);
	startindex=returnindex(index(length(index)))+1;
	filename=List(startindex:rawindex(k)+2);
	TrigTimes=trigfind(filename,Fs,M,Tresh);
	if ~isempty(TrigTimes) & strcmp(Trigfix,'y')
		Trig=trigfixstrf(TrigTimes,Ndouble,Ntrig);
	else
		Trig=TrigTimes;
	end

	%Saving TrigTimes to a MATLAB File
	dotindex=findstr(filename,'_ch');
	if strcmp(version,'4.2c')
		f=['save ' filename(1:dotindex-1) '_Trig Fs Trig TrigTimes'];
	else
		f=['save ' filename(1:dotindex-1) '_Trig Fs Trig TrigTimes -v4'];
	end
	eval(f);	

end

%Returning to Current Directory
f=['cd ' CurrentDir];
eval(f);
