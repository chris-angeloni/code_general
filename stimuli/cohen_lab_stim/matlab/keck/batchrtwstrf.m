%
%function []=batchrtwstrf(SpecFile,T1,T2,tapenum,filenum,SPL,MDB,Sound,ModType,SModType,p)
%
%       FILE NAME       : BATCH RTWSTRF
%       DESCRIPTION     : Batch Mode RTWSTRFLin and RTWSTRFdB
%
%       SpecFile        : Spectral Profile File
%       T1, T2          : Evaluation delay interval for WSTRF(T,F)
%                         T E [ T1 , T2 ]
%	tapenum		: Tape Number
%	filenum		: Array of filenumbers to download
%	SPL             : Array of Signal RMS Sound Pressure Level
%       MDB             : Array of Signal Modulation Index in dB
%       Sound           : Sound Type
%                         Moving Ripple : MR ( Default )
%                         Ripple Noise  : RN
%       ModType         : Kernel modulation type : 'lin' or 'dB'
%	SModType	: Sound modulation type : 'lin' or 'dB'
%	p 		: Significance Probability
%
function []=batchrtwstrf(SpecFile,T1,T2,tapenum,filenum,SPL,MDB,Sound,ModType,SModType,p)

%Preliminaries
more off

%Generating a File List
List=[];
for k=1:length(filenum)
	if filenum(k)<10
		f=['*t' int2str(tapenum) '*f0' int2str(filenum(k)) '*.mat' ];
		List=[List;dir(f)];
	else
		f=[f '*t' int2str(tapenum) '*f' int2str(filenum(k)) '*.mat' ];
		List=[List;dir(f)];
	end
end

%Finding SPET files in the List
count=1;
for l=1:size(List,1)
	if length(findstr(List(l).name,'_u'))==0 & length(findstr(List(l).name,'_SpkA'))==0
		Lst(count,1).name=List(l).name;
		count=count+1;
	end
end

%Batching RTWSTRF
N=size(Lst,1);
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
		if ~isempty( findstr('Trig',Lst(l).name) ) & ~isempty( findstr(fnum,Lst(l).name) )
			TrigFile=Lst(l).name;
		end
	end
	if exist(TrigFile)
		f=['load ' TrigFile];
		eval(f);
		disp(f);
	end

	%Running RTWSTRF
	for l=1:N

		%File Number
		if filenum(k)<10
	                fnum=['0' int2str(filenum(k))];
        	else
               		fnum=int2str(filenum(k));
        	end

		%Spet File
		if ~isempty( findstr('ch',Lst(l).name) ) & ~isempty( findstr(fnum,Lst(l).name) )
			SpetFile=Lst(l).name;
		end

		if ~isempty( findstr('ch',SpetFile) ) & ~isempty( findstr(fnum,SpetFile) ) & exist(TrigFile) & exist(SpetFile) & findstr(SpetFile,Lst(l).name)

			%Loading Spet Data File
			clear spet*
			f=['load ' Lst(l).name ];
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
				%Re-asigning 'spet' as generic variable
				f=['spet=spet' int2str(m) ';'];
				eval(f);

				%RTWSTRF
				Fss=Fs;
				if strcmp(SModType,'dB')
					[taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrfdb(SpecFile,T1,T2,spet,Trig,Fss,SPL(k),MDB(k),ModType,Sound,200);
				else
					[taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrflin(SpecFile,T1,T2,spet,Trig,Fss,SPL(k),MDB(k),ModType,Sound,200);
				end

				%Performing Statistical Significance Test
				[STRF1s]=wstrfstat(STRF1,p,No1,Wo1,PP,MDB(k),ModType,Sound,SModType);
				[STRF2s]=wstrfstat(STRF2,p,No1,Wo1,PP,MDB(k),ModType,Sound,SModType);

				%Saving to File
				MdB=MDB(k);
				index=findstr('.',Lst(l).name);
				if strcmp(ModType,'dB')
					outfile=[Lst(l).name(1:index-1) '_u' int2str(m) '_dB'];
				else
					outfile=[Lst(l).name(1:index-1) '_u' int2str(m) '_Lin'];
				end
				f=['save ' outfile ' taxis faxis STRF1 STRF2 STRF1s STRF2s PP Wo1 Wo2 No1 No2 p ModType Sound MdB SModType SPLN '];
				if ~strcmp(version,'4.2c')
					f=[f ' -v4'];
				end
				eval(f);
				disp(['saving ' outfile])
			end

		end
	end
end
