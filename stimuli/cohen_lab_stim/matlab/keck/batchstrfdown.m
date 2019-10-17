%
%function []=batchstrfdown(LT,LF,dirpath)
%
%       FILE NAME       : BATCH STRF DOWN
%       DESCRIPTION     : Down samples all STRF files in a directory
%
%	LT		: Temporal down sampling factor
%	LF		: Spectral down sampling factor
%	dirpath		: Directory path to store files
%
function []=batchstrfdown(LT,LF,dirpath)

%Preliminaries
more off

%Generating a File List
f=['ls *Lin.mat *dB.mat'];
[s,List]=unix(f);
List=[setstr(10) List setstr(10)];
returnindex=findstr(List,setstr(10));
for l=1:length(returnindex)-1
	for k=1:30
		if k+returnindex(l)<returnindex(l+1)
			Lst(l,k)=List(returnindex(l)+k);
		else
			Lst(l,k)=setstr(32);
		end
	end
end


%Batching STRF2RTFFILE
for k=1:size(Lst,1)
	index=findstr(Lst(k,:),'.mat');
	infile=[ Lst(k,1:index-1) '.mat'];
	outfile=[dirpath '/' infile];
	if exist(infile)

		%Down sampling STRF File
		strfdownsamf(infile,outfile,LT,LF);

		%Display
		disp(['Downsampling and saving: ' infile])
   
	end
end
