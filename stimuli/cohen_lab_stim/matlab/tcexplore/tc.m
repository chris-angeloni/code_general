function tc(file)
% function tc(file)
tic
matlab=[findstr(file, 'c') findstr(file, '_')];
ext=findstr(file, '.');
if isempty(matlab)==0 & isempty(ext)~=0
	file=[file '.mat'];
end
eval(['tcexplore(''' file ''')'])
set(1, 'position', [427   446   688   519])
histogram(0);
set(2, 'position', [423    -8   883   426])
figure(1)
toc
