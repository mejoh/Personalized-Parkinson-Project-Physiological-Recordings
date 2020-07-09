% function newmarkers=emg_transform_marker_backwards(markers,vector,s)
%
%
% this function transforms backward your set markers.
% it uses a 0010010010 vector (logical) to determine onsets.
% and translates the b and e from the segmented data into the b and e of
% the fully complete data.
%
% see my notes for a complete explanation.
%
% J
function newmarkers=emg_transform_marker_backwards(markers,vector,s)


    newmarkers=markers;
    

    for i=1:numel(markers)
        if numel(markers{i})>0
            for j=1:numel(markers{i})
                
                b=markers{i}(j).b;
                e=markers{i}(j).e;
                v=vector{i}(1,:);
                

                bt=zeros(size(b));
                et=zeros(size(e));
                % we have v, a 000011111000 vector.
                % we also have b and e, which are markers.

                % now, transform the b and e towards to correct positions.
                % and take care not to separate the b and e's too much.

                v1=uint32(v);
                v2=uint32(1:numel(v));
                v3=uint32(cumsum(v).*v);

                transmat=[v2;v1;v3];


                for k=1:numel(b)
                    
                    bt(k)=find(transmat(3,:)==b(k));
                    et(k)=find(transmat(3,:)==e(k));
                    
                end
                



                % scanario 3. there are 0's and a bunch of 1's between b and e.
                % if 3 is true, forget the following.

                for k=1:numel(bt)


                    vp=v(bt(k):et(k));
                    

                    if sum(vp)<numel(vp)

                        % okay.. vp, the part between bt and et, has a bunch of 0's in
                        % it. determine how many 'camps' there are. (usually, 2.)

                        [tmp_b tmp_e]=vector_walker([1 vp 1]);

                        % transform these vectors to i's, which can be used on raw
                        % data.
                        tmp_b=tmp_b+bt(k)-2; % write it out; you'll see it has to be 2.
                        tmp_e=tmp_e+bt(k)-2;

                        group=zeros(numel(tmp_b),2);
                        for l=1:numel(tmp_b)

                            group(l,:)=[numel(tmp_b(l):tmp_e(l)) sum(abs(s(tmp_b(l):tmp_e(l))))];

                        end

                        % determine which 'group' can claim the b and e markers.
                        % this is a test to see if the group sizes differ.
                        if sum(abs(group(:,1)-mean(group(:,1))))==0

                            % all groups have the same size; let the data decide.
                            winner=find(group(:,2)==max(group(:,2)));

                        else

                            % one group has the most amount of points; this one wins!
                            winner=find(group(:,1)==max(group(:,1)));


                        end

                        % transform the marker.
                        bt(k)=tmp_b(winner);
                        et(k)=tmp_e(winner);
                        


                    end
                    

                    


                end
                
                newmarkers{i}(j).b=bt;
                newmarkers{i}(j).e=et;
                
    
            end
        end
    end
    

