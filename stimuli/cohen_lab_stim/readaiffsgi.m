%
%function [sr,data]=readaiffsgi(filename,nch,sr,nsample,samplesize)
%function [sr,data]=readaiffsgi(filename)
%	
%	FILE NAME 	: readaiffsgi
%	DESCRIPTION 	: This functions reads AIFF files
% 
function [sr,data]=readaiffsgi(filename,nch,sr,nsample,samplesize)

fid=fopen(filename,'r','b');
temp=fread(fid,'integer*4');


%**************
% common-chunk:
%**************
icomm=0;

for j=1:4

  status = fseek(fid,j-1,'bof');
  clear temp; temp=fread(fid,'integer*4');
  tsize=max(size(temp));

  for i=1:tsize
    if round(temp(i)) == 1129270605
	icomm=1;	
 	commloc=i;
	break;
    end
  end

  if icomm == 1 break; end
end

if icomm == 0
  	disp('***** COMM-chunk not found ***');
else
	fp=commloc*4;

%        /* read chunk size */
	status = fseek(fid,fp,'bof');
       	subsize = fread(fid,1,'integer*4');
	fp = fp + 4;

%	 /* read number of channel */
	status = fseek(fid,fp,'bof');
       	nch = fread(fid,1,'short');
	fp = fp + 2;

%	/* read number of sample frames */
	status = fseek(fid,fp,'bof');
       	nsample = fread(fid,1,'integer*4');
	fp = fp + 4;

%	 /* read sample size */
	status = fseek(fid,fp,'bof');
       	samplesize = fread(fid,1,'short');
	fp = fp + 2;                                

%	/* read sample rate (sr = 80 bits real number) 
	status = fseek(fid,fp,'bof');
	b = fread(fid,5,'ushort');
	if b(1)>2^15
	  b(1) = b(1) - 2^15;
	end	
	expon = b(1) - 16383;
	expon = expon - 15; sr = b(2)*2^expon;
	expon = expon - 16; sr = sr + b(3)*2^expon;
	expon = expon - 16; sr = sr + b(4)*2^expon;
	expon = expon - 16; sr = sr + b(5)*2^expon;	
end
	
%*************
% data-chunk:
%*************
issnd=0;

for j=1:4

  status = fseek(fid,j-1,'bof');
  clear temp; temp=fread(fid,'integer*4');
  tsize=max(size(temp));

  for i=1:tsize
    if round(temp(i)) == 1397968452
	issnd=1;	
 	ssndloc=i;
	break;
    end
  end

  if issnd == 1 break; end
end

if issnd == 0
  	disp('***** SSND-chunk not found ***');
else
	fp=ssndloc*4;

%       /* read size */
	status = fseek(fid,fp,'bof');
       	subsize = fread(fid,1,'integer*4');
	fp = fp + 4;

%       /* read offset */
	status = fseek(fid,fp,'bof');
       	offset = fread(fid,1,'integer*4');
	fp = fp + 4;

%       /* read block size */
	status = fseek(fid,fp,'bof');
       	blocksize = fread(fid,1,'integer*4');
	fp = fp + 4;
     
%	read sound position
	sp = fp + offset;

end

clear temp;

% read data:

if icomm == 1 & issnd == 1
	status = fseek(fid,sp,'bof');
	datatype = ['int' int2str(samplesize)];
	if (nch==2) 
		totsamples=2*nsample; 
		data=fread(fid,totsamples,datatype);
		chan1=data(1:2:totsamples);
		chan2=data(2:2:totsamples);
		data=[chan1 chan2];
		clear chan1 chan2;
	else 
		totsamples=nsample;
		data = fread(fid,totsamples,datatype);
	end;

	disp(['AIFF-file ' filename ' :']);
	str=sprintf('%10.1f',sr); disp(['Sampling rate ' str ' Hz']);
	str=sprintf('%10.0f',nsample);
	disp([num2str(nch) ' channels, ' str ' samples, ' num2str(samplesize) ' bits']);
end

status=fclose(fid);
