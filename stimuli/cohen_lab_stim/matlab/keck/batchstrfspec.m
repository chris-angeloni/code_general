%
%function []=batchstrfspec(SpecFile,T1,T2,filenum,tapenum,SPL,p)
%
%       FILE NAME       : BATCH STRF SPEC
%       DESCRIPTION     : Batch Mode RTWSTRFSPEC
%			  Computes STRF on all files using Stimulus Spectrogram
%
%       SpecFile        : Spectral Profile File
%       T1, T2          : Evaluation delay interval for WSTRF(T,F)
%                         T E [ T1 , T2 ]
%	filenum		: Array of filenumbers to download
%	tapenum		: Tape number
%	SPL             : Array of Signal RMS Sound Pressure Level
%	p 		: Significance Probability
%
function []=batchstrfspec(SpecFile,T1,T2,filenum,tapenum,SPL,p)

%Preliminaries
more off

%tGenerating a File List
f=['ls ' ];
for k=1:length(filenum)
	if filenum(k)<10
		f=[f '*t' int2str(tapenum) 'f0' int2str(filenum(k)) '* ' ];
	else
		f=[f '*t' int2str(tapenum) 'f' int2str(filenum(k)) '* ' ];
	end
end
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

%Batching RTWSTRF
N=size(Lst);
N=N(1);
for k=1:length(filenum)
	
	%Finding Trigger File
	%File Number
	if filenum(k)<10
		fnum=['0' int2str(filenum(k))];
	else
		fnum=int2str(filenum(k));
	end
	for l=1:N
		%Trigger File
		if ~isempty( findstr('Trig',Lst(l,:)) ) & ~isempty( findstr(fnum,Lst(l,:)) )
			TrigFile=Lst(l,:);
		end
	end
	f=['load ' TrigFile];
	eval(f);
	disp(f);

	%Running RTWSTRF
	for l=1:N

		%File Number
		if filenum(k)<10
	                fnum=['0' int2str(filenum(k))];
        	else
               		fnum=int2str(filenum(k));
        	end

		if ~isempty( findstr('ch',Lst(l,:)) ) & ~isempty( findstr(fnum,Lst(l,:)) )

			%Loading Spet Data File
			clear spet*
			f=['load ' Lst(l,:)];
			eval(f);
			disp(f);

			%Finding All Non-Outlier spet
			count=-1;
			while exist(['spet' int2str(count+1)])
				count=count+1;
			end
			Nspet=(count+1)/2;

			%Running RTWSTRF on all non-outlier spet data
			for m=0:Nspet-1
				%Reasining 'spet' as generic variable
				f=['spet=spet' int2str(m) ';'];
				eval(f);

				%RTWSTRF
				Fss=Fs;
				[taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2]=rtwstrfspec(SpecFile,T1,T2,spet,Trig,Fss,SPL(k),200);

				%Performing Statistical Significance Test
		%		[STRF1s]=wstrfstat(STRF1,p,No1,Wo1,PP,MDB(k),ModType,Sound);
		%		[STRF2s]=wstrfstat(STRF2,p,No1,Wo1,PP,MDB(k),ModType,Sound);

				%Saving to File
				index=findstr('.',Lst(l,:));
				outfile=[Lst(l,1:index-1) '_u' int2str(m)];
%				f=['save ' outfile ' taxis faxis STRF1 STRF2 STRF1s STRF2s PP Wo1 Wo2 No1 No2 p -v4'];
				f=['save ' outfile ' taxis faxis STRF1 STRF2 PP Wo1 Wo2 No1 No2 p '];
				if ~strcmp(version,'4.2c')
					f=[f ' -v4'];
				end
				eval(f);
				disp(['saving ' outfile])
			end

		end
	end
end
