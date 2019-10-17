%
%function []=batchrtwstrfintboot(SpecFile,T1,T2,tapenum,filenum,SPL,MDB,Sound,ModType,UFMR,UFRN,SModType,NBoot)
%
%       FILE NAME       : BATCH RTWSTRF INT
%       DESCRIPTION     : Batch Mode RTWSTRFLin and RTWSTRFdB
%			  Interpolates all STRFs
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
%	UFMR		: Moving Ripple upsampling factor
%	UFRN		: Ripple Noise Upsampling factor
%	SModType	: Sound modulation type : 'lin' or 'dB'
%	NBoot 		: Number of bootstrap STRFs (typically 8 or 16)
%
function []=batchrtwstrfintboot(SpecFile,T1,T2,tapenum,filenum,SPL,MDB,Sound,ModType,UFMR,UFRN,SModType,NBoot)

%Preliminaries
more off

%Generating a File List
f=['ls ' ];
for k=1:length(filenum)
	if filenum(k)<10
		f=[f '*t' int2str(tapenum) '*f0' int2str(filenum(k)) '*.mat ' ];
	else
		f=[f '*t' int2str(tapenum) '*f' int2str(filenum(k)) '*.mat ' ];
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


%Finding SPET files in the List
count=1;
List=[];
for l=1:length(returnindex)-1
	if length(findstr(Lst(l,:),'_u'))==0 & length(findstr(Lst(l,:),'_SpkA'))==0
		List(count,:)=Lst(l,:);
		count=count+1;
	end
end
Lst=setstr(List);

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
		if ~isempty( findstr('Trig',Lst(l,:)) ) & ~isempty( findstr(fnum,Lst(l,:)) )
			index=findstr('.mat',Lst(l,:));
			TrigFile=Lst(l,1:index+3);
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
		if ~isempty( findstr('ch',Lst(l,:)) ) & ~isempty( findstr(fnum,Lst(l,:)) )
			index=findstr('.mat',Lst(l,:));
			SpetFile=Lst(l,1:index+3);
		end

		if ~isempty( findstr('ch',SpetFile) ) & ~isempty( findstr(fnum,SpetFile) ) & exist(TrigFile) & exist(SpetFile) & findstr(SpetFile,Lst(l,:))

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
				%Re-asigning 'spet' as generic variable
				f=['spet=spet' int2str(m) ';'];
				eval(f);

				%RTWSTRF
				Fss=Fs;
				if strcmp(SModType,'dB')
					if strcmp(Sound,'MR')
						[taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrfdbint(SpecFile,T1,T2,spet,Trig,Fss,SPL(k),MDB(k),ModType,Sound,200,UFMR,'float',NBoot);
					else
						[taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrfdbint(SpecFile,T1,T2,spet,Trig,Fss,SPL(k),MDB(k),ModType,Sound,200,UFRN,'float',NBoot);
					end
				else
					if strcmp(Sound,'MR')
						[taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrflinint(SpecFile,T1,T2,spet,Trig,Fss,SPL(k),MDB(k),ModType,Sound,200,UFMR,'float',NBoot);
					else
						[taxis,faxis,STRF1,STRF2,PP,Wo1,Wo2,No1,No2,SPLN]=rtwstrflinint(SpecFile,T1,T2,spet,Trig,Fss,SPL(k),MDB(k),ModType,Sound,200,UFRN,'float',NBoot);

					end
				end

				%Saving to File
				MdB=MDB(k);
				index=findstr('.',Lst(l,:));
				if strcmp(ModType,'dB')
					outfile=[Lst(l,1:index-1) '_u' int2str(m) '_dB_Boot'];
				else
					outfile=[Lst(l,1:index-1) '_u' int2str(m) '_Lin_Boot'];
				end
				f=['save ' outfile ' taxis faxis STRF1 STRF2 PP Wo1 Wo2 No1 No2 p ModType Sound MdB SModType SPLN '];
				eval(f);
				disp(['saving ' outfile])
			end

		end
	end
end
