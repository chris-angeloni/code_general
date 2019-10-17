function [MI2]=bootmidirec(MI,NB)

count=1;
for i=1:127
    if MI(i,1)==0
        count=count;
    else
        MI2(count,:)=MI(i,:)
        count=count+1;
    end       
end

for l=1:NB
    j = randsample(size(MI2,1),size(MI2,1),'true');
    MI2boot(l,:) = mean(MI2(j,:));
end
    MI2.M = mean(MI2boot,1);
    MI2.SE = std(MI2boot,1);
   