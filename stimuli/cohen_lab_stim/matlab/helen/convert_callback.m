function convert_callback;
%Fuction
%           This is for callback of convert button in Filter menu
%
%Copyright    Angel(ANQI QIU)
%             7/24/2001

Editlist=get(gcf,'Userdata');
if get(Editlist(17),'Value')==1
   filterflag='Low';
   cutoff1=str2num(get(Editlist(19),'String'));
   cutoff2=0;
else
   if get(Editlist(18),'Value')==1
      filterflag='Band';
      cutoff1=str2num(get(Editlist(20),'String'));
      cutoff2=str2num(get(Editlist(21),'String'));
   else
      msgbox('Please choice filter type!','Warning');
      pause;
      return;
   end
end
for n=1:16,
   filename=get(Editlist(n),'String');
   if ~isempty(filename)
      filterdata(filterflag,filename,cutoff1,cutoff2);
   end;
end;
clear filterflag Editlist cutoff1 cutoff2 filename;
         
     