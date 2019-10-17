function M2=matrixh2v(M1)
% DESCRIPTION       : matrix horizontal to vertical
%                     [1 2 3 4 5       [1 3 5 7 9
%                      6 7 8 9 10]      2 4 6 8 10]
% (c) Yi Zheng, July 2007

M = size(M1,1);
N = size(M1,2);

M2=zeros(M,N);

for row=1:M
    for col=1:N
        number=(row-1)*N+col;
        if rem(number,M)==0
            row2 = M;
        else
            row2 = rem(number,M);
        end
        col2 = (number-row2)/M+1;
     M2(row2,col2) = M1(row,col);
    end
end
