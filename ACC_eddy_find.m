clc; clear all; close all;
path_sla='..\';
% path_results='.\global_dailyADT_eddy_detected\';
% path_results='.\ACC_SLAeddy_results\';
path_results='.\ACC_eddy_results\';

folder_list=[2016:1:2017];
year_num=length(folder_list);
% % delete every fold in every folder
for i=1:year_num
    folderdir=[path_results,num2str(folder_list(i))];
%     rmdir(folderdir,'s');
    mkdir(folderdir);
end
% main
for y=1:year_num
    filedir=[path_sla,num2str(folder_list(y)),'\'];
    fileList=dir([filedir,'*.nc']);
    dd=size(fileList,1);
    % read and cut sla
%     ssh_all_acc=nan(1440,240,1);
    date_all=zeros(dd,1);
         ssh_all=[];
    for d=1:dd
        date=str2num(fileList(d).name(25:32))
        ssh=ncread([filedir,fileList(d).name],'adt',[1,1,1],[1440,240,1]);  % ACC : -89.8750:-30.1250
        ssh_all(:,:,d)=ssh;
%         ssh_all_acc(:,:,d)=ssh;
        date_all(d)=date;
    end
    ssh_all=permute(ssh_all,[2,1,3]);
%     ssh_all_acc=permute(ssh_all_acc,[2,1,3]);
    lat=ncread([filedir,fileList(1).name],'latitude');
    lon=ncread([filedir,fileList(1).name],'longitude');
    lat_acc=lat(1:240);
    lat_acc=double(lat_acc);
    lon=double(lon);
    lat=double(lat);
    lat_number = length(lat);
    lon_number = length(lon);
    area_map= generate_area_map(lat_number, lon_number); %%%%%%%%***************--- µ¥Î»Îªkm^2£»---**********************
%     areamap=area_map;
    areamap=area_map(1:240);
    destdir=[path_results,num2str(folder_list(y)),'\'];
    %     cyc='cyclonic';
    %     eddies = scan_single(ssh', lat_acc, lon, date, cyc, 'v1', areamap ,'sshUnits', 'meters');
    %     save([destdir cyc '_' num2str(date),'_',num2str(d)], 'eddies', '-v7');
    %     cyc='anticyc';
    %     eddies = scan_single(ssh', lat_acc, lon, date, cyc, 'v1', areamap ,'sshUnits', 'meters');
    %     save([destdir cyc '_' num2str(date),'_',num2str(d)], 'eddies', '-v7');
    scan_multi( ssh_all, lat_acc, lon, date_all, 'cyclonic', 'v2', areamap, destdir ,'sshUnits', 'meters')  % cyclone
    scan_multi( ssh_all, lat_acc, lon, date_all, 'anticyc', 'v2', areamap, destdir ,'sshUnits', 'meters')  % anti-cyclone
end

%% eddy track 
cyc={'anticyc','cyclonic'}; 
path_Aeddyall='./all/anticyclonic/'; 
path_Ceddyall='./all/cyclonic/'; 
atracks=tolerance_track_lnn(path_Aeddyall,cyc{1},1,1,9); 
ctracks=tolerance_track_lnn(path_Ceddyall,cyc{2},1,1,9); 
save('ACC_ADT_eddyTracks.mat','atracks','ctracks'); 
% save('ACC_SLA_eddyTracks.mat','atracks','ctracks'); 
% save('GLOBAL_SLA_eddyTracks.mat','atracks','ctracks'); 
% load alleddyTracks.mat
% 
% %% pain test track
% for i=1:length(atracks)
%     duringtimeA(i)=size(atracks{i},1);
% end
% itA=find(duringtimeA>=364);
% for i=1:length(ctracks)
%     duringtimeC(i)=size(ctracks{i},1);
% end
% itC=find(duringtimeC>=364);
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%   this pain method can solve circumpolar boundary
% %%%%%%%%%%%%%%%%%%%%%%   problem
% figure
% % m_proj('stereographic','lat',-90,'long',-70,'radius',60);
% % m_grid('xtick',7,'tickdir','out','ytick',[-70 -60 -50 -40 -30],'linest',':');
% m_proj('miller','lon',[-70 290],'lat',[-80 -30]);
% m_grid('linestyle','none','tickdir','out','linewidth',2);
% m_coast('patch',[.7 .7 .7],'edgecolor','k');
% title('lifetime .ge. 30Days eddies ')
% for i=1:length(itA)
%     track=atracks{itA(i)};
%     track(track(:,2)<=-70,2)=track(track(:,2)<=-70,2)+360;
%     left=find(track(:,2)<-69.5);
%     right=find(track(:,2)>289.5);
%     if length(right)>=1 & length(left)>=1
%         dis=diff(track(:,2));
%         bnd=find(abs(dis)>100);
%         nn=length(bnd);
%         hold on
%         m_plot(track(1:bnd(1),2),track(1:bnd(1),1),'r-','linewidth',0.25);
%         hold on
%         m_plot(track(bnd(nn)+1:end,2),track(bnd(nn)+1:end,1),'r-','linewidth',0.25);
%         if nn>1
%             for i=1:nn-1
%                 hold on
%                 m_plot(track(bnd(i)+1:bnd(i+1),2),track(bnd(i)+1:bnd(i+1),1),'r-','linewidth',0.25);
%             end
%         end
%     else
%         hold on
%         m_plot(track(:,2),track(:,1),'r-','linewidth',0.25);
%     end
% end
% for i=1:length(itC)
%     track=ctracks{itC(i)};
% %     track(track(:,2)<=-180,2)=track(track(:,2)<=-180,2)+360;
%     track(track(:,2)<=-70,2)=track(track(:,2)<=-70,2)+360;
%     left=find(track(:,2)<-69.5);
%     right=find(track(:,2)>289.5);
%     if length(right)>=1 & length(left)>=1
%         dis=diff(track(:,2));
%         bnd=find(abs(dis)>100);
%         nn=length(bnd);
%         hold on
%         m_plot(track(1:bnd(1),2),track(1:bnd(1),1),'b-','linewidth',0.25);
%         hold on
%         m_plot(track(bnd(nn)+1:end,2),track(bnd(nn)+1:end,1),'b-','linewidth',0.25);
%         if nn>1
%             for i=1:nn-1
%                 hold on
%                 m_plot(track(bnd(i)+1:bnd(i+1),2),track(bnd(i)+1:bnd(i+1),1),'b-','linewidth',0.25);
%             end
%         end
%     else
%         hold on
%         m_plot(track(:,2),track(:,1),'b-','linewidth',0.25);
%     end
% % mycmap =colormap(parula(365));
% % for i=1:365
% %     hold on
% %     m_plot(tarck(:,2),tarck(:,1),'o','MarkerFacecolor',mycmap(i,:),'MarkerEdgecolor',mycmap(i,:));
% % end
% end
% legenddata={['Anticyclonic: ',num2str(length(itA))],['Cyclonic: ',num2str(length(itC))]};
% m_text(-60,-73,legenddata,'fontsize',8,'Color','m')
% print('-dpng','-r600','acc_alleddy_30tracks')
% %
% %% test
% h=1;
% for i=1:length(itC)
%     track=ctracks{itC(i)};
%     track(track(:,2)<=-70,2)=track(track(:,2)<=-70,2)+360;
%     dis=diff(track(:,2));
%     bnd=find(abs(dis)>5);
%     if length(bnd)>0
%     i_flag(h)=i;
%     h=h+1;
%     end
% end
% 
% for i=1:length(i_flag)
%     figure(i)
%     m_proj('miller','lon',[-70 290],'lat',[-80 -30]);
%     m_grid('linestyle','none','tickdir','out','linewidth',2);
%     m_coast('patch',[.7 .7 .7],'edgecolor','k');
%     track=ctracks{itC(i_flag(i))};
%     track(track(:,2)<=-70,2)=track(track(:,2)<=-70,2)+360;
%     left=find(track(:,2)<-69.5);
%     right=find(track(:,2)>289.5);
%      if length(right)>=1 & length(left)>=1
%         dis=diff(track(:,2));
%         bnd=find(abs(dis)>100);
%         nn=length(bnd);
%         hold on
%         m_plot(track(1:bnd(1),2),track(1:bnd(1),1),'b-','linewidth',0.25);
%         hold on
%         m_plot(track(bnd(nn)+1:end,2),track(bnd(nn)+1:end,1),'b-','linewidth',0.25);
%         if nn>1
%             for i=1:nn-1
%                 hold on
%                 m_plot(track(bnd(i)+1:bnd(i+1),2),track(bnd(i)+1:bnd(i+1),1),'b-','linewidth',0.25);
%             end
%         end
%     else
%         hold on
%         m_plot(track(:,2),track(:,1),'b-','linewidth',0.25);
%     end
% end
% % for i=1:length(itC)
% %     track=ctracks{itC(i)};
% %     track(track(:,2)<=-70 & track(:,2)>=-180,2)=track(track(:,2)<=-70 & track(:,2)>=-180,2)+360;
% %     figure(i+500)
% %     m_proj('miller','lon',[-70 290],'lat',[-90 -30]);
% %     m_grid('linestyle','none','tickdir','out','linewidth',3);
% %     m_coast('patch',[.7 .7 .7],'edgecolor','k');
% %     hold on
% %     m_plot(track(:,2),track(:,1),'b-','linewidth',2);
% %     % mycmap =colormap(parula(365));
% %     % for i=1:365
% %     %     hold on
% %     %     m_plot(tarck(:,2),tarck(:,1),'o','MarkerFacecolor',mycmap(i,:),'MarkerEdgecolor',mycmap(i,:));
% %     % end
% % end
% % print('-dpng','-r600','acc_alleddy_tracks')

