
clc;clear all;close all
markers = ["lef","lbd","lelb","lelb1","lie","ref","rbd","relb","relb1","rie"];
addpath('F:\github\wearable-jacket\matlab\data_analysis_codes')
% Ndef = 30;Ndbd = 30;Ndelb = 40;Ndie = 25;Ndelb1 = 30;
smoovar = 2;
% subjectID = [312,2064,2463,2990,3154,3162,3380,3409,3581,3689,5837,6219,6339,6525,7612,9053,9717];
subjectID = 312;
for fu=1:length(subjectID)

SID = subjectID(fu);

% addpath('C:\Users\fabio\github\wearable-jacket\matlab\WISE_KNT') % fabio address
cd(strcat('F:\github\wearable-jacket\matlab\kinect+imudata\',num2str(SID)));

% addpath('C:\Users\fabio\github\wearable-jacket\matlab\WISE_KNT') % fabio address
cd(strcat('F:\github\wearable-jacket\matlab\kinect+imudata\',num2str(SID)));
% cd(strcat('C:\Users\fabio\github\wearable-jacket\matlab\kinect+imudata\',num2str(SID))); % fabio address

list = dir();
spike_files=dir('*.txt');

figure(1)
sgtitle(strcat(num2str(SID),' Kinect+WISE'));

figure(2)
sgtitle(strcat(num2str(SID),' Error signal'));

figure(3)
sgtitle(strcat(num2str(SID),' Peaks'));

tf = strcat(num2str(SID),'_true');
trfile = strcat(tf,'.txt');
fid = fopen(trfile,'wt');
        
for i = 1:length(spike_files)
    f1 = strsplit(spike_files(i).name,'.');
    f2 = strsplit(string(f1(1)),'_');
    if length(f2)>=2
    if f2(2) == "WISE+KINECT" && f2(1)==num2str(SID)
        if f2.length()>=5 && f2(3)== "testing"
            typ = f2(5);
        
        data = importWISEKINECT1(spike_files(i).name);
        len = size(data,1);
        textvars = data(1,:);
        Time = zeros(len-1,1);
        lfe = zeros(len-1,2);
        lbd = zeros(len-1,2);
        lie = zeros(len-1,2);
        lelbfe = zeros(len-1,2);
        rfe = zeros(len-1,2);
        rbd = zeros(len-1,2);
        rie = zeros(len-1,2);
        relbfe = zeros(len-1,2);
        for j = 2:len 
        Time(j-1) = str2double(data(j,1));
        lfe(j-1,:) = [str2double(data(j,2)) str2double(data(j,3))];
        lbd(j-1,:) = [str2double(data(j,4)) str2double(data(j,5))];
        lie(j-1,:) = [str2double(data(j,6)) str2double(data(j,7))];
        lelbfe(j-1,:) = [str2double(data(j,8)) str2double(data(j,9))];
        rfe(j-1,:) = [str2double(data(j,10)) str2double(data(j,11))];
        rbd(j-1,:) = [str2double(data(j,12)) str2double(data(j,13))];
        rie(j-1,:) = [str2double(data(j,14)) str2double(data(j,15))];
        relbfe(j-1,:) = [str2double(data(j,16)) str2double(data(j,17))];
        end
        delnumarr = find(round(Time)==12);
        lie(1:delnumarr(1),:) = [];
        lfe(1:delnumarr(1),:) = [];
        lbd(1:delnumarr(1),:) = [];
        lelbfe(1:delnumarr(1),:) = [];
        rfe(1:delnumarr(1),:) = [];
        rbd(1:delnumarr(1),:) = [];
        rie(1:delnumarr(1),:) = [];
        relbfe(1:delnumarr(1),:) = [];
        Time(length(lie)+1:length(Time))=[];
        smoovar = ceil(length(Time)/Time(length(Time)));
        fid = fopen(trfile,'a+');

        
        switch(typ)
            
            case markers(1)
                
%                 diff = zeros(length(lfe));
%                 diff = abs(lfe(:,1)-lfe(:,2));
%                 mn = mean(diff);
%                 sd = std(diff);
%                 variable = mn+(3*sd);
%                 N = find(abs(diff)>=variable);
%                 lfe(N,:) = [];
%                 Time(length(lfe)+1:length(Time)) = [];
                figure(1)
                subplot(5,2,1)
                plot(Time,lfe(:,1),'r');
                hold on
                plot(Time,lfe(:,2),'b');
                title('Left arm flexion-extension')
                legend('Kinect','WISE')
                ylabel('Joint angle (degrees)')
                xlabel('Time (seconds)')
                hold off    
                lfe(:,1) = smooth(lfe(:,1),smoovar);
                lfe(:,2) = smooth(lfe(:,2),smoovar);
                rmse1 = signal_RMSE(lfe(:,1),lfe(:,2));
                figure(2)
                hold on
                subplot(5,2,1)
                plot(Time,abs(lfe(:,1)-lfe(:,2)),'k');
                title(strcat('Left arm flexion-extension ',' RMSE = ',num2str(rmse1)))
                ylabel('Error angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                [pkinect,kloc] = findpeaks(lfe(:,1),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [pwise,wloc] = findpeaks(lfe(:,2),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [p,k] = findpeaks(-lfe(:,1),Time,'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                [p1,l] = findpeaks(-lfe(:,1),'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                var = (min(min(length(pwise),length(pkinect)),length(p)));
                rmse2 = signal_RMSE(pkinect(1:var),pwise(1:var));
                figure(3)
                subplot(5,2,1)
                plot(Time,lfe(:,1),'r');
                hold on
                plot(Time,lfe(:,2),'b');
                hold off
                for j=1:var
                    fprintf(fid,"%s,%s,%s,%s,%s\n",typ,strcat('P',string(j)),string(pkinect(j)),string(pwise(j)),string(p(j)));
                end
                        figure(3)
                        subplot(5,2,1)
                        hold on
                        scatter(kloc,pkinect,'r*')
                        scatter(wloc,pwise,'b*')
                        scatter(k,-p,'k*')
                        title(strcat('Left arm flexion-extension ',' RMSE peaks = ',num2str(rmse2)))
                        legend('Kinect','WISE')
                        ylabel('Joint angle (degrees)')
                        xlabel('Time (seconds)')
                        hold off
                rmse_trial = zeros(length(l)+2,1);
                rmse_trial(1) = signal_RMSE(lfe(1:l(1),1),lfe(1:l(1),2));
                for j=1:length(l)-1
                   rmse_trial(j+1) =  signal_RMSE(lfe(l(j):l(j+1),1),lfe(l(j):l(j+1),2));
                end
                rmse_trial(j+2) = signal_RMSE(lfe(l(j+1):length(lfe),1),lfe(l(j+1):length(lfe),2));
                for j=1:length(rmse_trial)
                    fprintf(fid,"%s,%s,%s\n",typ,strcat('R',string(j)),string(rmse_trial(j)));
                end
                fprintf(fid,"%s,%s,%s,%s,%s\n",typ,'RMSE signal: ',num2str(rmse1),'RMSE peaks: ',num2str(rmse2));
                clearvars pwise pkinect kloc wloc p k p1 l  rmse_trial rmse1 rmse2 var diff
                
            case markers(2)
%                 diff = zeros(length(lbd));
%                 diff = abs(lbd(:,1)-lbd(:,2));
%                 mn = mean(diff);
%                 sd = std(diff);
%                 variable = mn+(3*sd);
%                 N = find(abs(diff)>=variable);
%                 lbd(N,:) = [];
%                 Time(length(lbd)+1:length(Time)) = [];
                figure(1)
                subplot(5,2,3)
                plot(Time,lbd(:,1),'r');
                hold on
                plot(Time,lbd(:,2),'b');
                title('Left arm abduction-adduction')
                ylabel('Joint angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                lbd(:,1) = smooth(lbd(:,1),smoovar);
                lbd(:,2) = smooth(lbd(:,2),smoovar);
                rmse1 = signal_RMSE(lbd(:,1),lbd(:,2));
                figure(2)
                hold on
                subplot(5,2,3)
                plot(Time,abs(lbd(:,1)-lbd(:,2)),'k');
                title(strcat(' Left arm abduction-adduction ',' RMSE = ',num2str(rmse1)))
                ylabel('Error angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                [pkinect,kloc] = findpeaks(lbd(:,1),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [pwise,wloc] = findpeaks(lbd(:,2),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [p,k] = findpeaks(-lbd(:,1),Time,'MinPeakHeight',-20,'MinPeakProminence',50,'NPeaks',8);
                [p1,l] = findpeaks(-lbd(:,1),'MinPeakHeight',-20,'MinPeakProminence',50,'NPeaks',8);
                figure(3)
                subplot(5,2,3)
                plot(Time,lbd(:,1),'r');
                hold on
                plot(Time,lbd(:,2),'b');
                var = (min(min(length(pwise),length(pkinect)),length(p)));
                rmse2 = signal_RMSE(pkinect(1:var),pwise(1:var));
                        for j=1:var
                            fprintf(fid,"%s,%s,%s,%s,%s\n",typ,strcat('P',string(j)),string(pkinect(j)),string(pwise(j)),string(p(j)));
                        end
                        figure(3)
                        subplot(5,2,3)
                        hold on
                        title(strcat('Left arm abduction-adduction ',' RMSE peaks = ',num2str(rmse2)))
                        scatter(kloc,pkinect,'r*')
                        scatter(wloc,pwise,'b*')
                        scatter(k,-p,'k*')
                        ylabel('Joint angle (degrees)')
                        xlabel('Time (seconds)')
                        hold off
                rmse_trial = zeros(length(l)+2,1);
                rmse_trial(1) = signal_RMSE(lbd(1:l(1),1),lbd(1:l(1),2));
                for j=1:length(l)-1
                   rmse_trial(j+1) =  signal_RMSE(lbd(l(j):l(j+1),1),lbd(l(j):l(j+1),2));
                end
                rmse_trial(j+2) = signal_RMSE(lbd(l(j+1):length(lbd),1),lbd(l(j+1):length(lbd),2));
                for j=1:length(rmse_trial)
                    fprintf(fid,"%s,%s,%s\n",typ,strcat('R',string(j)),string(rmse_trial(j)));
                end
                fprintf(fid,"%s,%s,%s,%s,%s\n",typ,'RMSE signal: ',num2str(rmse1),'RMSE peaks: ',num2str(rmse2));
                clearvars pwise pkinect kloc wloc p k p1 l  rmse_trial rmse1 rmse2 var diff
                
            case markers(3)
                lelbfe(lelbfe>=200) = NaN;
                [Row] = find(isnan(lelbfe(:,2)));
                lelbfe(Row,:) = [];
%                 diff = zeros(length(lelbfe));
%                 diff = abs(lelbfe(:,1)-lelbfe(:,2));
%                 mn = mean(diff);
%                 sd = std(diff);
%                 variable = mn+(3*sd);
%                 N = find(diff>=variable);
%                 lelbfe(N,:) = [];
                Time(length(lelbfe)+1:length(Time)) = [];
                figure(1)
                subplot(5,2,5)
                plot(Time,lelbfe(:,1),'r');
                hold on
                plot(Time,lelbfe(:,2),'b');
                title(strcat('Left forearm Flexion-Extension without abduction'))
                ylabel('Joint angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                lelbfe(:,1) = smooth(lelbfe(:,1),smoovar);
                lelbfe(:,2) = smooth(lelbfe(:,2),smoovar);                
                rmse1 = signal_RMSE(lelbfe(:,1),lelbfe(:,2));
                figure(2)
                hold on
                subplot(5,2,5)
                plot(Time,abs(lelbfe(:,1)-lelbfe(:,2)),'k');
                title(strcat('Left forearm Flexion-Extension without abduction ',' RMSE = ',num2str(rmse1)))
                ylabel('Error angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                figure(3)
                subplot(5,2,5)
                plot(Time,lelbfe(:,1),'r');
                hold on
                plot(Time,lelbfe(:,2),'b');
                [pkinect,kloc] = findpeaks(lelbfe(:,1),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [pwise,wloc] = findpeaks(lelbfe(:,2),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [p,k] = findpeaks(-lelbfe(:,1),Time,'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                [p1,l] = findpeaks(-lelbfe(:,1),'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                var = (min(min(length(pwise),length(pkinect)),length(p)));
                rmse2 = signal_RMSE(pkinect(1:var),pwise(1:var));
                        for j=1:var
                            fprintf(fid,"%s,%s,%s,%s,%s\n",typ,strcat('P',string(j)),string(pkinect(j)),string(pwise(j)),string(p(j)));
                        end
                        figure(3)
                        subplot(5,2,5)
                        hold on
                        title(strcat('Left forearm flexion-extension without abduction ',' RMSE peaks = ',num2str(rmse2)))
                        scatter(kloc,pkinect,'r*')
                        scatter(wloc,pwise,'b*')
                        scatter(k,-p,'k*')
                        ylabel('Joint angle (degrees)')
                        xlabel('Time (seconds)')
                        hold off
                rmse_trial = zeros(length(l)+2,1);
                rmse_trial(1) = signal_RMSE(lelbfe(1:l(1),1),lelbfe(1:l(1),2)); 
                for j=1:length(l)-1
                   rmse_trial(j+1) =  signal_RMSE(lelbfe(l(j):l(j+1),1),lelbfe(l(j):l(j+1),2));
                end
                rmse_trial(j+2) = signal_RMSE(lelbfe(l(j+1):length(lelbfe),1),lelbfe(l(j+1):length(lelbfe),2));
                for j=1:length(rmse_trial)
                    fprintf(fid,"%s,%s,%s\n",typ,strcat('R',string(j)),string(rmse_trial(j)));
                end
                fprintf(fid,"%s,%s,%s,%s,%s\n",typ,'RMSE signal: ',num2str(rmse1),'RMSE peaks: ',num2str(rmse2));
                clearvars pwise pkinect kloc wloc p k p1 l  rmse_trial rmse1 rmse2 var diff
                
            case markers(4)
                lelbfe(lelbfe>=200) = NaN;
                [Row] = find(isnan(lelbfe(:,2)));
                lelbfe(Row,2) = lelbfe(Row,1);
%                 diff = zeros(length(lelbfe));
%                 diff = abs(lelbfe(:,1)-lelbfe(:,2));
%                 mn = mean(diff);
%                 sd = std(diff);
%                 variable = mn+(3*sd);
%                 N = find(diff>=variable);
%                 lelbfe(N,:) = [];
                Time(length(lelbfe)+1:length(Time)) = [];
                figure(1)
                subplot(5,2,7)
                plot(Time,lelbfe(:,1),'r');
                hold on
                plot(Time,lelbfe(:,2),'b');
                title(strcat('Left forearm flexion-extension with abduction')) 
                ylabel('Joint angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                lelbfe(:,1) = smooth(lelbfe(:,1),smoovar);
                lelbfe(:,2) = smooth(lelbfe(:,2),smoovar);  
                rmse1 = signal_RMSE(lelbfe(:,1),lelbfe(:,2));
                figure(2)
                hold on
                subplot(5,2,7)
                plot(Time,abs(lelbfe(:,1)-lelbfe(:,2)),'k');
                title(strcat('Left forearm flexion-extension without abduction ',' RMSE = ',num2str(rmse1)))
                ylabel('Error angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                [pkinect,kloc] = findpeaks(lelbfe(:,1),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [pwise,wloc] = findpeaks(lelbfe(:,2),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [p,k] = findpeaks(-lelbfe(:,1),Time,'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                [p1,l] = findpeaks(-lelbfe(:,1),'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                figure(3)
                subplot(5,2,7)
                plot(Time,lelbfe(:,1),'r');
                hold on
                plot(Time,lelbfe(:,2),'b');
                hold off        
                var = (min(min(length(pwise),length(pkinect)),length(p)));
                rmse2 = signal_RMSE(pkinect(1:var),pwise(1:var));
                        for j=1:var
                            fprintf(fid,"%s,%s,%s,%s,%s\n",typ,strcat('P',string(j)),string(pkinect(j)),string(pwise(j)),string(p(j)));
                        end
                        figure(3)
                        subplot(5,2,7)
                        hold on
                        title(strcat('Left forearm flexion-extension with abduction ',' RMSE peaks = ',num2str(rmse2)))
                        scatter(kloc,pkinect,'r*')
                        scatter(wloc,pwise,'b*')
                        scatter(k,-p,'k*')
                        ylabel('Joint angle (degrees)')
                        xlabel('Time (seconds)')
                        hold off
                rmse_trial = zeros(length(l)+2,1);
                rmse_trial(1) = signal_RMSE(lelbfe(1:l(1),1),lelbfe(1:l(1),2));
                for j=1:length(l)-1
                   rmse_trial(j+1) =  signal_RMSE(lelbfe(l(j):l(j+1),1),lelbfe(l(j):l(j+1),2));
                end
                rmse_trial(j+2) = signal_RMSE(lelbfe(l(j+1):length(lelbfe),1),lelbfe(l(j+1):length(lelbfe),2));
                for j=1:length(rmse_trial)
                    fprintf(fid,"%s,%s,%s\n",typ,strcat('R',string(j)),string(rmse_trial(j)));
                end
                fprintf(fid,"%s,%s,%s,%s,%s\n",typ,'RMSE signal: ',num2str(rmse1),'RMSE peaks: ',num2str(rmse2));
                clearvars pwise pkinect kloc wloc p k p1 l  rmse_trial rmse1 rmse2 var diff
                
            case markers(5)
                
                lie(lie>=500) = NaN;
                [Row] = find(isnan(lie(:,1)));
                lie(Row,:) = [];
                [Row1] = find(isnan(lie(:,2)));
                lie(Row1,:) = [];
                Zerokinectpos = find(round(lie(:,1)/10)==0);
                min1kinectpos = find(round(lie(:,1)/10)==-1);
                pls1kinectpos = find(round(lie(:,1)/10)==+1);
                ZeroIMUval = mean(lie([Zerokinectpos;min1kinectpos;pls1kinectpos],2));
                lie(:,2) = lie(:,2)-ZeroIMUval;
%                 diff = zeros(length(lie));
%                 diff = abs(lie(:,1)-lie(:,2));
%                 mn = mean(diff);
%                 sd = std(diff);
%                 variable = mn+(3*sd);
%                 N = find(diff>=variable);
%                 lie(N,:) = [];
                Time(length(lie)+1:length(Time)) = [];
                figure(1)
                subplot(5,2,9)
                plot(Time,lie(:,1),'r');
                hold on
                plot(Time,lie(:,2),'b');
                title(strcat('Left arm internal-external rotation with flexion'))
                ylabel('Joint angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                lie(:,1) = smooth(lie(:,1),smoovar);
                lie(:,2) = smooth(lie(:,2),smoovar); 
                rmse1 = signal_RMSE(lie(:,1),lie(:,2));
                figure(2)
                hold on
                subplot(5,2,9)
                plot(Time,abs(lie(:,1)-lie(:,2)),'k');
                title(strcat('Left arm internal-external rotation with flexion ',' RMSE = ',num2str(rmse1)))
                ylabel('Error angle (degrees)')
                xlabel('Time (seconds)')
                figure(3)
                subplot(5,2,9)
                plot(Time,lie(:,1),'r');
                hold on
                plot(Time,lie(:,2),'b');
                [pkinect,kloc] = findpeaks(lie(:,1),Time,'MinPeakHeight',20,'NPeaks',7,'MinPeakProminence',20);
                [pwise,wloc] = findpeaks(lie(:,2),Time,'MinPeakHeight',20,'NPeaks',7,'MinPeakProminence',20);
                [p,k] = findpeaks(-lie(:,1),Time,'MinPeakHeight',0,'MinPeakProminence',20,'NPeaks',8);
                [p1,l] = findpeaks(-lie(:,1),'MinPeakHeight',0,'MinPeakProminence',20,'NPeaks',8);
                var = (min(min(length(pwise),length(pkinect)),length(p)));
                rmse2 = signal_RMSE(pkinect(1:var),pwise(1:var));
                        for j=1:var
                            fprintf(fid,"%s,%s,%s,%s,%s\n",typ,strcat('P',string(j)),string(pkinect(j)),string(pwise(j)),string(p(j)));
                        end
                        figure(3)
                        subplot(5,2,9)
                        plot(Time,lie(:,1),'r');
                        hold on
                        plot(Time,lie(:,2),'b');
                        title(strcat('Left arm internal-external rotation with flexion ',' RMSE peaks = ',num2str(rmse2)))
                        scatter(kloc,pkinect,'r*')
                        scatter(wloc,pwise,'b*')
                        scatter(k,-p,'k*');
                        ylabel('Joint angle (degrees)')
                        xlabel('Time (seconds)')
                        hold off
                rmse_trial = zeros(length(l)+2,1);
                rmse_trial(1) = signal_RMSE(lie(1:l(1),1),lie(1:l(1),2));
                for j=1:length(l)-1
                   rmse_trial(j+1) =  signal_RMSE(lie(l(j):l(j+1),1),lie(l(j):l(j+1),2));
                end
                rmse_trial(j+2) = signal_RMSE(lie(l(j+1):length(lie),1),lie(l(j+1):length(lie),2));
                for j=1:length(rmse_trial)
                    fprintf(fid,"%s,%s,%s\n",typ,strcat('R',string(j)),string(rmse_trial(j)));
                end
                fprintf(fid,"%s,%s,%s,%s,%s\n",typ,'RMSE signal: ',num2str(rmse1),'RMSE peaks: ',num2str(rmse2));
                clearvars pwise pkinect kloc wloc p k p1 l  rmse_trial rmse1 rmse2 var diff
                
            case markers(6)
%                 diff = zeros(length(rfe));
%                 diff = abs(rfe(:,1)-rfe(:,2));
%                 mn = mean(diff);
%                 sd = std(diff);
%                 variable = mn+(3*sd);
%                 N = find(diff>=variable);
%                 rfe(N,:) = [];
%                 Time(length(rfe)+1:length(Time)) = [];
                figure(1)
                subplot(5,2,2)
                plot(Time,rfe(:,1),'r');
                hold on
                plot(Time,rfe(:,2),'b');
                title(strcat('Right arm flexion extension'))
                ylabel('Joint angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                rfe(:,1) = smooth(rfe(:,1),smoovar);
                rfe(:,2) = smooth(rfe(:,2),smoovar); 
                rmse1 = signal_RMSE(rfe(:,1),rfe(:,2));
                figure(2)
                hold on
                subplot(5,2,2)
                plot(Time,abs(rfe(:,1)-rfe(:,2)),'k');
                title(strcat('Right arm flexion extension ',' RMSE = ',num2str(rmse1)))
                ylabel('Error angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                figure(3)
                subplot(5,2,2)
                plot(Time,rfe(:,1),'r');
                hold on
                plot(Time,rfe(:,2),'b');
                [pkinect,kloc] = findpeaks(rfe(:,1),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [pwise,wloc] = findpeaks(rfe(:,2),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [p,k] = findpeaks(-rfe(:,1),Time,'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                [p1,l] = findpeaks(-rfe(:,1),'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                var = (min(min(length(pwise),length(pkinect)),length(p)));
                    rmse2 = signal_RMSE(pkinect(1:var),pwise(1:var));
                        for j=1:var
                            fprintf(fid,"%s,%s,%s,%s,%s\n",typ,strcat('P',string(j)),string(pkinect(j)),string(pwise(j)),string(p(j)));
                        end
                        figure(3)
                        subplot(5,2,2)
                        hold on
                        title(strcat('Right arm flexion extension ',' RMSE peaks = ',num2str(rmse2)))
                        scatter(kloc,pkinect,'r*')
                        scatter(wloc,pwise,'b*')
                        scatter(k,-p,'k*')
                        ylabel('Joint angle (degrees)')
                        xlabel('Time (seconds)')
                        hold off
                rmse_trial = zeros(length(l)+2,1);
                rmse_trial(1) = signal_RMSE(rfe(1:l(1),1),rfe(1:l(1),2));
                figure(4)
                subplot(5,1,1)
                hold on
%                 title('Right arm shoulder flexion-extension','FontSize',15)
                xlim([0,50])
%                 xlabel('Time [s]','FontSize',15)
                ylabel('Angle [deg^o]','FontSize',15)
                A = plot(Time,rfe(:,1),'r','DisplayName','Kinect','LineWidth',2);
                B = plot(Time,rfe(:,2),'b','DisplayName','WISE','LineWidth',2);
                C = scatter(kloc,pkinect,'r*','DisplayName','Kinect peaks','LineWidth',2)
                D = scatter(wloc,pwise,'b*','DisplayName','WISE peaks','LineWidth',2)
                E = scatter(k,-p,'k*','DisplayName','Slice points','LineWidth',2)
                lgd = legend([A,B,C,D,E],'FontSize',12);
                lgd1.Orientation = 'vertical';
                hold off
                for j=1:length(l)-1
                   rmse_trial(j+1) =  signal_RMSE(rfe(l(j):l(j+1),1),rfe(l(j):l(j+1),2));
                end
                rmse_trial(j+2) = signal_RMSE(rfe(l(j+1):length(rfe),1),rfe(l(j+1):length(rfe),2));
                for j=1:length(rmse_trial)
                    fprintf(fid,"%s,%s,%s\n",typ,strcat('R',string(j)),string(rmse_trial(j)));
                end
                fprintf(fid,"%s,%s,%s,%s,%s\n",typ,'RMSE signal: ',num2str(rmse1),'RMSE peaks: ',num2str(rmse2));
                clearvars pwise pkinect kloc wloc p k p1 l  rmse_trial rmse1 rmse2 var diff
                
            case markers(7)
%                 diff = zeros(length(rbd));
%                 diff = abs(rbd(:,1)-rbd(:,2));
%                 mn = mean(diff);
%                 sd = std(diff);
%                 variable = mn+(3*sd);
%                 N = find(diff>=variable);
%                 rbd(N,:) = [];
%                 Time(length(rbd)+1:length(Time)) = [];
                figure(1)
                subplot(5,2,4)
                plot(Time,rbd(:,1),'r');
                hold on
                plot(Time,rbd(:,2),'b');
                title(strcat('Right arm abduction-adduction'))
                ylabel('Joint angle (degrees)')
                xlabel('Time (seconds)')
                hold off   
                rbd(:,1) = smooth(rbd(:,1),smoovar);
                rbd(:,2) = smooth(rbd(:,2),smoovar); 
                rmse1 = signal_RMSE(rbd(:,1),rbd(:,2));
                figure(2)
                hold on
                subplot(5,2,4)
                plot(Time,abs(rbd(:,1)-rbd(:,2)),'k');
                title(strcat('Right arm abduction-adduction ',' RMSE = ',num2str(rmse1)))
                ylabel('Error angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                figure(3)
                subplot(5,2,4)
                plot(Time,rbd(:,1),'r');
                hold on
                plot(Time,rbd(:,2),'b');
                [pkinect,kloc] = findpeaks(rbd(:,1),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [pwise,wloc] = findpeaks(rbd(:,2),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [p,k] = findpeaks(-rbd(:,1),Time,'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                [p1,l] = findpeaks(-rbd(:,1),'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                var = (min(min(length(pwise),length(pkinect)),length(p)));
                rmse2 = signal_RMSE(pkinect(1:var),pwise(1:var));
                figure(4)
                subplot(5,1,2)
                hold on
%                 title('Right arm shoulder flexion-extension','FontSize',15)
                xlim([0,50]);
%                 xlabel('Time [s]','FontSize',15);
                ylabel('Angle [deg^o]','FontSize',15);
                A = plot(Time,rbd(:,1),'r','LineWidth',2);
                B = plot(Time,rbd(:,2),'b','LineWidth',2);
                scatter(kloc,pkinect,'r*','LineWidth',2)
                scatter(wloc,pwise,'b*','LineWidth',2)
                scatter(k(1:7),-p(1:7),'k*','LineWidth',2)
                hold off
                        for j=1:var
                            fprintf(fid,"%s,%s,%s,%s,%s\n",typ,strcat('P',string(j)),string(pkinect(j)),string(pwise(j)),string(p(j)));
                        end
                        figure(3)
                        subplot(5,2,4)
                        hold on
                        title(strcat('Right arm abduction-adduction ',' RMSE peaks = ',num2str(rmse2)))
                        scatter(kloc,pkinect,'r*')
                        scatter(wloc,pwise,'b*')
                        scatter(k,-p,'k*')
                        ylabel('Joint angle (degrees)')
                        xlabel('Time (seconds)')
                        
                        hold off
                rmse_trial = zeros(length(l)+2,1);
                rmse_trial(1) = signal_RMSE(rbd(1:l(1),1),rbd(1:l(1),2));
                for j=1:length(l)-1
                   rmse_trial(j+1) =  signal_RMSE(rbd(l(j):l(j+1),1),rbd(l(j):l(j+1),2));
                end
                rmse_trial(j+2) = signal_RMSE(rbd(l(j+1):length(rbd),1),rbd(l(j+1):length(rbd),2));
                for j=1:length(rmse_trial)
                    fprintf(fid,"%s,%s,%s\n",typ,strcat('R',string(j)),string(rmse_trial(j)));
                end
                fprintf(fid,"%s,%s,%s,%s,%s\n",typ,'RMSE signal: ',num2str(rmse1),'RMSE peaks: ',num2str(rmse2));
                clearvars pwise pkinect kloc wloc p k p1 l  rmse_trial rmse1 rmse2 var diff
                
            case markers(8)
                relbfe(relbfe>=200) = NaN;
                [Row] = find(isnan(relbfe(:,2)));
                relbfe(Row,:) = [];
%                 diff = zeros(length(relbfe));
%                 diff = abs(relbfe(:,1)-relbfe(:,2));
%                 mn = mean(diff);
%                 sd = std(diff);
%                 variable = mn+(3*sd);
%                 N = find(diff>=variable);
%                 relbfe(N,:) = [];
%                 Time(length(relbfe)+1:length(Time)) = [];
                figure(1)
                subplot(5,2,6)
                plot(Time,relbfe(:,1),'r');
                hold on
                plot(Time,relbfe(:,2),'b');
                title(strcat('Right forearm flexion-extension without abduction'))
                ylabel('Joint angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                relbfe(:,1) = smooth(relbfe(:,1),smoovar);
                relbfe(:,2) = smooth(relbfe(:,2),smoovar); 
                rmse1 = signal_RMSE(relbfe(:,1),relbfe(:,2));
                figure(2)
                hold on
                subplot(5,2,6)
                plot(Time,abs(relbfe(:,1)-relbfe(:,2)),'k');
                title(strcat('Right forearm flexion-extension without abduction ',' RMSE = ',num2str(rmse1)))
                ylabel('Error angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                figure(3)
                subplot(5,2,6)
                plot(Time,relbfe(:,1),'r');
                hold on
                plot(Time,relbfe(:,2),'b');
                [pkinect,kloc] = findpeaks(relbfe(:,1),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [pwise,wloc] = findpeaks(relbfe(:,2),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [p,k] = findpeaks(-relbfe(:,1),Time,'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                [p1,l] = findpeaks(-relbfe(:,1),'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                var = (min(min(length(pwise),length(pkinect)),length(p)));
                rmse2 = signal_RMSE(pkinect(1:var),pwise(1:var));
                figure(4)
                subplot(5,1,3)
                hold on
%                 title('Right arm shoulder flexion-extension','FontSize',15)
                xlim([0,50]);
%                 xlabel('Time [s]','FontSize',15);
                ylabel('Angle [deg^o]','FontSize',15);
                A = plot(Time,relbfe(:,1),'r','LineWidth',2);
                B = plot(Time,relbfe(:,2),'b','LineWidth',2);
                scatter(kloc,pkinect,'r*','LineWidth',2)
                scatter(wloc,pwise,'b*','LineWidth',2)
                scatter(k(1:7),-p(1:7),'k*','LineWidth',2)
                hold off
                        for j=1:var
                            fprintf(fid,"%s,%s,%s,%s,%s\n",typ,strcat('P',string(j)),string(pkinect(j)),string(pwise(j)),string(p(j)));
                        end
                        figure(3)
                        subplot(5,2,6)
                        hold on
                        title(strcat('Right forearm flexion-extension without abduction ',' RMSE peaks = ',num2str(rmse2)))
                        scatter(kloc,pkinect,'r*')
                        scatter(wloc,pwise,'b*')
                        scatter(k,-p,'k*');
                        ylabel('Joint angle (degrees)')
                        xlabel('Time (seconds)')
                        hold off
                rmse_trial = zeros(length(l)+2,1);
                rmse_trial(1) = signal_RMSE(relbfe(1:l(1),1),relbfe(1:l(1),2));
                
                for j=1:length(l)-1
                   rmse_trial(j+1) =  signal_RMSE(relbfe(l(j):l(j+1),1),relbfe(l(j):l(j+1),2));
                end
                rmse_trial(j+2) = signal_RMSE(relbfe(l(j+1):length(relbfe),1),relbfe(l(j+1):length(relbfe),2));
                for j=1:length(rmse_trial)
                    fprintf(fid,"%s,%s,%s\n",typ,strcat('R',string(j)),string(rmse_trial(j)));
                end
                fprintf(fid,"%s,%s,%s,%s,%s\n",typ,'RMSE signal: ',num2str(rmse1),'RMSE peaks: ',num2str(rmse2));
                clearvars pwise pkinect kloc wloc p k p1 l  rmse_trial rmse1 rmse2 var diff
                                
            case markers(9)
                relbfe(relbfe>=200) = NaN;
                [Row] = find(isnan(relbfe(:,2)));
                relbfe(Row,2) = relbfe(Row,1);
%                 diff = zeros(length(relbfe));
%                 diff = abs(relbfe(:,1)-relbfe(:,2));
%                 mn = mean(diff);
%                 sd = std(diff);
%                 variable = mn+(3*sd);
%                 N = find(diff>=variable);
%                 relbfe(N,:) = [];
%                 Time(length(relbfe)+1:length(Time)) = [];
                figure(1)
                subplot(5,2,8)
                plot(Time,relbfe(:,1),'r');
                hold on
                plot(Time,relbfe(:,2),'b');
                title(strcat('Right elbow flexion-extension with abduction'))
                ylabel('Joint angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                relbfe(:,1) = smooth(relbfe(:,1),smoovar);
                relbfe(:,2) = smooth(relbfe(:,2),smoovar); 
                rmse1 = signal_RMSE(relbfe(:,1),relbfe(:,2));
                figure(2)
                hold on
                subplot(5,2,8)
                plot(Time,abs(relbfe(:,1)-relbfe(:,2)),'k');
                title(strcat('Right elbow flexion-extension with abduction ',' RMSE = ',num2str(rmse1)))
                ylabel('Error angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                [pkinect,kloc] = findpeaks(relbfe(:,1),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [pwise,wloc] = findpeaks(relbfe(:,2),Time,'MinPeakHeight',80,'MinPeakProminence',50,'NPeaks',7);
                [p,k] = findpeaks(-relbfe(:,1),Time,'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                [p1,l] = findpeaks(-relbfe(:,1),'MinPeakHeight',-40,'MinPeakProminence',50,'NPeaks',8);
                figure(3)
                subplot(5,2,8)
                plot(Time,relbfe(:,1),'r');
                hold on
                plot(Time,relbfe(:,2),'b');
                var = (min(min(length(pwise),length(pkinect)),length(p)));
                rmse2 = signal_RMSE(pkinect(1:var),pwise(1:var));
                figure(4)
                subplot(5,1,4)
                hold on
%                 title('Right arm shoulder flexion-extension','FontSize',15)
                xlim([0,50]);
%                 xlabel('Time [s]','FontSize',15);
                ylabel('Angle [deg^o]','FontSize',15);
                A = plot(Time,relbfe(:,1),'r','LineWidth',2);
                B = plot(Time,relbfe(:,2),'b','LineWidth',2);
                scatter(kloc,pkinect,'r*','LineWidth',2)
                scatter(wloc,pwise,'b*','LineWidth',2)
                scatter(k(1:7),-p(1:7),'k*','LineWidth',2)
                hold off
                        for j=1:var
                            fprintf(fid,"%s,%s,%s,%s,%s\n",typ,strcat('P',string(j)),string(pkinect(j)),string(pwise(j)),string(p(j)));
                        end
                        figure(3)
                        subplot(5,2,8)
                        hold on
                        title(strcat('Right elbow flexion-extension with abduction ',' RMSE peaks = ',num2str(rmse2)))
                        scatter(kloc,pkinect,'r*')
                        scatter(wloc,pwise,'b*')
                        scatter(k,-p,'k*')
                        ylabel('Joint angle (degrees)')
                        xlabel('Time (seconds)')
                        hold off
                rmse_trial = zeros(length(l)+2,1);
                rmse_trial(1) = signal_RMSE(relbfe(1:l(1),1),relbfe(1:l(1),2));
                for j=1:length(l)-1
                   rmse_trial(j+1) =  signal_RMSE(relbfe(l(j):l(j+1),1),relbfe(l(j):l(j+1),2));
                end
                rmse_trial(j+2) = signal_RMSE(relbfe(l(j+1):length(relbfe),1),relbfe(l(j+1):length(relbfe),2));
                for j=1:length(rmse_trial)
                    fprintf(fid,"%s,%s,%s\n",typ,strcat('R',string(j)),string(rmse_trial(j)));
                end
                fprintf(fid,"%s,%s,%s,%s,%s\n",typ,'RMSE signal: ',num2str(rmse1),'RMSE peaks: ',num2str(rmse2));
                clearvars pwise pkinect kloc wloc p k p1 l  rmse_trial rmse1 rmse2 var diff
                
            case markers(10)
                
                rie(rie>=500) = NaN;
                [Row] = find(isnan(rie(:,1)));
                rie(Row,:) = [];
                [Row1] = find(isnan(rie(:,2)));
                rie(Row1,:) = [];
                Zerokinectpos = find(round(rie(:,1)/10)==0);
                min1kinectpos = find(round(rie(:,1)/10)==-1);
                pls1kinectpos = find(round(rie(:,1)/10)==+1);
                ZeroIMUval = mean(rie([Zerokinectpos;min1kinectpos;pls1kinectpos],2));
                rie(:,2) = rie(:,2)-ZeroIMUval;
%                 diff = zeros(length(rie));
%                 diff = abs(rie(:,1)-rie(:,2));
%                 mn = mean(diff);
%                 sd = std(diff);
%                 variable = mn+(3*sd);
%                 N = find(diff>=variable);
%                 rie(N,:) = [];
                Time(length(rie)+1:length(Time)) = [];
                figure(1)
                subplot(5,2,10)
                plot(Time,rie(:,1),'r');
                hold on
                plot(Time,rie(:,2),'b');
                title(strcat('Right arm internal-external rotation with flexion'))
                ylabel('Joint angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                rie(:,1) = smooth(rie(:,1),smoovar);
                rie(:,2) = smooth(rie(:,2),smoovar); 
                rmse1 = signal_RMSE(rie(:,1),rie(:,2));
                figure(2)
                hold on
                subplot(5,2,10)
                plot(Time,abs(rie(:,1)-rie(:,2)),'k');
                title(strcat('Right arm internal-external rotation with flexion ',' RMSE = ',num2str(rmse1)))
                ylabel('Error angle (degrees)')
                xlabel('Time (seconds)')
                hold off
                figure(3)
                subplot(5,2,10)
                plot(Time,rie(:,1),'r');
                hold on
                plot(Time,rie(:,2),'b');
                [pkinect,kloc] = findpeaks(rie(:,1),Time,'MinPeakHeight',20,'NPeaks',7,'MinPeakProminence',20);
                [pwise,wloc] = findpeaks(rie(:,2),Time,'MinPeakHeight',20,'NPeaks',7,'MinPeakProminence',20);
                [p,k] = findpeaks(-rie(:,1),Time,'MinPeakHeight',0,'MinPeakProminence',20,'NPeaks',8);
                [p1,l] = findpeaks(-rie(:,1),'MinPeakHeight',0,'MinPeakProminence',20,'NPeaks',8);
                var = (min(min(length(pwise),length(pkinect)),length(p)));
                rmse2 = signal_RMSE(pkinect(1:var),pwise(1:var));
                figure(4)
                subplot(5,1,5)
                hold on
%               title('Right arm shoulder flexion-extension','FontSize',15)
                xlim([0,50]);
                xlabel('Time [s]','FontSize',15);
                ylabel('Angle [deg^o]','FontSize',15);
                A = plot(Time,rie(:,1),'r','LineWidth',2);
                B = plot(Time,rie(:,2),'b','LineWidth',2);
                scatter(kloc,pkinect,'r*','LineWidth',2)
                scatter(wloc,pwise,'b*','LineWidth',2)
                scatter(k(1:7),-p(1:7),'k*','LineWidth',2)
                hold off
                        for j=1:var
                            fprintf(fid,"%s,%s,%s,%s,%s\n",typ,strcat('P',string(j)),string(pkinect(j)),string(pwise(j)),string(p(j)));
                        end
                        figure(3)
                        subplot(5,2,10)
                        title(strcat('Right arm internal-external rotation with flexion ',' RMSE peaks = ',num2str(rmse2)))
                        scatter(kloc,pkinect,'r*')
                        scatter(wloc,pwise,'b*')
                        scatter(k,-p,'k*');
                        ylabel('Joint angle (degrees)')
                        xlabel('Time (seconds)')
                        hold off
                rmse_trial = zeros(length(l)+2,1);
                rmse_trial(1) = signal_RMSE(rie(1:l(1),1),rie(1:l(1),2));
                
                for j=1:length(l)-1
                   rmse_trial(j+1) =  signal_RMSE(rie(l(j):l(j+1),1),rie(l(j):l(j+1),2));
                end
                rmse_trial(j+2) = signal_RMSE(rie(l(j+1):length(rie),1),rie(l(j+1):length(rie),2));
                for j=1:length(rmse_trial)
                    fprintf(fid,"%s,%s,%s\n",typ,strcat('R',string(j)),string(rmse_trial(j)));
                end
                fprintf(fid,"%s,%s,%s,%s,%s\n",typ,'RMSE signal: ',num2str(rmse1),'RMSE peaks: ',num2str(rmse2));
                clearvars pwise pkinect kloc wloc p k p1 l  rmse_trial rmse1 rmse2 var diff
        end
    fclose(fid);
    end
    end

   end 
end
end



%%



