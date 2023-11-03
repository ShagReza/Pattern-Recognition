

function FeatureLabelExtraction_ivectorTest3(pathstates,new)

load(pathstates);
WavPath   = dir([new,'\Waves\*.wav']);
for b1 = 1:length(WavPath)
    b1
    InputWaveFile=[new,'\Waves\',WavPath(b1).name];
    Name=WavPath(b1).name; Name(end-3:end)=[];
    OutputLabelFile=[new,'\Labels\',Name,'.lbl'];
    OutputFeatureFile=[new,'\Features\',Name,'.ftr'];  
    dos(['SAD.exe  ',InputWaveFile,' ', OutputLabelFile,' ', Path.SADmodels,'   Temp 1 Energy.txt 0  10  10 0.05 0.73 100']);
    dos(['MFCCWhitSAD.exe ',InputWaveFile,' ',OutputFeatureFile ,' ',Path.SADmodels]);
end
%-------------------------------------------
