



%     %% maak een tweede serie coole plaatjes.
%     % keyboard;
%     tmp=find(strcmp({EEG.event(:).type},'s')==1);
%     tmp2=find(strcmp({EEG.event(:).type},'V')==1);
%     for i=[1:20:numel(tmp2)]
%         fh=figure;
%         b=EEG.event(tmp2(i)).latency-200;
%         e=b+400;
%         plot(b:e,EEG.data(1,b:e))
%         hold on
%         ylim=get(gca,'ylim');
% 
%         % get all of the slice triggers, nearest to our volume trigger.
%         tmp5=find(abs(EEG.event(tmp2(i)).latency-[EEG.event(tmp).latency])<200);
% 
%         for j=tmp5
%             line(EEG.event(tmp(j)).latency*[1 1],ylim,'color','m')
%         end
% 
%         line(EEG.event(tmp2(i)).latency*[1 1],ylim,'color','k')
% 
% 
% 
%         saveas(fh,['slicetrigger_check/na_correctie_en_30_250_filter_' num2str(i)],'jpg');
% 
%         % print('-dpdf',['volume_trigger_' num2str(i)]);
%         close(fh);
% 
% 
%     end
