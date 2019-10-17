function stopshow(fid,num);
%Function
%          to close files
%Input    
%        fid   the array of file handles
%        num   the number of files
%
%Copyright    Angel(ANQI QIU)
%             7/24/2001


Axeslist=get(gcf,'Userdata');
set(Axeslist(18),'Enable','off');
set(Axeslist(17),'Enable','on');
set(Axeslist(20),'Enable','off');
set(Axeslist(19),'Enable','off');
for n=1:num,
   if fid(n)>0
      fclose(fid(n));
      axes(Axeslist(n));
      cla;
   end   
end;

