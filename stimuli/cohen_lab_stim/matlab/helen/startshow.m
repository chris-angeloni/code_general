function [fid,Fs,filesize,point]=startshow(Filenamelist,num);
%Function
%          to open files and draw curves 
%Input
%          Filenamelist      the array of names of files
%                            that come from openchannel or openlfilter
%                            or openbfilter
%          num               the number of files
%
%Copyright    Angel(ANQI QIU)
%             7/24/2001




Axeslist=get(gcf,'Userdata');
point=zeros(16,1);
Fs=zeros(16,1);
filesize=zeros(16,1);
fid=-1*ones(16,1);
for n=1:num,
   if ~isempty(Filenamelist(n,:))
      i=find(Filenamelist(n,:)=='.');
      fid(n)=fopen(Filenamelist(n,1:i+3),'r');
      if fid(n)<0
         msgbox('Please open your data file again! You made a mistake when you opened the file.','Warning');
         pause;
      end      
      Fs(n)=fread(fid(n),1,'int16');
      filesize(n)=fread(fid(n),1,'int32');
      if filesize(n)<Fs(n)
         msgbox('File has no enough data! Can not show!','Warning');
         pause;
         for m=1:n,
            if ~isempty(Filenamelist(m,:))
               fclose(fid(m));
            end            
         end
         return;
      else
         datach=fread(fid(n),Fs(n),'int16');
         axes(Axeslist(n));
         plot(point(n)+(1:length(datach))/Fs(n),datach); 
         point(n)=point(n)+1;
      end;
   end;
end;
%set(Axeslist(18),'Enable','on');
set(Axeslist(17),'Enable','off');
set(Axeslist(20),'Enable','on');
if point(1)<round(filesize(1)/Fs(n))
   set(Axeslist(19),'Enable','on');
end;

