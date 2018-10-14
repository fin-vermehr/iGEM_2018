gamma = 1.1; % yield constant (?)
kappa = 0.01; % death rate h^-1
D = 3; % dilution/flow rate h^-1
beta = 0.03; % detachment rate of particle from biomass surface h^-1
alpha = 1.5; % attachment rate h^-1
mu_m = 0.8; % maximum specific growth rate (monod equation) unitless
K_s = 2.87*10^(-7); % monod constont mol L^-1
delta = 1.5; % maximum carrying capacity
N_i = 0.4; % initial cellular concentration L^-1
S_i = 0.63; % initial substrate concentration L^-1
Xu_i = 0.5; % initial unbound metal concentration L^-1
Xw_i = 0; % initial bound metal concentration L^-1
epsilon = 0.0001; % Acceptable metal concentration threshold

f = @(t,x) [N_i * ((mu_m * x(2)) / (K_s + x(2))) - x(1) * (D + kappa);
    -((mu_m * x(2)) / (K_s + x(2))) * x(1) / gamma;
    beta * x(4) - alpha * x(3) * (delta * x(1) - x(4))/(delta * x(1));
    -(beta * x(4) - alpha * x(3) * (delta * x(1) - x(4))/(delta * x(1))) - D*x(4)];

[t,xa] = ode45(f,[0 50],[N_i S_i Xu_i Xw_i]);
fprintf('ode solved\n')

ind = find(xa(:,3) <= epsilon);
xap = xa(1:ind,:);
tp = t(1:ind);

figure;
plot(tp,xap(:,1)); % Cell concetration mol L^-1
hold on 
plot(tp,xap(:,2)); % Substrate concentration
hold on
plot(tp,xap(:,3)) % Unbound metal concentration mol L^-1
hold on
plot(tp,xap(:,4)) % Bound metal concentration mol L^-1
hold on
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

legend('E. coli Pop', 'Substrate','Unbound Particle', 'Bound particle in MR')
xlabel('Time (h)'), ylabel('mol/L')

