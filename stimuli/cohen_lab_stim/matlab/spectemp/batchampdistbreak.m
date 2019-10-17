%
%function [BreakPoints]=batchampdistbreak()
%
%	FILE NAME 	: BATCH AMP DIST BREAK
%	DESCRIPTION 	: Manually find the edges (break) points of the 
%			  relevant segments of an amplitude distribution
%			  Segments are choosen sequentially
%
%RETUERNED VARIABLES
%
%	BreakPoints	: Array of Edge samples (in sample number) break points
%			  Sample locations are interleaved with 
%			  start and endpoints
%			  e.g., BreakPoints=[s1 e1 s2 e2 s3 e3]
%
function [BreakPoints]=batchampdistbreak()
 
%Generating a File List
f=['ls *Cont.mat' ];
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

%Batching AMPDISTBREAK
count=1;
for k=1:size(Lst,1)
        filename=Lst(k,:);
 
        if exist(filename)
		BreakPoints(count,:)=-9999*ones(1,10);
		f=['load ' filename]; 
		eval(f)
		[BP]=ampdistbreak(Time,Amp,PDist);
		BreakPoints(count,1:length(BP))=BP;
		count=count+1;
        end
end                                                                               



