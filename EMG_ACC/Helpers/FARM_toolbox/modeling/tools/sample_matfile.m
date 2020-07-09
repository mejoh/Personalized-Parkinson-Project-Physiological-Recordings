function outmat=sample_matfile(onsets,durations,tr,nvol,srate)

m=zeros(round(nvol*tr*srate),numel(onsets));

% bekijk m voor en m na, 
% zie het verschil (!)
% en vergelijk dit vervolgens met je model dat je had gedefinieerd.
% !! ze zijn hetzelfde.
% dit lijkt dus omslachtig, maar dit script bespaart je de moeite om je
% model nog apart na te zoeken, en je kan ook een willekeurig event-related
% design er dus in stoppen
% Moet je wel zorgen bij het interpoleren dat je durations niet < TR zijn
% (!!!), of zelf er in in proggen.
for i=1:numel(onsets)
    
    for j=1:numel(onsets{i})
        
        b=round(onsets{i}(j)*srate+1);
        e=round(durations{i}(j)*srate)+b;

        m(b:e,i)=1;
        
    end
end




% circumvent nasty error messages.
m(end:end+srate*10,:)=1;




% fh=figure;
% imagesc(dm);
% title('resampled design matrix check');
% saveas (fh,'emg_check/tmp_resampled_design','jpg');
% close(fh);
%
% clear m;
%
%
% fh=figure;
% imagesc(m);
% saveas(fh,'emg_check/tmp_sampled_design','jpg');
% close(fh);

