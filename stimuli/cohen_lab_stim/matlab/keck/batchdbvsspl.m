%
%function []=batchdbvsspl(BatchFile,Fsd,Fsdx,Ncopy,T,ZeroBin)
%
%       FILE NAME       : BATCH DB VS SPL
%       DESCRIPTION     : Batch Mode dB vs. SPL Sensitivity Function Generator
%			  and dB vs. SPL X-Correlation Generator
%
%	BatchFile	: Contains Experiment Data for all Sounds
%			  Presentations
%	Fsd		: Sampling Rate for Var and Mean Estimates
%	Fsdx		: Sampling Rate for dB vs. SPL X-Correlation 
%	Ncopy		: Number of copies used in 'float2wavdbvsspl'
%	T		: Maximum Temporal Lag for X-Correlation (sec)
%	ZeroBin		: Fix Zeroth Bin for dB vs. SPL X-Correlation
%			  Default : 'n'
%
%	Batch File should be tab delimited and arranged colum-wise 
%	with the Following information
%
%	tapenum	filenum	SPL	MdB	Sound	SModType  Experiment
%-----------------------------------------------------------------
%Eg.	3	23	60	30	RN	dB	    RF
%	4	12	50	30	MR	lin	    RF
%	2	23	40	40	MR		    PRE
%	5	12     [70 60 50 40 30]	RN		    ALL
%	4	15	50				    TC
%	4	17					    BAD
%
function []=batchdbvsspl(BatchFile,Fsd,Fsdx,Ncopy,T,ZeroBin)

%Preliminaries
more off
if nargin<6
	ZeroBin='n';
end

%Getting Batch Data
ch=setstr(39);
fid=fopen(BatchFile);
List=fread(fid,inf,'uchar')';
List=[10 List 10];
returnindex=find(List==10);
for l=1:length(returnindex)-1
	CurrentList=List(returnindex(l)+1:returnindex(l+1)-1);
	tabindex=find(CurrentList==9);
	Param=setstr(ones(7,5)*32);
	if length(tabindex)==6
		for k=1:7
			if k==1
				n=1:tabindex(k)-1;
				Param(k,n)=CurrentList(n);
			elseif k==7
				n=tabindex(k-1):length(CurrentList);
				Param(k,1:length(n))=CurrentList(n);
			else
				n=tabindex(k-1)+1:tabindex(k)-1;
				Param(k,1:length(n))=CurrentList(n);
			end
		end
	end

	if length(tabindex)==6 & ~isempty(findstr('ALL',Param(7,:)))
			index=find(Param(1,1:2)~=32);
			TapeNum=setstr(Param(1,index));
			index=find(Param(2,1:2)~=32);
			FileNum=setstr(Param(2,index));
			SPL=str2num(setstr(Param(3,:)));
			if str2num(FileNum) >= 10
				f=['ls *t' TapeNum '*f' FileNum '*ch*.mat'];
			else
				f=['ls *t' TapeNum '*f0' FileNum '*ch*.mat'];
			end

			[s,AllList]=unix(f);
			AllList=[10 AllList 10];
			rindex=find(AllList==10);
			for j=1:length(rindex)-1
				filename=AllList(rindex(j)+1:rindex(j+1)-1);
				if ~isempty(findstr(filename,'.mat')) & isempty(findstr(filename,'Pre')) & isempty(findstr(filename,'SpkA')) & isempty(findstr(filename,'RTFHist')) &  isempty(findstr(filename,'_u'))

					%Displaying Output
					clc
					f=['Computing dB vs. SPL Sensitivity Fxn for : ' filename];
					disp(f);

					%Computing dB vs. SPL Sensitivity Function and 
					%dB vs. SPL X-Correlation 
					f=['dbvssplfile(''' filename ''',Fsd,Fsdx,SPL,Ncopy,T,''' ZeroBin ''');'];
					eval(f);
					pause(0)
				end
			end

	end

end
