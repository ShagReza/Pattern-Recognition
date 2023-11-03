
function y=estimateLvector(N,F,vLVM,CSV,J)
NumData=size(N,1);
NumGmm=size(N,2);
Dim=size(F,2)/NumGmm;
y=[];
v=vLVM;
%----------
for r=1:NumData
    for c=1:NumGmm
        var0=CSV(1,:);
        for k1=1:Dim
            for k2=1:Dim
                if k1==k2
                    var(k1,k2)=var0(k1);
                end
            end
        end
        Linv(1:J,1:J)=eye(J,J)+inv(N(r,c)*v'*(var\v));
        y(r,c,1:J)=(Linv*v'*(var\F(r,(c-1)*39+1:c*39)'))';
    end
end
%-----