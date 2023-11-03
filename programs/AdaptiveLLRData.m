function NameAdaptLLRData=AdaptiveLLRData(pathstates,GMMUBMpath,NumImpSpeak)
%------------------------------------------------------------------
load(pathstates);
load([pathstates,'\train']);
%--------------------------------------------------------------------------
dirTargets=dir(Path.TargetSpeakers_Train);
NameAdaptLLRData=[];
for NS=3:length(dirTargets)
    %----------
    SpeakerName=dirTargets(NS).name;
    %----------
    % dadegane moshabeh az UBM
    [MSV,CSV,W]=readALZgmm_me([GMMUBMpath,'\Models\',SpeakerName,'.gmm']);
    dirUBM=dir([Path.UBM,'\*.wav']);
    for j=1:length(dirUBM)
        Name=dirUBM(j).name;  Name(end-3:end)=[];
        [MSV2,CSV2,W2]=readALZgmm_me([GMMUBMpath,'\Models\',Name,'.gmm']);
        s2=0;
        for j1=1:size(MSV,1)
            s1=0;
            for j2=1:size(MSV,2)
                s1=s1+((MSV(j1,j2)-MSV2(j1,j2))^2)/CSV(j1,j2);
            end
            s2=s2+s1*W(j1);
        end
        Dist(j)=s2;
    end
    [minDist,IndexDist]=sort(Dist);
    for j=1:NumImpSpeak
        Name=dirUBM(IndexDist(j)).name;  Name(end-3:end)=[];
        NameAdaptLLRData{NS-2,j}=Name;
    end   
end