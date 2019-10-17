function ploteegcorr;
%Function   
%               correlation between the data and show curve
%               it is the function of eegcorr.m
%
%Copyright     Angel(ANQI QIU)
%              7/24/2001



handlelist=get(gcf,'Userdata');
filename1=get(handlelist(1),'String');
filename2=get(handlelist(2),'String');
t1=str2num(get(handlelist(3),'String'));
t2=str2num(get(handlelist(4),'String'));
if isempty(filename1)
   msgbox('This file is not here! Please input again!','Warning');
   pause;
   return;
else
   fid(1)=fopen(filename1,'r');
   if fid(1)<0
      msgbox('This file is not here! Please input again!','Warning');
   	pause;
      return;
   end
   Fs(1)=fread(fid(1),1,'int16');
   filesize(1)=fread(fid(1),1,'int32');
end
point1=floor(Fs(1)*t1);
point2=floor(Fs(1)*t2);
if (point1<filesize(1)) & (point2<filesize(1))
   fseek(fid(1),point1*2,0);
   h1=fread(fid(1),point2-point1,'int16');
else
   msgbox('Time is too large!Please choose time again!','Warning');
   pause;
   return;
end
if isempty(filename2)
   msgbox('This file is not here! Please input again!','Warning');
   pause;
   return;
else
   fid(2)=fopen(filename2,'r');
   if fid(2)<0
      msgbox('This file is not here! Please input again!','Warning');
   	pause;
      return;
   end
   Fs(2)=fread(fid(2),1,'int16');
   filesize(2)=fread(fid(2),1,'int32');
end
point1=floor(Fs(2)*t1);
point2=floor(Fs(2)*t2);
if (point1<filesize(2)) & (point2<filesize(2))
   fseek(fid(2),point1*2,0);
   h2=fread(fid(2),point2-point1,'int16');
else
   msgbox('Time is too large!Please choose time again!','Warning');
   pause;
   return;
end
c=xcorr(h1,h2);
figure;
plot(((-length(h1)+1):(length(h2)-1))/Fs(1),c);
axis([(-length(h1)+1)/Fs(1) (length(h2)-1)/Fs(1) min(c) max(c)]);
xlabel('s');
for n=1:2,
	if fid(n)>0
   	fclose(fid(n));
   end;
end;

clear filename pathname handlelist;
