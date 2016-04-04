FCTD = FastCTD_ReadASCII('/Volumes/Users/Shared/FCTD/FCTD12_10_07_011245.ascii');


figure(1);
clf;
pts = 50;
subplot(2,3,4:6);
plot(FCTD.time,FCTD.pressure,'r-*','markersize',2);
ylim([0 2000]);
datetick('x','MM:SS','keeplimits')
axis ij;
hold on;
ylabel('Pressure [dbar]');
xlabel('Time (MM:SS) [UTC]');
grid on;
box on;
j = 0;
for i = 10400:5:length(FCTD.time)-pts
    subplot(2,3,1);
    plot3(FCTD.compass(i+(0:(pts-1)),1),FCTD.compass(i+(0:(pts-1)),2),FCTD.compass(i+(0:(pts-1)),3),'r-*','markersize',2);
    hold on;
    
    plot3([0 FCTD.compass(i+(pts-1),1)],[0 FCTD.compass(i+(pts-1),2)],[0 FCTD.compass(i+(pts-1),3)],'b-','linewidth',2);

    plot3(FCTD.compass(i+(pts-6),1),FCTD.compass(i+(pts-6),2),FCTD.compass(i+(pts-6),3),'b-o','markersize',3,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-5),1),FCTD.compass(i+(pts-5),2),FCTD.compass(i+(pts-5),3),'b-o','markersize',4,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-4),1),FCTD.compass(i+(pts-4),2),FCTD.compass(i+(pts-4),3),'b-o','markersize',5,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-3),1),FCTD.compass(i+(pts-3),2),FCTD.compass(i+(pts-3),3),'b-o','markersize',6,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-2),1),FCTD.compass(i+(pts-2),2),FCTD.compass(i+(pts-2),3),'b-o','markersize',7,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-1),1),FCTD.compass(i+(pts-1),2),FCTD.compass(i+(pts-1),3),'b-o','markersize',8,'markerfacecolor','b');
    
    plot3(FCTD.compass(i+(pts-1),1),FCTD.compass(i+(pts-1),2),FCTD.compass(i+(pts-1),3),'b-^','markersize',8,'markerfacecolor','b');

    xlim([-0.4 0.4]);
    ylim([-0.4 0.4]);
    zlim([-0.4 0.4]);
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass');
    
    subplot(2,3,2);
    plot3(FCTD.gyro(i+(0:(pts-1)),1),FCTD.gyro(i+(0:(pts-1)),2),FCTD.gyro(i+(0:(pts-1)),3),'r-*','markersize',2);
    hold on;
    
    plot3([0 FCTD.gyro(i+(pts-1),1)],[0 FCTD.gyro(i+(pts-1),2)],[0 FCTD.gyro(i+(pts-1),3)],'b-','linewidth',2);
    
    plot3(FCTD.gyro(i+(pts-6),1),FCTD.gyro(i+(pts-6),2),FCTD.gyro(i+(pts-6),3),'b-o','markersize',3,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-5),1),FCTD.gyro(i+(pts-5),2),FCTD.gyro(i+(pts-5),3),'b-o','markersize',4,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-4),1),FCTD.gyro(i+(pts-4),2),FCTD.gyro(i+(pts-4),3),'b-o','markersize',5,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-3),1),FCTD.gyro(i+(pts-3),2),FCTD.gyro(i+(pts-3),3),'b-o','markersize',6,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-2),1),FCTD.gyro(i+(pts-2),2),FCTD.gyro(i+(pts-2),3),'b-o','markersize',7,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-1),1),FCTD.gyro(i+(pts-1),2),FCTD.gyro(i+(pts-1),3),'b-o','markersize',8,'markerfacecolor','b');
    
    plot3(FCTD.gyro(i+(pts-1),1),FCTD.gyro(i+(pts-1),2),FCTD.gyro(i+(pts-1),3),'b-^','markersize',8,'markerfacecolor','b');

    
    xlim([-4 4]);
    ylim([-4 4]);
    zlim([-4 4]);
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Gyro');
    
    subplot(2,3,3);
    plot3(FCTD.acceleration(i+(0:(pts-1)),1),FCTD.acceleration(i+(0:(pts-1)),2),FCTD.acceleration(i+(0:(pts-1)),3),'r-*','markersize',2);
    hold on;
    
    plot3([0 FCTD.acceleration(i+(pts-1),1)],[0 FCTD.acceleration(i+(pts-1),2)],[0 FCTD.acceleration(i+(pts-1),3)],'b-','linewidth',2);
    
    plot3(FCTD.acceleration(i+(pts-6),1),FCTD.acceleration(i+(pts-6),2),FCTD.acceleration(i+(pts-6),3),'b-o','markersize',3,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-5),1),FCTD.acceleration(i+(pts-5),2),FCTD.acceleration(i+(pts-5),3),'b-o','markersize',4,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-4),1),FCTD.acceleration(i+(pts-4),2),FCTD.acceleration(i+(pts-4),3),'b-o','markersize',5,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-3),1),FCTD.acceleration(i+(pts-3),2),FCTD.acceleration(i+(pts-3),3),'b-o','markersize',6,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-2),1),FCTD.acceleration(i+(pts-2),2),FCTD.acceleration(i+(pts-2),3),'b-o','markersize',7,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),FCTD.acceleration(i+(pts-1),3),'b-o','markersize',8,'markerfacecolor','b');
    
    plot3(FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),FCTD.acceleration(i+(pts-1),3),'b-^','markersize',8,'markerfacecolor','b');
    xlim([-1.5 1.5]);
    ylim([-1.5 1.5]);
    zlim([-1.5 1.5]);
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Acceleration');
    
    subplot(2,3,4:6);
    h = plot(FCTD.time(i+(pts-1)),FCTD.pressure(i+(pts-1)),'b-o','markersize',10,'markerfacecolor','b');
    title(datestr(FCTD.time(i+(pts-1)),'yyyy-mm-dd HH:MM:SS'));
    j = j + 1;
    SN_printfig(sprintf('YEI_Movie/img_%06d.png',j));
    
    delete(h);

end    

%%

mydir = dir('YEI_Movie/*png');
for i = 1:length(mydir)
    movefile(['YEI_Movie/' mydir(i).name],sprintf('YEI_Movie/img_%05d.png',i));
end


%%
FCTD = FastCTD_ReadASCII('/Volumes/Users/Shared/FCTD/FCTD12_10_07_011245.ascii');


figure(1);
clf;
pts = 50;
subplot(2,3,4:6);
plot(FCTD.time,FCTD.pressure,'r-*','markersize',2);
ylim([0 2000]);
datetick('x','MM:SS','keeplimits')
axis ij;
hold on;
ylabel('Pressure [dbar]');
xlabel('Time (MM:SS) [UTC]');
grid on;
box on;

for i = 8000:30:length(FCTD.time)-pts
    subplot(2,3,1);
    plot3(FCTD.compass(i+(0:(pts-1)),1),FCTD.compass(i+(0:(pts-1)),2),FCTD.compass(i+(0:(pts-1)),3),'r-*','markersize',2);
    hold on;
    
    plot3([0 FCTD.compass(i+(pts-1),1)],[0 FCTD.compass(i+(pts-1),2)],[0 FCTD.compass(i+(pts-1),3)],'b-','linewidth',2);

    plot3(FCTD.compass(i+(pts-6),1),FCTD.compass(i+(pts-6),2),FCTD.compass(i+(pts-6),3),'b-o','markersize',3,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-5),1),FCTD.compass(i+(pts-5),2),FCTD.compass(i+(pts-5),3),'b-o','markersize',4,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-4),1),FCTD.compass(i+(pts-4),2),FCTD.compass(i+(pts-4),3),'b-o','markersize',5,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-3),1),FCTD.compass(i+(pts-3),2),FCTD.compass(i+(pts-3),3),'b-o','markersize',6,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-2),1),FCTD.compass(i+(pts-2),2),FCTD.compass(i+(pts-2),3),'b-o','markersize',7,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-1),1),FCTD.compass(i+(pts-1),2),FCTD.compass(i+(pts-1),3),'b-o','markersize',8,'markerfacecolor','b');
    
    plot3(FCTD.compass(i+(pts-1),1),FCTD.compass(i+(pts-1),2),FCTD.compass(i+(pts-1),3),'b-^','markersize',8,'markerfacecolor','b');

    xlim([-0.4 0.4]);
    ylim([-0.4 0.4]);
    zlim([-0.4 0.4]);
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass');
    
    subplot(2,3,2);
    plot3(FCTD.gyro(i+(0:(pts-1)),1),FCTD.gyro(i+(0:(pts-1)),2),FCTD.gyro(i+(0:(pts-1)),3),'r-*','markersize',2);
    hold on;
    plot3([0 FCTD.gyro(i+(pts-1),1)],[0 FCTD.gyro(i+(pts-1),2)],[0 FCTD.gyro(i+(pts-1),3)],'b-','linewidth',2);
    
    plot3(FCTD.gyro(i+(pts-6),1),FCTD.gyro(i+(pts-6),2),FCTD.gyro(i+(pts-6),3),'b-o','markersize',3,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-5),1),FCTD.gyro(i+(pts-5),2),FCTD.gyro(i+(pts-5),3),'b-o','markersize',4,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-4),1),FCTD.gyro(i+(pts-4),2),FCTD.gyro(i+(pts-4),3),'b-o','markersize',5,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-3),1),FCTD.gyro(i+(pts-3),2),FCTD.gyro(i+(pts-3),3),'b-o','markersize',6,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-2),1),FCTD.gyro(i+(pts-2),2),FCTD.gyro(i+(pts-2),3),'b-o','markersize',7,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-1),1),FCTD.gyro(i+(pts-1),2),FCTD.gyro(i+(pts-1),3),'b-o','markersize',8,'markerfacecolor','b');
    
    plot3(FCTD.gyro(i+(pts-1),1),FCTD.gyro(i+(pts-1),2),FCTD.gyro(i+(pts-1),3),'b-^','markersize',8,'markerfacecolor','b');
    
    xlim([-4 4]);
    ylim([-4 4]);
    zlim([-4 4]);
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Gyro');
    
    subplot(2,3,3);
    plot3(FCTD.acceleration(i+(0:(pts-1)),1),FCTD.acceleration(i+(0:(pts-1)),2),FCTD.acceleration(i+(0:(pts-1)),3),'r-*','markersize',2);
    hold on;
    
    plot3([0 FCTD.acceleration(i+(pts-1),1)],[0 FCTD.acceleration(i+(pts-1),2)],[0 FCTD.acceleration(i+(pts-1),3)],'b-','linewidth',2);
    
    plot3(FCTD.acceleration(i+(pts-6),1),FCTD.acceleration(i+(pts-6),2),FCTD.acceleration(i+(pts-6),3),'b-o','markersize',3,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-5),1),FCTD.acceleration(i+(pts-5),2),FCTD.acceleration(i+(pts-5),3),'b-o','markersize',4,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-4),1),FCTD.acceleration(i+(pts-4),2),FCTD.acceleration(i+(pts-4),3),'b-o','markersize',5,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-3),1),FCTD.acceleration(i+(pts-3),2),FCTD.acceleration(i+(pts-3),3),'b-o','markersize',6,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-2),1),FCTD.acceleration(i+(pts-2),2),FCTD.acceleration(i+(pts-2),3),'b-o','markersize',7,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),FCTD.acceleration(i+(pts-1),3),'b-o','markersize',8,'markerfacecolor','b');
    
    plot3(FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),FCTD.acceleration(i+(pts-1),3),'b-^','markersize',8,'markerfacecolor','b');
    xlim([-1.5 1.5]);
    ylim([-1.5 1.5]);
    zlim([-1.5 1.5]);
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Acceleration');
    
    subplot(2,3,4:6);
    h = plot(FCTD.time(i+(pts-1)),FCTD.pressure(i+(pts-1)),'b-o','markersize',10,'markerfacecolor','b');
    title(datestr(FCTD.time(i+(pts-1)),'yyyy-mm-dd HH:MM:SS'));
    pause(0.001);
%     SN_printfig(sprintf('YEI_Movie/img_%06d.png',i));
    
    delete(h);

end

%%
% FCTD = FastCTD_ReadASCII('/Volumes/Users/Shared/FCTD/FCTD12_10_07_011245.ascii');
FCTD = FastCTD_ReadASCII('/Volumes/Users/Shared/FCTD/FCTD12_10_07_184210.ascii'); 
figure(1);
clf;
pts = 50;
subplot(2,3,5:6);
plot(FCTD.time,FCTD.pressure,'r-*','markersize',2);
ylim([0 2000]);
datetick('x','MM:SS','keeplimits')
axis ij;
hold on;
ylabel('Pressure [dbar]');
xlabel('Time (MM:SS) [UTC]');
grid on;
box on;

for i = 4000:10:length(FCTD.time)-pts
    r_acc = sqrt(sum(FCTD.acceleration(i,:).*FCTD.acceleration(i,:)));
    
    subplot(2,3,1);
    plot3(FCTD.compass(i+(0:(pts-1)),1),FCTD.compass(i+(0:(pts-1)),2),FCTD.compass(i+(0:(pts-1)),3),'r-*','markersize',2);
    hold on;
    
%     plot3([0 FCTD.compass(i+(pts-1),1)],[0 FCTD.compass(i+(pts-1),2)],[0 FCTD.compass(i+(pts-1),3)],'b-','linewidth',2);

    plot3(FCTD.compass(i+(pts-6),1),FCTD.compass(i+(pts-6),2),FCTD.compass(i+(pts-6),3),'b-o','markersize',3,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-5),1),FCTD.compass(i+(pts-5),2),FCTD.compass(i+(pts-5),3),'b-o','markersize',4,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-4),1),FCTD.compass(i+(pts-4),2),FCTD.compass(i+(pts-4),3),'b-o','markersize',5,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-3),1),FCTD.compass(i+(pts-3),2),FCTD.compass(i+(pts-3),3),'b-o','markersize',6,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-2),1),FCTD.compass(i+(pts-2),2),FCTD.compass(i+(pts-2),3),'b-o','markersize',7,'markerfacecolor','b');
    plot3(FCTD.compass(i+(pts-1),1),FCTD.compass(i+(pts-1),2),FCTD.compass(i+(pts-1),3),'b-o','markersize',8,'markerfacecolor','b');
    
%     plot3(FCTD.compass(i+(pts-1),1),FCTD.compass(i+(pts-1),2),FCTD.compass(i+(pts-1),3),'b-^','markersize',8,'markerfacecolor','b');

    quiver3(0,0,0,FCTD.compass(i+(pts-1),1),FCTD.compass(i+(pts-1),2),FCTD.compass(i+(pts-1),3),'color','b','linewidth',3);
    
    xlim([-0.4 0.4]);
    ylim([-0.4 0.4]);
    zlim([-0.4 0.4]);
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass');
    
    subplot(2,3,2);
    plot3(FCTD.gyro(i+(0:(pts-1)),1),FCTD.gyro(i+(0:(pts-1)),2),FCTD.gyro(i+(0:(pts-1)),3),'r-*','markersize',2);
    hold on;
%     plot3([0 FCTD.gyro(i+(pts-1),1)],[0 FCTD.gyro(i+(pts-1),2)],[0 FCTD.gyro(i+(pts-1),3)],'b-','linewidth',2);
    
    plot3(FCTD.gyro(i+(pts-6),1),FCTD.gyro(i+(pts-6),2),FCTD.gyro(i+(pts-6),3),'b-o','markersize',3,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-5),1),FCTD.gyro(i+(pts-5),2),FCTD.gyro(i+(pts-5),3),'b-o','markersize',4,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-4),1),FCTD.gyro(i+(pts-4),2),FCTD.gyro(i+(pts-4),3),'b-o','markersize',5,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-3),1),FCTD.gyro(i+(pts-3),2),FCTD.gyro(i+(pts-3),3),'b-o','markersize',6,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-2),1),FCTD.gyro(i+(pts-2),2),FCTD.gyro(i+(pts-2),3),'b-o','markersize',7,'markerfacecolor','b');
    plot3(FCTD.gyro(i+(pts-1),1),FCTD.gyro(i+(pts-1),2),FCTD.gyro(i+(pts-1),3),'b-o','markersize',8,'markerfacecolor','b');
    
%     plot3(FCTD.gyro(i+(pts-1),1),FCTD.gyro(i+(pts-1),2),FCTD.gyro(i+(pts-1),3),'b-^','markersize',8,'markerfacecolor','b');
    quiver3(0,0,0,FCTD.gyro(i+(pts-1),1),FCTD.gyro(i+(pts-1),2),FCTD.gyro(i+(pts-1),3),'color','b','linewidth',3);
    
    xlim([-4 4]);
    ylim([-4 4]);
    zlim([-4 4]);
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Gyro');
    
    subplot(2,3,3);
    plot3(FCTD.acceleration(i+(0:(pts-1)),1),FCTD.acceleration(i+(0:(pts-1)),2),FCTD.acceleration(i+(0:(pts-1)),3),'r-*','markersize',2);
    hold on;
    
%     plot3([0 FCTD.acceleration(i+(pts-1),1)],[0 FCTD.acceleration(i+(pts-1),2)],[0 FCTD.acceleration(i+(pts-1),3)],'b-','linewidth',2);
    
    plot3(FCTD.acceleration(i+(pts-6),1),FCTD.acceleration(i+(pts-6),2),FCTD.acceleration(i+(pts-6),3),'b-o','markersize',3,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-5),1),FCTD.acceleration(i+(pts-5),2),FCTD.acceleration(i+(pts-5),3),'b-o','markersize',4,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-4),1),FCTD.acceleration(i+(pts-4),2),FCTD.acceleration(i+(pts-4),3),'b-o','markersize',5,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-3),1),FCTD.acceleration(i+(pts-3),2),FCTD.acceleration(i+(pts-3),3),'b-o','markersize',6,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-2),1),FCTD.acceleration(i+(pts-2),2),FCTD.acceleration(i+(pts-2),3),'b-o','markersize',7,'markerfacecolor','b');
    plot3(FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),FCTD.acceleration(i+(pts-1),3),'b-o','markersize',8,'markerfacecolor','b');
    
%     plot3(FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),FCTD.acceleration(i+(pts-1),3),'b-^','markersize',8,'markerfacecolor','b');
    
    quiver3(0,0,0,FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),FCTD.acceleration(i+(pts-1),3),'color','b','linewidth',3);
    
    xlim([-1.5 1.5]);
    ylim([-1.5 1.5]);
    zlim([-1.5 1.5]);
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Acceleration');
    
    subplot(2,3,4);
    plot3(FCTD.compass(i+(0:(pts-1)),1)/0.4,FCTD.compass(i+(0:(pts-1)),2)/0.4,FCTD.compass(i+(0:(pts-1)),3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(FCTD.gyro(i+(0:(pts-1)),1)/3,FCTD.gyro(i+(0:(pts-1)),2)/3,FCTD.gyro(i+(0:(pts-1)),3)/3,'r-*','markersize',1);
    plot3(FCTD.acceleration(i+(0:(pts-1)),1),FCTD.acceleration(i+(0:(pts-1)),2),FCTD.acceleration(i+(0:(pts-1)),3),'g-*','markersize',1);
    
%     plot3([0 FCTD.compass(i+(pts-1),1)]/0.4,[0 FCTD.compass(i+(pts-1),2)]/0.4,[0 FCTD.compass(i+(pts-1),3)]/0.4,'b-','linewidth',2);
%     plot3([0 FCTD.gyro(i+(pts-1),1)]/3,[0 FCTD.gyro(i+(pts-1),2)]/3,[0 FCTD.gyro(i+(pts-1),3)]/3,'r-','linewidth',2);
%     plot3([0 FCTD.acceleration(i+(pts-1),1)],[0 FCTD.acceleration(i+(pts-1),2)],[0 FCTD.acceleration(i+(pts-1),3)],'g-','linewidth',2);
%     
%     plot3(FCTD.compass(i+(pts-1),1)/0.4,FCTD.compass(i+(pts-1),2)/0.4,FCTD.compass(i+(pts-1),3)/0.4,'b-^','markersize',8,'markerfacecolor','b');
%     plot3(FCTD.gyro(i+(pts-1),1)/3,FCTD.gyro(i+(pts-1),2)/3,FCTD.gyro(i+(pts-1),3)/3,'r-^','markersize',8,'markerfacecolor','r');
%     plot3(FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),FCTD.acceleration(i+(pts-1),3),'g-^','markersize',8,'markerfacecolor','g');
    
    quiver3(0,0,0,FCTD.compass(i+(pts-1),1)/0.4,FCTD.compass(i+(pts-1),2)/0.4,FCTD.compass(i+(pts-1),3)/0.4,'color','b','linewidth',3);
    quiver3(0,0,0,FCTD.gyro(i+(pts-1),1)/3,FCTD.gyro(i+(pts-1),2)/3,FCTD.gyro(i+(pts-1),3)/3,'color','r','linewidth',3);
    quiver3(0,0,0,FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),FCTD.acceleration(i+(pts-1),3),'color','g','linewidth',3);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G)');
    
    subplot(2,3,5:6);
    h = plot(FCTD.time(i+(pts-1)),FCTD.pressure(i+(pts-1)),'b-o','markersize',10,'markerfacecolor','b');
    title(datestr(FCTD.time(i+(pts-1)),'yyyy-mm-dd HH:MM:SS'));
    pause(0.001);
%     SN_printfig(sprintf('YEI_Movie/img_%06d.png',i));
    
    delete(h);

end

%%

%%
% FCTD = FastCTD_ReadASCII('/Volumes/Users/Shared/FCTD/FCTD12_10_07_011245.ascii');
% FCTD = FastCTD_ReadASCII('/Volumes/EquatorFlexA/FCTD/FCTD12_10_07_223505.ascii'); 

% FCTD = FastCTD_ReadASCII('/Volumes/EquatorFlexA/FCTD/FCTD12_10_07_184210.ascii'); 

FCTD = FastCTD_ReadASCII('/Volumes/EquatorFlexA/FCTD/FCTD12_10_08_020433.ascii'); 


figure(1);
clf;
pts = 30;
subplot(2,3,5:6);
plot(FCTD.time,FCTD.pressure,'r-*','markersize',2);
% ylim([0 2000]);
datetick('x','MM:SS','keeplimits')
axis ij;
hold on;
ylabel('Pressure [dbar]');
xlabel('Time (MM:SS) [UTC]');
grid on;
box on;
LHS = true;
if LHS
    multiplier = -1;
else
    multiplier = 1;
end
for i = 4000:10:length(FCTD.time)-pts %length(FCTD.time)-pts;
    subplot(2,3,1);
    plot3(FCTD.compass(i+(0:(pts-1)),1)/0.4,FCTD.compass(i+(0:(pts-1)),2)/0.4,multiplier*FCTD.compass(i+(0:(pts-1)),3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(FCTD.gyro(i+(0:(pts-1)),1)/3,FCTD.gyro(i+(0:(pts-1)),2)/3,multiplier*FCTD.gyro(i+(0:(pts-1)),3)/3,'r-*','markersize',1);
    plot3(FCTD.acceleration(i+(0:(pts-1)),1),FCTD.acceleration(i+(0:(pts-1)),2),multiplier*FCTD.acceleration(i+(0:(pts-1)),3),'g-*','markersize',1);
      
    quiver3(0,0,0,FCTD.compass(i+(pts-1),1)/0.4,FCTD.compass(i+(pts-1),2)/0.4,multiplier*FCTD.compass(i+(pts-1),3)/0.4,'color','b','linewidth',3);
    quiver3(0,0,0,FCTD.gyro(i+(pts-1),1)/3,FCTD.gyro(i+(pts-1),2)/3,multiplier*FCTD.gyro(i+(pts-1),3)/3,'color','r','linewidth',3);
    quiver3(0,0,0,FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),multiplier*FCTD.acceleration(i+(pts-1),3),'color','g','linewidth',3);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G)');
    view(30,90);
    
    subplot(2,3,2);
    plot3(FCTD.compass(i+(0:(pts-1)),1)/0.4,FCTD.compass(i+(0:(pts-1)),2)/0.4,multiplier*FCTD.compass(i+(0:(pts-1)),3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(FCTD.gyro(i+(0:(pts-1)),1)/3,FCTD.gyro(i+(0:(pts-1)),2)/3,multiplier*FCTD.gyro(i+(0:(pts-1)),3)/3,'r-*','markersize',1);
    plot3(FCTD.acceleration(i+(0:(pts-1)),1),FCTD.acceleration(i+(0:(pts-1)),2),multiplier*FCTD.acceleration(i+(0:(pts-1)),3),'g-*','markersize',1);
       
    quiver3(0,0,0,FCTD.compass(i+(pts-1),1)/0.4,FCTD.compass(i+(pts-1),2)/0.4,multiplier*FCTD.compass(i+(pts-1),3)/0.4,'color','b','linewidth',3);
    quiver3(0,0,0,FCTD.gyro(i+(pts-1),1)/3,FCTD.gyro(i+(pts-1),2)/3,multiplier*FCTD.gyro(i+(pts-1),3)/3,'color','r','linewidth',3);
    quiver3(0,0,0,FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),multiplier*FCTD.acceleration(i+(pts-1),3),'color','g','linewidth',3);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G)');
%     view(60,30);
    view(-5,10);
    
    subplot(2,3,3);
    plot3(FCTD.compass(i+(0:(pts-1)),1)/0.4,FCTD.compass(i+(0:(pts-1)),2)/0.4,multiplier*FCTD.compass(i+(0:(pts-1)),3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(FCTD.gyro(i+(0:(pts-1)),1)/3,FCTD.gyro(i+(0:(pts-1)),2)/3,multiplier*FCTD.gyro(i+(0:(pts-1)),3)/3,'r-*','markersize',1);
    plot3(FCTD.acceleration(i+(0:(pts-1)),1),FCTD.acceleration(i+(0:(pts-1)),2),multiplier*FCTD.acceleration(i+(0:(pts-1)),3),'g-*','markersize',1);
       
    quiver3(0,0,0,FCTD.compass(i+(pts-1),1)/0.4,FCTD.compass(i+(pts-1),2)/0.4,multiplier*FCTD.compass(i+(pts-1),3)/0.4,'color','b','linewidth',3);
    quiver3(0,0,0,FCTD.gyro(i+(pts-1),1)/3,FCTD.gyro(i+(pts-1),2)/3,multiplier*FCTD.gyro(i+(pts-1),3)/3,'color','r','linewidth',3);
    quiver3(0,0,0,FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),multiplier*FCTD.acceleration(i+(pts-1),3),'color','g','linewidth',3);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G)');
    view(135,45);
    
    subplot(2,3,4);
    plot3(FCTD.compass(i+(0:(pts-1)),1)/0.4,FCTD.compass(i+(0:(pts-1)),2)/0.4,multiplier*FCTD.compass(i+(0:(pts-1)),3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(FCTD.gyro(i+(0:(pts-1)),1)/3,FCTD.gyro(i+(0:(pts-1)),2)/3,multiplier*FCTD.gyro(i+(0:(pts-1)),3)/3,'r-*','markersize',1);
    plot3(FCTD.acceleration(i+(0:(pts-1)),1),FCTD.acceleration(i+(0:(pts-1)),2),multiplier*FCTD.acceleration(i+(0:(pts-1)),3),'g-*','markersize',1);
       
    quiver3(0,0,0,FCTD.compass(i+(pts-1),1)/0.4,FCTD.compass(i+(pts-1),2)/0.4,multiplier*FCTD.compass(i+(pts-1),3)/0.4,'color','b','linewidth',3);
    quiver3(0,0,0,FCTD.gyro(i+(pts-1),1)/3,FCTD.gyro(i+(pts-1),2)/3,multiplier*FCTD.gyro(i+(pts-1),3)/3,'color','r','linewidth',3);
    quiver3(0,0,0,FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),multiplier*FCTD.acceleration(i+(pts-1),3),'color','g','linewidth',3);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G)');
    
    subplot(2,3,5:6);
    h = plot(FCTD.time(i+(pts-1)),FCTD.pressure(i+(pts-1)),'b-o','markersize',10,'markerfacecolor','b');
    title(datestr(FCTD.time(i+(pts-1)),'yyyy-mm-dd HH:MM:SS'));
    pause(0.001);
%     SN_printfig(sprintf('YEI_Movie/img_%06d.png',i));
    delete(h);

end

%%
% FCTD = FastCTD_ReadASCII('/Volumes/Users/Shared/FCTD/FCTD12_10_07_011245.ascii');
acc = ([rand(1) rand(1) rand(1)]'-0.5)/rand(1);
% acc = [-0.1294   -0.8745   0.4170]';
% acc = [1.4 1.3 1]';
% acc = FCTD.acceleration(5000,:)';
r_acc = sqrt(sum(acc.^2));
cosS = sum(acc.*([0; 0; 1]))/r_acc;
S = acos(cosS);



r_acc = sqrt(sum(acc([2,3]).^2));
cosP = sum(acc([2,3]).*([0; 1;]))/r_acc;
P = acos(cosP);
% if (acc(3) < 0 && acc(2) > 0) || (acc(3) > 0 && acc(2) > 0 && acc(1) < 0)
%     P = P;
if acc(2) < 0
    P = -P;
end

r_acc = sqrt(sum(acc([1,3]).^2));
cosT = sum(acc([1,3]).*([0; 1;]))/r_acc;
T1 = acos(cosT);

% The orthogonal matrix (post-multiplying a column vector) corresponding to a clockwise/left-handed rotation
% http://en.wikipedia.org/wiki/Rotation_matrix
R_mat = @(s,t,p)[cos(t)*cos(s), -cos(p)*sin(s) + sin(p)*sin(t)*cos(s),  sin(p)*sin(s) + cos(p)*sin(t)*cos(s);
                 cos(t)*sin(s),  cos(p)*cos(s) + sin(p)*sin(t)*sin(s), -sin(p)*cos(s) + cos(p)*sin(t)*sin(s);
                 -sin(t),        sin(p)*cos(t),                         cos(p)*cos(t)];

             
             
             
             
             
             
             
R = @(p,t)[ cos(p),         sin(p),         sin(t)*sin(t);
            -cos(t)*sin(p), cos(t)*cos(p), -sin(t)*cos(p);
            0,              sin(t),         cos(t)];

        
        
% acc2 = R_mat(0,T-pi/2,0)*acc';
acc2 = R_mat(0,0,P)*acc;

if (fix(acc2(2)*100000) ~= 0)
    disp(['%%%%%%%%%%% errr in acc2 %%%%%%%%%%']);
end

r_acc2 = sqrt(sum(acc2([1,3]).^2));
cosT = sum(acc2([1,3]).*([0; 1;]))/r_acc2;
T = acos(cosT);
if acc2(1) > 0
    T = -T;
end

acc3 = R_mat(0,T,0)*acc2;

if (fix(acc3(1)*100000) ~= 0)
    disp(['%%%%%%%%%%% errr in acc3 %%%%%%%%%%']);
end


acc4 = R_mat(0,T,P)*acc;

figure(10); 
clf;
quiver3(0,0,0,acc(1),acc(2),acc(3),'color','b','linewidth',2);
hold on;
quiver3(0,0,0,acc2(1),acc2(2),acc2(3),'color','r','linewidth',2);
quiver3(0,0,0,acc3(1),acc3(2),acc3(3),'color','g','linewidth',2);
quiver3(0,0,0,acc4(1),acc4(2),acc4(3),'color','m','linewidth',2);

set(gca,'dataAspectRatio',[1,1,1]);
xlabel('x');
ylabel('y');
zlabel('z');
disp([acc'; acc2'; acc3'; acc4']);
disp([sqrt(sum(acc.^2)), sqrt(sum(acc2.^2)), sqrt(sum(acc3.^2)), sqrt(sum(acc4.^2))])



%% Plotting with acceleration // to z axis

% FCTD = FastCTD_ReadASCII('/Volumes/Users/Shared/FCTD/FCTD12_10_07_011245.ascii');
% FCTD = FastCTD_ReadASCII('/Volumes/EquatorFlexA/FCTD/FCTD12_10_07_223505.ascii'); 

% FCTD = FastCTD_ReadASCII('/Volumes/EquatorFlexA/FCTD/FCTD12_10_07_184210.ascii'); 

FCTD = FastCTD_ReadASCII('/Volumes/EquatorFlexA/FCTD/FCTD12_10_08_020433.ascii'); 

pts = 30;

FCTD.compass = medfilt1(FCTD.compass,pts/2,[],1);
FCTD.gyro = medfilt1(FCTD.gyro,pts/2,[],1);
FCTD.acceleration = medfilt1(FCTD.acceleration,pts/2,[],1);

mygausswin = gausswin(pts);
mygausswin = mygausswin/sum(mygausswin);

FCTD.compass = conv2(FCTD.compass,mygausswin,'same');
FCTD.gyro = conv2(FCTD.gyro,mygausswin,'same');
FCTD.acceleration = conv2(FCTD.acceleration,mygausswin,'same');

figure(1);
clf;
subplot(2,3,5:6);
plot(FCTD.time,FCTD.pressure,'r-*','markersize',2);
% ylim([0 2000]);
datetick('x','MM:SS','keeplimits')
axis ij;
hold on;
ylabel('Pressure [dbar]');
xlabel('Time (MM:SS) [UTC]');
grid on;
box on;
LHS = true;
if LHS
    multiplier = -1;
else
    multiplier = 1;
end
for i = 12000:16:length(FCTD.time)-pts %length(FCTD.time)-pts;
    
    compass = FCTD.compass(i+(0:(pts-1)),:);
    gyro = FCTD.gyro(i+(0:(pts-1)),:);
    acceleration = FCTD.acceleration(i+(0:(pts-1)),:);
    
    compass(:,3) = multiplier*compass(:,3);
    gyro(:,3) = multiplier*gyro(:,3);
    acceleration(:,3) = multiplier*acceleration(:,3);
    
    for k = 1:pts
        [Phi, Theta, Psi, Rot_mat] = SN_RotateToZAxis(acceleration(k,:));
        compass(k,:) = Rot_mat*(compass(k,:)');
        gyro(k,:) = Rot_mat*(gyro(k,:)');
        acceleration(k,:) = Rot_mat*(acceleration(k,:)');
    end
    
    subplot(2,3,1);
    plot3(compass(:,1)/0.4,compass(:,2)/0.4,compass(:,3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(gyro(:,1)/3,gyro(:,2)/3,gyro(:,3)/3,'r-*','markersize',1);
    plot3(acceleration(:,1)/1,acceleration(:,2)/1,acceleration(:,3)/1,'g-*','markersize',1);
      
    quiver3(0,0,0,compass(end,1)/0.4,compass(end,2)/0.4,compass(end,3)/0.4,'color','b','linewidth',5);
    quiver3(0,0,0,gyro(end,1)/3,gyro(end,2)/3,gyro(end,3)/3,'color','r','linewidth',10);
    quiver3(0,0,0,acceleration(end,1)/1,acceleration(end,2)/1,acceleration(end,3)/1,'color','g','linewidth',10);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G) (acc. // grav.)[Top down]');
    view(0,90);
    
    subplot(2,3,2);
    plot3(compass(:,1)/0.4,compass(:,2)/0.4,compass(:,3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(gyro(:,1)/3,gyro(:,2)/3,gyro(:,3)/3,'r-*','markersize',1);
    plot3(acceleration(:,1)/1,acceleration(:,2)/1,acceleration(:,3)/1,'g-*','markersize',1);
      
    quiver3(0,0,0,compass(end,1)/0.4,compass(end,2)/0.4,compass(end,3)/0.4,'color','b','linewidth',5);
    quiver3(0,0,0,gyro(end,1)/3,gyro(end,2)/3,gyro(end,3)/3,'color','r','linewidth',10);
    quiver3(0,0,0,acceleration(end,1)/1,acceleration(end,2)/1,acceleration(end,3)/1,'color','g','linewidth',10);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G) (acc. // grav.)');
%     view(60,30);
    view(-5,10);
    
    subplot(2,3,3);
    plot3(compass(:,1)/0.4,compass(:,2)/0.4,compass(:,3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(gyro(:,1)/3,gyro(:,2)/3,gyro(:,3)/3,'r-*','markersize',1);
    plot3(acceleration(:,1)/1,acceleration(:,2)/1,acceleration(:,3)/1,'g-*','markersize',1);
      
    quiver3(0,0,0,compass(end,1)/0.4,compass(end,2)/0.4,compass(end,3)/0.4,'color','b','linewidth',5);
    quiver3(0,0,0,gyro(end,1)/3,gyro(end,2)/3,gyro(end,3)/3,'color','r','linewidth',10);
    quiver3(0,0,0,acceleration(end,1)/1,acceleration(end,2)/1,acceleration(end,3)/1,'color','g','linewidth',10);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G) (acc. // grav.)');
    view(135,45);
    
    subplot(2,3,4);
    plot3(FCTD.compass(i+(0:(pts-1)),1)/0.4,FCTD.compass(i+(0:(pts-1)),2)/0.4,multiplier*FCTD.compass(i+(0:(pts-1)),3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(FCTD.gyro(i+(0:(pts-1)),1)/3,FCTD.gyro(i+(0:(pts-1)),2)/3,multiplier*FCTD.gyro(i+(0:(pts-1)),3)/3,'r-*','markersize',1);
    plot3(FCTD.acceleration(i+(0:(pts-1)),1),FCTD.acceleration(i+(0:(pts-1)),2),multiplier*FCTD.acceleration(i+(0:(pts-1)),3),'g-*','markersize',1);
       
    quiver3(0,0,0,FCTD.compass(i+(pts-1),1)/0.4,FCTD.compass(i+(pts-1),2)/0.4,multiplier*FCTD.compass(i+(pts-1),3)/0.4,'color','b','linewidth',5);
    quiver3(0,0,0,FCTD.gyro(i+(pts-1),1)/3,FCTD.gyro(i+(pts-1),2)/3,multiplier*FCTD.gyro(i+(pts-1),3)/3,'color','r','linewidth',10);
    quiver3(0,0,0,FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),multiplier*FCTD.acceleration(i+(pts-1),3),'color','g','linewidth',10);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G)');
    
    subplot(2,3,5:6);
    h = plot(FCTD.time(i+(pts-1)),FCTD.pressure(i+(pts-1)),'b-o','markersize',10,'markerfacecolor','b');
    title(datestr(FCTD.time(i+(pts-1)),'yyyy-mm-dd HH:MM:SS'));
    pause(0.001);
%     SN_printfig(sprintf('YEI_Movie/img_%06d.png',i));
    delete(h);

end

%% Plotting with acceleration // to z axis

% FCTD = FastCTD_ReadASCII('/Volumes/Users/Shared/FCTD/FCTD12_10_07_011245.ascii');
% FCTD = FastCTD_ReadASCII('/Volumes/EquatorFlexA/FCTD/FCTD12_10_07_223505.ascii'); 

% FCTD = FastCTD_ReadASCII('/Volumes/EquatorFlexA/FCTD/FCTD12_10_07_184210.ascii'); 

% FCTD = FastCTD_ReadASCII('/Volumes/EquatorFlexA/FCTD/FCTD12_10_09_013016.ascii'); 

FCTD = FastCTD_ReadASCII('/Volumes/EquatorFlexA/FCTD/FCTD12_10_10_004011.ascii'); 


pts = 30;

FCTD.compass = medfilt1(FCTD.compass,pts/2,[],1);
FCTD.gyro = medfilt1(FCTD.gyro,pts/2,[],1);
FCTD.acceleration = medfilt1(FCTD.acceleration,pts/2,[],1);

mygausswin = gausswin(pts);
mygausswin = mygausswin/sum(mygausswin);

FCTD.compass = conv2(FCTD.compass,mygausswin,'same');
FCTD.gyro = conv2(FCTD.gyro,mygausswin,'same');
FCTD.acceleration = conv2(FCTD.acceleration,mygausswin,'same');

figure(100);
clf;
plot(FCTD.time,FCTD.compass,'-*','markersize',2);
a_acc = gca;

figure(1);
clf;
subplot(2,3,5:6);
plot(FCTD.time,FCTD.pressure,'r-*','markersize',2);
% ylim([0 2000]);
datetick('x','MM:SS','keeplimits')
axis ij;
hold on;
ylabel('Pressure [dbar]');
xlabel('Time (MM:SS) [UTC]');
grid on;
box on;
LHS = true;
if LHS
    multiplier = -1;
else
    multiplier = 1;
end
for i = 32000:16*2:length(FCTD.time)-pts %length(FCTD.time)-pts;
    
    compass = FCTD.compass(i+(0:(pts-1)),:);
    gyro = FCTD.gyro(i+(0:(pts-1)),:);
    acceleration = FCTD.acceleration(i+(0:(pts-1)),:);
    
    compass(:,3) = multiplier*compass(:,3);
    gyro(:,3) = multiplier*gyro(:,3);
    acceleration(:,3) = multiplier*acceleration(:,3);
    
    for k = 1:pts
        [Phi, Theta, Psi, Rot_mat] = SN_RotateToZAxis(acceleration(k,:));
        compass(k,:) = Rot_mat*(compass(k,:)');
        gyro(k,:) = Rot_mat*(gyro(k,:)');
        acceleration(k,:) = Rot_mat*(acceleration(k,:)');
    end
    figure(1);
    subplot(2,3,1);
    plot3(compass(:,1)/0.4,compass(:,2)/0.4,compass(:,3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(gyro(:,1)/3,gyro(:,2)/3,gyro(:,3)/3,'r-*','markersize',1);
    plot3(acceleration(:,1)/1,acceleration(:,2)/1,acceleration(:,3)/1,'g-*','markersize',1);
      
    quiver3(0,0,0,compass(end,1)/0.4,compass(end,2)/0.4,compass(end,3)/0.4,'color','b','linewidth',5);
    quiver3(0,0,0,gyro(end,1)/3,gyro(end,2)/3,gyro(end,3)/3,'color','r','linewidth',10);
    quiver3(0,0,0,acceleration(end,1)/1,acceleration(end,2)/1,acceleration(end,3)/1,'color','g','linewidth',10);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G) (acc. // grav.) [Top Down]');
    view(0,90);
    
    subplot(2,3,2);
    plot3(compass(:,1)/0.4,compass(:,2)/0.4,compass(:,3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(gyro(:,1)/3,gyro(:,2)/3,gyro(:,3)/3,'r-*','markersize',1);
    plot3(acceleration(:,1)/1,acceleration(:,2)/1,acceleration(:,3)/1,'g-*','markersize',1);
      
    quiver3(0,0,0,compass(end,1)/0.4,compass(end,2)/0.4,compass(end,3)/0.4,'color','b','linewidth',5);
    quiver3(0,0,0,gyro(end,1)/3,gyro(end,2)/3,gyro(end,3)/3,'color','r','linewidth',10);
    quiver3(0,0,0,acceleration(end,1)/1,acceleration(end,2)/1,acceleration(end,3)/1,'color','g','linewidth',10);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G) (acc. // grav.)');
%     view(60,30);
    view(-5,10);
    
    subplot(2,3,3);
    plot3(compass(:,1)/0.4,compass(:,2)/0.4,compass(:,3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(gyro(:,1)/3,gyro(:,2)/3,gyro(:,3)/3,'r-*','markersize',1);
    plot3(acceleration(:,1)/1,acceleration(:,2)/1,acceleration(:,3)/1,'g-*','markersize',1);
      
    quiver3(0,0,0,compass(end,1)/0.4,compass(end,2)/0.4,compass(end,3)/0.4,'color','b','linewidth',5);
    quiver3(0,0,0,gyro(end,1)/3,gyro(end,2)/3,gyro(end,3)/3,'color','r','linewidth',10);
    quiver3(0,0,0,acceleration(end,1)/1,acceleration(end,2)/1,acceleration(end,3)/1,'color','g','linewidth',10);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G) (acc. // grav.)');
    view(135,45);
    
    subplot(2,3,4);
    plot3(FCTD.compass(i+(0:(pts-1)),1)/0.4,FCTD.compass(i+(0:(pts-1)),2)/0.4,multiplier*FCTD.compass(i+(0:(pts-1)),3)/0.4,'b-*','markersize',1);
    hold on;
    plot3(FCTD.gyro(i+(0:(pts-1)),1)/3,FCTD.gyro(i+(0:(pts-1)),2)/3,multiplier*FCTD.gyro(i+(0:(pts-1)),3)/3,'r-*','markersize',1);
    plot3(FCTD.acceleration(i+(0:(pts-1)),1),FCTD.acceleration(i+(0:(pts-1)),2),multiplier*FCTD.acceleration(i+(0:(pts-1)),3),'g-*','markersize',1);
       
    quiver3(0,0,0,FCTD.compass(i+(pts-1),1)/0.4,FCTD.compass(i+(pts-1),2)/0.4,multiplier*FCTD.compass(i+(pts-1),3)/0.4,'color','b','linewidth',5);
    quiver3(0,0,0,FCTD.gyro(i+(pts-1),1)/3,FCTD.gyro(i+(pts-1),2)/3,multiplier*FCTD.gyro(i+(pts-1),3)/3,'color','r','linewidth',10);
    quiver3(0,0,0,FCTD.acceleration(i+(pts-1),1),FCTD.acceleration(i+(pts-1),2),multiplier*FCTD.acceleration(i+(pts-1),3),'color','g','linewidth',10);
    
    xlim([-1 1]);
    ylim([-1 1]);
    zlim([-1 1]);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G)');
    
    subplot(2,3,5:6);
    h = plot(FCTD.time(i+(pts-1)),FCTD.pressure(i+(pts-1)),'b-o','markersize',10,'markerfacecolor','b');
    title(datestr(FCTD.time(i+(pts-1)),'yyyy-mm-dd HH:MM:SS [UTC]'));
    
    figure(100); 
    xlim(a_acc,[-5 0]/60/24+FCTD.time(i+(pts-1))); 
    datetick('x','MM:SS','keeplimits'); 
    title('Compass'); 
    grid on;
    
    pause(0.001);
%     SN_printfig(sprintf('YEI_Movie/img_%06d.png',i));
    delete(h); 

end