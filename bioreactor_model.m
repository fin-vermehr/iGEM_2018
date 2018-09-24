gamma = 0.5;
kappa = 0.01;
Xwm = 5000;
D = 0.2;
beta = 0.03;
alpha = 5;
S_0 = 200;
mu_m = 0.35;
K_s = 80;
Xuo = 100;
delta = 1.5;

f = @(t,x) [x(1) * (((mu_m * x(2)) / (K_s + x(2))) - D - kappa);
            D * (S_0 - x(2)) - 1 / gamma * ((mu_m * x(2)) / (K_s + x(2)) * x(1));
            D * (Xuo - x(3)) + beta * x(4) - alpha * x(3) * (1 - x(4) / (delta * x(1)));
            -D * x(4) - beta * x(4) + alpha * x(3) * (1 - x(4) / (delta * x(1)));]
        
        
[t,xa] = ode45(f,[0 250],[20 40 100 0])

plot(t,xa(:,1));
hold on 
plot(t,xa(:,2));
hold on
plot(t,xa(:,3))
hold on
plot(t,xa(:,4))
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

legend('E. coli Pop', 'Substrate','Floating', 'Adhered')
xlabel('Time (t)'), ylabel('y(t)    ')

