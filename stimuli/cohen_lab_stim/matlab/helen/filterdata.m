function filterdata(filterflag,filename,f1,f2);
%Function
%                to convert data through low or band pass filter(only for one file)
%Input
%       filterflag         choice low pass filter or band pass filter
%       filename           name of datafile
%       f1                 lower cutoff frequency (if you choice a low pass filter,
%                          you only need to write the number)
%       f2                 upper cutoff frequency (if you choice a band pass filter, 
%                          you need to write this number)
%
%Copyright    Angel(ANQI QIU)
%             7/24/2001

if strcmp(filterflag,'Low')
   fid=fopen(filename,'r');
   if fid<0
      msgbox('You inputed the wrong data file! Please input data file again!','Warning');
      pause;
      return;
   end
   i=find(filename=='.');
   filenamenew=[filename(1:i-1) '_Low.dat'];
   fid1=fopen(filenamenew,'w');
   if fid1<0
      msgbox('You can not create a new file! Please try again!','Warning');
      pause;
      fclose(fid);
      return;
   end      
   Fs=fread(fid,1,'int16');
   filesize=fread(fid,1,'int32');
   num=floor(filesize/Fs);
   fwrite(fid1,Fs,'int16');
   fwrite(fid1,Fs*num,'int32');
   H=lowpass(f1,10,Fs,40,'off');
   Numh=length(H);
   for n=1:num,
      datach=fread(fid,Fs,'int16');
      y=conv(datach,H);
      fwrite(fid1,y(round((Numh-1)/2)+1:(Fs+round((Numh-1)/2))),'int16');
   end;
   fclose(fid);
   fclose(fid1);
else
   fid=fopen(filename,'r');
   if fid<0
      msgbox('You inputed the wrong data file! Please input data file again!','Warning');
      pause;
      return;
   end
   i=find(filename=='.');
   filenamenew=[filename(1:i-1) '_Band.dat'];
   fid1=fopen(filenamenew,'w');
   if fid1<0
      msgbox('You can not create a new file! Please try again!','Warning');
      pause;
      fclose(fid);
      return;
   end      
   Fs=fread(fid,1,'int16');
   filesize=fread(fid,1,'int32');
   num=floor(filesize/Fs);
   fwrite(fid1,Fs,'int16');
   fwrite(fid1,Fs*num,'int32');
   H=bandpass(f1,f2,10,Fs,40,'off');
   Numh=length(H);
   for n=1:num,
      datach=fread(fid,Fs,'int16');
      y=conv(datach,H);
      fwrite(fid1,y(round((Numh-1)/2)+1:(Fs+round((Numh-1)/2))),'int16');
   end;
   fclose(fid);
   fclose(fid1);            
end


