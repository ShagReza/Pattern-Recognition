

function FeatureLabelExtraction_ivectorTest2(pathstates,new)

load(pathstates);
EnhSegmentsPath   = dir([new,'\Waves\*.wav']);


%--------
ft_func     = ['function_',Methods.ft];
ftsel_func  = ['function_',Methods.ftsel];
lab_func    = ['function_',Methods.lab,'2'];
%--------
WavPath   = dir([new,'\Waves\*.wav']);
for b1 = 1:length(EnhSegmentsPath)
    b1
    speech=[new,'\Waves\',WavPath(b1).name];
    dos(['VAD.exe ',speech,' lbl.lbl',' 0 10 10  0  SNR.txt 0.03 ']);
    %dos(['Clip-VOICE.exe ' , speech,' lbl.lbl', ' ', 'a.wav']);
    copyfile(speech,'a.wav');
    [AA,B,C,D,Scrs] = textread('lbl.lbl','%s %s %s %s %f');
    if isempty(AA)==0
        dos(['Add-Noise.exe ' , 'a.wav',' ', speech, ' ','0.32767']);
        pathwav=[new,'\Waves\'];
        pathfeat=[new,'\Features\'];
        pathLabel=[new,'\Labels\'];
        Name=WavPath(b1).name; Name(end-3:end)=[];
        eval([ft_func,'(Name,pathwav,pathfeat)']);
        eval([lab_func,'(Name,pathwav,pathLabel)']);
        [Masking, FeatSize ] = eval(ftsel_func);
    end
end
%-------------------------------------------
