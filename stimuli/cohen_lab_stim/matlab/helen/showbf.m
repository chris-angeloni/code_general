function [fid,Fs,filesize,point]=showbf(flag,fid,Fs,filesize,point,num);
%Function
%            to show back 1 sec or forward 1 sec data
%Input
%            flag         '1'  back
%                         '2'  forward
%            fid          file's handles
%            Fs           the array of sample frequency
%            filesize     the array of the size of file
%            point        the point of file
%            num          the number of files
%
%Copyright    Angel(ANQI QIU)
%             7/24/2001

Axeslist=get(gcf,'Userdata');
if flag==1
   for n=1:num,
      if point(n)>1
         if fseek(fid(n),-Fs(n)*4,0)==0
            datach=[];
            point(n)=point(n)-2;
            datach=fread(fid(n),Fs(n),'int16');
            axes(Axeslist(n));
            plot(point(n)+(1:length(datach))/Fs(n),datach);
            if point(n)==0
               set(Axeslist(18),'Enable','off');
            end 
            if point(n)<floor(filesize(n)/Fs(n))
               set(Axeslist(19),'Enable','on');
            end;     
            point(n)=point(n)+1;
         else
            msgbox('File is the beginning!Please start again.','Warning');
            pause;
            for m=1:num,
               fclose(fid(m));
            end
            return;
         end         
      end;      
   end
else
   for n=1:num,
      if point(n)<floor(filesize(n)/Fs(n))
            datach=[];
            datach=fread(fid(n),Fs(n),'int16');
            axes(Axeslist(n));
            plot(point(n)+(1:length(datach))/Fs(n),datach);
            point(n)=point(n)+1;
            if point(n)==floor(filesize(n)/Fs(n))
               set(Axeslist(19),'Enable','off');
            end  
            if point(n)>1
               set(Axeslist(18),'Enable','on');
            end  
         else
            msgbox('File is the end!Please go back again.','Warning');
            pause;
            return;
      end;
   end   
end
