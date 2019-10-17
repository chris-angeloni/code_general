function [mVS]=average(VS)

for i=1:15
  a = VS(:,i)
  aa = a(find(a~=0)) 
  mVS(i) = mean(aa);
end
