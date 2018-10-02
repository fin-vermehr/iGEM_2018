gamma = 0.5; %yield constant (?)
kappa = 0.01; %death rate h^-1
%Xwm = 5000; %maximal area mass density of surface attachment mg/cm^2 not used?
D = 0.2; %dilution/flow rate h^-1
beta = 0.03; %detachment rate of particle from biomass surface h^-1
alpha = 5; %attachment rate h^-1
S_0 = 200; %concentration of substrate in incoming feed mol L^-1
mu_m = 0.35; %maximum specific growth rate (monod equation) unitless
K_s = 80; %monod constont mol L^-1
Xuo = 50; %initial concentration of unbound particle mol L^-1
delta = 1.5; %

f = @(t,x) [x(1) * (((mu_m * x(2)) / (K_s + x(2))) - D - kappa);
            D * (S_0 - x(2)) - 1 / gamma * ((mu_m * x(2)) / (K_s + x(2)) * x(1));
            D * (Xuo-x(5) - x(3)) + beta * x(4) - alpha * x(3) * (1 - x(4) / (delta * x(1)));
            -D * x(4) - beta * x(4) + alpha * x(3) * (1 - x(4) / (delta * x(1)));
            D*x(4)];
        
[t,xa] = ode45(f,[0 250],[20 40 Xuo 0 0]);
fprintf('ode solved\n')

ind = find((Xuo-xa(:,5))<=0);
tp = t(1:ind(1));
xap = xa(1:ind(1),:);

figure;
plot(tp,xap(:,1)); %Cell concetration mol L^-1
hold on 
plot(tp,xap(:,2)); %Substrate concentration mol L^-1
hold on
plot(tp,xap(:,3)) %?
hold on
plot(tp,xap(:,4)) %?
hold on
plot(tp, Xuo - xap(:,5)) %Concentration remaining in in system of particle mol L^-1
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

legend('E. coli Pop', 'Substrate','Floating', 'Adhered', 'Particle left in system')
xlabel('Time (t)'), ylabel('y(t)    ')

