function trydbexportdemo

%to connect database
conn=database('try','','');


%to define the data and column's name
colnames={'Name','student'};
exdata(1,1)={'tte'};
exdata(1,2)={11};

if get(conn,'AutoCommit')=='on' 
   insert(conn,'Orders',colnames,exdata);
else
   clc;
   disp('Can not connect database');
end
close(conn);

   
