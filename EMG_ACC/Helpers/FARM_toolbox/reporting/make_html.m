% html res
s=[];

s=[s '<html>\n'];
s=[s '<head><title>Block Design Results, patients</title></head>\n'];
s=[s '<body>\n'];

s=[s '<h1>Myo1 results</title></h1><hr>\n'];
names=dir;
names(1:2)=[];

for i=1:numel(names)
    if names(i).isdir
        pp=names(i).name;
        s=[s '<h2>Subject ' pp '<h2>\n'];
        load(['../../../pp/' pp '/muscles.mat']);
        
        fid=fopen([pwd '/' pp '/muscles_info.txt']);
        muscle=fgetl(fid);
        eventsa=fgetl(fid);
        eventsb=fgetl(fid);
        eventsc=fgetl(fid);
        ap=fgetl(fid);
        fclose(fid);
        
        s = [s '<h3>Spieren...</h3>\n'];
        for i=1:8
            if strcmpi(muscles{i},muscle)
                s = [s num2str(i) ' <b>' muscles{i} '</b><br>\n'];
            else
                s = [s num2str(i) ' ' muscles{i} '<br>\n'];
            end
        end
        
        s = [s 'events: ' eventsa ', ' eventsb ', ' eventsc '<br>\n'];
        if strcmp(ap,'P');
            s = [s 'passive: muscle not participating'];
        else
            s = [s 'muscle is activated with tapping/stretching'];
        end

        s=[s '<table><tr> <td><a href="' pp '/out1.jpg"><img src="' pp '/out1.jpg" width=500></a></td> <td><a href="' pp '/out2.jpg"><img src="' pp '/out3.jpg" width=500></a></td></tr></table>\n'];
        s=[s '<table><tr> <td><a href="' pp '/out3.jpg"><img src="' pp '/out2.jpg" width=500></a></td> <td><a href="' pp '/out4.jpg"><img src="' pp '/out4.jpg" width=500></a></td></tr></table>\n'];
        s=[s '<table><tr> <td><a href="' pp '/out5.jpg"><img src="' pp '/out5.jpg" width=500></a></td> <td><a href="' pp '/out6.jpg"><img src="' pp '/out6.jpg" width=500></a></td></tr></table>\n'];
        % s=[s '<table><tr> <td><a href="' pp '/out5.jpg"><img src="' pp '/out5.jpg" width=500></a></td> <td>&nbsp;</td></tr></table>\n'];
        s=[s '<hr>\n\n'];
    end
end


s=[s '</body>\n'];
s=[s '</html>\n'];

fid=fopen('report.htm','w+');
sprintf(s);
fprintf(fid,s);
fclose(fid);
