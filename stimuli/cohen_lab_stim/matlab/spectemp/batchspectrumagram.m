%
%function []=batchspectrumagram(faxis)
%
%	FILE NAME 	: BATCH SPECTRUM AGRAM
%	DESCRIPTION 	: Batch file which computes the average spectrum
%			  for all AUDIOGRAM (STE) files in a directory.
%			  Results are saved to file.
%	
%	M		: Data Block Size (Default==1024)
%	faxis		: Frequency axis for audigram data
%
function []=batchspectrumagram(M,faxis)

%Input Arguments
if nargin<1
	M=1024;
end

%Preliminaries
more off

%Generating a File List
f=['ls *_001.ste' ];
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

%Batching SPECTRUMAGRAM
for k=1:size(Lst,1)
	index=findstr(Lst(k,:),'_001.ste');
	header=[Lst(k,1:index-1)];
	outfile=[header '_STE_AGRAM.mat'];

		%Evaluating Spectrumagram and saving data to file
		[ASP]=spectrumagram(header,M); 

		%Saving Output File
		f=['save -v4 ' outfile ' ASP'];
		if nargin==2
			f=[f ' faxis'];
		end	
		disp(f)
		eval(f)

		plot(faxis,ASP)
		pause(0)
end
