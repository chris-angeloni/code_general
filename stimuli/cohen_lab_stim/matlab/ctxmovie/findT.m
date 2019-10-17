%function [Tx,Ty]=findT(data,N,dis)
%
%	FILE NAME 	: findT 
%	DESCRIPTION 	: Finds the mean and std of the sampling 
%			  period (T) of a randomly sampled map / Image
%			  
%	data		: Input Map / Image
%	N		: Numberof neighbors used to find Tx,Ty
%	dis		: Flag for displaying: 'y' or 'n'
%	n		: Array of indecies for closest N-neighbors
%			  Arranged so that the kth row corresponds to 
%			  indexcies of the closest N-neighbors in the 
%			  data Arrray
%
%	Tx,Ty		: mean sampling period in X and Y directions
%
function [Tx,Ty]=findT(data,N,dis)

%Finding distance matrix -> D(j,k)="Distance from j to k"
for j=1:length(data)
	for k=1:length(data)
		D(j,k)= sqrt( (data(k,1)-data(j,1))^2 + (data(k,2)-data(j,2))^2 );
	end
end

%Finding N-neigbors
for k=1:length(data)
	index=find(D(k,:)==0);
	D(k,index)=9999;
end
for k=1:length(data)
	for j=1:N
		n(k,j)=min(find(D(k,:)==min(D(k,:))));
		D(k,n(k,j))=9999;
	end
end

%Finding mean and variance for T
clear D;
Dx=zeros(1,length(data)*N);
Dy=zeros(1,length(data)*N);
for k=1:length(data)
	Dx((k-1)*N+1:k*N)=abs(data(n(k,:),1)-data(k,1));
	Dy((k-1)*N+1:k*N)=abs(data(n(k,:),2)-data(k,2));
end

Tx=mean(Dx)*2;
Ty=mean(Dy)*2;

%Displaying
if dis=='y'
	for k=1:length(data)
		hold off
		plot(data(:,1),data(:,2),'r+')
		hold on
		plot(data(k,1),data(k,2),'b+')
		plot(data(n(k,:),1),data(n(k,:),2),'+y')
		pause(1)
	end
end

%plot(Dx,'+r')
%pause
%Plotting hist
%hist(Dx,30)
%pause
%hist(Dy,30)

