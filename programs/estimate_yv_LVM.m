function vLVM=estimate_yv_LVM(F, N,CSV,J)
%initialize:-----------------------
NumData=size(N,1);
NumGmm=size(N,2);
Dim=size(F,2)/size(N,2);
v = randn(Dim, J) ;
A = randn(Dim, J) ;
y=randn(NumData,NumGmm,J);
Linv=randn(J,J);
%----------------------------------
for itr=1:10
    itr
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
    %------------
    A=zeros(Dim, J);
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
            y0(1:J)=y(r,c,1:J);
            if abs(y0(1))>0.000001
                A=A+var\F(r,(c-1)*39+1:c*39)'*y0;
            end
        end
    end
    %------------
    for i=1:Dim
        C=zeros(J,J);
        for c=1:104
             var0=CSV(1,:);
            for k1=1:Dim
                for k2=1:Dim
                    if k1==k2
                        var(k1,k2)=var0(k1);
                    end
                end
            end
            ivar=inv(var);
            B=zeros(J,J);
            for r=1:NumData
                y0(1:J)=y(r,c,1:J);
                if N(r,c)>0.00001
                    B=B+N(r,c)*y0'*y0;
                end
            end
            C=C+ivar(i,i)*B;
        end
        v(i,1:J)=A(i,1:J)*inv(C);
    end
end
%----------------------------------
vLVM=v;


