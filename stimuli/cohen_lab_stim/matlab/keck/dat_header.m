%
%function [Fs,interleave,file_num]=dat_header(infile)
%
%       FILE NAME       : DAT HEADER
%       DESCRIPTION     : Extracts the sampling rate and the interleave order
%			  from the header of a a given DAT file. 
%
%       infile          : Input File
%	Fs		: Sampling Rate
%	interleave	: Array with interleve order of channels
%	file_num	: File Number
%
function [Fs,interleave,file_num]=dat_header(infile)

%The following C structure is from Purvis B's header-reader.
%typedef struct {
%  unsigned file_num; /* serial file number */
%  int rec_num; /* not used */
%  int rec_size; /* 0 => continuous recording */
%                /* 1,2,4,8,16 = number of data records of DATA_RECORD_LENGTH */
%                /* size in a burst mode file */
%  int interval; /* not used */
%  char mpx; /* 0 to 27, `a la CDAT 16 display */
%  char cdat_type; /* 1 is for CDAT 16 */
%  char bcdtime[6]; /* BCD time record.  HHMMSS */
%  char bcddate[6]; /* BCD date record.  MMDDYY */
%  char gain[8];    /* channel gain, 2 channels per byte. */
%                  /* 0=X1, 1=X2, 3=X5, 4=X10, 5=X20, 6=X50, 7=X100 */
%  int spare;
%  int out_offset[16]; /* unused */
%  int headroom[32];
%} CDAT_HEADER;

%Opening input File
fid=fopen(infile,'r');

%Reading MPX from File Header
file_num = fread(fid, 1, 'uint');
fseek(fid, 4, 0);		%Why only 4, not 6?  but this works!
mpx = fread(fid, 1, 'char');
disp(['mpx = ' num2str(mpx)]);
disp(['file number = ' num2str(file_num)]);

%Choosing apropriate sampling rate and interleave
if mpx == 6
   Fs = 24000;
   interleave = [1 5 2 6];
elseif mpx == 7
   Fs = 48000;
   interleave = [1 5 2 6];
elseif mpx == 13
   Fs = 24000;
   interleave = [1 5 3 7 2 6 4 8];
elseif mpx == 3
   Fs = 48000;
   interleave = [1 2];
else 
   disp('Unrecognized mpx');
end

%switch mpx
%	case {0,1,2,3}
%		interleave=[1 2];
%	case {4,5,6,7}
%		interleave=[1 5 2 6];
%	case {8,9,10,11}
%		interleave=[1 5 2 7 1 6 2 8];
%	case {11,12,13,14}
%		interleave=[1 5 3 7 2 6 4 8 ];
%	case {15,16,17} 
%		interleave=[1 5 9 13 2 6 10 15 1 5 9 14 2 6 10 16];
%	case {18,19,20}
%		interleave=[1 5 9 13 2 6 11 15 1 5 10 14 2 6 12 16];
%	case {21,22,23}
%		interleave=[1 5 9 13 2 7 11 15 1 6 10 14 2 8 12 16];
%	case {24,25,26,27}
%		interleave=[1 5 9 13 3 7 11 15 2 6 10 14 4 8 12 16];
%	otherwise disp('Unrecognized mpx')
%end

%Closing input file
fclose(fid);
