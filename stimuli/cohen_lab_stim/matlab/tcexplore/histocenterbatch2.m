figure(1)
ui_handles = get(1,'userdata');
if isempty(ui_handles)==1
	tcexplore('/net/eco/kilgard/rat06/csr06010.dtc')
end
rat=input('Ratfinal to analyze:  ');
loadatfile(rat)
eval(['load ' rat])
eval(['ai=find(' rat '(:,43)==0);'])
figure(2)
ls
e=input('End of files; ');
if e=='.mat'
	b='tc_0';
else
	b=input('Beginning of files; ');
end
h=0;
hdata=zeros(size(ai,2), 200);
norm=1;
for i=ai'
	eval(['r=' rat '(i, 1);'])
	if r<10000, x='0'; else, x=[];, end
	if e=='.mat'&r>999, x='';, end
	file=[b x num2str(r, 5) e];
	if e=='.mat', file(7)='c';, end
	disp(file)
	tcexplore(file)
	[histo, sp]=histocenter2;
	if isempty(histo)==0
		hdata(i,1:size(histo, 2)+2)=[r sp histo];
		figure(2)
		hold on
		hi=(h)*ones(size(histo));
		if norm==0,
			plot((histo)+hi)
               		plot([0 size(histo, 2)], [h h])
			h=h+(max(histo)/sp);
		else
			%line([0 size(histo, 2)], [h h], 'color', 'g')
			hh=(histo-(ones(size(histo))*sp));
			hh(find(hh<=0))=hh(find(hh<=0))*0;
			hh=hh+hi;
			hh=[h hh h];
			patch(1:size(hh,2), hh, 'r')
			line([0 size(histo, 2)], [h-sp h-sp], 'color', 'g')
			h=max(hh);
               end		
	end
end
