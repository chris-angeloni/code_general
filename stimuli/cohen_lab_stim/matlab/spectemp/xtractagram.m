%
%function [ste]=xtractagram(header,N1,N2)
%
%       FILE NAME       : XTRACT AGRAM
%       DESCRIPTION     : Xtracts a segment of the audiogram (.ste) starting
%			  at sample N1 and ending at sample N2
%
%	header		: File name header
%	N1		: Lower temporal sample 
%	N2		: Upper temporal sample
%
%RETURNED VALUES
%
%	ste		: Spectro-temporal envelope matrix
%			  returns -1 upon failure or EOF
%
function [ste]=xtractagram(header,N1,N2)

%Generating a File List
f=['ls '  header '*.ste' ];
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

%Generating STE
count=1;
for k=1:size(Lst,1)
        index=findstr(Lst(k,:),'.ste');
        filename=[ Lst(k,1:index-1) '.ste'];
        if exist(filename)
		fid=fopen(filename,'r');
		status2=fseek(fid,N1*4+1,-1);	%Check 2 sample into future
		status=fseek(fid,N1*4,-1);
		if status2~=-1 & ~feof(fid)
			ste(count,:)=fread(fid,N2-N1+1,'float')';	
			fclose(fid);
			count=count+1;
		end
        end
end

if ~exist('ste','var')
	ste=-1;
end

