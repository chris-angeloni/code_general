%function [mvdata] = getpsth(Idfile,scrdat,sequence,var)
%
%	FILE NAME 	: GET PSTH
%	DESCRIPTION 	: Gets the PSTH Data required for a PSTH
%			  movie.
%
%	Idfile		: File Identifier - including path
%	scrdat		: Script Data - obtained from scrdata
%	sequence	: Sequence Number
%	var		: Variation Number
%	mvdata		: Returned Movie Data
%	
function [mvdata] = getpsth(Idfile,scrdat,sequence,var)

%Getting Movie Data
t=max( [find(Idfile=='\') find(Idfile=='/')] );
Id=Idfile(t+1:length(Idfile));

%Extracting Data
k=1;
for j=1:length(scrdat(:,1))

	%Message
	if sum(scrdat(j,:)==-9999)==0
		f=['Loading Unit ',num2str(scrdat(j,1),10),':',Idfile,...
		num2str(scrdat(j,5),10),'.hhh'];
		disp(f);

		f=['load ',Idfile,num2str(scrdat(j,5),10),'.hhh',';'];
		eval(f);
		f=['current=',Id,num2str(scrdat(j,5),10),';'];
		eval(f);		
		f=['clear ',Id,num2str(scrdat(j,5),10),';'];
		eval(f);

		%Finding the Apropriate data from PSTH file
		index=find(scrdat(:,5)==scrdat(j,5));
		N=length(current(:,1))/6;

		dN=N-find(scrdat(index,1)==scrdat(j,1));
		data(k,:)=current(N*var-dN,:);
		mvdata(k,:)=scrdat(j,2:3);
		normfact(k,:)=scrdat(k,4);	
		k=k+1;
	end
end

%Normalizing
for k=1:length(data(:,1)) 
	data(k,:)=data(k,:)/normfact(k);
end

%Adding data
mvdata=[mvdata data];
