function PlotYEIonFCTD(FCTD)
pts = 160;
fpts = 6;

i = length(FCTD.time)-3/2*pts;
if i < 1
    return;
end

FCTD.compass = medfilt1(FCTD.compass,fpts/2,[],1);
FCTD.gyro = medfilt1(FCTD.gyro,fpts/2,[],1);
FCTD.acceleration = medfilt1(FCTD.acceleration,fpts/2,[],1);

mygausswin = gausswin(fpts);
mygausswin = mygausswin/sum(mygausswin);

FCTD.compass = conv2(FCTD.compass,mygausswin,'same');
FCTD.gyro = conv2(FCTD.gyro,mygausswin,'same');
FCTD.acceleration = conv2(FCTD.acceleration,mygausswin,'same');

% figure(100);
% clf;
% plot(FCTD.time,FCTD.compass,'-*','markersize',2);
% a_acc = gca;

figure(1000);
set(gcf,'renderer','painters');
% clf;
subplot(2,3,5:6);
plot(FCTD.time(i+(0:(pts-1))),FCTD.pressure(i+(0:(pts-1))),'r-*','markersize',2);
% ylim([0 2000]);
axis ij;
% hold on;
ylabel('Pressure [dbar]','interpreter','latex');
xlabel('Time (MM:SS) [UTC]','interpreter','latex');
grid on;
box on;
datetick('x','MM:SS','keeplimits')
LHS = true;
if LHS
    multiplier = -1;
else
    multiplier = 1;
end

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
    figure(1000);
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
    xlabel('x','interpreter','latex');
    ylabel('y','interpreter','latex');
    zlabel('z','interpreter','latex');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G) (acc. // grav.) [Top Down]','interpreter','latex');
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
    xlabel('x','interpreter','latex');
    ylabel('y','interpreter','latex');
    zlabel('z','interpreter','latex');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G) (acc. // grav.)','interpreter','latex');
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
    xlabel('x','interpreter','latex');
    ylabel('y','interpreter','latex');
    zlabel('z','interpreter','latex');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G) (acc. // grav.)','interpreter','latex');
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
    xlabel('x','interpreter','latex');
    ylabel('y','interpreter','latex');
    zlabel('z','interpreter','latex');
    set(gca,'dataaspectratio',[1 1 1]);
    grid on;
    box on;
    hold off;
    title('Compass(B), Gyro(R), Acceleration(G)','interpreter','latex');
    
%     subplot(2,3,5:6);
%     h = plot(FCTD.time(i+(pts-1)),FCTD.pressure(i+(pts-1)),'b-o','markersize',10,'markerfacecolor','b');
%     title(datestr(FCTD.time(i+(pts-1)),'yyyy-mm-dd HH:MM:SS [UTC]'));
%     hold off;
    
%     figure(100); 
%     xlim(a_acc,[-5 0]/60/24+FCTD.time(i+(pts-1))); 
%     datetick('x','MM:SS','keeplimits'); 
%     title('Compass'); 
%     grid on;
end