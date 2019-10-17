

%%%%%%%%%%%% DADY'S CODE - extracting and formating word database
fid=fopen('/usr/share/dict/words','r');
X=fread(fid,inf,'char')';
i=find(X==10);
for k=1:length(i)-1    
    Words(k).X=(X(i(k)+1:i(k+1)-1));
    l=find(Words(k).X<=90 & Words(k).X>=65);
    Words(k).X(l)=Words(k).X(l)+32;
end



%%%%%%%%%%%%%% HOLDEN'S CODE

dw=[];      %defining dollar word
for a=1:235885      %foor loop to search for all words
    
    if  sum(Words(a).X-96)==100         %find dollar words  
       dw=[dw Words(a).X 9];            %store dollar words - 9 is a tab
    end
    
end


%Daddy's code - save results to file
fid=fopen('holdendw.txt','w');
fwrite(fid,dw,'char')
fclose all
