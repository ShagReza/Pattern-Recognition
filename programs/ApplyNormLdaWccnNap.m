
function y=ApplyNormLdaWccnNap(y,Norm_ivector,LDA_ivector,NAP_ivector,WCCN_ivector,LDAmodel,P_NAP,B_WCCN)

if (Norm_ivector==1)
    for i=1:size(y,1)
        y(i,:)=y(i,:)./norm(y(i,:));
    end
end
%---
%LDA:
if (LDA_ivector==1)
    y=linproj(y', LDAmodel)';
end
%---
%NAP:
if (NAP_ivector==1)
    y=(P_NAP*y')';
end
%---
%WCCN:
if (WCCN_ivector==1)
    y=(B_WCCN*y')';
end