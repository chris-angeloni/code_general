%
%function []=classbatcross(tapenum,filenum,chan,statefile,outfile)
%
%
%	FILE NAME       : CLASS BAT CROSS
%	DESCRIPTION     : Generates a Classification Batch file for Mark Kvale 
%			  Spike Sort Program 
%			  Sorts across multiple RAW Files with a Single State
%			  File
%
%	tapenum		: Tape Number of Files to Analyze
%	filenum		: Array of File Numbers to Classify
%	statefile	: State Files ( Optional )
%			  If States Files is present then calls 
%			  spikesort on the fly
%	chan		: Channel to SpikeSort
%			  Necessary when statefile is given
%	outfile		: Ouput batch file (Optional)
%			  Default: '/tmp/temp***.bat' where *** is a random number
%
function []=classbatcross(tapenum,filenum,chan,statefile,outfile)

%Input Arguments
if nargin<5
	outfile=['/tmp/temp' int2str(round(rand*1000)) '.bat'];
end

%Genrating Temporary File List
if exist('/tmp/filelist.bat')
	!rm /tmp/filelist.bat;
end
if filenum(1)<10
	f=['!ls *t' int2str(tapenum) '*f0' int2str(filenum(1)) '*.raw '];
else
	f=['!ls *t' int2str(tapenum) '*f'  int2str(filenum(1)) '*.raw '];
end
if length(filenum)>1
	for k=2:length(filenum)
		if filenum(k)<10
			f=[f '*t' int2str(tapenum),...
			 '*f0' int2str(filenum(k)) '*.raw '];
		else
			f=[f '*t' int2str(tapenum),...
			 '*f'  int2str(filenum(k)) '*.raw '];
		end		
	end
end
f=[f ' > /tmp/filelist.bat'];
eval(f);

%Opening Ouput File and File List
fidin=fopen('/tmp/filelist.bat');
fidout=fopen(outfile,'w');

%Loading File List
List=fread(fidin,inf,'uchar');
List=setstr(List');
List=[setstr(10) List setstr(10)];

%Finding Channel Numbers
chindex=findstr('ch',List);
spaceindex=findstr('_',List);
returnindex=findstr(setstr(10),List);
for k=1:length(chindex)
	index=find(spaceindex  > chindex(k));
	space=spaceindex(index(1));	
	channels(k)=str2num(List(chindex(k)+2:space-1));
end

%Finding Channels that are present
present=zeros(1,16);
for k=1:16
	if length(find(channels==k)) > 1
		present(k)=1;
	else
		present(k)=0;
	end
end
present=find(present==1);

%Checking 'chan' 
if ~isempty(statefile)
	present=chan;
end

%Writing Batch
for l=1:length(present)
	for k=1:length(returnindex)-1
		filename=List(returnindex(k)+1:returnindex(k+1)-1);
		dotindex=find(filename=='.');
		if length(findstr(filename,['ch' num2str(present(l))]))>=1
	
			%Command Line
			command=['classify ' filename ,...
			' ' filename(1:dotindex-1) '.spk ',...
			 filename(1:dotindex-1) '.mdl' setstr(10)];
	
			%Checking For State File
			if isempty(statefile)	
				fwrite(fidout,command,'uchar');
			else
				if exist(outfile)
					f=['!rm ' outfile];
					eval(f);
				end
				fidout=fopen(outfile,'w');
				fwrite(fidout,['recall_state ' statefile setstr(10)],'uchar');
				fwrite(fidout,command,'uchar');
				fclose(fidout);
				f=['!nice -19 SpikeSort -f ' outfile];	
				eval(f);
		end
		end
	end

	if isempty(statefile)
		fwrite(fidout,setstr(10),'uchar');
	end
end

%Closing all Files
fclose('all');

%Removing Outfile
f=['!rm ' outfile];
eval(f);
