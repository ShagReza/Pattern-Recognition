% Language: list of target GMM files
function Langauge=LanguageNames(GMMpath)
Langauge=[];
GMMnames=dir([GMMpath,'\*.gmm']);
for i=1:(length(GMMnames))
    gmmname=GMMnames(i).name; gmmname(end-3:end)=[];
    if (isequal(gmmname,'UBM') || isequal(gmmname,'UBMinit'))~=1
        Langauge=[Langauge, gmmname,'   '];
    end
end