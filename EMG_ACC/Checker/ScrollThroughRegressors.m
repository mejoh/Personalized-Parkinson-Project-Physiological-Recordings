% Scroll through tremor regressors from automatic peak selection
RegDir = '/project/3022026.01/analyses/EMG/motor_PIT/processing/prepemg/Regressors/ZSCORED';
load('/project/3022026.01/analyses/EMG/motor_PIT/manually_checked/Martin/Tremor_check-20-Nov-2020.mat', 'Tremor_check')
for i = 1:length(Tremor_check.cName)
    [~, Filename, ~] = fileparts(Tremor_check.cName{i});
    Sub = Filename(1:24);
    Visit = Filename(26:35);
    Image = spm_select('FPList', RegDir, [Sub, '-', Visit, '.*_power.jpg']);
    dat = imread(Image);
    imshow(dat)
    input('Press key to show next image')
end