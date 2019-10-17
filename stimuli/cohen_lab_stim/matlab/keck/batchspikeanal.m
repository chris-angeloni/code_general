%
%function []=batchspikeanal(BatchFile,Fsd,T,TC,df,p,T1,T2,L,Disp)
%
%       FILE NAME       : BATCH SPIKE ANAL
%       DESCRIPTION     : Computes the X-Correlation , Fano Factor, and PSD, IETH of all
%                         'RF' and 'SPO' SPET Files in a Directory
%
%	BatchFile	: Contains Experiment Data for all Sounds
%			  Presentations
%	Fsd		: Sampling Rate for R(T), PSD(W), FF(T), and IETH
%	T		: X-Correlation Temporal Lag (sec) and Time for IETH
%	TC		: Post Spike Conditioned Spike Histogram Time Width ( sec )
%	df		: Frequency Resolution for PSD
%	p		: Significance Probability for PSD
%	T1		: Smallest Fano Factor counting window size (sec)
%			  Note: T1 >= 1/Fsd
%	T2		: Maximum Fano Factor counting window size (sec)
%	L		: Number of Fano Factor Samples
%	Disp		: Display : Optional : Default = 'n'
%
%	Batch File should be tab delimited and arranged colum-wise 
%	with the Following information
%
%	tapenum	filenum	SPL	MdB	Sound	SModType  Experiment
%-----------------------------------------------------------------
%Eg.	3	23	60	30	RN	dB	    RF
%	4	12	50	30	MR	lin	    RF
%	2	23	40	40	MR		    PRE
%	5	12	55		RN		    ALL
%	4	15	50				    TC
%	4	17					    BAD
%
function []=batchspikeanal(BatchFile,Fsd,T,TC,df,p,T1,T2,L,Disp)

%Preliminaries
more off

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

	%Checking for RF and SPO Files only
	if length(tabindex)==6 & ( ~isempty(findstr('RF',Param(7,:))) |  ~isempty(findstr('SPO',Param(7,:))) )
			index=find(Param(1,1:2)~=32);
			TapeNum=setstr(Param(1,index));
			index=find(Param(2,1:2)~=32);
			FileNum=setstr(Param(2,index));
			if str2num(FileNum) >= 10
				f=['ls *t' TapeNum '*f' FileNum '*ch*.mat'];
			else
				f=['ls *t' TapeNum '*f0' FileNum '*ch*.mat'];
			end

			[s,SpkList]=unix(f);
			SpkList=[10 SpkList 10];
			rindex=find(SpkList==10);
			for j=1:length(rindex)-1
				filename=SpkList(rindex(j)+1:rindex(j+1)-1);
				if ~isempty(findstr(filename,'.mat')) & isempty(findstr(filename,'Pre')) & isempty(findstr(filename,'SpkA')) & isempty(findstr(filename,'RTFHist')) &  isempty(findstr(filename,'_u')) 

					%Generating Spike Analysis File
					spikeanalfile(filename,Fsd,T,TC,df,p,T1,T2,L,Disp);

				end
			end
	end

end
