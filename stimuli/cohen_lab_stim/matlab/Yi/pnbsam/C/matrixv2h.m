function M2=matrixv2h(M1)
% DESCRIPTION       : matrix vertical to horizontal
%                      [1 3 5 7 9      [1 2 3 4 5
%                       2 4 6 8 10]     6 7 8 9 10]   

% (c) Yi Zheng, July 2007

M = size(M1,1);
N = size(M1,2);

M2=zeros(M,N);

for row=1:M
    for col=1:N
        number=(col-1)*M+row;
        if rem(number,N)==0
            col2 = N;
        else
            col2 = rem(number,N);
        end
        row2 = (number-col2)/N+1;
     M2(row2,col2) = M1(row,col);
    end
end
